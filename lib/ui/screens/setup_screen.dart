import 'package:flutter/material.dart';

import '../../app/scope.dart';
import '../../platform/bridge/native_bridge.dart';
import '../../platform/permissions/permissions.dart';
import '../widgets/widgets.dart';

/// S8 — the six permissions, required first. Re-read on every resume by the
/// app; the rows update themselves.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppScope.of(context).permissions.refresh();
  }

  Future<void> _run(Future<void> Function() open) async {
    try {
      await open();
    } on BridgeException catch (e) {
      if (mounted) say(context, "Couldn't open that settings page: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = AppScope.of(context).permissions;
    final t = Theme.of(context).textTheme;
    final keys = [
      ...PermissionKey.values.where((k) => k.required),
      ...PermissionKey.values.where((k) => !k.required),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Setup')),
      body: ListenableBuilder(
        listenable: p,
        builder: (context, _) => ListView(padding: const EdgeInsets.only(bottom: 24), children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Habit Force needs these to work while it is closed.', style: t.bodyLarge),
          ),
          if (p.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text("Couldn't read permissions: ${p.error}"),
            ),
          for (final k in keys) _row(context, p, k),
        ]),
      ),
    );
  }

  Widget _row(BuildContext context, PermissionsController p, PermissionKey k) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final granted = p.status?[k];
    final icon = granted == true
        ? Icon(Icons.check_circle, color: c.primary)
        : Icon(k.required ? Icons.error : Icons.warning_amber_rounded,
            color: k.required ? c.error : Colors.amber.shade700);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            icon,
            const SizedBox(width: 12),
            Expanded(child: Text(k.title, style: t.titleMedium)),
            if (k.required) Text('Required', style: t.labelSmall),
          ]),
          const SizedBox(height: 8),
          Text(k.why),
          if (granted == false) ...[
            const SizedBox(height: 4),
            Text('Without it: ${k.without}', style: t.bodySmall),
          ],
          if (k == PermissionKey.accessibility && granted != true) ...[
            const SizedBox(height: 8),
            // The step everyone gets stuck on (docs/01-platform/permissions/lld.md §1).
            Text(
              'On Android 13 and later, the switch is greyed out for apps installed from outside '
              'the Play Store. Open App info, tap ⋮, choose Allow restricted settings, then come back.',
              style: t.bodySmall,
            ),
          ],
          if (granted != true) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: [
              FilledButton(onPressed: () => _run(() => p.open(k)), child: const Text('Open settings')),
              if (k == PermissionKey.accessibility)
                OutlinedButton(onPressed: () => _run(p.openAppInfo), child: const Text('App info')),
            ]),
          ],
        ]),
      ),
    );
  }
}
