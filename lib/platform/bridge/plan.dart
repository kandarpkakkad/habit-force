// The plan Dart hands to Kotlin: dates and minutes, never instants (D8).
// Shapes: docs/01-platform/bridge/schema.md. A field added here is added to
// PlanCodec and to Kotlin's Plan.parse in the same commit (AGENTS.md §2).

class PlanSettings {
  final int headsUpMinutes;
  final int pauseMinutes;
  final int pauseCooldownSeconds;
  final String pausePhrase;

  const PlanSettings({
    required this.headsUpMinutes,
    required this.pauseMinutes,
    required this.pauseCooldownSeconds,
    required this.pausePhrase,
  });
}

class PlanApp {
  final String package;
  final String label;

  const PlanApp(this.package, this.label);
}

class PlanWindow {
  /// `<habitId>@<yyyy-mm-dd>` — the occurrence key events carry too.
  final String key;
  final String habitId;
  final String name;
  final bool hard;
  final int priority;
  final bool dnd;
  final DateTime date;

  /// 0..1439.
  final int start;

  /// `start + 1` … `start + 1439`. Above 1439 means it ends the next day.
  final int end;
  final List<PlanApp> apps;

  const PlanWindow({
    required this.key,
    required this.habitId,
    required this.name,
    required this.hard,
    required this.priority,
    required this.dnd,
    required this.date,
    required this.start,
    required this.end,
    required this.apps,
  });
}

class PlanAlarm {
  /// `<yyyy-mm-dd>@<minute>` — at most one entry per minute (D15).
  final String key;
  final List<String> alarmIds;
  final String label;
  final DateTime date;

  /// 0..1439, already normalised onto [date].
  final int minute;
  final bool vibrate;
  final int snoozeMinutes;
  final int snoozeLimit;

  /// `none`, `sum` or `phrase`.
  final String challenge;

  const PlanAlarm({
    required this.key,
    required this.alarmIds,
    required this.label,
    required this.date,
    required this.minute,
    required this.vibrate,
    required this.snoozeMinutes,
    required this.snoozeLimit,
    required this.challenge,
  });
}

class Plan {
  static const version = 1;

  final int generatedAt;
  final DateTime firstDate;
  final DateTime horizon;
  final PlanSettings settings;
  final List<PlanWindow> windows;
  final List<PlanAlarm> alarms;

  const Plan({
    required this.generatedAt,
    required this.firstDate,
    required this.horizon,
    required this.settings,
    required this.windows,
    required this.alarms,
  });
}
