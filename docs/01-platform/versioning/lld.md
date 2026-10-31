# Versioning — LLD

## 1. The two places

```yaml
# pubspec.yaml
version: 0.1.0+1
```

```dart
// lib/platform/versioning/version.dart
const String kAppVersion = '0.1.0';
const int kAppBuild = 1;
```

## 2. Moving them

`tool/bump_version.sh patch | minor | major | set x.y.z` — reads `pubspec.yaml`, moves the
semver, **always** increments the build number, writes both files with `perl -pi`, then greps
both to prove the edit landed, and prints the new version.

## 3. The guard

`test/platform/version_test.dart` reads `pubspec.yaml` and fails if its version or build
differs from the constants.

## 4. Where it shows

Settings, last row: *Habit Force 0.1.0 (1)*.
