import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_force/common/dates.dart';
import 'package:habit_force/domain/habits/habit.dart';
import 'package:habit_force/domain/schedule/planner.dart';
import 'package:habit_force/domain/settings/settings.dart';
import 'package:habit_force/platform/bridge/plan_codec.dart';

import '../support/support.dart';

// Field names and types exactly as docs/01-platform/bridge/schema.md, which is
// what Kotlin's Plan.parse reads.

void main() {
  test('plan JSON matches the bridge schema', () {
    final today = thisMonday();
    final plan = buildPlan(
      habits: [
        habit('h', start: '21:00', end: '22:00', name: 'Learning', apps: const [
          BlockedApp('com.instagram.android', 'Instagram'),
        ]),
      ],
      alarms: const [],
      settings: AppSettings.defaults,
      today: today,
      generatedAt: 42,
    );
    final json = jsonDecode(PlanCodec.encode(plan)) as Map<String, Object?>;

    expect(json['version'], 1);
    expect(json['generatedAt'], 42);
    expect(json['firstDate'], isoDate(addDays(today, -1)));
    expect(json['horizon'], isoDate(addDays(today, 13)));
    expect((json['settings'] as Map)['pausePhrase'], AppSettings.defaults.pausePhrase);

    final w = (json['windows'] as List).first as Map;
    expect(w['key'], 'h@${isoDate(today)}');
    expect(w['hard'], isFalse);
    expect(w['start'], 1260);
    expect(w['end'], 1320);
    expect(w['date'], isoDate(today));
    expect(w['apps'], [
      {'package': 'com.instagram.android', 'label': 'Instagram'},
    ]);
  });
}
