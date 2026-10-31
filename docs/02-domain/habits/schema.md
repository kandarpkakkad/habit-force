# Habits — schema

Source of truth: `lib/platform/storage/tables.dart`. Conventions: [storage schema](../../01-platform/storage/schema.md).

## `habits`

```sql
CREATE TABLE habits (
  id           TEXT    NOT NULL PRIMARY KEY,
  name         TEXT    NOT NULL CHECK (length(trim(name)) BETWEEN 1 AND 40),
  days         INTEGER NOT NULL CHECK (days BETWEEN 1 AND 127),
  start_minute INTEGER NOT NULL CHECK (start_minute BETWEEN 0 AND 1439),
  end_minute   INTEGER NOT NULL CHECK (end_minute BETWEEN 0 AND 1439),
  strictness   TEXT    NOT NULL CHECK (strictness IN ('hard', 'soft')),
  priority     INTEGER NOT NULL DEFAULT 2 CHECK (priority BETWEEN 1 AND 3),
  dnd          INTEGER NOT NULL DEFAULT 0 CHECK (dnd IN (0, 1)),
  enabled      INTEGER NOT NULL DEFAULT 1 CHECK (enabled IN (0, 1)),
  created_at   INTEGER NOT NULL,
  archived_at  INTEGER,
  CHECK (end_minute <> start_minute)
);
```

| Column | Meaning |
|---|---|
| `days` | Days the window **starts** on |
| `end_minute < start_minute` | Crosses midnight; ends the next day |
| `priority` | 1 low · 2 normal · 3 high. Read only for soft habits |
| `enabled` | 0 = not planned, not checked for overlaps, still listed |
| `archived_at` | Set = gone from the list, kept for History. Never cleared (D19) |

## `habit_apps`

```sql
CREATE TABLE habit_apps (
  habit_id TEXT NOT NULL REFERENCES habits (id) ON DELETE CASCADE,
  package  TEXT NOT NULL CHECK (length(package) BETWEEN 1 AND 255),
  label    TEXT NOT NULL,
  PRIMARY KEY (habit_id, package)
);
```

`label` is the app's name when it was chosen, so an uninstalled app still reads as a name.
The cascade never fires in practice — habits are archived, not deleted — and is there so a
future delete cannot leave orphans.

## Deliberately not stored

| | |
|---|---|
| Overlap results | Computed at save, never kept |
| A habit's windows | The planner derives them; Kotlin holds them in `plan.json` |
| Streak | Derived from `events` every time it is shown |
