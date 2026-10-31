import 'package:drift/drift.dart';

// The schema. docs/**/schema.md describe it; this file is the truth. The
// CHECKs are written as SQL so they read exactly as the documents print them.

@DataClassName('SettingsRow')
class Settings extends Table {
  IntColumn get id => integer()();
  IntColumn get headsUpMinutes => integer().withDefault(const Constant(10))();
  IntColumn get hardBufferMinutes => integer().withDefault(const Constant(15))();
  IntColumn get pauseMinutes => integer().withDefault(const Constant(5))();
  IntColumn get pauseCooldownSeconds => integer().withDefault(const Constant(60))();
  TextColumn get pausePhrase =>
      text().withDefault(const Constant('I am choosing to break my own rule'))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'CHECK (id = 1)',
        'CHECK (heads_up_minutes BETWEEN 0 AND 120)',
        'CHECK (hard_buffer_minutes BETWEEN 0 AND 120)',
        'CHECK (pause_minutes BETWEEN 1 AND 30)',
        'CHECK (pause_cooldown_seconds BETWEEN 10 AND 600)',
        'CHECK (length(trim(pause_phrase)) BETWEEN 8 AND 80)',
      ];
}

@DataClassName('HabitRow')
class Habits extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get days => integer()();
  IntColumn get startMinute => integer()();
  IntColumn get endMinute => integer()();
  TextColumn get strictness => text()();
  IntColumn get priority => integer().withDefault(const Constant(2))();
  BoolColumn get dnd => boolean().withDefault(const Constant(false))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
  IntColumn get archivedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'CHECK (length(trim(name)) BETWEEN 1 AND 40)',
        'CHECK (days BETWEEN 1 AND 127)',
        'CHECK (start_minute BETWEEN 0 AND 1439)',
        'CHECK (end_minute BETWEEN 0 AND 1439)',
        "CHECK (strictness IN ('hard', 'soft'))",
        'CHECK (priority BETWEEN 1 AND 3)',
        'CHECK (end_minute <> start_minute)',
      ];
}

@DataClassName('HabitAppRow')
class HabitApps extends Table {
  TextColumn get habitId => text().references(Habits, #id, onDelete: KeyAction.cascade)();
  TextColumn get package => text()();
  TextColumn get label => text()();

  @override
  Set<Column> get primaryKey => {habitId, package};

  @override
  List<String> get customConstraints => ['CHECK (length(package) BETWEEN 1 AND 255)'];
}

@DataClassName('AlarmRow')
@TableIndex(name: 'alarms_habit', columns: {#habitId})
class Alarms extends Table {
  TextColumn get id => text()();
  TextColumn get label => text().withDefault(const Constant(''))();
  TextColumn get anchor => text()();
  TextColumn get habitId =>
      text().nullable().references(Habits, #id, onDelete: KeyAction.cascade)();
  IntColumn get minute => integer().nullable()();
  IntColumn get offsetMinutes => integer().withDefault(const Constant(0))();
  IntColumn get days => integer().withDefault(const Constant(0))();
  TextColumn get onceDate => text().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  BoolColumn get vibrate => boolean().withDefault(const Constant(true))();
  IntColumn get snoozeMinutes => integer().withDefault(const Constant(5))();
  IntColumn get snoozeLimit => integer().withDefault(const Constant(2))();
  TextColumn get challenge => text().withDefault(const Constant('sum'))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'CHECK (length(label) <= 40)',
        "CHECK (anchor IN ('clock', 'habit_start', 'habit_end'))",
        'CHECK (minute BETWEEN 0 AND 1439)',
        'CHECK (offset_minutes BETWEEN -180 AND 180)',
        'CHECK (days BETWEEN 0 AND 127)',
        'CHECK (snooze_minutes BETWEEN 1 AND 30)',
        'CHECK (snooze_limit BETWEEN 0 AND 10)',
        "CHECK (challenge IN ('none', 'sum', 'phrase'))",
        // The three shapes an alarm can have, and no others
        // (docs/02-domain/alarms/schema.md).
        "CHECK ((anchor = 'clock' AND habit_id IS NULL AND minute IS NOT NULL "
            'AND offset_minutes = 0 AND ((days = 0) = (once_date IS NOT NULL))) '
            "OR (anchor <> 'clock' AND habit_id IS NOT NULL AND minute IS NULL "
            'AND days = 0 AND once_date IS NULL))',
      ];
}

// No foreign keys: history outlives deleted alarms
// (docs/02-domain/history/hld.md).
@DataClassName('EventRow')
@TableIndex(name: 'events_at', columns: {#at})
@TableIndex(name: 'events_habit_kind', columns: {#habitId, #kind, #at})
class Events extends Table {
  TextColumn get id => text()();
  IntColumn get at => integer()();
  TextColumn get kind => text()();
  TextColumn get habitId => text().nullable()();
  TextColumn get occurrence => text().nullable()();
  TextColumn get alarmId => text().nullable()();
  TextColumn get package => text().nullable()();
  TextColumn get detail => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        "CHECK (kind IN ('window_started', 'window_ended', 'blocked', 'paused', "
            "'alarm_fired', 'alarm_snoozed', 'alarm_dismissed', 'alarm_missed', "
            "'enforcer_on', 'enforcer_off'))",
      ];
}
