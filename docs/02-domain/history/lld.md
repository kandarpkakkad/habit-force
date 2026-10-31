# History — LLD

Shapes: [schema.md](schema.md). Code: `lib/domain/history/`.

## 1. Collecting

```dart
Future<CollectResult> collect()
  (events, torn) = await bridge.readEvents()
  rows = events that parse as an EventRow (known kind, `id`, `at`); unparseable → torn too
  transaction { for r in rows: INSERT OR IGNORE INTO events }
  await bridge.ackEvents(ids: rows.ids, torn: torn)
  return CollectResult(inserted: count actually inserted, torn: torn.length)
```

**Insert, then acknowledge (D10).** A crash after the insert re-reads the same lines, and the
`OR IGNORE` drops them. A crash before it loses nothing either: the lines are still in the
file.

Torn lines are acknowledged so they leave the file; their count is shown once in a snackbar
on History. They cannot be repaired, and keeping them would report the same failure forever.

Called on launch, on resume, and by pull-to-refresh on History.

## 2. Streaks (D20)

```dart
int streak(String habitId, List<EventRow> eventsOfHabit, DateTime now)
  started = window_started, newest first
  paused  = { occurrence of every paused }
  ended   = { occurrence of every window_ended }
  n = 0
  for s in started:
    if paused contains s.occurrence → break
    finished = ended contains s.occurrence || now − s.at >= 24 h
    if !finished → continue              // still running: not yet counted
    n++
  return n
```

The 24-hour rule covers a window whose end was missed (the phone was off at the end): no
window is longer than a day, so a day after its start it is certainly over.

## 3. The day view

Last 14 local days, newest first. A day with nothing is omitted.

| Events | One line |
|---|---|
| `window_started` | *21:00 · Learning started* |
| `window_ended` | *22:00 · Learning done* |
| `blocked` | *Instagram sent away 4 times · Learning* — one per (day, habit, package), at the first time |
| `paused` | *21:12 · Paused 5 min in Instagram · Learning* |
| `alarm_fired` | *06:30 · Alarm rang · Wake up* |
| `alarm_snoozed` | *06:35 · Snoozed (1)* |
| `alarm_dismissed` | *06:41 · Dismissed (sum)* |
| `alarm_missed` | *06:40 · Not answered* |
| `enforcer_off` / `enforcer_on` | *Blocker turned off* / *Blocker turned on* |

Habit names come from `habits`, archived included. An alarm id with no row reads *a deleted
alarm*.

## 4. What to test

Streak: a pause breaks it; a running window is skipped but a pause in it still breaks; a
missed end counts after 24 hours; nothing started → 0. Collect: a duplicate id is ignored and
still acknowledged.
