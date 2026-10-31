# History — schema

Source of truth: `lib/platform/storage/tables.dart`. Conventions: [storage schema](../../01-platform/storage/schema.md).
The file these rows arrive in is described in the [bridge schema](../../01-platform/bridge/schema.md).

## `events`

```sql
CREATE TABLE events (
  id         TEXT    NOT NULL PRIMARY KEY,
  at         INTEGER NOT NULL,
  kind       TEXT    NOT NULL CHECK (kind IN (
               'window_started', 'window_ended', 'blocked', 'paused',
               'alarm_fired', 'alarm_snoozed', 'alarm_dismissed', 'alarm_missed',
               'enforcer_on', 'enforcer_off')),
  habit_id   TEXT,
  occurrence TEXT,
  alarm_id   TEXT,
  package    TEXT,
  detail     TEXT
);
CREATE INDEX events_at         ON events (at);
CREATE INDEX events_habit_kind ON events (habit_id, kind, at);
```

| Kind | `habit_id` | `occurrence` | `alarm_id` | `package` | `detail` |
|---|---|---|---|---|---|
| `window_started`, `window_ended` | ✓ | ✓ | | | |
| `blocked` | ✓ | ✓ | | ✓ | |
| `paused` | ✓ — the window named on the block screen | ✓ | | ✓ | minutes paused |
| `alarm_fired` | | | ✓ | | the label |
| `alarm_snoozed` | | | ✓ | | snooze number, 1-based |
| `alarm_dismissed` | | | ✓ | | challenge used |
| `alarm_missed` | | | ✓ | | |
| `enforcer_on`, `enforcer_off` | | | | | |

A merged alarm entry (D15) writes one event **per alarm id** it stands for.

**No foreign keys.** History outlives deleted alarms; ids that no longer resolve show as
*a deleted alarm*.

## Deliberately not stored

| | |
|---|---|
| Streaks, daily counts | Derived on read |
| Which window a pause belonged to, beyond the one named | A pause covers all running windows; the one on the block screen is the one charged |
