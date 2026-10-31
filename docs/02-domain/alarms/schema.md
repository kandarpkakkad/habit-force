# Alarms — schema

Source of truth: `lib/platform/storage/tables.dart`. Conventions: [storage schema](../../01-platform/storage/schema.md).

## `alarms`

```sql
CREATE TABLE alarms (
  id             TEXT    NOT NULL PRIMARY KEY,
  label          TEXT    NOT NULL DEFAULT '' CHECK (length(label) <= 40),
  anchor         TEXT    NOT NULL CHECK (anchor IN ('clock', 'habit_start', 'habit_end')),
  habit_id       TEXT    REFERENCES habits (id) ON DELETE CASCADE,
  minute         INTEGER CHECK (minute BETWEEN 0 AND 1439),
  offset_minutes INTEGER NOT NULL DEFAULT 0 CHECK (offset_minutes BETWEEN -180 AND 180),
  days           INTEGER NOT NULL DEFAULT 0 CHECK (days BETWEEN 0 AND 127),
  once_date      TEXT,
  enabled        INTEGER NOT NULL DEFAULT 1 CHECK (enabled IN (0, 1)),
  vibrate        INTEGER NOT NULL DEFAULT 1 CHECK (vibrate IN (0, 1)),
  snooze_minutes INTEGER NOT NULL DEFAULT 5 CHECK (snooze_minutes BETWEEN 1 AND 30),
  snooze_limit   INTEGER NOT NULL DEFAULT 2 CHECK (snooze_limit BETWEEN 0 AND 10),
  challenge      TEXT    NOT NULL DEFAULT 'sum' CHECK (challenge IN ('none', 'sum', 'phrase')),
  created_at     INTEGER NOT NULL,
  CHECK (
    (anchor = 'clock'
       AND habit_id IS NULL AND minute IS NOT NULL AND offset_minutes = 0
       AND ((days = 0) = (once_date IS NOT NULL)))
    OR
    (anchor <> 'clock'
       AND habit_id IS NOT NULL AND minute IS NULL AND days = 0 AND once_date IS NULL)
  )
);
CREATE INDEX alarms_habit ON alarms (habit_id);
```

| Shape | Columns set |
|---|---|
| Clock, repeating | `minute`, `days` ≠ 0 |
| Clock, once | `minute`, `days` = 0, `once_date` = the date it will ring |
| Habit-tied | `habit_id`, `anchor` = start or end, `offset_minutes`. Follows the habit's days |

The table CHECK makes the three shapes the only ones that can exist.

## Deliberately not stored

| | |
|---|---|
| "Rang" / "done" for a once alarm | Derived: `once_date` is before today |
| Snooze count | Lives in the intent while ringing; recorded in the event |
| Sound | The system default alarm sound |
