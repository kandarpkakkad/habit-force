# Storage — schema

The source of truth is `lib/platform/storage/tables.dart`. This file describes it.

`kSchemaVersion = 1`. Tables owned by other systems are described in their own `schema.md`:

| Table | Described in |
|---|---|
| `habits`, `habit_apps` | [02-domain/habits/schema.md](../../02-domain/habits/schema.md) |
| `alarms` | [02-domain/alarms/schema.md](../../02-domain/alarms/schema.md) |
| `events` | [02-domain/history/schema.md](../../02-domain/history/schema.md) |
| `settings` | here |

## Conventions

| | |
|---|---|
| Primary keys | `TEXT`, UUID v7, minted in Dart. Events are the exception: Kotlin mints them (D21) |
| Instants | `INTEGER`, epoch milliseconds |
| Times of day | `INTEGER` minutes, 0–1439 |
| Weekdays | `INTEGER` bitmask, Monday = bit 0 … Sunday = bit 6. 127 = every day |
| Dates | `TEXT`, `yyyy-mm-dd`, the phone's local calendar |
| Booleans | `INTEGER` 0 / 1 |
| Foreign keys | `PRAGMA foreign_keys = ON` at open |

## `settings`

One row, `id = 1`, inserted by `onCreate`.

```sql
CREATE TABLE settings (
  id                     INTEGER NOT NULL PRIMARY KEY CHECK (id = 1),
  heads_up_minutes       INTEGER NOT NULL DEFAULT 10  CHECK (heads_up_minutes BETWEEN 0 AND 120),
  hard_buffer_minutes    INTEGER NOT NULL DEFAULT 15  CHECK (hard_buffer_minutes BETWEEN 0 AND 120),
  pause_minutes          INTEGER NOT NULL DEFAULT 5   CHECK (pause_minutes BETWEEN 1 AND 30),
  pause_cooldown_seconds INTEGER NOT NULL DEFAULT 60  CHECK (pause_cooldown_seconds BETWEEN 10 AND 600),
  pause_phrase           TEXT    NOT NULL DEFAULT 'I am choosing to break my own rule'
                                 CHECK (length(trim(pause_phrase)) BETWEEN 8 AND 80)
);
```

| Column | Read by |
|---|---|
| `heads_up_minutes` | planner → plan → boundary chain. 0 turns heads-up off |
| `hard_buffer_minutes` | overlap engine (D14) |
| `pause_minutes`, `pause_cooldown_seconds`, `pause_phrase` | planner → plan → block screen |

## Deliberately not stored

| | |
|---|---|
| Permission state | Read live, every time (permissions HLD) |
| The plan | Rebuilt from the tables on every publish; Kotlin keeps its copy in `plan.json` |
| Pause state, "DND set by us", chain position | Native preferences — Kotlin's, not the database's |
| Device id, HLC, outbox | No sync (D2) |
