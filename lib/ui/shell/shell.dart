import 'package:flutter/material.dart';

import '../../app/scope.dart';
import '../screens/alarms_screen.dart';
import '../screens/habits_screen.dart';
import '../screens/history_screen.dart';
import '../screens/setup_screen.dart';
import '../screens/today_screen.dart';

/// Four tabs, each keeping its own scroll position (docs/03-frontend/navigation.md).
class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  var _tab = 0;
  var _setupChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_setupChecked) return;
    _setupChecked = true;
    final s = AppScope.of(context);
    // While there are no habits and something required is missing, Setup goes
    // over Today. The habit count is the only memory of "first launch".
    Future(() async {
      await s.permissions.refresh();
      final habits = await s.habits.loadAll();
      final requiredMissing = s.permissions.missing.any((k) => k.required);
      if (!mounted || habits.isNotEmpty || !requiredMissing) return;
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SetupScreen()));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(
          index: _tab,
          children: const [TodayScreen(), HabitsScreen(), AlarmsScreen(), HistoryScreen()],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.today_outlined), selectedIcon: Icon(Icons.today), label: 'Today'),
            NavigationDestination(icon: Icon(Icons.repeat), label: 'Habits'),
            NavigationDestination(icon: Icon(Icons.alarm_outlined), selectedIcon: Icon(Icons.alarm), label: 'Alarms'),
            NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          ],
        ),
      );
}
