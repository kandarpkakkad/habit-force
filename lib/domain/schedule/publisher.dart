import 'package:flutter/foundation.dart';

import '../../platform/bridge/native_bridge.dart';
import '../alarms/alarms_repository.dart';
import '../habits/habits_repository.dart';
import '../settings/settings.dart';
import 'planner.dart';

class PublishState {
  final InstallResult? result;
  final String? error;
  final DateTime at;

  const PublishState({this.result, this.error, required this.at});

  bool get ok => error == null;
}

/// Rebuilds the plan from the database and hands it to Kotlin — after every
/// write, on launch, on resume. Never patched, always whole
/// (docs/02-domain/schedule/lld.md §4).
class PlanPublisher {
  final HabitsRepository habits;
  final AlarmsRepository alarms;
  final SettingsRepository settings;
  final NativeBridge bridge;

  /// The last outcome. Today shows the error, if there is one; the previous
  /// plan stays in force in the meantime.
  final ValueNotifier<PublishState?> state = ValueNotifier(null);

  PlanPublisher({
    required this.habits,
    required this.alarms,
    required this.settings,
    required this.bridge,
  });

  /// Never throws: a write has already committed by the time this runs, and a
  /// failure to hand the plan over must not make the save look failed.
  Future<void> publish({DateTime? now}) async {
    final when = now ?? DateTime.now();
    try {
      final plan = buildPlan(
        habits: await habits.loadAll(),
        alarms: await alarms.loadAll(),
        settings: await settings.get(),
        today: when,
        generatedAt: when.millisecondsSinceEpoch,
      );
      final result = await bridge.installPlan(plan);
      state.value = PublishState(result: result, at: when);
    } on BridgeException catch (e) {
      state.value = PublishState(error: e.toString(), at: when);
    }
  }
}
