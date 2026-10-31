# Blocking — HLD

Sending a blocked app away the moment it opens, while a habit's window is running.

## Purpose

Make the planned behaviour the default one, without the app being open.

## Responsibilities

- Watching which app comes to the front (accessibility, window-state changes only).
- Deciding, from the plan alone, whether it is blocked right now.
- Sending it away — the home screen, then the block screen — and recording that it happened.
- The pause: cooldown, sentence, timed suspension, and resuming on its own.
- Re-checking the app on screen when a window starts or a pause ends, since neither produces an
  accessibility event.
- Recording when the blocker is switched off and on.

## Owns

Natively: the pause (`pausedUntil`), in the app's private preferences. Nothing in SQLite.

## Depends on

The plan (bridge). Nothing in Dart at run time.

## Key decisions

**Accessibility, not usage-stats polling.** An accessibility event arrives as the window
changes; polling `UsageStatsManager` every second costs battery and still lags.

**Home, then the block screen.** `GLOBAL_ACTION_HOME` takes the app off screen at once; the
block screen explains why. The accessibility service may start an activity from the background,
so no overlay permission is needed.

**Never blocked, whatever a habit says:** Habit Force, the default dialler, the default home
app, `com.android.systemui`, and Android's settings — the last so the person can always reach
the permission pages, and so the blocker can never lock someone out of their own phone (D4).

**Two windows at once block the union (D12).** The block screen names the window that matters
most: hard before soft, then higher priority, then the one ending last.

**A pause covers every running window.** It is the person stepping out, not one habit
loosening. Hard habits double the cooldown (D4).

**One `blocked` event per app per window per minute.** Bouncing between Instagram and home ten
times in a minute is one line in History, not ten.

## Failure modes

| | |
|---|---|
| Accessibility off | Nothing blocked. `enforcer_off` recorded when it is switched off; Today's banner |
| Plan missing or expired | Nothing blocked; Today says why |
| An app opens in split-screen or a bubble | Its window state change is seen and sent home like any other |
| The app is already on screen when a window starts | The start boundary tells the blocker to look again |
| The pause ends inside a blocked app | A timer in the service checks the app on screen at the pause's end |

## Non-goals

- Blocking websites or content inside an app.
- Blocking during anything but a planned window — there is no "block now for an hour" in v1.
- Making the blocker impossible to turn off.
