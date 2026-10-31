# Habit Force — Habits That Hold, Alarms That Ring

**v1.0 · 31 October 2026 · Kandarp Kakkad**
Android 16+ · Flutter with native Kotlin · SQLite on the phone · no server, no sync, no backup

> **This describes the app as designed for v1.** Where the code has to depart from it, the
> code wins and the reason goes in [`00-overview/decisions.md`](00-overview/decisions.md) —
> numbered D1…Dn and cited from the code. Design detail lives in the per-system
> `hld` / `schema` / `lld` documents; [`README.md`](README.md) says what is built and what is
> not.

---

## 1. What it is

A phone app that holds one person to the routine they chose. You write down your habits —
*learning 21:00–22:00 on weekdays, sleep at 23:00* — and for as long as a habit is running the
apps you named stop opening. Alarms ring like a clock alarm, and are harder to ignore than
one.

It exists because intentions do not survive a phone. Instagram at 21:05 is the default; this
app makes the default the thing you planned.

**Scale:** one person, one phone, a handful of habits and alarms. Offline, always.

---

## 2. Goals

| | Measured by |
|---|---|
| A planned habit is enforced without the app being open | A blocked app opened during a habit is sent away within a second, with the app swiped away from recents |
| Overlaps are caught when a habit is saved, not when it runs | No two hard habits can ever be planned at the same minute |
| An alarm rings on time, every time, over the lock screen | Fires within the minute it was set for, from a cold, locked, dozing phone |
| Breaking a rule is possible, deliberate, and recorded | Every pause, snooze, dismissal and missed alarm is in History, with the time |

---

## 3. Non-goals

| Not doing | Why |
|---|---|
| Server, account, login | One person, one phone. Nothing to share with anyone |
| Sync between devices | One phone. A second would need a merge model the app does not have |
| Backup and restore | Deliberately absent (D2). A lost phone loses its habits, which take minutes to re-enter |
| Plain-English habit entry (an LLM) | Needs a model or a network. A form does the job; this is a v2 idea at most |
| Analytics, telemetry, crash reporting | Nothing leaves the phone |
| Play Store distribution | Side-loaded from GitHub Releases (D3). The permissions a blocker needs are the ones Play reviews hardest |
| Blocking websites | v1 blocks apps. A browser is an app, and can be blocked whole |
| A hard lock that cannot be undone | The chosen strictness is friction plus a log (D4), not a cage |
| Custom alarm sounds | The system's default alarm sound |
| iOS, tablets, Android below 16 | Android 16 phones only (D5) |

---

## 4. The user

One person who is serious about a routine and knows their own weak minutes. They set the
app up once, revisit it when the routine changes, and otherwise only see it when it gets in
their way — which is the point.

---

## 5. Concepts

| Term | Meaning |
|---|---|
| **Habit** | A named, repeating window of time — days of the week, a start and an end — during which some apps are blocked |
| **Hard habit** | Fixed. Nothing may overlap it. Sleep, work, a class |
| **Soft habit** | Movable. Gives way to a hard habit, and to a soft habit of higher priority |
| **Window** | One occurrence of a habit on one date — *Learning, Mon 2 Nov, 21:00–22:00* |
| **Blocked app** | An app that cannot be used while a window of a habit naming it is running |
| **Pause** | A short, deliberate break in blocking, earned by waiting and typing a sentence |
| **Alarm** | Rings at a time, like a clock alarm. Either at a clock time, or tied to a habit's start or end |
| **Challenge** | What it takes to dismiss an alarm: nothing, a sum, or a typed phrase |
| **Plan** | The next 14 days of windows and alarms, worked out by the app and handed to Android |

The glossary is [`00-overview/glossary.md`](00-overview/glossary.md).

---

## 6. Features

### 6.1 Habits

A habit has:

| Field | Rules |
|---|---|
| Name | 1–40 characters |
| Days | Any of Mon–Sun, at least one |
| Start, end | Minutes of the day. End before start means the window **crosses midnight** — *Sleep 23:00–06:30* belongs to the day it starts |
| Strictness | Hard or soft |
| Priority | Low, normal, high — soft habits only. Decides which soft habit gives way |
| Blocked apps | Any installed app with a launcher icon. May be empty — a habit can exist only to remind and to ring |
| Do not disturb | Optional. Turns Android's Do Not Disturb on for the window |
| Enabled | Off means not planned and not checked for overlaps. Its history stays |

A habit is never deleted, only **archived**, so its history keeps its name.

### 6.2 Overlaps, handled when a habit is saved

Saving a habit checks it against every other enabled habit, across the whole week, including
windows that cross midnight and the Sunday-night-into-Monday wrap.

| Clash | What happens |
|---|---|
| Hard with hard | **Refused.** The message names the other habit, the days and the minutes |
| Soft with hard | The soft habit gives way. The app offers to **shift** it (same length, nearest free slot later or earlier that works on every one of its days) or **trim** it (the longest part that is free). The save waits for a choice |
| Soft with soft | The lower priority gives way; on a tie, the one being saved does. Same shift and trim offers, plus **keep both** — both block during the overlap |

**A buffer before hard habits.** A soft habit may not end within *N* minutes before a hard
one starts (default 15, set in Settings), so *learning* cannot run into *sleep*. Hard habits
are not buffered from each other.

The habit that gives way may be the one already saved rather than the one being edited —
saving a new hard *Gym 21:30–22:30* offers to shift the existing soft *Learning*. Whatever the
choice, both habits are written in one transaction.

**Alarms never clash.** An alarm is an instant, not a window. Two alarms in the same minute
ring once, naming both.

### 6.3 Blocking

While a window runs, opening an app it blocks sends you to the home screen and shows the
**block screen**:

```
                Learning
         until 22:00 · 37 min left

     Instagram is blocked during this habit.

          [ Go to the home screen ]
              Pause for 5 minutes
```

- **Always allowed**, whatever a habit names: Habit Force itself, the phone dialler, the home
  screen, system UI and Android's settings. An emergency call is never blocked, and the
  permission pages are always reachable.
- **Two windows at once** (a kept soft–soft overlap) block the union of their apps. The block
  screen names the stricter, then the higher priority.
- A window that starts while a blocked app is on screen takes effect at once.

### 6.4 Pausing — friction, then a log

**Pause** is on the block screen, and it is slow on purpose:

1. Wait **60 seconds** (120 during a hard habit). The countdown is on the button.
2. Type the pause sentence exactly — by default *I am choosing to break my own rule*.
3. Blocking stops for **5 minutes**, for every window running, then resumes on its own —
   including over the app you are in.

Every pause is recorded with the habit, the app and the time. It breaks that habit's streak.
Cooldown, length and sentence are in Settings.

**Turning the blocker off in Android's settings is possible** and is recorded too: the app
notices when its accessibility service is disconnected and logs it, and the Today screen says
blocking is off until it is back.

### 6.5 Alarms

| Field | Rules |
|---|---|
| When | A clock time, **or** a habit's start or end plus an offset (−180 to +180 minutes) — *20:55, five minutes before Learning* |
| Repeat | Clock alarms: any days of the week, or none for **once** — the next time that clock time comes round. Habit alarms follow the habit's days |
| Label | Up to 40 characters, optional |
| Challenge | None, **sum** (two two-digit numbers), or **phrase** (type *I am awake and getting up*) |
| Snooze | 1–30 minutes, at most 0–10 times. When the snoozes are used up, the button is gone |
| Vibrate | On or off |
| Enabled | On or off |

**Ringing behaves like a clock app:** on time even in deep sleep, over the lock screen, screen
on, at alarm volume, through Do Not Disturb. It rings for 10 minutes and then stops and is
recorded as **missed**.

**Test** on the alarm screen rings it in ten seconds, exactly as it would for real.

### 6.6 Notifications

| When | Says |
|---|---|
| *N* minutes before a window (default 10) | *Learning starts at 21:00 · Instagram, YouTube will be blocked* |
| At the start | *Learning has started · until 22:00* |
| At the end | *Learning is done* |
| Two days before the plan runs out | *Open Habit Force to keep your habits running* |

Windows starting or ending at the same minute share one notification. Heads-up time is in
Settings; 0 turns it off.

### 6.7 Do Not Disturb

A habit with DND on switches Android's Do Not Disturb to **priority only** at its start and
back at its end — but only if Habit Force was the one that turned it on. DND you set yourself
is left alone. Alarms ring through it either way.

### 6.8 History and streaks

- A **streak** per habit: consecutive windows that ran without a pause. A window that never
  started (the phone was off) neither counts nor breaks it.
- The last 14 days, by day: windows run, apps sent away, pauses, alarms dismissed, snoozed and
  missed — each with its time.
- Turning the blocker off and back on is listed too.

### 6.9 Setup

The first launch shows a checklist; Today shows a banner while anything on it is missing.

| Permission | Why | Without it |
|---|---|---|
| Notifications | Heads-up, start, end, and the alarm itself | Alarms still ring full-screen; nothing else is said |
| Alarms & reminders (exact alarms) | Starting and ending windows and ringing alarms on the minute | Granted at install for a side-loaded app (D3). Shown in case it is revoked |
| Full-screen alarms | Ringing over the lock screen | Alarms arrive as a notification only |
| Accessibility — the blocker | Seeing which app is opening, to send it away | **Nothing is blocked.** Everything else works |
| Do Not Disturb access | The per-habit DND switch | The switch is ignored |
| Unrestricted battery | Keeping the blocker and alarms alive on aggressive phones | Usually fine on stock Android; needed on some brands |

**Android 13+ restricts accessibility for side-loaded apps.** The toggle is greyed out until
you open *App info → ⋮ → Allow restricted settings*. Setup says so, at the step where it bites.

---

## 7. Screens

Four tabs and three screens behind them. Declared in full in
[`03-frontend/screen-dsl.md`](03-frontend/screen-dsl.md).

| | |
|---|---|
| **Today** | What is running now and until when; today's windows and alarms in order; the setup banner |
| **Habits** | Every habit, with days, times, strictness, blocked-app count and streak |
| **Alarms** | Every alarm, clock and habit-tied, with an on/off switch |
| **History** | Streaks, then the last 14 days, day by day |
| Habit editor | All of §6.1, the apps picker, the habit's alarms, and the overlap sheet on save |
| Alarm editor | All of §6.5, and Test |
| Settings | Heads-up minutes, hard buffer, pause length, cooldown, pause sentence, version |
| Setup | The checklist in §6.9 |

---

## 8. Architecture, in one paragraph

Flutter draws the app and owns the data: habits, alarms, settings and history in SQLite.
Native Kotlin does everything that must happen while the app is closed — the accessibility
blocker, exact alarms, ringing, notifications, Do Not Disturb. The two meet in exactly two
files and one channel: Flutter writes a **plan** (the next 14 days, worked out in Dart), and
Kotlin appends **events** (what happened) for Flutter to collect. Kotlin never decides what a
habit means; Dart never runs while the phone sleeps. See
[`00-overview/hld.md`](00-overview/hld.md).

---

## 9. Constraints

| | |
|---|---|
| Android | 16+ only — `minSdk 36` |
| Distribution | Side-loaded APK from GitHub Releases. Debug APK per push to `main` |
| Network | None. The app has no `INTERNET` permission in release |
| Language | English, 24-hour times, the phone's time zone |
| Data | On the phone only. Uninstalling deletes it |

---

## 10. Milestones

| | |
|---|---|
| M1 | Storage, the bridge, the plan — a habit saved in Dart reaches Kotlin |
| M2 | Blocking and the block screen, with pause |
| M3 | Alarms: scheduling, ringing, challenges, snooze, test |
| M4 | Notifications and DND |
| M5 | History and streaks; setup checklist |
| M6 | CI: debug APK per push, signed release on demand |

---

## 11. Open questions

- Should a hard habit's pause be refused outright rather than slower? v1 says slower (D4).
- Should the plan be re-made in the background so it never runs out? v1 warns instead (D9).
