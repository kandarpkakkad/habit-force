import 'package:drift/drift.dart';

import '../../common/clock_time.dart';
import '../../common/dates.dart';
import '../../platform/bridge/native_bridge.dart';
import '../../platform/storage/database.dart';

const kEventKinds = {
  'window_started',
  'window_ended',
  'blocked',
  'paused',
  'alarm_fired',
  'alarm_snoozed',
  'alarm_dismissed',
  'alarm_missed',
  'enforcer_on',
  'enforcer_off',
};

class CollectResult {
  final int inserted;
  final int torn;

  const CollectResult(this.inserted, this.torn);
}

class HistoryRepository {
  final AppDatabase db;
  final NativeBridge bridge;

  HistoryRepository(this.db, this.bridge);

  /// Insert, then acknowledge (D10). A crash after the insert re-reads the
  /// same lines and `OR IGNORE` drops them; a crash before it loses nothing,
  /// because the lines are still in the file.
  /// docs/02-domain/history/lld.md §1.
  Future<CollectResult> collect() async {
    final batch = await bridge.readEvents();
    final rows = <EventsCompanion>[];
    // Lines with an id that this build cannot keep (an unknown kind, say) are
    // acknowledged by that id, so they leave the file instead of coming back
    // on every collect.
    final unusable = <String>[];
    for (final e in batch.events) {
      final row = _parse(e);
      if (row != null) {
        rows.add(row);
      } else if (e['id'] is String) {
        unusable.add(e['id'] as String);
      }
    }
    final ids = [for (final r in rows) r.id.value];
    var inserted = 0;
    await db.transaction(() async {
      final known = await (db.selectOnly(db.events)
            ..addColumns([db.events.id])
            ..where(db.events.id.isIn(ids)))
          .map((r) => r.read(db.events.id))
          .get();
      inserted = rows.length - known.length;
      for (final r in rows) {
        await db.into(db.events).insert(r, mode: InsertMode.insertOrIgnore);
      }
    });
    if (ids.isNotEmpty || unusable.isNotEmpty || batch.torn.isNotEmpty) {
      await bridge.ackEvents(ids: [...ids, ...unusable], torn: batch.torn);
    }
    return CollectResult(inserted, batch.torn.length + unusable.length);
  }

  static EventsCompanion? _parse(Map<String, Object?> e) {
    final id = e['id'], at = e['at'], kind = e['kind'];
    if (id is! String || at is! int || kind is! String || !kEventKinds.contains(kind)) return null;
    String? s(String k) => e[k] is String ? e[k] as String : null;
    return EventsCompanion.insert(
      id: id,
      at: at,
      kind: kind,
      habitId: Value(s('habitId')),
      occurrence: Value(s('occurrence')),
      alarmId: Value(s('alarmId')),
      package: Value(s('package')),
      detail: Value(s('detail')),
    );
  }

  Stream<List<EventRow>> watchSince(DateTime since) => (db.select(db.events)
        ..where((t) => t.at.isBiggerOrEqualValue(since.millisecondsSinceEpoch))
        ..orderBy([(t) => OrderingTerm.desc(t.at)]))
      .watch();

  /// Every event a streak needs: starts, ends and pauses, all time.
  Stream<List<EventRow>> watchStreakEvents() => (db.select(db.events)
        ..where((t) => t.kind.isIn(const ['window_started', 'window_ended', 'paused']))
        ..orderBy([(t) => OrderingTerm.desc(t.at)]))
      .watch();
}

/// Consecutive windows of [habitId] kept without a pause, newest first.
/// Read from what ran, not from the rules (D20).
/// docs/02-domain/history/lld.md §2.
int streak(String habitId, List<EventRow> events, DateTime now) {
  final mine = [for (final e in events) if (e.habitId == habitId) e];
  final paused = {for (final e in mine) if (e.kind == 'paused') e.occurrence};
  final ended = {for (final e in mine) if (e.kind == 'window_ended') e.occurrence};
  final started = [for (final e in mine) if (e.kind == 'window_started') e]
    ..sort((a, b) => b.at.compareTo(a.at));
  final dayMs = const Duration(hours: 24).inMilliseconds;
  var n = 0;
  for (final s in started) {
    if (paused.contains(s.occurrence)) break;
    // No window is longer than a day, so a day after its start it is over
    // even if its end was missed with the phone off.
    final finished = ended.contains(s.occurrence) || now.millisecondsSinceEpoch - s.at >= dayMs;
    if (!finished) continue;
    n++;
  }
  return n;
}

class HistoryLine {
  final String? time;
  final String text;

  const HistoryLine(this.time, this.text);
}

class HistoryDay {
  final DateTime date;
  final List<HistoryLine> lines;

  const HistoryDay(this.date, this.lines);
}

/// The day-by-day view: newest day first, oldest line first within a day.
/// docs/02-domain/history/lld.md §3.
List<HistoryDay> buildDays(
  List<EventRow> events, {
  required Map<String, String> habitNames,
  required Map<String, String> alarmLabels,
  required Map<String, String> appLabels,
}) {
  String habit(String? id) => habitNames[id] ?? 'a removed habit';
  String app(String? pkg) => appLabels[pkg] ?? pkg ?? 'an app';
  String alarm(String? id) {
    if (id == null || !alarmLabels.containsKey(id)) return 'a deleted alarm';
    final l = alarmLabels[id]!;
    return l.isEmpty ? 'Alarm' : l;
  }

  final byDay = <DateTime, List<EventRow>>{};
  for (final e in events) {
    final day = dateOnly(DateTime.fromMillisecondsSinceEpoch(e.at));
    (byDay[day] ??= []).add(e);
  }

  final days = <HistoryDay>[];
  for (final day in byDay.keys.toList()..sort((a, b) => b.compareTo(a))) {
    final list = byDay[day]!..sort((a, b) => a.at.compareTo(b.at));
    final lines = <HistoryLine>[];
    final blocked = <String, (int, int)>{}; // habit|package → (first at, count)
    for (final e in list) {
      final time = hhmm(minuteOfDay(DateTime.fromMillisecondsSinceEpoch(e.at)));
      switch (e.kind) {
        case 'window_started':
          lines.add(HistoryLine(time, '${habit(e.habitId)} started'));
        case 'window_ended':
          lines.add(HistoryLine(time, '${habit(e.habitId)} done'));
        case 'blocked':
          final k = '${e.habitId}|${e.package}';
          final prev = blocked[k];
          blocked[k] = prev == null ? (e.at, 1) : (prev.$1, prev.$2 + 1);
        case 'paused':
          final minutes = e.detail == null ? '' : ' ${e.detail} min';
          lines.add(HistoryLine(time, 'Paused$minutes in ${app(e.package)} · ${habit(e.habitId)}'));
        case 'alarm_fired':
          lines.add(HistoryLine(time, 'Alarm rang · ${alarm(e.alarmId)}'));
        case 'alarm_snoozed':
          lines.add(HistoryLine(time, e.detail == null ? 'Snoozed' : 'Snoozed (${e.detail})'));
        case 'alarm_dismissed':
          lines.add(HistoryLine(time, e.detail == null ? 'Dismissed' : 'Dismissed (${e.detail})'));
        case 'alarm_missed':
          lines.add(HistoryLine(time, 'Not answered · ${alarm(e.alarmId)}'));
        case 'enforcer_off':
          lines.add(HistoryLine(time, 'Blocker turned off'));
        case 'enforcer_on':
          lines.add(HistoryLine(time, 'Blocker turned on'));
      }
    }
    for (final entry in blocked.entries) {
      final parts = entry.key.split('|');
      final (first, count) = entry.value;
      final times = count == 1 ? 'once' : '$count times';
      lines.add(HistoryLine(
        hhmm(minuteOfDay(DateTime.fromMillisecondsSinceEpoch(first))),
        '${app(parts[1])} sent away $times · ${habit(parts[0])}',
      ));
    }
    lines.sort((a, b) => (a.time ?? '').compareTo(b.time ?? ''));
    days.add(HistoryDay(day, lines));
  }
  return days;
}
