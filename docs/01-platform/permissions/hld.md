# Permissions — HLD

Six things Android must allow before Habit Force can do its job, and an honest account of
which ones are missing.

## Purpose

Show the person exactly what is granted, take them to the right settings page for what is
not, and never pretend a feature works when its permission is gone.

## Responsibilities

- Reading the state of each permission, natively, every time Setup or Today is shown.
- Opening the settings page for each one.
- Saying, in words, what stops working without it.

## Owns

Nothing stored. Permission state is read live; caching it would be the way it goes stale.

## Depends on

The bridge, for `permissionStatus` and `openPermission`.

## The six

| Key | Android | How it is read | How it is granted |
|---|---|---|---|
| `notifications` | `POST_NOTIFICATIONS` | `checkSelfPermission` | Runtime prompt from `MainActivity`; the settings page if refused twice |
| `exactAlarms` | `USE_EXACT_ALARM` | `AlarmManager.canScheduleExactAlarms()` | At install (D3). Settings page shown only if revoked |
| `fullScreen` | `USE_FULL_SCREEN_INTENT` | `NotificationManager.canUseFullScreenIntent()` | `ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT` |
| `accessibility` | The `BlockerService` accessibility service | `Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES` contains our component | `ACTION_ACCESSIBILITY_SETTINGS` |
| `dnd` | Notification policy access | `isNotificationPolicyAccessGranted` | `ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS` |
| `battery` | Unrestricted battery | `PowerManager.isIgnoringBatteryOptimizations` | `ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` |

## Key decisions

**Never gate a feature on a check — offer it, and let it fail loudly.** The habit editor
offers DND whether or not access is granted; Setup and Today say it will be ignored. A check
that answers wrongly on some phone must not remove a feature.

**Restricted settings is named where it bites.** Since Android 13, a side-loaded app's
accessibility toggle is greyed out until *App info → ⋮ → Allow restricted settings*. The
accessibility row says this in its own text and has a second button for App info, because
it is the step everyone gets stuck on.

**Required versus useful.** `accessibility` and `exactAlarms` are what the app is for: Today's
banner is red without them. The others are amber.

## Failure modes

| | |
|---|---|
| The person grants and comes back | Setup re-reads on resume; the row turns green |
| A permission is revoked later | Today's banner reappears on the next open |
| An OEM settings page is missing | The open call throws; the row says it could not open the page and why |

## Non-goals

- Device admin. Strictness is friction and a log (D4).
- Overlay permission. The block screen is an activity started by the accessibility service,
  which Android allows to start activities from the background.
