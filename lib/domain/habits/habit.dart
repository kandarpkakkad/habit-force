import '../../common/clock_time.dart';
import '../../platform/storage/database.dart';

enum Strictness { hard, soft }

class BlockedApp {
  final String package;

  /// The app's name when it was chosen, so an uninstalled app still reads as
  /// a name (docs/02-domain/habits/hld.md).
  final String label;

  const BlockedApp(this.package, this.label);

  @override
  bool operator ==(Object other) => other is BlockedApp && other.package == package;

  @override
  int get hashCode => package.hashCode;
}

const kPriorityLow = 1;
const kPriorityNormal = 2;
const kPriorityHigh = 3;

class Habit {
  final String id;
  final String name;

  /// Days the window **starts** on. Monday = bit 0.
  final int days;
  final ClockTime start;
  final ClockTime end;
  final Strictness strictness;

  /// 1 low · 2 normal · 3 high. Read only for soft habits.
  final int priority;
  final bool dnd;
  final bool enabled;
  final List<BlockedApp> apps;
  final DateTime createdAt;
  final DateTime? archivedAt;

  const Habit({
    required this.id,
    required this.name,
    required this.days,
    required this.start,
    required this.end,
    required this.strictness,
    this.priority = kPriorityNormal,
    this.dnd = false,
    this.enabled = true,
    this.apps = const [],
    required this.createdAt,
    this.archivedAt,
  });

  bool get hard => strictness == Strictness.hard;
  bool get crossesMidnight => end.minutes < start.minutes;
  bool get active => enabled && archivedAt == null;

  /// 1..1439. Never 0: `end == start` is refused (CHECK).
  int get duration => (end.minutes - start.minutes + kDay) % kDay;

  factory Habit.fromRows(HabitRow r, Iterable<HabitAppRow> apps) => Habit(
        id: r.id,
        name: r.name,
        days: r.days,
        start: ClockTime(r.startMinute),
        end: ClockTime(r.endMinute),
        strictness: r.strictness == 'hard' ? Strictness.hard : Strictness.soft,
        priority: r.priority,
        dnd: r.dnd,
        enabled: r.enabled,
        apps: [for (final a in apps) BlockedApp(a.package, a.label)],
        createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt),
        archivedAt: r.archivedAt == null ? null : DateTime.fromMillisecondsSinceEpoch(r.archivedAt!),
      );

  Habit copyWith({
    String? name,
    int? days,
    ClockTime? start,
    ClockTime? end,
    Strictness? strictness,
    int? priority,
    bool? dnd,
    bool? enabled,
    List<BlockedApp>? apps,
    DateTime? archivedAt,
  }) =>
      Habit(
        id: id,
        name: name ?? this.name,
        days: days ?? this.days,
        start: start ?? this.start,
        end: end ?? this.end,
        strictness: strictness ?? this.strictness,
        priority: priority ?? this.priority,
        dnd: dnd ?? this.dnd,
        enabled: enabled ?? this.enabled,
        apps: apps ?? this.apps,
        createdAt: createdAt,
        archivedAt: archivedAt ?? this.archivedAt,
      );
}

/// Field → message. Every failing field at once, so the editor can mark them
/// all (docs/02-domain/habits/lld.md §2).
Map<String, String> validateHabit(Habit h) {
  final name = h.name.trim();
  return {
    if (name.isEmpty) 'name': 'Give the habit a name',
    if (name.length > 40) 'name': 'Keep the name under 40 characters',
    if (h.days == 0) 'days': 'Pick at least one day',
    if (h.start == h.end) 'time': "Start and end can't be the same time",
  };
}
