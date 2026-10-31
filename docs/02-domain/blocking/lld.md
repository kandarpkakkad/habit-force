# Blocking — LLD

Kotlin: `block/`. Reads the plan only ([bridge schema](../../01-platform/bridge/schema.md)).

## 1. The service

`BlockerService : AccessibilityService`, declared with `res/xml/blocker_service.xml`:

| Attribute | Value | Why |
|---|---|---|
| `accessibilityEventTypes` | `typeWindowStateChanged` | Only app switches; never content |
| `canRetrieveWindowContent` | `true` | Needed for `rootInActiveWindow.packageName` in `recheck`. The content itself is never read |
| `notificationTimeout` | 100 ms | |
| `accessibilityFlags` | `flagDefault` | |

`instance` is a static weak reference set in `onServiceConnected` and cleared in `onUnbind`,
so receivers can call `recheck()` without binding.

## 2. Never blocked

```kotlin
fun alwaysAllowed(ctx): Set<String> =
  setOf(ctx.packageName, "android", "com.android.systemui", "com.android.settings",
        "com.android.permissioncontroller", "com.google.android.permissioncontroller") +
  defaultHome(ctx) + defaultDialer(ctx)
```

`defaultHome` resolves `ACTION_MAIN` + `CATEGORY_HOME`; `defaultDialer` is
`TelecomManager.defaultDialerPackage`. Both are read on connect and cached until the next
connect — they change rarely, and a stale value fails safe (it allows).

## 3. Deciding

```kotlin
fun enforce(pkg: String, now = currentTimeMillis())
  if pkg in allowed → return
  plan = PlanStore.load(ctx)
  blocking = plan.windows.filter { startAt(it) <= now < endAt(it) && pkg in it.packages }
  if blocking.isEmpty() → return
  if Pause.until(ctx) > now → return
  top = blocking.sortedWith(hard desc, priority desc, endAt desc).first()
  performGlobalAction(GLOBAL_ACTION_HOME)
  startActivity(BlockActivity, top, pkg, label(pkg), plan.settings)   // NEW_TASK | CLEAR_TASK
  recordBlocked(top, pkg, now)

onAccessibilityEvent(e)
  if e.eventType == TYPE_WINDOW_STATE_CHANGED → enforce(e.packageName ?: return)

recheck()                            // window started, pause ended, plan installed
  pkg = rootInActiveWindow?.packageName ?: return
  enforce(pkg)
```

`recordBlocked` writes `blocked` only when `"$pkg|${top.key}|${now / 60_000}"` differs from
the last one written (blocking HLD).

## 4. Pause

```kotlin
object Pause {
  fun until(ctx): Long                     // prefs pausedUntil, 0 if never
  fun start(ctx, minutes, window, pkg)
    pausedUntil = now + minutes min
    EventLog paused(habitId, occurrence = window.key, package = pkg, detail = minutes)
    BlockerService.instance?.recheckAt(pausedUntil + 500)
}
```

`recheckAt` is a `Handler.postDelayed` in the service. If the service is restarted in
between, the delayed check is lost — and the next app switch enforces anyway.

## 5. `BlockActivity`

Extras: window key, habit name, `hard`, end instant, package, app label, and the pause
settings from the plan. `excludeFromRecents`, its own task affinity.

```
state Info:
  "<habit>"  ·  "until HH:MM · N min left"  ·  "<App> is blocked during this habit."
  [Go to the home screen]  → HOME intent; finish
  [Pause for P minutes]    → Cooldown

state Cooldown:  cooldown = settings.pauseCooldownSeconds × (hard ? 2 : 1)
  "Take a moment. Do you need <App> right now?"
  button disabled: "Wait 0:59" … ticking each second
  [Never mind — go home] → HOME; finish
  at 0 → Typing

state Typing:
  "Type this to pause:"  "<pause phrase>"
  text field; [Pause] enabled only when normalise(text) == normalise(phrase)
  [Pause] → Pause.start(P, window, pkg); open pkg's launch intent; finish
  [Never mind — go home] → HOME; finish

Back, anywhere → HOME; finish
If minutes left ≤ 0 when shown → finish (the window ended)
```

**The cooldown is not remembered.** Leaving the block screen and coming back starts it again.
That is part of the friction (D4), not an oversight.

`normalise` is the one in alarms LLD §5.

## 6. On and off

| Callback | Records |
|---|---|
| `onServiceConnected` | `enforcer_on` |
| `onUnbind` | `enforcer_off` |

An app update unbinds and rebinds the service, so History shows an off/on pair at each
update. Accepted: it is true.

## 7. Edge cases

| Case | Behaviour |
|---|---|
| A blocked app is the one Habit Force opens after a pause | Paused, so allowed |
| Pause taken in one window, a second window starts during it | Still paused; a pause covers everything running |
| The window ends while the block screen is up | It stays until dismissed; going back to the app is allowed |
| The same app blocked by a soft and a hard window | Named as the hard one; cooldown doubled |
| Picture-in-picture video from a blocked app | Its window change is seen and sent home |

## 8. What to test

`enforce`'s choice of `top`; the throttle key; the allow-list. These are pure enough to unit
test with a fake clock and a plan built in code.
