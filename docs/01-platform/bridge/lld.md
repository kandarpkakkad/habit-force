# Bridge — LLD

Shapes: [schema.md](schema.md). This file never restates them.

## 1. The channel

One `MethodChannel`, `habit_force/native`, registered in `MainActivity.configureFlutterEngine`.
Dart wrapper: `lib/platform/bridge/native_bridge.dart`. Kotlin: `bridge/NativeChannel.kt`.

| Method | Argument | Returns | Errors (`PlatformException.code`) |
|---|---|---|---|
| `installPlan` | `String` — the plan JSON | `{windows: int, alarms: int}` | `plan_invalid` (does not parse, or `version ≠ 1`), `plan_write` (I/O). The old plan stays in force on either |
| `planStatus` | — | `{state: 'ok' \| 'missing' \| 'unreadable' \| 'expired', horizon?: String, generatedAt?: int, error?: String}` | — |
| `readEvents` | — | `{events: List<String>, torn: List<String>}` — each event a JSON object as text; torn lines raw | `events_read` |
| `ackEvents` | `{ids: List<String>, torn: List<String>}` | `int` lines removed | `events_write` |
| `listApps` | — | `List<{package, label}>`, launchable apps except the ones the blocker never blocks (blocking LLD §2), sorted by label | — |
| `permissionStatus` | — | `Map<String, bool>` — the six keys in the permissions LLD | — |
| `openPermission` | `String` key | `null` | `no_settings_page` with the exception's message |
| `openAppInfo` | — | `null` | `no_settings_page` |
| `testAlarm` | `String` — one alarm entry as JSON | `int` — epoch ms it will ring | `plan_invalid` |

Everything else Kotlin does, it does on its own.

## 2. Kotlin: `PlanStore`

```kotlin
fun install(ctx, json: String): Plan
  plan = Plan.parse(json)                    // throws PlanInvalid — nothing written
  write ctx.filesDir/plan.json.tmp, fsync, rename over plan.json
  cache = plan with the new file's lastModified
  if prefs.lastHandledAt == 0 → prefs.lastHandledAt = now     // first install: replay nothing
  Rearm.all(ctx, plan)
  return plan

fun load(ctx): Plan
  file missing          → Plan.EMPTY, status 'missing'
  lastModified == cache → cache
  parse fails           → Plan.EMPTY, status 'unreadable' + message
  else                  → parsed, cached
```

**`Plan.EMPTY` is a real plan**, with no windows and no alarms. Every caller can use whatever
`load` returns without a null check — an unreadable file must never take the blocker or the
alarm path down with it.

`Plan.parse` ignores fields it does not know, and rejects:

- `version ≠ 1`
- a window with `end ≤ start` or `end > start + 1439`
- a date that does not parse as `yyyy-mm-dd`
- a challenge outside `none | sum | phrase`

## 3. Kotlin: dates and minutes to instants

```kotlin
fun instant(date: LocalDate, minute: Int, zone: ZoneId = ZoneId.systemDefault()): Long =
    LocalDateTime.of(date, LocalTime.MIDNIGHT).plusMinutes(minute.toLong())
        .atZone(zone).toInstant().toEpochMilli()
```

**Wall-clock minutes, not elapsed ones (D8).** `plusMinutes` on a `LocalDateTime` moves the
clock face; `atZone` then resolves a DST gap forward and an overlap to the earlier offset. A
window *21:00–22:00* is 21:00–22:00 on the clock whatever the day's length.

The zone is read **every time**, never cached, so a zone change is picked up by the next call.

## 4. Kotlin: `EventLog`

```kotlin
object EventLog {
  private val lock = Any()

  fun append(ctx, kind, habitId?, occurrence?, alarmId?, pkg?, detail?, at = now)
    line = JSON {id: UUID.randomUUID(), at, kind, …present fields only}
    synchronized(lock) { append line + "\n" to events.jsonl }

  fun read(ctx): (events: List<String>, torn: List<String>)
    synchronized(lock) { lines = file lines, blank ones dropped }
    each line: parses as an object with string "id" → events, else → torn

  fun ack(ctx, ids: Set<String>, torn: Set<String>): Int
    synchronized(lock) {
      keep = lines where not (parsed id in ids) and not (raw in torn)
      write keep to events.jsonl.tmp, rename over
    }
    return removed count
}
```

Lines appended between `read` and `ack` are untouched by the `ack`: it removes by id, not by
position.

## 5. Kotlin: re-arming

```kotlin
object Rearm {
  fun all(ctx, plan = PlanStore.load(ctx), now = currentTimeMillis())
    BoundaryScheduler.armNext(ctx, plan, after = prefs.lastHandledAt)   // notifications LLD
    AlarmScheduler.armNext(ctx, plan, after = now)                      // alarms LLD
    Dnd.reconcile(ctx, plan, now)                                       // notifications LLD
    BlockerService.recheck()                                            // blocking LLD
}
```

Called from:

| Trigger | Where |
|---|---|
| `installPlan` | `PlanStore.install` |
| `BOOT_COMPLETED`, `TIME_SET`, `TIMEZONE_CHANGED`, `MY_PACKAGE_REPLACED` | `SystemEventsReceiver` |
| A boundary fires | `BoundaryReceiver`, for its own chain only |

## 6. Dart: `NativeBridge`

A thin class over the channel. It converts, and does nothing else:

- `installPlan(Plan)` → `PlanCodec.encode` → channel. Returns `InstallResult`.
- `readEvents()` → `({List<Map<String, Object?>> events, List<String> torn})`, each event
  decoded from its JSON text.
- Every `PlatformException` is rethrown as `BridgeException(code, message)` — the message is
  the reason, and it reaches the screen (AGENTS.md §2).

In widget and unit tests the bridge is replaced by `FakeNativeBridge`, which records calls.

## 7. Edge cases

| Case | Behaviour |
|---|---|
| `installPlan` with the same plan twice | Same file, re-armed. Harmless |
| `installPlan` while a boundary is firing | Both run on the main thread; one finishes first. The later re-arm wins, and it is computed from the newer plan |
| `ackEvents` with ids that are not in the file | Removes nothing for those; returns the count actually removed |
| A plan whose horizon is in the past | `planStatus` says `expired`; nothing is armed; nothing blocks |

## 8. What to test

- `PlanCodec.encode` → fields and types exactly as [schema.md](schema.md).
- Kotlin `Plan.parse`: rejects each invalid case above; ignores an unknown field.
- Kotlin `instant`: a window across a DST change keeps its clock times.
