import 'dart:convert';

import 'package:flutter/services.dart';

import 'plan.dart';
import 'plan_codec.dart';

/// A native call that failed. [message] is the native exception's own text —
/// it goes on screen, because "could not save" with the reason thrown away is
/// an afternoon lost (AGENTS.md §2).
class BridgeException implements Exception {
  final String code;
  final String? message;

  const BridgeException(this.code, this.message);

  @override
  String toString() => message == null || message!.isEmpty ? code : '$message ($code)';
}

class InstallResult {
  final int windows;
  final int alarms;

  const InstallResult(this.windows, this.alarms);
}

enum PlanState { ok, missing, unreadable, expired }

class PlanStatus {
  final PlanState state;
  final String? horizon;
  final String? error;

  const PlanStatus(this.state, {this.horizon, this.error});
}

class EventBatch {
  final List<Map<String, Object?>> events;

  /// Lines that did not parse. Acknowledged so they leave the file
  /// (docs/02-domain/history/lld.md §1).
  final List<String> torn;

  const EventBatch(this.events, this.torn);
}

class InstalledApp {
  final String package;
  final String label;

  const InstalledApp(this.package, this.label);
}

/// Everything Dart asks of Kotlin. Contract: docs/01-platform/bridge/lld.md §1.
abstract class NativeBridge {
  Future<InstallResult> installPlan(Plan plan);
  Future<PlanStatus> planStatus();
  Future<EventBatch> readEvents();
  Future<int> ackEvents({required List<String> ids, required List<String> torn});
  Future<List<InstalledApp>> listApps();
  Future<Map<String, bool>> permissionStatus();
  Future<void> openPermission(String key);
  Future<void> openAppInfo();
  Future<DateTime> testAlarm(PlanAlarm entry);
}

class ChannelNativeBridge implements NativeBridge {
  static const _channel = MethodChannel('habit_force/native');

  Future<T?> _call<T>(String method, [Object? args]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on PlatformException catch (e) {
      throw BridgeException(e.code, e.message);
    } on MissingPluginException catch (e) {
      throw BridgeException('no_native_side', e.message);
    }
  }

  @override
  Future<InstallResult> installPlan(Plan plan) async {
    final r = await _call<Map<Object?, Object?>>('installPlan', PlanCodec.encode(plan));
    return InstallResult(r?['windows'] as int? ?? 0, r?['alarms'] as int? ?? 0);
  }

  @override
  Future<PlanStatus> planStatus() async {
    final r = await _call<Map<Object?, Object?>>('planStatus') ?? const {};
    final state = PlanState.values.firstWhere(
      (s) => s.name == r['state'],
      orElse: () => PlanState.unreadable,
    );
    return PlanStatus(state, horizon: r['horizon'] as String?, error: r['error'] as String?);
  }

  @override
  Future<EventBatch> readEvents() async {
    final r = await _call<Map<Object?, Object?>>('readEvents') ?? const {};
    final events = <Map<String, Object?>>[];
    final torn = <String>[...((r['torn'] as List?) ?? const []).cast<String>()];
    for (final line in ((r['events'] as List?) ?? const []).cast<String>()) {
      try {
        events.add((jsonDecode(line) as Map).cast<String, Object?>());
      } on FormatException {
        torn.add(line);
      }
    }
    return EventBatch(events, torn);
  }

  @override
  Future<int> ackEvents({required List<String> ids, required List<String> torn}) async =>
      await _call<int>('ackEvents', {'ids': ids, 'torn': torn}) ?? 0;

  @override
  Future<List<InstalledApp>> listApps() async {
    final r = await _call<List<Object?>>('listApps') ?? const [];
    return [
      for (final m in r.cast<Map<Object?, Object?>>())
        InstalledApp(m['package'] as String, m['label'] as String),
    ];
  }

  @override
  Future<Map<String, bool>> permissionStatus() async {
    final r = await _call<Map<Object?, Object?>>('permissionStatus') ?? const {};
    return {for (final e in r.entries) e.key as String: e.value == true};
  }

  @override
  Future<void> openPermission(String key) => _call<void>('openPermission', key);

  @override
  Future<void> openAppInfo() => _call<void>('openAppInfo');

  @override
  Future<DateTime> testAlarm(PlanAlarm entry) async {
    final at = await _call<int>('testAlarm', PlanCodec.encodeAlarm(entry));
    return DateTime.fromMillisecondsSinceEpoch(at ?? 0);
  }
}
