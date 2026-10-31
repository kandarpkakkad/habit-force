# Alarms — LLD

Shapes: [schema.md](schema.md), the plan entry in [bridge schema](../../01-platform/bridge/schema.md).
Dart: `lib/domain/alarms/`. Kotlin: `alarm/`.

## 1. Dart: the model and its rules

```dart
enum AlarmAnchor { clock, habitStart, habitEnd }
enum Challenge { none, sum, phrase }
```

| Field | Rule |
|---|---|
| label | trimmed, ≤ 40 |
| clock | `minute` set; `days` any; `days == 0` → `once_date` is computed, never typed |
| habit-tied | `habitId` set, `offset` −180…180 |
| snooze | minutes 1–30, limit 0–10 |

**`once_date`, on every save of a once alarm:**

```
onceDate(minute, now) = today if minute > now.minuteOfDay else tomorrow
```

Strictly greater: an alarm set at 07:00 for 07:00 is for tomorrow, not for the minute that is
already going.

**Done:** a once alarm whose `once_date` is before today shows as *Done* and is not planned.
Switching it back on re-saves it, which sets a fresh `once_date`.

## 2. Kotlin: arming

Three pending intents to `AlarmReceiver`, by request code, so each replaces only itself:

| Code | For | `chain` |
|---|---|---|
| 100 | The next plan entry | true |
| 101 | A snooze | false |
| 102 | A test | false |

```kotlin
fun armNext(ctx, plan, after: Long)
  e = plan.alarms.firstOrNull { instant(it.date, it.minute) > after }
  if e == null → cancel code 100; return
  am.setAlarmClock(AlarmClockInfo(at, showIntent = MainActivity), pi(100, e, snoozeNo = 0, chain = true))

fun armSnooze(ctx, e, snoozeNo)  → setAlarmClock(now + e.snoozeMinutes min, pi(101, e, snoozeNo, false))
fun armTest(ctx, e)              → setAlarmClock(now + 10 s,                pi(102, e, 0, false))
```

The entry travels **as JSON in the intent**. A snooze or a test does not depend on the plan
still containing it.

## 3. Kotlin: `AlarmReceiver`

```kotlin
onReceive(intent)
  e = AlarmEntry.parse(intent.entryJson)
  startForegroundService(AlarmRingService, e, snoozeNo)
  if intent.chain → AlarmScheduler.armNext(ctx, PlanStore.load(ctx), after = max(now, instant(e)))
```

## 4. Kotlin: `AlarmRingService`

Foreground service, type `mediaPlayback`.

```
onStartCommand(e, snoozeNo):
  if ringing → stopSound()                 // a second alarm replaces the first on screen
  current = (e, snoozeNo)
  startForeground(2001, notification(e), MEDIA_PLAYBACK)
  play default alarm sound, looping, USAGE_ALARM;  vibrate waveform, repeating, if e.vibrate
  for id in e.alarmIds → EventLog alarm_fired (detail = label)
  postDelayed(10 min) → timeout()

ACTION_SNOOZE:  snoozeNo + 1 > e.snoozeLimit → ignore (the button was not shown)
                armSnooze(e, snoozeNo + 1); for id → alarm_snoozed (detail = snoozeNo + 1); stop()
ACTION_DISMISS: for id → alarm_dismissed (detail = challenge); stop()
timeout():      for id → alarm_missed; stop()
stop():         stopSound(); stopForeground(REMOVE); stopSelf(); current = null
```

**The notification:** channel `alarms`, `CATEGORY_ALARM`, ongoing, no sound of its own (the
service plays it), full-screen intent and content intent both → `AlarmActivity`. Title is the
label, or *Alarm*; text is the time.

**Sound:** `RingtoneManager.getDefaultUri(TYPE_ALARM)`, falling back to `TYPE_RINGTONE`, then
`TYPE_NOTIFICATION`. If none can be played, vibration still runs and the screen still shows.

`isRinging` is a static flag; `MainActivity.onResume` opens `AlarmActivity` when it is set
(alarms HLD, *Notifications off*).

## 5. Kotlin: `AlarmActivity`

`setShowWhenLocked(true)`, `setTurnScreenOn(true)`. Back is swallowed.

```
show: time HH:MM (large), label or "Alarm"
      [Snooze 5 min · 2 left]   shown only while snoozeNo < snoozeLimit
      [Dismiss]

Dismiss with challenge:
  none   → ACTION_DISMISS
  sum    → a, b uniform in 10..99; "a + b = ?"; number field; correct → ACTION_DISMISS
                                                          wrong   → field cleared, new a, b
  phrase → "Type: I am awake and getting up"; normalised match → ACTION_DISMISS

normalise(s) = s.trim().lowercase().replace(/\s+/, " ")
```

The activity reads the entry from `AlarmRingService.current`; if nothing is ringing any more
(it timed out), it finishes.

## 6. Edge cases

| Case | Behaviour |
|---|---|
| Phone rebooted past an alarm's minute | `armNext(after = now)` skips it. Not rung late |
| Plan reinstalled while ringing | Ringing continues; code 100 re-armed for the next entry after now |
| A snooze pending when another snooze is set | The newer replaces it (one code). Rare; accepted |
| Test pressed twice | The second replaces the first |
| Challenge wrong five times | No limit. The alarm keeps ringing; that is the point |
| Snooze limit 0 | No snooze button at all |

## 7. What to test

Dart: `onceDate` at, before and after the minute; validation of each shape.
Kotlin: `armNext` picks the first entry strictly after `after`; entries in the past are never
armed.
