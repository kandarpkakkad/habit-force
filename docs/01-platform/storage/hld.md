# Storage — HLD

The one SQLite file that holds everything the person typed in, and everything that happened.

## Purpose

Give every Dart module a typed, reactive, transactional store, and nothing else. The
database is local, unencrypted and unsynced (D2).

## Responsibilities

- Opening the database, creating it on first launch, migrating it forward.
- The `settings` singleton, created with defaults on first launch.
- Minting ids (UUID v7) for every row Dart creates.

## Owns

`habit_force.db` in the app's documents directory. Tables are in [schema.md](schema.md).

## Depends on

drift and `package:sqlite3` (whose build hook supplies the native library). Nothing else.

## Key decisions

**Kotlin never opens this file (D7).** drift ships its own SQLite; Android ships another. Two
copies of SQLite on one file in one process do not see each other's POSIX locks. Everything
native learns about the data through the plan, and reports through the event log.

**No encryption.** little-loaf encrypts because a bakery's customers' phone numbers and
addresses are in it. Habit names and app package names are not worth a key on the phone, and
a key is one more thing to lose.

**Additive, forward-only migrations.** `kSchemaVersion` and one step per version. A column
that must go is emptied in one release and dropped in the next.

**Stream reads.** Screens `watch()`; nothing on screen is a one-off `get()`. A write anywhere
updates every screen that shows it.

## Failure modes

| | |
|---|---|
| Migration step missing | Opening throws `no migration step from schema vN`, loudly. Never guessed |
| Disk full | The write throws; the transaction rolls back; the UI shows the reason |
| A CHECK fails | The write throws. The UI validates first, so this is a bug, and it says which constraint |

## Non-goals

- Sync columns (`device_id`, HLC, outbox). One phone (D2).
- Soft deletes everywhere. Only habits archive (D19); alarms delete outright, and their events
  keep the id.
