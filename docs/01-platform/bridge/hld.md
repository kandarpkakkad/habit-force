# Bridge — HLD

Where Dart and Kotlin meet: two files and one method channel. Nothing else crosses.

## Purpose

Let Dart, which knows what the habits mean, tell Kotlin what to do for the next 14 days — and
let Kotlin, which is there when things happen, tell Dart what happened.

## Responsibilities

- Carrying the **plan** from Dart to Kotlin, and storing it atomically.
- Carrying **events** from Kotlin to Dart, without losing or doubling one.
- Answering the few questions Dart cannot answer itself: which apps are installed, which
  permissions are granted, and "ring this alarm in ten seconds".
- Re-arming the schedule from the stored plan whenever Android forgets it: boot, time change,
  time-zone change, app update.

## Owns

| File | Written by | Read by |
|---|---|---|
| `files/plan.json` | Kotlin, on Dart's request — the whole file, atomically | Kotlin only |
| `files/events.jsonl` | Kotlin, appended | Kotlin, on Dart's request |

Shapes in [schema.md](schema.md). The channel contract in [lld.md](lld.md).

## Depends on

Dart: `platform/storage` for the events Dart keeps. Kotlin: nothing beyond the platform.

## Key decisions

**The plan is complete, every time.** `installPlan` replaces the file whole; there is no
"add one window". A partial update is a second source of truth, and the two would drift.

**The plan is wall-clock dates and minutes (D8).** Kotlin converts to instants with the zone
of the moment, so a zone change needs no Dart.

**Events are acknowledged, not drained (D10).** `readEvents` returns lines and changes nothing;
`ackEvents(ids)` removes exactly those. A crash in between costs a re-read, which the
`INSERT OR IGNORE` absorbs.

**One process, one lock.** Every Kotlin writer of `events.jsonl` is in the app's one process,
so a single JVM lock orders them. Nothing else touches the file.

**Kotlin parses defensively.** An unreadable or newer-than-known plan is an empty plan, and
says so — it never crashes the blocker or the alarm path. A field Kotlin does not know is
ignored, so an older native side survives a newer Dart side.

## Failure modes

| | |
|---|---|
| `plan.json` missing (first launch, before Dart has run) | Empty plan. Nothing blocked, nothing rings |
| `plan.json` corrupt | Empty plan; `planStatus` reports the error so Today can show it |
| `installPlan` fails to write | The old plan stays in force; the call returns the error and Dart shows it |
| Dart never opened again | The plan runs out at the horizon; warned two days before (D9) |
| `events.jsonl` grows while the app is unopened | ~100 bytes an event, tens a day. Months fit in a megabyte |
| A line in `events.jsonl` is torn (power loss mid-append) | That line is skipped and reported; the rest are read |

## Non-goals

- A background Dart isolate (D9).
- Kotlin reading or writing SQLite (D7).
- Streaming events live to a running app. Reading on start, resume and pull-to-refresh is
  enough for a history screen.
