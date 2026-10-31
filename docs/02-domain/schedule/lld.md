# Schedule — LLD

Two pure engines and a publisher. Code: `lib/domain/schedule/`. Tables they read:
[habits](../habits/schema.md), [alarms](../alarms/schema.md), [settings](../../01-platform/storage/schema.md).

## 1. Week minutes

```dart
const kDay = 1440, kWeek = 7 * kDay;   // Monday 00:00 = 0

int duration(h) => (h.end - h.start + kDay) % kDay;          // 1..1439, never 0 (CHECK)

/// Every day in `days`, a run of `length` minutes starting `offset` minutes into that day.
/// `offset` may be negative (a buffer reaching into the previous day). Wraps at the week.
List<Span> weekly(int days, int offset, int length)
  for d in 0..6 where days has bit d:
    a = (d * kDay + offset) mod kWeek          // true modulo, never negative
    b = a + length
    b <= kWeek ? [a, b) : [a, kWeek) + [0, b - kWeek)

spans(h)          = weekly(h.days, h.start, duration(h))
buffered(h, buf)  = weekly(h.days, h.start - buf, duration(h) + buf)   // hard habits only (D14)
```

## 2. Overlaps

### 2.1 Clashes

`checkOverlaps(candidate, others, bufferMinutes) → OverlapReport`. `others` are every enabled,
unarchived habit except the candidate itself.

```
for o in others:
  (a, b) = (candidate, o)
  if a.hard and b.hard:      common = spans(a) ∩ spans(b);              refused = true
  elif a.hard != b.hard:     soft, hard = …
                             common = spans(soft) ∩ buffered(hard, buf); yielder = soft
  else:                      common = spans(a) ∩ spans(b)
                             yielder = b.priority < a.priority ? b : a  // tie → candidate
  if common not empty → Clash(other: o, common, refused?, yielder)
```

**Display:** each clash's `common` spans are turned back into clock ranges per weekday and
grouped by identical range: *Mon–Fri 21:45–22:00*. A span that runs past midnight is shown on
the day it starts.

### 2.2 What the person is offered

```
if any clash.refused        → Refused(clashes)           // Save stays disabled
yielders = distinct clash.yielder
if candidate in yielders    → one Section for the candidate:
                                 proposals = proposals(candidate, against = others)
                                 keepBoth  = every clash of the candidate is soft–soft
else                        → one Section per yielding other o:
                                 proposals = proposals(o, against = others − o + candidate)
                                 keepBoth  = every clash with o is soft–soft
```

**If the candidate yields, only the candidate moves.** It would be strange to save a habit
that gives way to one thing by moving a third.

A section with no proposals and no keep-both blocks the save: *No free time for Learning on
all its days — edit it first.*

### 2.3 Proposals

The yielding habit `y` is always soft. What it must stay clear of:

```
forbidden(y, against) = ∪ over o in against: o.hard ? buffered(o, buf) : spans(o)
fits(y, start, length) = weekly(y.days, start, length) ∩ forbidden == ∅
```

**Shift** — same length, start on the 5-minute grid:

```
L = duration(y); crosses = y.end < y.start
ok(t) = (crosses or t + L <= kDay) and fits(y, t, L)
later   = first t in (y.start, 1439], t % 5 == 0, ok(t)
earlier = last  t in [0, y.start),   t % 5 == 0, ok(t)
```

**Trim** — the longest part of the original window that is free on every day:

```
free[r] for r in 0 ..< L  =  fits(y, y.start + r, 1)
(a, b) = longest run of true in free
offer if b − a >= 15 and b − a < L:   start = (y.start + a) % kDay, end = (y.start + b) % kDay
```

Each proposal carries the new start and end and a sentence: *Shift to 22:30–23:30*,
*Trim to 21:00–21:45*, *Keep both — both block during the overlap*.

### 2.4 Saving a resolution

`HabitsRepository.save(candidate, resolutions)`, in **one** transaction (D13): write the
candidate (moved, if its section's choice moved it), write each yielding other that moved,
then publish once.

## 3. Planner

`buildPlan(habits, alarms, settings, today) → Plan`. Pure: `today` is passed in.

```
firstDate = today − 1;  horizon = today + 13

windows:
  for date in firstDate … horizon, for h in enabled unarchived habits with weekday(date) in h.days:
    end = h.end > h.start ? h.end : h.end + kDay
    if date == firstDate and end <= kDay: skip        // yesterday's, finished before today
    add Window(key: '${h.id}@$date', date, start: h.start, end, hard, priority, dnd, apps)

alarm instances (enabled alarms only):
  clock, days ≠ 0: for date in today … horizon with weekday(date) in days → (date, minute)
  clock, once:     once_date in today … horizon                     → (once_date, minute)
  habit_start:     for each window w of the habit                   → norm(w.date, w.start + offset)
  habit_end:       for each window w of the habit                   → norm(w.date, w.end + offset)
  norm(d, m) = (d + floor(m / kDay) days, m mod kDay); kept only if today ≤ date ≤ horizon

  label, if the alarm's own is empty:
    habit_start → '<habit> starts at HH:MM',  habit_end → '<habit> ends at HH:MM'
    clock       → ''   (the alarm screen shows "Alarm")

merge by (date, minute)  (D15):
  alarmIds      = in creation order
  label         = distinct non-empty labels joined with ' · '
  vibrate       = any
  snoozeMinutes = min,  snoozeLimit = min
  challenge     = hardest of none < sum < phrase
  key           = '$date@$minute'

order: windows by (date, start, key); alarms by (date, minute)
```

**Weekday:** `date.weekday − 1`, so Monday is bit 0, matching the schema.

**Habit-tied alarms of a disabled or archived habit** produce nothing, because that habit has
no windows. Nothing else has to remember to exclude them.

## 4. Publisher

```dart
Future<InstallResult> publish({DateTime? now})
  rows   = read habits (+ apps), alarms, settings     // one read transaction
  plan   = buildPlan(rows…, today: localDate(now ?? DateTime.now()))
  return bridge.installPlan(plan)
```

Called after every write in `habits` and `alarms` and in Settings, on launch, and on resume.
The result's error is shown in a snackbar; the previous plan stays in force.

## 5. Edge cases

| Case | Behaviour |
|---|---|
| Sunday 23:00–01:00 against Monday 00:30–02:00 | Clash, found through the week wrap |
| Soft ends 22:50, hard starts 23:00, buffer 15 | Clash (buffer), the soft yields |
| Soft ends 22:45, hard starts 23:00, buffer 15 | No clash |
| Two hard habits back to back | No clash (D14) |
| Candidate is disabled | No overlap check; disabled habits are never checked (habits HLD) |
| Re-enabling a habit | Is a save: checked like any other |
| Habit alarm offset −30 on a 00:10 start | Rings at 23:40 the day before |
| Once alarm whose date has passed | Not planned; shown as done |
| Two habit alarms on one minute, one sum, one phrase | One entry, phrase |

## 6. What to test

Overlaps: hard–hard refusal; the week wrap; buffer edge (inside, exactly at, outside); the
tie rule; a yielding *other*; later/earlier shift on a multi-day habit where one day blocks
the obvious slot; trim; no-proposal blocking.
Planner: midnight crossing and the yesterday rule; habit-alarm normalisation across midnight;
merging; once alarms inside and outside the horizon; disabled habits drop their alarms.
