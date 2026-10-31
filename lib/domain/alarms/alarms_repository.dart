import 'package:drift/drift.dart';

import '../../common/dates.dart';
import '../../platform/storage/database.dart';
import 'alarm.dart';

class AlarmsRepository {
  final AppDatabase db;

  /// Set by boot: republish the plan.
  Future<void> Function() onChanged = () async {};

  AlarmsRepository(this.db);

  Stream<List<Alarm>> watchAll() => (db.select(db.alarms)
        ..orderBy([(t) => OrderingTerm.asc(t.minute), (t) => OrderingTerm.asc(t.createdAt)]))
      .watch()
      .map((rows) => rows.map(Alarm.fromRow).toList());

  Future<List<Alarm>> loadAll() async =>
      (await (db.select(db.alarms)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get())
          .map(Alarm.fromRow)
          .toList();

  /// A once alarm gets a fresh date on every save, so switching a done one
  /// back on, or changing its time, re-aims it at the next occurrence.
  Future<Map<String, String>> save(Alarm a, {DateTime? now}) async {
    final errors = validateAlarm(a);
    if (errors.isNotEmpty) return errors;
    final when = now ?? DateTime.now();
    final once = a.isOnce ? onceDateFor(a.minute!, when) : null;

    await db.into(db.alarms).insertOnConflictUpdate(AlarmsCompanion.insert(
          id: a.id,
          label: Value(a.label.trim()),
          anchor: a.anchor.db,
          habitId: Value(a.isClock ? null : a.habitId),
          minute: Value(a.isClock ? a.minute : null),
          offsetMinutes: Value(a.isClock ? 0 : a.offsetMinutes),
          days: Value(a.isClock ? a.days : 0),
          onceDate: Value(once == null ? null : isoDate(once)),
          enabled: Value(a.enabled),
          vibrate: Value(a.vibrate),
          snoozeMinutes: Value(a.snoozeMinutes),
          snoozeLimit: Value(a.snoozeLimit),
          challenge: Value(a.challenge.name),
          createdAt: a.createdAt.millisecondsSinceEpoch,
        ));
    await onChanged();
    return const {};
  }

  Future<void> setEnabled(Alarm a, bool enabled) async {
    await save(a.copyWith(enabled: enabled));
  }

  Future<void> delete(String id) async {
    await (db.delete(db.alarms)..where((t) => t.id.equals(id))).go();
    await onChanged();
  }
}
