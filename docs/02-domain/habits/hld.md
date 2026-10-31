# Habits — HLD

The weekly rules a person sets for themselves: when, how strictly, and which apps go quiet.

## Purpose

Hold each habit's definition, keep it valid, and refuse to save one that clashes with another
unless the clash has been resolved.

## Responsibilities

- Creating, editing, enabling, disabling and archiving habits.
- The list of apps each habit blocks.
- Calling the overlap engine before every save, and writing a resolution — which may change a
  second habit — in the same transaction (D13).
- Asking the planner to republish after every change.

## Owns

`habits`, `habit_apps`. See [schema.md](schema.md).

## Depends on

`schedule` (overlap engine, publisher), `storage`, and the bridge for the installed-apps list.

## Key decisions

**A habit belongs to the day it starts.** *Sleep 23:00–06:30, Mon–Fri* runs Monday night into
Tuesday morning, and Friday night into Saturday. It does not run Sunday night.

**End equal to start is refused.** It would mean either nothing or 24 hours, and neither is
a habit.

**Disabled is not archived.** Disabled is "not this fortnight" — kept in the list, switched
back on in one tap. Archived is "not any more" — gone from the list, kept in History (D19).

**An app is stored with the label it had when chosen.** An uninstalled app still shows by name
in the habit rather than as a package string.

**Priority belongs to soft habits.** A hard habit's priority is stored as normal and never
read; the editor does not show it.

## Failure modes

| | |
|---|---|
| Overlap with a hard habit | Save refused, with the other habit, the days and the minutes |
| Overlap with a soft habit | The overlap sheet; nothing is written until a choice is made |
| A blocked app is uninstalled | It stays in the list by label; blocking a package that never opens costs nothing |
| Habit Force itself, the dialler or the launcher chosen | Not offered in the picker; ignored by the blocker if present anyway |

## Non-goals

- Habits that repeat other than weekly (every other day, monthly).
- A habit longer than 24 hours.
- Different times on different days. Two habits do that.
