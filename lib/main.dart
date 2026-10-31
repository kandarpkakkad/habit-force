import 'package:flutter/material.dart';

import 'app/boot.dart';
import 'app/scope.dart';
import 'app/services.dart';
import 'ui/shell/shell.dart';
import 'ui/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await boot();
  runApp(HabitForceApp(services: services));
}

class HabitForceApp extends StatefulWidget {
  final Services services;

  const HabitForceApp({super.key, required this.services});

  @override
  State<HabitForceApp> createState() => _HabitForceAppState();
}

class _HabitForceAppState extends State<HabitForceApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.services.refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Every resume moves the plan's horizon forward (D9) and picks up what
    // happened while the app was closed.
    if (state == AppLifecycleState.resumed) widget.services.refresh();
  }

  @override
  Widget build(BuildContext context) => AppScope(
        services: widget.services,
        child: MaterialApp(
          title: 'Habit Force',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          home: const Shell(),
        ),
      );
}
