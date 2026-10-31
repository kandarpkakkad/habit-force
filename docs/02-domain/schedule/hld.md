# Schedule — HLD

Two pure functions and the thing that runs them: the **overlap engine**, which decides
whether a habit can be saved, and the **planner**, which turns habits and alarms into the next
14 days.

## Purpose

Do every piece of time arithmetic in one place, in Dart, with tests — so Kotlin only ever
compares instants (D8).

## Responsibilities

- **Overlaps:** for a habit about to be saved, find every clash with every other enabled habit
  across the week; say which habit gives way; propose shifts and trims that are clash-free on
  every day of the yielding habit.
- **Planner:** from habits, alarms and settings, produce the windows and alarm entries for
  yesterday through 13 days ahead, merging alarms that share a minute (D15).
- **Publisher:** rebuild the plan from the database and hand it to the bridge — after every
  write, on launch, on resume.

## Owns

Nothing stored. Both engines are pure: same inputs, same output, no clock read inside.

## Depends on

`habits`, `alarms` and `storage` for inputs; the bridge for `installPlan`.

## Key decisions

**Weekly arithmetic in week minutes.** Monday 00:00 is 0; a habit on Sunday 23:00–01:00 is two
intervals, `[10 020, 10 080)` and `[0, 60)`. Every overlap question becomes interval
intersection, and the Sunday-to-Monday wrap stops being a special case.

**Who gives way (D13):**

| A | B | Outcome |
|---|---|---|
| hard | hard | refused |
| soft | hard | the soft one gives way |
| soft | soft | the lower priority gives way; on a tie, the one being saved |

**Proposals must work on every day.** A habit has one start time for all its days, so a shift
to 22:30 is only offered if 22:30 is free on each of them — against hard habits with their
buffer (D14), and against every soft habit the yielding one would have to give way to.

**Only two kinds of proposal.** *Shift:* same length, nearest free start after, and nearest
free start before. *Trim:* the longest stretch of the original window that is free on all its
days, at least 15 minutes. Anything cleverer — splitting a habit in two, moving other habits —
is a decision the person should make, not the app.

**Keep both is offered only between soft habits.** Two windows at once block the union of
their apps (D12).

**The planner includes yesterday.** A window that started yesterday at 23:00 is running at
00:30 today, and the blocker must know.

**One-off alarms are planned for one date.** The date is fixed when the alarm is saved — the
next time its clock time comes round — so planning stays a pure function of the rows.

## Failure modes

| | |
|---|---|
| No free slot anywhere | No shift offered. Trim if possible; otherwise only Cancel |
| A clash with more than one habit | One sheet, every clash listed; proposals are free of all of them |
| The plan cannot be installed | The error is shown; the previous plan stays in force |

## Non-goals

- Solving the whole week as an optimisation problem.
- Clash checks for alarms (D15).
- Background re-planning (D9).
