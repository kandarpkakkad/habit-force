# Alarms — HLD

Alarms that ring like a clock app's, from a locked, sleeping phone, and are harder to wave
away.

## Purpose

Wake the person, or pull them out of what they are doing, at a set minute — and record how
they answered.

## Responsibilities

- **Dart:** defining alarms — clock or habit-tied, repeat, challenge, snooze rules — and
  handing their instances to the planner.
- **Kotlin:** arming the next alarm entry with `setAlarmClock`, ringing it (sound, vibration,
  screen on over the lock screen), running the challenge, snoozing within the limit, and
  stopping after 10 minutes as missed. Appending an event for each.
- **Test:** ringing a given alarm ten seconds from now, through the real path.

## Owns

`alarms` ([schema.md](schema.md)). On the native side, nothing stored beyond the plan: the
entry being rung travels in the intent, so a snooze survives a plan change.

## Depends on

`habits` (for habit-tied alarms), `schedule` (planner), the bridge, `notifications` (the alarm
channel).

## Key decisions

**`setAlarmClock`, not an exact alarm.** It is the API Android reserves for alarms a person set:
exempt from Doze, shown in the status bar, and the one the system treats as user-visible.

**Native ringing (D16).** `AlarmReceiver` starts a foreground `AlarmRingService`, which posts a
notification with a full-screen intent to `AlarmActivity`. No Flutter engine is between the
alarm and the screen that stops it.

**Sound at alarm volume through DND.** `AudioAttributes.USAGE_ALARM`, the system default alarm
sound, looping. Do Not Disturb lets alarms through by default.

**The challenge is on dismiss, never on snooze.** Snoozing is already limited; making it hard
too just makes people throw the phone.

**Same minute, one ring (D15).** The planner merges; the entry carries every alarm id it
stands for, and the events name each.

**One-off alarms are fixed to a date at save.** "Once" means the next time the clock time comes
round after saving. After that date it is simply not planned again; the list shows it as done.

## Failure modes

| | |
|---|---|
| Full-screen intent not allowed | The notification rings anyway, heads-up; tapping it opens the alarm screen |
| Notifications off | The ring service still runs and sounds, but Android may not show the full-screen screen. Opening Habit Force while an alarm rings goes straight to the alarm screen |
| Phone off at the minute | It does not ring. On boot, alarms already passed are not rung late |
| Two alarms at one minute | One ring, both labels |
| A snooze outlives a plan change | The snooze carries its own entry; it rings as set |
| Nobody answers | 10 minutes, then stop and record `alarm_missed` |

## Non-goals

- Custom sounds, gradual volume, a QR or photo challenge.
- Alarms on more than one device.
- Sleep tracking or smart wake windows.
