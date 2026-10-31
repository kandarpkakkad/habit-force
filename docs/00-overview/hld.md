# Overview — High Level Design

## 1. What this system is

A Flutter app with a native Kotlin half, on one Android 16 phone, that turns a written
routine into windows of blocked apps and alarms that ring. **There is no server, no sync and
no backup** (D1, D2). Everything lives in one SQLite file and two small files beside it.

The architecture follows from one fact: **the things that matter happen while the app is
closed.** A blocked app opens at 21:05 with Habit Force nowhere on screen; an alarm rings at
06:30 from a phone that has been asleep for seven hours. Dart cannot be relied on to be
running at either moment. Kotlin can, because Android starts it.

## 2. Module map

```
┌──────────────────────────────── Flutter (Dart) ────────────────────────────────┐
│ UI (03-frontend)   Today · Habits · Alarms · History · editors · Setup          │
│                                     │ drift streams                             │
│ Domain (02)        habits · schedule (overlaps, planner) · alarms · history     │
│                                     │ repositories                              │
│ Platform (01)      storage (SQLite) · bridge · permissions · versioning         │
└─────────────────────────────────────┬───────────────────────────────────────────┘
               plan.json  ▼            │  method channel           ▲ events.jsonl
┌──────────────────────────────── Native (Kotlin) ───────────────────────────────┐
│ bridge     PlanStore · EventLog · NativeChannel                                 │
│ schedule   boundary chain (heads-up, start, end, expiry) · system receivers     │
│ block      BlockerService (accessibility) · BlockActivity · pause               │
│ alarm      AlarmScheduler · AlarmReceiver · AlarmRingService · AlarmActivity    │
│ notify     channels · notifications · Do Not Disturb                            │
└─────────────────────────────────────────────────────────────────────────────────┘
                                   Android
```

**Dependencies run downward on each side, and across only through the bridge.** Domain
modules never call each other's internals. Platform never imports domain. Nothing in Kotlin
knows what a habit *is* — it knows windows on dates, which is all it needs.

## 3. Who owns what

| | Owner | Other side |
|---|---|---|
| Habits, alarms, settings, history | Dart, in SQLite | Never opened by Kotlin (D7) |
| The plan — 14 days of windows and alarms | Dart writes, through the channel | Kotlin stores it in `plan.json` and only reads it |
| Events — what happened | Kotlin appends to `events.jsonl` | Dart reads, inserts, then acknowledges (D10) |
| Pause state | Kotlin | Dart never needs it |
| "We turned DND on" | Kotlin | — |
| Scheduled Android alarms | Kotlin | — |

Two writers never share a file. That is the whole concurrency story.

## 4. The write path — a change in the app

```
UI action
  └─ domain validates (overlaps checked here, D12)
       └─ ONE SQLite transaction — both habits, if one gave way (D13)
       └─ commit → UI updates from the drift stream
  └─ PlanPublisher
       └─ planner builds the next 14 days from the database
       └─ channel: installPlan(json)
            └─ Kotlin writes plan.json atomically (tmp + rename)
            └─ re-arms the boundary chain and the next alarm
            └─ tells the blocker to look again
```

**The plan is rebuilt from the database every time, never patched.** A change, a launch, a
resume: same function, same output for the same data.

## 5. The run path — the app closed

```
AlarmManager fires the next boundary (exact, D11)
  └─ BoundaryReceiver
       ├─ posts heads-up / start / end notifications (batched by minute)
       ├─ reconciles Do Not Disturb with the windows now running (D17)
       ├─ appends window_started / window_ended to events.jsonl
       ├─ nudges the blocker to re-check the app on screen
       └─ arms the next boundary

Foreground app changes
  └─ BlockerService (accessibility)
       └─ blocked by a running window, not paused?
            └─ HOME, then BlockActivity — and append `blocked`

AlarmManager.setAlarmClock fires
  └─ AlarmReceiver → AlarmRingService (foreground) → AlarmActivity over the lock screen
       └─ snooze / dismiss / 10-minute timeout → appended to events.jsonl
       └─ arms the next alarm
```

## 6. The read path — what happened while closed

```
app start · resume · History pull-to-refresh
  └─ channel: readEvents() → lines
       └─ INSERT OR IGNORE into events (id is the key)
       └─ channel: ackEvents(ids) → Kotlin removes exactly those lines
```

A crash between insert and acknowledge re-reads the same lines next time; the insert ignores
them. Nothing is lost and nothing is doubled.

## 7. Cross-cutting rules

| Rule | Enforced by |
|---|---|
| Kotlin never opens the database | No SQLite dependency on the native side (D7) |
| The plan is wall-clock dates and minutes, not instants | Kotlin converts with the zone at the moment of use (D8) |
| Times of day are integer minutes, 0–1439 | `ClockTime` in Dart; plain `Int` in Kotlin |
| Instants are epoch milliseconds | Events, `created_at`, `archived_at` |
| UUID v7 ids for rows Dart creates | `common/ids.dart` |
| Habits are archived, never deleted | No `DELETE` on `habits` (D19) |
| Every rule-break is recorded | Pause, snooze, dismiss, miss, blocker off — each appends an event |
| Nothing late is replayed as if on time | Boundaries over 2 minutes late are skipped (D18) |

## 8. Failure modes, and what happens

| Failure | Behaviour | Owner |
|---|---|---|
| Accessibility service off | Nothing is blocked. Logged as `enforcer_off`; Today shows a banner | blocking |
| Notifications denied | No heads-up, start or end. Alarms still ring full-screen | notifications |
| Full-screen intent denied | The alarm arrives as a high-priority notification that rings | alarms |
| Phone off at a window's start | No start event, no notification; the window is still enforced if the phone comes on within it | schedule |
| Phone rebooted | `BOOT_COMPLETED` re-arms from `plan.json`. Blocking needs nothing re-armed | bridge |
| Time or time zone changed | Re-armed from `plan.json`; dates and minutes are re-read in the new zone | bridge |
| App not opened for 14 days | The plan runs out. Warned two days before (D9) | schedule |
| `plan.json` unreadable | Treated as an empty plan: nothing blocked, nothing rings, and Today says so on next open | bridge |
| App killed mid-ring | The ring service is a foreground service; Android restarts nothing, but the alarm screen is already up | alarms |
| Brand battery killer | The blocker and alarms die. Setup asks for unrestricted battery | permissions |
| Two windows at once | Union of blocked apps; name the stricter one (D12) | blocking |

## 9. Concurrency and threading

- **Dart:** one isolate. drift's own background isolate for SQLite.
- **Kotlin:** receivers run on the main thread and finish fast; the plan file is small
  (a few KB) and parsed once, then cached until its modification time changes.
- **One process.** Every Kotlin component lives in the app's single process, so the event
  log is guarded by one JVM lock and needs nothing more.

## 10. What is deliberately absent

| Not built | Because |
|---|---|
| A server, an account, the `INTERNET` permission in release | D1 |
| Sync, backup, export | D2 |
| A background Dart isolate | Kotlin needs no Dart to enforce or ring (D6). The cost is the 14-day horizon (D9) |
| Compat libraries (`androidx.core`, `NotificationCompat`) | `minSdk 36`: the platform APIs are all there (D5) |
| Analytics, crash reporting | Nothing leaves the phone |

## 11. Build order

```
storage → bridge → schedule (planner) → blocking → alarms → notifications → history
   └─ then: permissions and setup, the screens, CI
```

This matches the milestones in PRD §10.
