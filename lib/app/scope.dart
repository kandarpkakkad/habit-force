import 'package:flutter/widgets.dart';

import 'services.dart';

class AppScope extends InheritedWidget {
  final Services services;

  const AppScope({super.key, required this.services, required super.child});

  static Services of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.services;

  @override
  bool updateShouldNotify(AppScope oldWidget) => services != oldWidget.services;
}
