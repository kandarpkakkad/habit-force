# Versioning — HLD

What version this is, kept in step in the two places that say it.

## Purpose

Every APK names its version, and the app agrees with its own file name.

## Owns

| File | Holds |
|---|---|
| `pubspec.yaml` | `version: x.y.z+build` — what Gradle stamps into the APK |
| `lib/platform/versioning/version.dart` | `kAppVersion`, `kAppBuild` — what Settings shows |

## Key decisions

**They move together or not at all.** `tool/bump_version.sh` edits both and proves the edit
landed. A test fails the build if they disagree.

**Every push to `main` bumps the patch; a release bumps the minor.** The same pipeline as
little-loaf, minus its update gate.

**The build number only goes up.** Android refuses an update whose `versionCode` is not
higher than the installed one.

## Non-goals

- An update check. There is no network (D1). A new version is fetched from GitHub Releases
  by hand.
- A minimum-supported version. One phone, one install, nothing to lock out.
