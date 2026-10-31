import '../../common/dates.dart';
import '../../platform/storage/database.dart';

enum AlarmAnchor {
  clock('clock'),
  habitStart('habit_start'),
  habitEnd('habit_end');

  final String db;
  const AlarmAnchor(this.db);

  static AlarmAnchor fromDb(String s) => values.firstWhere((a) => a.db == s);
}

/// Ordered from easiest to hardest: merging keeps the hardest (D15).
enum Challenge { none, sum, phrase }

class Alarm {
  final String id;
  final String label;
  final AlarmAnchor anchor;
  final String? habitId;

  /// Clock alarms only.
  final int? minute;

  /// Habit-tied alarms only. Negative = before.
  final int offsetMinutes;

  /// Clock alarms only. 0 = once, on [onceDate].
  final int days;
  final DateTime? onceDate;
  final bool enabled;
  final bool vibrate;
  final int snoozeMinutes;
  final int snoozeLimit;
  final Challenge challenge;
  final DateTime createdAt;

  const Alarm({
    required this.id,
    this.label = '',
    required this.anchor,
    this.habitId,
    this.minute,
    this.offsetMinutes = 0,
    this.days = 0,
    this.onceDate,
    this.enabled = true,
    this.vibrate = true,
    this.snoozeMinutes = 5,
    this.snoozeLimit = 2,
    this.challenge = Challenge.sum,
    required this.createdAt,
  });

  bool get isClock => anchor == AlarmAnchor.clock;
  bool get isOnce => isClock && days == 0;

  /// A once alarm whose day has gone. Not planned; listed as done.
  bool isDone(DateTime today) => isOnce && onceDate != null && onceDate!.isBefore(dateOnly(today));

  factory Alarm.fromRow(AlarmRow r) => Alarm(
        id: r.id,
        label: r.label,
        anchor: AlarmAnchor.fromDb(r.anchor),
        habitId: r.habitId,
        minute: r.minute,
        offsetMinutes: r.offsetMinutes,
        days: r.days,
        onceDate: r.onceDate == null ? null : parseIsoDate(r.onceDate!),
        enabled: r.enabled,
        vibrate: r.vibrate,
        snoozeMinutes: r.snoozeMinutes,
        snoozeLimit: r.snoozeLimit,
        challenge: Challenge.values.byName(r.challenge),
        createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt),
      );

  Alarm copyWith({
    String? label,
    AlarmAnchor? anchor,
    int? minute,
    int? offsetMinutes,
    int? days,
    DateTime? onceDate,
    bool? enabled,
    bool? vibrate,
    int? snoozeMinutes,
    int? snoozeLimit,
    Challenge? challenge,
  }) =>
      Alarm(
        id: id,
        label: label ?? this.label,
        anchor: anchor ?? this.anchor,
        habitId: habitId,
        minute: minute ?? this.minute,
        offsetMinutes: offsetMinutes ?? this.offsetMinutes,
        days: days ?? this.days,
        onceDate: onceDate ?? this.onceDate,
        enabled: enabled ?? this.enabled,
        vibrate: vibrate ?? this.vibrate,
        snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
        snoozeLimit: snoozeLimit ?? this.snoozeLimit,
        challenge: challenge ?? this.challenge,
        createdAt: createdAt,
      );
}

/// The date a once alarm will ring: today if its minute is still ahead,
/// otherwise tomorrow. Strictly ahead — an alarm set at 07:00 for 07:00 is
/// for tomorrow, not for the minute already going (docs/02-domain/alarms/lld.md §1).
DateTime onceDateFor(int minute, DateTime now) =>
    minute > minuteOfDay(now) ? dateOnly(now) : addDays(dateOnly(now), 1);

Map<String, String> validateAlarm(Alarm a) => {
      if (a.label.trim().length > 40) 'label': 'Keep the label under 40 characters',
      if (a.isClock && a.minute == null) 'time': 'Pick a time',
      if (!a.isClock && (a.offsetMinutes < -180 || a.offsetMinutes > 180))
        'offset': 'Up to 3 hours either way',
      if (a.snoozeMinutes < 1 || a.snoozeMinutes > 30) 'snooze': 'Between 1 and 30 minutes',
      if (a.snoozeLimit < 0 || a.snoozeLimit > 10) 'snoozeLimit': 'Between 0 and 10 times',
    };
