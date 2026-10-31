import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'database.g.dart';

const kSchemaVersion = 1;

typedef MigrationStep = Future<void> Function(Migrator m, AppDatabase db);

// One entry per version, keyed by the version it migrates FROM. Forward-only;
// a step is never edited once released (docs/01-platform/storage/lld.md §2).
final Map<int, MigrationStep> _steps = {};

@DriftDatabase(tables: [Settings, Habits, HabitApps, Alarms, Events])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => kSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await into(settings).insert(const SettingsCompanion(id: Value(1)));
        },
        onUpgrade: (m, from, to) async {
          for (var v = from; v < to; v++) {
            final step = _steps[v];
            // Loud, never guessed. A database from a schema this build does
            // not know how to reach must not be opened as if it were current.
            if (step == null) throw StateError('no migration step from schema v$v');
            await step(m, this);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

/// The app's one connection. A second one would be a second world whose
/// writes this one's streams never hear (docs/01-platform/storage/lld.md §1).
Future<AppDatabase> openAppDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  return AppDatabase(NativeDatabase.createInBackground(File(p.join(dir.path, 'habit_force.db'))));
}
