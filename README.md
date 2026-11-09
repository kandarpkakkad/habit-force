<img src="branding/logo-512.png" alt="Habit Force logo: an alarm clock whose hands form a check mark" width="96">

# Habit Force

Habits that hold, alarms that ring. You write down your routine — *learning
21:00–22:00 on weekdays, sleep at 23:00* — and while a habit runs, the apps you
named stop opening. Alarms ring like a clock app's, and are harder to wave away.

Android 16+ only. Flutter 3.38 with a native Kotlin half. Offline: no server, no
account, no sync, no backup, and no `INTERNET` permission in release.

---

## What it does

**Habits.** Days of the week, a start and an end (crossing midnight is fine),
hard or soft, a priority among soft habits, the apps to block, and optionally Do
Not Disturb.

**Overlaps, settled when you save.** Two hard habits cannot overlap. A soft habit
gives way to a hard one — including a buffer before it, so *learning* cannot run
into *sleep* — and to a soft habit of higher priority. The app offers to shift or
trim whichever habit gives way, even if it is not the one you are editing.

**Blocking.** While a window runs, a blocked app is sent to the home screen and a
block screen says why. Pausing is possible, slowly: a wait, a typed sentence, a
few minutes, and a line in History.

**Alarms.** At a clock time or relative to a habit's start or end. Over the lock
screen, at alarm volume, through Do Not Disturb. Dismissing takes a sum or a typed
sentence if you want it to; snoozes are limited.

**History.** Streaks per habit, and the last two weeks: windows run, apps sent
away, pauses, alarms answered and missed.

## How it is built

```
lib/                      Flutter: screens, habits, overlaps, the planner, SQLite
android/app/src/main/kotlin/
                          Kotlin: accessibility blocker, exact alarms, ringing,
                          notifications, Do Not Disturb
```

The two halves meet in two files and one channel. Dart writes a **plan** — the
next 14 days of windows and alarms, as dates and minutes. Kotlin appends
**events** — what happened — for Dart to collect. Kotlin never opens the
database and never decides what a habit means.

Start with [`docs/README.md`](docs/README.md), then the
[PRD](docs/PRD.md) and the [decisions](docs/00-overview/decisions.md).
[`AGENTS.md`](AGENTS.md) is how work is done here.

## Running it

No Flutter needed on the machine, only Docker:

```bash
tool/test_in_docker.sh      # flutter analyze + flutter test
tool/build_in_docker.sh     # debug APKs in build/docker/, plus the Kotlin unit tests
```

Installing and checking it on a phone: [`.claude/skills/run-habit-force/SKILL.md`](.claude/skills/run-habit-force/SKILL.md).

## Status

Everything in the PRD is written. The engines are unit tested. **Nothing native
has been run on a phone yet** — see the table in [`docs/README.md`](docs/README.md).

## Licence

MIT — see [`LICENSE`](LICENSE).
