import 'package:flutter/foundation.dart';

import '../bridge/native_bridge.dart';

/// The six things Android must allow. Text and severity:
/// docs/01-platform/permissions/lld.md §1.
enum PermissionKey {
  accessibility(
    required: true,
    title: 'Blocker (accessibility)',
    why: 'Sees which app has opened, so it can send blocked apps away.',
    without: 'Nothing is blocked.',
  ),
  exactAlarms(
    required: true,
    title: 'Alarms & reminders',
    why: 'Starts and ends habits, and rings alarms, on the minute.',
    without: 'Habits start late and alarms may not ring on time.',
  ),
  notifications(
    required: false,
    title: 'Notifications',
    why: 'Says before a habit starts, when it starts and when it ends.',
    without: 'No heads-up, start or end messages.',
  ),
  fullScreen(
    required: false,
    title: 'Full-screen alarms',
    why: 'Shows the alarm over the lock screen.',
    without: 'Alarms ring as a notification, not over the lock screen.',
  ),
  dnd(
    required: false,
    title: 'Do Not Disturb access',
    why: 'Lets a habit turn Do Not Disturb on and off.',
    without: 'The Do Not Disturb switch on habits is ignored.',
  ),
  battery(
    required: false,
    title: 'Unrestricted battery',
    why: 'Keeps the blocker and alarms alive in the background.',
    without: 'Some phones stop the blocker and alarms in the background.',
  );

  final bool required;
  final String title;
  final String why;
  final String without;

  const PermissionKey({
    required this.required,
    required this.title,
    required this.why,
    required this.without,
  });
}

enum Severity { none, optional, required }

/// Holds the last native reading. Re-read on resume; never cached across
/// launches, because a cached grant is how it goes stale.
class PermissionsController extends ChangeNotifier {
  final NativeBridge bridge;

  Map<PermissionKey, bool>? status;
  String? error;

  PermissionsController(this.bridge);

  Future<void> refresh() async {
    try {
      final raw = await bridge.permissionStatus();
      status = {for (final k in PermissionKey.values) k: raw[k.name] ?? false};
      error = null;
    } on BridgeException catch (e) {
      error = e.toString();
    }
    notifyListeners();
  }

  Iterable<PermissionKey> get missing =>
      PermissionKey.values.where((k) => status != null && status![k] == false);

  Severity get severity {
    final m = missing.toList();
    if (m.isEmpty) return Severity.none;
    return m.any((k) => k.required) ? Severity.required : Severity.optional;
  }

  /// Throws [BridgeException] with the reason when no settings page opens.
  Future<void> open(PermissionKey key) => bridge.openPermission(key.name);

  Future<void> openAppInfo() => bridge.openAppInfo();
}
