import 'dart:convert';

import '../../common/dates.dart';
import 'plan.dart';

/// Plan → the JSON Kotlin parses. One-way: Kotlin keeps the file and Dart
/// never reads it back (docs/01-platform/bridge/hld.md).
class PlanCodec {
  static String encode(Plan plan) => jsonEncode(toJson(plan));

  static Map<String, Object> toJson(Plan plan) => {
        'version': Plan.version,
        'generatedAt': plan.generatedAt,
        'firstDate': isoDate(plan.firstDate),
        'horizon': isoDate(plan.horizon),
        'settings': {
          'headsUpMinutes': plan.settings.headsUpMinutes,
          'pauseMinutes': plan.settings.pauseMinutes,
          'pauseCooldownSeconds': plan.settings.pauseCooldownSeconds,
          'pausePhrase': plan.settings.pausePhrase,
        },
        'windows': [for (final w in plan.windows) windowJson(w)],
        'alarms': [for (final a in plan.alarms) alarmJson(a)],
      };

  static Map<String, Object> windowJson(PlanWindow w) => {
        'key': w.key,
        'habitId': w.habitId,
        'name': w.name,
        'hard': w.hard,
        'priority': w.priority,
        'dnd': w.dnd,
        'date': isoDate(w.date),
        'start': w.start,
        'end': w.end,
        'apps': [
          for (final a in w.apps) {'package': a.package, 'label': a.label},
        ],
      };

  static Map<String, Object> alarmJson(PlanAlarm a) => {
        'key': a.key,
        'alarmIds': a.alarmIds,
        'label': a.label,
        'date': isoDate(a.date),
        'minute': a.minute,
        'vibrate': a.vibrate,
        'snoozeMinutes': a.snoozeMinutes,
        'snoozeLimit': a.snoozeLimit,
        'challenge': a.challenge,
      };

  static String encodeAlarm(PlanAlarm a) => jsonEncode(alarmJson(a));
}
