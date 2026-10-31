# Storage — LLD

Shapes: [schema.md](schema.md). Code: `lib/platform/storage/`.

## 1. Opening

```dart
Future<AppDatabase> openAppDatabase()
  dir  = getApplicationDocumentsDirectory()
  file = '${dir.path}/habit_force.db'
  return AppDatabase(NativeDatabase.createInBackground(File(file)))
```

**One connection for the life of the app**, held by `AppScope`. A second `openAppDatabase()`
is a second connection whose writes the first one's streams never see (little-loaf AGENTS.md,
*Another isolate writing the same file notifies nobody*). Nothing in this app needs one.

## 2. `MigrationStrategy`

```dart
onCreate:   m.createAll(); insert settings row id = 1 with defaults
onUpgrade:  for v in from ..< to: step = _steps[v] ?? throw StateError('no migration step from schema v$v'); await step(m)
beforeOpen: PRAGMA foreign_keys = ON
```

`_steps` is empty at `kSchemaVersion = 1`. A step is added with the version that needs it,
never edited afterwards.

## 3. Ids

`newId()` in `common/ids.dart` — `Uuid().v7()`. Ids are opaque everywhere else.

## 4. Settings

`SettingsRepository.watch()` streams the single row; `update(...)` writes it and publishes.
Validation mirrors the CHECKs:

| Field | Range | Message |
|---|---|---|
| heads-up | 0–120 min | *Between 0 and 120 minutes* |
| hard buffer | 0–120 min | *Between 0 and 120 minutes* |
| pause length | 1–30 min | *Between 1 and 30 minutes* |
| cooldown | 10–600 s | *Between 10 seconds and 10 minutes* |
| pause sentence | trimmed, 8–80 chars | *Use 8 to 80 characters* |

A field left empty in the form keeps its current value — an empty box never means zero.

## 5. Raw SQL

None. Every query goes through drift's typed API, so the analyser sees every column name. If a
`customStatement` is ever needed, it passes `updates:` with the tables it touches, or streams
will not hear it.

## 6. What to test

Every test opens the real schema in memory (`NativeDatabase.memory()`), so CHECKs and foreign
keys are the real ones.
