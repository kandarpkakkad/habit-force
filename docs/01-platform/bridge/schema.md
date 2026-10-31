# Bridge — schema

The two files Kotlin keeps in the app's private `files/` directory. Dart never opens them; it
reaches them only through the channel ([lld.md](lld.md)).

## `plan.json`

Written whole by `installPlan`, via `plan.json.tmp` and a rename, so a reader never sees half
of one.

```json
{
  "version": 1,
  "generatedAt": 1793404800000,
  "firstDate": "2026-10-31",
  "horizon": "2026-11-13",
  "settings": {
    "headsUpMinutes": 10,
    "pauseMinutes": 5,
    "pauseCooldownSeconds": 60,
    "pausePhrase": "I am choosing to break my own rule"
  },
  "windows": [
    {
      "key": "0192f3a1-…@2026-11-02",
      "habitId": "0192f3a1-…",
      "name": "Learning",
      "hard": false,
      "priority": 2,
      "dnd": false,
      "date": "2026-11-02",
      "start": 1260,
      "end": 1320,
      "apps": [ { "package": "com.instagram.android", "label": "Instagram" } ]
    }
  ],
  "alarms": [
    {
      "key": "2026-11-02@1255",
      "alarmIds": ["0192f3b7-…"],
      "label": "Learning in 5",
      "date": "2026-11-02",
      "minute": 1255,
      "vibrate": true,
      "snoozeMinutes": 5,
      "snoozeLimit": 2,
      "challenge": "sum"
    }
  ]
}
```

| Field | Rules |
|---|---|
| `version` | `1`. Kotlin treats any other value as an empty plan and reports it |
| `firstDate` | Yesterday at planning time — the earliest date a window can start on |
| `horizon` | The last date planned. The expiry warning is two days before it |
| `windows[].start` | 0–1439 |
| `windows[].end` | `start + 1` … `start + 1439`. Above 1439 means it ends the next day |
| `windows[].hard` | Strictness, as a boolean |
| `alarms[].minute` | 0–1439, already normalised onto `date` |
| `alarms[].challenge` | `none`, `sum`, `phrase` |
| `alarms[]` | Sorted by `date`, then `minute`. At most one entry per minute (D15) |

Instants are never stored: `date` + minutes are converted with the zone in force when Kotlin
reads them (D8).

## `events.jsonl`

One JSON object per line, appended under a lock, `\n` terminated.

```json
{"id":"7f1c…","at":1793466000000,"kind":"blocked","habitId":"0192f3a1-…","occurrence":"0192f3a1-…@2026-11-02","package":"com.instagram.android"}
```

Field names and kinds match the `events` table ([history schema](../../02-domain/history/schema.md)),
in camelCase. Absent fields are omitted, not `null`.

## Native preferences (`habit_force_native`)

Not files Dart sees, but recorded here so they have one home.

| Key | Type | Owner | Meaning |
|---|---|---|---|
| `pausedUntil` | long, epoch ms | blocking | Blocking is suspended until then |
| `lastHandledAt` | long, epoch ms | notifications | The chain has acted on every boundary up to here |
| `dndSetByUs` | boolean | notifications | Habit Force turned DND on and should be the one to turn it off |
