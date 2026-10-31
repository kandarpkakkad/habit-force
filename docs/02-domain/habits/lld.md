# Habits — LLD

Shapes: [schema.md](schema.md). Code: `lib/domain/habits/`.

## 1. Model

```dart
enum Strictness { hard, soft }

class Habit {
  final String id;
  final String name;
  final int days;               // Monday = bit 0
  final ClockTime start, end;   // minutes 0..1439
  final Strictness strictness;
  final int priority;           // 1 low · 2 normal · 3 high
  final bool dnd, enabled;
  final List<BlockedApp> apps;  // {package, label}
  final DateTime createdAt;
  final DateTime? archivedAt;
  bool get hard => strictness == Strictness.hard;
  bool get crossesMidnight => end.minutes < start.minutes;
}
```

## 2. Validation — before the overlap engine, before any write

| Field | Rule | Message |
|---|---|---|
| name | trimmed, 1–40 | *Give the habit a name* · *Keep the name under 40 characters* |
| days | ≠ 0 | *Pick at least one day* |
| start, end | `end ≠ start` | *Start and end can't be the same time* |
| priority | 1–3; forced to 2 when hard | — |
| apps | no duplicates; never Habit Force itself | — (the picker cannot produce either) |

Validation returns every failing field at once, so the editor marks them all.

## 3. Saving

```
save(draft, {resolution}) → SaveOutcome
  errors = validate(draft);             if errors → Invalid(errors)
  if not draft.enabled                  → write(draft); publish; Saved
  others = enabled, unarchived habits except draft.id
  report = checkOverlaps(draft, others, settings.hardBufferMinutes)
  if report.clean                       → write(draft); publish; Saved
  if report is Refused                  → Refused(report)
  if resolution == null                 → NeedsChoice(report)       // the editor shows the sheet
  apply resolution:
    for each section: choice is shift/trim → that habit's start/end replaced
                      choice is keepBoth   → nothing changes
  re-check the candidate as resolved against the others as resolved
    still clashing                      → NeedsChoice(new report)   // proposals were stale
  transaction { write candidate; write each moved other }
  publish; Saved
```

**The re-check is not paranoia.** A proposal is computed against the habits as they were when
the sheet opened. Re-checking inside `save` keeps one rule true no matter what: nothing that
clashes is ever written without a keep-both choice.

`write` is an upsert of the `habits` row and a replace of its `habit_apps` rows — delete all,
insert the list — in the same transaction.

## 4. Other transitions

| Action | Effect |
|---|---|
| `setEnabled(id, false)` | Write; publish. No overlap check |
| `setEnabled(id, true)` | Goes through `save` — re-enabling can clash |
| `archive(id)` | `archived_at = now`, `enabled = 0`; disables its habit-tied alarms by having no windows; publish |

There is no unarchive in v1 and no delete (D19).

## 5. Apps picker

`bridge.listApps()` — launchable apps, minus everything the blocker never blocks: Habit Force,
the default dialler, the home app, Settings (blocking LLD §2). Offering them would promise a
block that cannot happen. Search is a case-insensitive substring on the label. Chosen apps are
kept with their label.

## 6. Edge cases

| Case | Behaviour |
|---|---|
| Editing a habit's days so a window that is running now no longer exists | Publish removes it; the blocker stops at the next check |
| Shortening a running window to have ended already | Same: no longer running, no `window_ended` event — the chain only acts on boundaries in the plan |
| Name with surrounding spaces | Trimmed on save |

## 7. What to test

Validation messages; disabled skips overlap; Refused writes nothing; a stale resolution is
caught by the re-check; a moved *other* is written in the same transaction as the candidate.
