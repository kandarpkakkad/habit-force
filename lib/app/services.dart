import 'package:flutter/foundation.dart';

import '../domain/alarms/alarms_repository.dart';
import '../domain/habits/habits_repository.dart';
import '../domain/history/history.dart';
import '../domain/schedule/publisher.dart';
import '../domain/settings/settings.dart';
import '../platform/bridge/native_bridge.dart';
import '../platform/permissions/permissions.dart';
import '../platform/storage/database.dart';

/// Everything a screen may reach, built once by [boot].
class Services {
  final AppDatabase db;
  final NativeBridge bridge;
  final SettingsRepository settings;
  final HabitsRepository habits;
  final AlarmsRepository alarms;
  final HistoryRepository history;
  final PlanPublisher publisher;
  final PermissionsController permissions;

  /// What Kotlin says about the plan it holds. Today shows anything but ok.
  final ValueNotifier<PlanStatus?> planStatus = ValueNotifier(null);

  /// The last collect, for History's one-time note about unreadable lines.
  final ValueNotifier<CollectResult?> lastCollect = ValueNotifier(null);

  Services({
    required this.db,
    required this.bridge,
    required this.settings,
    required this.habits,
    required this.alarms,
    required this.history,
    required this.publisher,
    required this.permissions,
  });

  factory Services.wire(AppDatabase db, NativeBridge bridge) {
    final settings = SettingsRepository(db);
    final habits = HabitsRepository(db, settings);
    final alarms = AlarmsRepository(db);
    final publisher = PlanPublisher(habits: habits, alarms: alarms, settings: settings, bridge: bridge);
    final services = Services(
      db: db,
      bridge: bridge,
      settings: settings,
      habits: habits,
      alarms: alarms,
      history: HistoryRepository(db, bridge),
      publisher: publisher,
      permissions: PermissionsController(bridge),
    );
    Future<void> changed() async {
      await publisher.publish();
      await services.refreshPlanStatus();
    }

    settings.onChanged = changed;
    habits.onChanged = changed;
    alarms.onChanged = changed;
    return services;
  }

  /// Launch and resume: re-plan (which moves the horizon, D9), collect what
  /// happened while closed, re-read permissions.
  Future<void> refresh() async {
    await publisher.publish();
    await refreshPlanStatus();
    await collect();
    await permissions.refresh();
  }

  Future<void> refreshPlanStatus() async {
    try {
      planStatus.value = await bridge.planStatus();
    } on BridgeException catch (e) {
      planStatus.value = PlanStatus(PlanState.unreadable, error: e.toString());
    }
  }

  Future<void> collect() async {
    try {
      lastCollect.value = await history.collect();
    } on BridgeException {
      // Nothing lost: the events stay in the file for the next collect.
    }
  }
}
