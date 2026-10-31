# Permissions — LLD

Dart: `lib/platform/permissions/`. Kotlin: `perms/Permissions.kt`.

## 1. Keys and what they say

| Key | Required | Title | Without it |
|---|---|---|---|
| `accessibility` | yes | Blocker (accessibility) | *Nothing is blocked.* |
| `exactAlarms` | yes | Alarms & reminders | *Habits start late and alarms may not ring on time.* |
| `notifications` | no | Notifications | *No heads-up, start or end messages.* |
| `fullScreen` | no | Full-screen alarms | *Alarms ring as a notification, not over the lock screen.* |
| `dnd` | no | Do Not Disturb access | *The Do Not Disturb switch on habits is ignored.* |
| `battery` | no | Unrestricted battery | *Some phones stop the blocker and alarms in the background.* |

Today's banner: red if a required key is false, amber if only optional ones are, absent if
all are true.

The accessibility row carries a second line and a second button:

> On Android 13 and later, the switch is greyed out for apps installed from outside the Play
> Store. Open **App info**, tap **⋮**, choose **Allow restricted settings**, then come back.

## 2. Kotlin: reading

```kotlin
fun status(ctx): Map<String, Boolean> = mapOf(
  "notifications" to (checkSelfPermission(POST_NOTIFICATIONS) == GRANTED),
  "exactAlarms"   to am.canScheduleExactAlarms(),
  "fullScreen"    to nm.canUseFullScreenIntent(),
  "accessibility" to enabledServices(ctx).contains(ComponentName(ctx, BlockerService::class)),
  "dnd"           to nm.isNotificationPolicyAccessGranted,
  "battery"       to pm.isIgnoringBatteryOptimizations(ctx.packageName),
)
```

`enabledServices` splits `Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES` on `:` and parses
each with `ComponentName.unflattenFromString`.

## 3. Kotlin: opening

| Key | Intent |
|---|---|
| `notifications` | First time: `requestPermissions([POST_NOTIFICATIONS])` from `MainActivity`. After that: `ACTION_APP_NOTIFICATION_SETTINGS` |
| `exactAlarms` | `ACTION_REQUEST_SCHEDULE_EXACT_ALARM` with `package:` URI |
| `fullScreen` | `ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT` with `package:` URI |
| `accessibility` | `ACTION_ACCESSIBILITY_SETTINGS` |
| `dnd` | `ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS` |
| `battery` | `ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` with `package:` URI |
| App info | `ACTION_APPLICATION_DETAILS_SETTINGS` with `package:` URI |

"First time" is a native preference, `askedNotifications`. An `ActivityNotFoundException`
becomes `no_settings_page` with its message.

## 4. Dart

`PermissionsController` holds the last `status()` and re-reads it on resume. Setup and Today
both listen to it. Nothing caches across launches.
