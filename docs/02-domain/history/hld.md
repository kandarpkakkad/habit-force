# History — HLD

What actually happened, kept, and turned into streaks.

## Purpose

The log is the other half of the strictness (D4): a pause is easy enough to take, and
impossible to take quietly.

## Responsibilities

- Collecting events from the bridge — on launch, on resume, on pull-to-refresh — and keeping
  them in SQLite.
- Streaks per habit.
- The 14-day, day-by-day view.

## Owns

`events` ([schema.md](schema.md)).

## Depends on

The bridge (`readEvents`, `ackEvents`), `habits` for names.

## Key decisions

**Events are facts, written once.** No updates, no deletes. `INSERT OR IGNORE` on the id
makes collecting idempotent (D10).

**No foreign keys from events.** An alarm can be deleted and its history must stay; habits are
archived anyway (D19). Names are looked up at display time, and a missing one shows as
*a deleted alarm*.

**A streak is read from what ran (D20).** Walk a habit's `window_started` events newest first;
count until one has a `paused` event with the same occurrence key. A window that never
started is not in the list at all.

**The window still running does not count yet** — it has not been kept until it has ended —
but a pause inside it ends the streak at once.

**Blocked bounces are counted, not listed.** *Instagram sent away 4 times* is one line per app
per day.

## Failure modes

| | |
|---|---|
| Events not collected for weeks | They wait in `events.jsonl`; collected on next open, in order of `at` |
| A torn line in the file | Skipped and reported in the result; acknowledged so it does not come back forever |
| Clock changed backwards | Events keep the `at` they were stamped with; order follows `at` |

## Non-goals

- Charts, scores, gamification.
- Exporting history (D2).
