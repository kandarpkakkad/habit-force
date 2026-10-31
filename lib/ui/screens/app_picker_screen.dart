import 'package:flutter/material.dart';

import '../../app/scope.dart';
import '../../domain/habits/habit.dart';
import '../../platform/bridge/native_bridge.dart';
import '../widgets/widgets.dart';

/// S6 — choose the apps a habit blocks. Apps the blocker never blocks are not
/// offered at all (docs/02-domain/habits/lld.md §5).
class AppPickerScreen extends StatefulWidget {
  final List<BlockedApp> chosen;

  const AppPickerScreen({super.key, required this.chosen});

  @override
  State<AppPickerScreen> createState() => _AppPickerScreenState();
}

class _AppPickerScreenState extends State<AppPickerScreen> {
  late final Map<String, BlockedApp> _chosen = {for (final a in widget.chosen) a.package: a};
  late final Future<List<InstalledApp>> _apps = AppScope.of(context).bridge.listApps();
  var _query = '';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Blocked apps'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, _chosen.values.toList()),
              child: const Text('Done'),
            ),
          ],
        ),
        body: FutureBuilder<List<InstalledApp>>(
          future: _apps,
          builder: (context, snap) {
            if (snap.hasError) {
              return EmptyState(text: "Couldn't list the apps on this phone: ${snap.error}");
            }
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final q = _query.toLowerCase();
            final installed = {for (final a in snap.data!) a.package};
            final matches = [for (final a in snap.data!) if (a.label.toLowerCase().contains(q)) a];
            // Chosen but no longer installed: still listed, by the label kept
            // when it was chosen, so it can be removed.
            final gone = [
              for (final a in _chosen.values)
                if (!installed.contains(a.package) && a.label.toLowerCase().contains(q)) a,
            ];
            final chosenHere = [for (final a in matches) if (_chosen.containsKey(a.package)) a];
            final rest = [for (final a in matches) if (!_chosen.containsKey(a.package)) a];

            Widget tile(String package, String label, {bool missing = false}) => CheckboxListTile(
                  value: _chosen.containsKey(package),
                  title: Text(label),
                  subtitle: missing ? const Text('Not installed') : null,
                  onChanged: (on) => setState(() {
                    if (on == true) {
                      _chosen[package] = BlockedApp(package, label);
                    } else {
                      _chosen.remove(package);
                    }
                  }),
                );

            return ListView(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search apps'),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              if (chosenHere.isNotEmpty || gone.isNotEmpty) const SectionHeader('Chosen'),
              for (final a in chosenHere) tile(a.package, a.label),
              for (final a in gone) tile(a.package, a.label, missing: true),
              const SectionHeader('All apps'),
              for (final a in rest) tile(a.package, a.label),
            ]);
          },
        ),
      );
}
