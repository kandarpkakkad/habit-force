import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_force/platform/versioning/version.dart';

// The two places that hold the version must agree; tool/bump_version.sh moves
// both (docs/01-platform/versioning/lld.md §3).
void main() {
  test('pubspec.yaml and version.dart agree', () {
    final line = File('pubspec.yaml').readAsLinesSync().firstWhere((l) => l.startsWith('version:'));
    final v = line.substring('version:'.length).trim();
    expect(v, '$kAppVersion+$kAppBuild');
  });
}
