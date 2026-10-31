import 'package:flutter_test/flutter_test.dart';
import 'package:habit_force/common/dates.dart';
import 'package:habit_force/domain/alarms/alarm.dart';
import 'package:habit_force/domain/schedule/planner.dart';
import 'package:habit_force/domain/settings/settings.dart';

import '../support/support.dart';

// docs/02-domain/schedule/lld.md §3 and §6.

Alarm clockAlarm(String id, int minute,
        {int days = kEveryDay, DateTime? once, Challenge challenge = Challenge.sum, int limit = 2, int created = 0}) =>
    Alarm(
      id: id,
      anchor: AlarmAnchor.clock,
      minute: minute,
      days: once == null ? days : 0,
      onceDate: once,
      challenge: challenge,
      snoozeLimit: limit,
      createdAt: DateTime.fromMillisecondsSinceEpoch(created),
    );

void main() {
  final today = thisMonday();

  test('a window crossing midnight is planned from yesterday too', () {
    final plan = buildPlan(
      habits: [habit('sleep', start: '23:00', end: '06:30')],
      alarms: const [],
      settings: AppSettings.defaults,
      today: today,
      generatedAt: 0,
    );
    expect(plan.windows.first.date, addDays(today, -1));
    expect(plan.windows.first.end, 1440 + 390);
    expect(plan.windows, hasLength(15));
    expect(plan.horizon, addDays(today, kHorizonDays));
  });

  test("yesterday's window that finished before midnight is left out", () {
    final plan = buildPlan(
      habits: [habit('learning', start: '21:00', end: '22:00')],
      alarms: const [],
      settings: AppSettings.defaults,
      today: today,
      generatedAt: 0,
    );
    expect(plan.windows.first.date, today);
    expect(plan.windows, hasLength(14));
  });

  test('only the days the habit starts on', () {
    final plan = buildPlan(
      habits: [habit('gym', start: '07:00', end: '08:00', days: dayMask([0, 2]))],
      alarms: const [],
      settings: AppSettings.defaults,
      today: today,
      generatedAt: 0,
    );
    expect(plan.windows.map((w) => weekdayIndex(w.date)).toSet(), {0, 2});
    expect(plan.windows, hasLength(4));
  });

  test('a habit alarm 30 minutes before a 00:10 start rings at 23:40 the day before', () {
    final plan = buildPlan(
      habits: [habit('early', start: '00:10', end: '01:00', name: 'Early')],
      alarms: [
        Alarm(
          id: 'a',
          anchor: AlarmAnchor.habitStart,
          habitId: 'early',
          offsetMinutes: -30,
          createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        ),
      ],
      settings: AppSettings.defaults,
      today: today,
      generatedAt: 0,
    );
    // Today's 00:10 window would want 23:40 yesterday — before the plan starts.
    final first = plan.alarms.first;
    expect(first.date, today);
    expect(first.minute, 23 * 60 + 40);
    expect(first.label, 'Early starts at 00:10');
  });

  test('two alarms in one minute ring once, with the hardest challenge and fewest snoozes (D15)', () {
    final plan = buildPlan(
      habits: const [],
      alarms: [
        clockAlarm('a', 390, challenge: Challenge.sum, limit: 3, created: 1),
        clockAlarm('b', 390, challenge: Challenge.phrase, limit: 1, created: 2),
      ],
      settings: AppSettings.defaults,
      today: today,
      generatedAt: 0,
    );
    expect(plan.alarms, hasLength(14));
    final e = plan.alarms.first;
    expect(e.alarmIds, ['a', 'b']);
    expect(e.challenge, 'phrase');
    expect(e.snoozeLimit, 1);
  });

  test('a once alarm is planned only on its date, and only inside the horizon', () {
    final inside = buildPlan(
      habits: const [],
      alarms: [clockAlarm('a', 420, once: addDays(today, 3))],
      settings: AppSettings.defaults,
      today: today,
      generatedAt: 0,
    );
    expect(inside.alarms.single.date, addDays(today, 3));

    final past = buildPlan(
      habits: const [],
      alarms: [clockAlarm('a', 420, once: addDays(today, -1))],
      settings: AppSettings.defaults,
      today: today,
      generatedAt: 0,
    );
    expect(past.alarms, isEmpty);
  });

  test("a disabled habit's alarms drop out with its windows", () {
    final plan = buildPlan(
      habits: [habit('learning', start: '21:00', end: '22:00', enabled: false)],
      alarms: [
        Alarm(
          id: 'a',
          anchor: AlarmAnchor.habitEnd,
          habitId: 'learning',
          createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        ),
      ],
      settings: AppSettings.defaults,
      today: today,
      generatedAt: 0,
    );
    expect(plan.windows, isEmpty);
    expect(plan.alarms, isEmpty);
  });

  test('onceDateFor is strictly ahead', () {
    final at = DateTime(today.year, today.month, today.day, 7);
    expect(onceDateFor(7 * 60, at), addDays(today, 1));
    expect(onceDateFor(7 * 60 + 1, at), today);
    expect(onceDateFor(6 * 60, at), addDays(today, 1));
  });
}
