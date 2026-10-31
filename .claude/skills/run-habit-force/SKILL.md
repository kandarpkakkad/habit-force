---
name: run-habit-force
description: Test, build, install and check Habit Force (Flutter + native Kotlin, Android 16+) from this Windows machine, which has Docker but no Flutter, Java or Android SDK installed. Use when asked to run the tests, build the APK, install it on a phone, check that the blocker or alarms are armed, or read what the app has written on the device.
---

# Running Habit Force

## The facts everything depends on

| | |
|---|---|
| Project | `C:\Users\DELL\Downloads\Github\habit-force` |
| Host | Windows 11, Git Bash. **No Flutter, Java or Android SDK on the host** |
| Toolchain | Docker image `instrumentisto/flutter:3.38.10` — Flutter, Java 21, Android SDK 36 |
| Package | `com.habitforce.habit_force` (release), `com.habitforce.habit_force.debug` (debug) |
| Device | A real Android 16 phone. **No emulator is set up on this machine** |

Everything that needs Flutter runs in a throwaway container defined in
`docker-compose.test.yml`. The source is copied in, never run in place, so the
container cannot write Linux paths into the checkout.

**Every script is time-limited** — 20 minutes for tests and codegen, 60 for the
build. When the limit hits, the container is killed and removed and the script
exits 124. Raise it for one run with `HABIT_FORCE_TIMEOUT=90m tool/build_in_docker.sh`.
Any wait you write yourself is bounded too: `timeout 1500 bash -c 'until …; do sleep 5; done'`.

## Test

```bash
cd /c/Users/DELL/Downloads/Github/habit-force
tool/test_in_docker.sh
```

`flutter analyze` then `flutter test`. Both must be clean. About a minute once
the pub cache volume is warm.

## Regenerate drift code

After any change to `lib/platform/storage/tables.dart`:

```bash
tool/codegen_in_docker.sh
```

Copies back only `lib/**/*.g.dart` and `pubspec.lock`.

## Build the APK (and run the Kotlin unit tests)

```bash
tool/build_in_docker.sh
```

Builds `--debug --split-per-abi`, runs `:app:testDebugUnitTest`, and copies the
APKs to `build/docker/`:

- `habit-force-debug-arm64.apk` — for the phone
- `habit-force-debug-x86_64.apk` — for an emulator, if one is ever set up

The first run downloads Gradle and the Android dependencies into the
`gradle-home` volume and takes several minutes. Run it in the background and wait
for it to finish rather than polling.

**This is the only check that the Kotlin compiles.** It proves nothing about how
the native half behaves on a device.

## Install on a phone

`adb` is not installed. One-time:

```powershell
winget install Google.PlatformTools
```

Then, with USB debugging on and the phone connected:

```bash
adb devices                                   # must list the phone as "device"
adb install -r build/docker/habit-force-debug-arm64.apk
adb shell monkey -p com.habitforce.habit_force.debug -c android.intent.category.LAUNCHER 1
```

`install -r` over an earlier debug build only works if both were signed with
the same key. A local Docker build uses the container's own debug key, CI uses
the pinned one — **switching between them needs an uninstall, and an uninstall
deletes every habit** (D2: no backup).

## Granting the blocker on a side-loaded build

Android 13+ greys out the accessibility switch for apps not installed from the
Play Store. On the phone: **Settings → Apps → Habit Force debug → ⋮ → Allow
restricted settings**, then **Accessibility → Habit Force blocker → On**. The
app's Setup screen says the same.

Over adb, for a test phone only:

```bash
adb shell settings put secure enabled_accessibility_services \
  com.habitforce.habit_force.debug/com.habitforce.habit_force.block.BlockerService
adb shell settings put secure accessibility_enabled 1
```

## Check it is actually armed

Debug builds are debuggable, so `run-as` can read the app's private files.

```bash
P=com.habitforce.habit_force.debug

# The plan Kotlin holds (D8: dates and minutes, never instants).
adb shell run-as $P cat files/plan.json

# Events waiting for Dart to collect (D10).
adb shell run-as $P cat files/events.jsonl

# Native state: pause, chain position, DND ownership.
adb shell run-as $P cat shared_prefs/habit_force_native.xml

# The next boundary (request code 200) and the next alarm (100/101/102).
adb shell dumpsys alarm | grep -A3 "$P"

# Is the blocker bound?
adb shell dumpsys accessibility | grep -i habit_force

# Native errors.
adb logcat -d | grep -iE "habit_force|AndroidRuntime" | tail -50
```

## Things that are not bugs

- **"Blocker turned off" then "Blocker turned on" in History after an update.**
  An update unbinds and rebinds the service; both are recorded (blocking LLD §6).
- **No "has started" notification after a reboot mid-window.** Boundaries more
  than two minutes late are dropped on purpose (D18). The window is still
  enforced.
- **Today shows "No schedule has been handed to Android yet"** on a first
  launch before any habit exists. The plan is published once the app is up.

## For an AI running this

- Run `tool/test_in_docker.sh` before calling anything done, and say the number
  of tests.
- Run `tool/build_in_docker.sh` after any Kotlin change. It is slow; run it in
  the background.
- **Never describe device behaviour you have not observed.** Until someone
  records otherwise in `habit-force-device-findings`, nothing native has run on
  a phone.
- Do not `adb uninstall` without asking: it deletes the person's habits and
  history, and there is no backup.
