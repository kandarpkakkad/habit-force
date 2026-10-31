import 'package:flutter/material.dart';

/// A steady blue: neither alarm-red nor reward-green
/// (docs/03-frontend/design-system.md §1).
const kSeed = Color(0xFF2E5BBA);

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: kSeed, brightness: brightness);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    inputDecorationTheme: InputDecorationTheme(
      border: const OutlineInputBorder(),
      // A hint is guidance, not content: styled so it never reads as
      // something already typed (design-system §4).
      hintStyle: TextStyle(color: scheme.onSurfaceVariant.withValues(alpha: 0.6)),
    ),
  );
}

/// Tabular figures, so a column of times lines up and a countdown does not
/// jitter (design-system §2).
TextStyle? times(TextStyle? base) =>
    base?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
