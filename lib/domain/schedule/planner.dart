import '../../common/clock_time.dart';
import '../../common/dates.dart';
import '../../platform/bridge/plan.dart';
import '../alarms/alarm.dart';
import '../habits/habit.dart';
import '../settings/settings.dart';

/// Days of plan after today. With today itself, 14 days (D9).
const kHorizonDays = 13;

/// Habits, alarms and settings → the next 14 days. Pure: `today` is passed
/// in, and nothing here reads the clock. docs/02-domain/schedule/lld.md §3.
Plan buildPlan({
  required List<Habit> habits,
  required List<Alarm> alarms,
  required AppSettings settings,
  required DateTime today,
  required int generatedAt,
}) {
  today = dateOnly(today);
  // Yesterday too: a window that started at 23:00 last night is still
  // running at 00:30, and the blocker has to know.
  final firstDate = addDays(today, -1);
  final horizon = addDays(today, kHorizonDays);

  final windows = <PlanWindow>[];
  final windowsByHabit = <String, List<PlanWindow>>{};
  final active = [for (final h in habits) if (h.active) h];

  for (var date = firstDate; !date.isAfter(horizon); date = addDays(date, 1)) {
    for (final h in active) {
      if (!hasDay(h.days, weekdayIndex(date))) continue;
      final end = h.end.minutes > h.start.minutes ? h.end.minutes : h.end.minutes + kDay;
      if (date == firstDate && end <= kDay) continue;
      final w = PlanWindow(
        key: '${h.id}@${isoDate(date)}',
        habitId: h.id,
        name: h.name,
        hard: h.hard,
        priority: h.priority,
        dnd: h.dnd,
        date: date,
        start: h.start.minutes,
        end: end,
        apps: [for (final a in h.apps) PlanApp(a.package, a.label)],
      );
      windows.add(w);
      (windowsByHabit[h.id] ??= []).add(w);
    }
  }

  final habitsById = {for (final h in habits) h.id: h};
  final instances = <_Instance>[];

  void add(Alarm a, DateTime date, int minute, String label) {
    // Normalise onto the right day: −20 on Monday is 23:40 on Sunday.
    final shift = (minute / kDay).floor();
    final d = addDays(date, shift);
    final m = minute - shift * kDay;
    if (d.isBefore(today) || d.isAfter(horizon)) return;
    instances.add(_Instance(a, d, m, label));
  }

  for (final a in alarms) {
    if (!a.enabled) continue;
    switch (a.anchor) {
      case AlarmAnchor.clock:
        if (a.days != 0) {
          for (var date = today; !date.isAfter(horizon); date = addDays(date, 1)) {
            if (hasDay(a.days, weekdayIndex(date))) add(a, date, a.minute!, a.label);
          }
        } else if (a.onceDate != null) {
          add(a, a.onceDate!, a.minute!, a.label);
        }
      case AlarmAnchor.habitStart:
      case AlarmAnchor.habitEnd:
        // A disabled or archived habit has no windows, so its alarms drop out
        // here without anything having to remember to exclude them.
        final habit = habitsById[a.habitId];
        for (final w in windowsByHabit[a.habitId] ?? const <PlanWindow>[]) {
          final atStart = a.anchor == AlarmAnchor.habitStart;
          final base = atStart ? w.start : w.end;
          final label = a.label.isNotEmpty
              ? a.label
              : '${habit?.name ?? 'Habit'} ${atStart ? 'starts' : 'ends'} at ${hhmm(base)}';
          add(a, w.date, base + a.offsetMinutes, label);
        }
    }
  }

  // One ring per minute (D15).
  final byMinute = <String, List<_Instance>>{};
  for (final i in instances) {
    (byMinute['${isoDate(i.date)}@${i.minute}'] ??= []).add(i);
  }
  final planAlarms = [
    for (final e in byMinute.entries) _merge(e.key, e.value),
  ]..sort((x, y) {
      final d = x.date.compareTo(y.date);
      return d != 0 ? d : x.minute.compareTo(y.minute);
    });

  windows.sort((x, y) {
    final d = x.date.compareTo(y.date);
    if (d != 0) return d;
    final s = x.start.compareTo(y.start);
    return s != 0 ? s : x.key.compareTo(y.key);
  });

  return Plan(
    generatedAt: generatedAt,
    firstDate: firstDate,
    horizon: horizon,
    settings: PlanSettings(
      headsUpMinutes: settings.headsUpMinutes,
      pauseMinutes: settings.pauseMinutes,
      pauseCooldownSeconds: settings.pauseCooldownSeconds,
      pausePhrase: settings.pausePhrase,
    ),
    windows: windows,
    alarms: planAlarms,
  );
}

class _Instance {
  final Alarm alarm;
  final DateTime date;
  final int minute;
  final String label;

  const _Instance(this.alarm, this.date, this.minute, this.label);
}

PlanAlarm _merge(String key, List<_Instance> group) {
  group.sort((x, y) => x.alarm.createdAt.compareTo(y.alarm.createdAt));
  final labels = <String>[];
  for (final i in group) {
    if (i.label.isNotEmpty && !labels.contains(i.label)) labels.add(i.label);
  }
  final ids = <String>[];
  for (final i in group) {
    if (!ids.contains(i.alarm.id)) ids.add(i.alarm.id);
  }
  final hardest = group.map((i) => i.alarm.challenge).reduce((a, b) => a.index >= b.index ? a : b);
  return PlanAlarm(
    key: key,
    alarmIds: ids,
    label: labels.join(' · '),
    date: group.first.date,
    minute: group.first.minute,
    vibrate: group.any((i) => i.alarm.vibrate),
    snoozeMinutes: group.map((i) => i.alarm.snoozeMinutes).reduce((a, b) => a < b ? a : b),
    snoozeLimit: group.map((i) => i.alarm.snoozeLimit).reduce((a, b) => a < b ? a : b),
    challenge: hardest.name,
  );
}

/// One alarm as a plan entry, for the Test button. Kotlin rings it ten
/// seconds after it arrives, whatever its date and minute say; the label is
/// the one the planner would give it.
PlanAlarm testEntry(Alarm a, {String? habitName}) {
  final label = a.label.isNotEmpty
      ? a.label
      : a.isClock
          ? ''
          : '${habitName ?? 'Habit'} ${a.anchor == AlarmAnchor.habitStart ? 'starts' : 'ends'}';
  final now = DateTime.now();
  return PlanAlarm(
    key: 'test@${now.millisecondsSinceEpoch}',
    alarmIds: [a.id],
    label: label,
    date: dateOnly(now),
    minute: minuteOfDay(now),
    vibrate: a.vibrate,
    snoozeMinutes: a.snoozeMinutes,
    snoozeLimit: a.snoozeLimit,
    challenge: a.challenge.name,
  );
}
