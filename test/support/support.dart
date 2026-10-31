import 'package:habit_force/common/clock_time.dart';
import 'package:habit_force/common/dates.dart';
import 'package:habit_force/domain/habits/habit.dart';
import 'package:habit_force/platform/bridge/native_bridge.dart';
import 'package:habit_force/platform/bridge/plan.dart';

/// `'21:30'` → ClockTime.
ClockTime t(String hm) => ClockTime.hm(int.parse(hm.substring(0, 2)), int.parse(hm.substring(3, 5)));

/// The Monday of this week. Tests that care about weekdays count from here,
/// so no test mints a literal date that rots (AGENTS.md §2, *Times*).
DateTime thisMonday() {
  final today = dateOnly(DateTime.now());
  return addDays(today, -weekdayIndex(today));
}

Habit habit(
  String id, {
  required String start,
  required String end,
  int days = kEveryDay,
  bool hard = false,
  int priority = kPriorityNormal,
  bool enabled = true,
  List<BlockedApp> apps = const [],
  String? name,
}) =>
    Habit(
      id: id,
      name: name ?? id,
      days: days,
      start: t(start),
      end: t(end),
      strictness: hard ? Strictness.hard : Strictness.soft,
      priority: priority,
      enabled: enabled,
      apps: apps,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    );

int dayMask(List<int> indexes) => indexes.fold(0, (m, i) => m | (1 << i));

/// Records what Dart asked of Kotlin.
class FakeNativeBridge implements NativeBridge {
  final installed = <Plan>[];
  List<Map<String, Object?>> pendingEvents = [];
  List<String> pendingTorn = [];
  final acked = <String>[];

  @override
  Future<InstallResult> installPlan(Plan plan) async {
    installed.add(plan);
    return InstallResult(plan.windows.length, plan.alarms.length);
  }

  @override
  Future<PlanStatus> planStatus() async => const PlanStatus(PlanState.ok);

  @override
  Future<EventBatch> readEvents() async => EventBatch(pendingEvents, pendingTorn);

  @override
  Future<int> ackEvents({required List<String> ids, required List<String> torn}) async {
    acked.addAll(ids);
    pendingEvents = [for (final e in pendingEvents) if (!ids.contains(e['id'])) e];
    pendingTorn = [for (final l in pendingTorn) if (!torn.contains(l)) l];
    return ids.length + torn.length;
  }

  @override
  Future<List<InstalledApp>> listApps() async => const [];

  @override
  Future<Map<String, bool>> permissionStatus() async => const {};

  @override
  Future<void> openPermission(String key) async {}

  @override
  Future<void> openAppInfo() async {}

  @override
  Future<DateTime> testAlarm(PlanAlarm entry) async => DateTime.now();
}
