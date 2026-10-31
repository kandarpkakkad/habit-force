# Notifications — LLD

Kotlin: `schedule/` (the chain) and `notify/` (channels, text, DND).

## 1. Boundaries

```kotlin
enum class Kind { HEADS_UP, START, END, EXPIRY }
data class Boundary(val at: Long, val kind: Kind, val window: Window?)

fun boundaries(plan): List<Boundary>       // sorted by at, then kind
  for w in plan.windows:
    s = instant(w.date, w.start);  e = instant(w.date, w.end)
    if plan.settings.headsUpMinutes > 0 → HEADS_UP at s − headsUp min
    START at s;  END at e
  if plan.horizon != null → EXPIRY at instant(horizon − 2 days, 20 × 60)
```

`boundaries` is pure. It is computed on each fire from the stored plan; the plan is a few KB.

## 2. The chain (D11, D18)

One exact alarm, request code 200, to `BoundaryReceiver`.

```kotlin
fun armNext(ctx, plan, after: Long)
  b = boundaries(plan).firstOrNull { it.at > after }
  if b == null → cancel 200; return
  am.setExactAndAllowWhileIdle(RTC_WAKEUP, b.at, pi(200))

BoundaryReceiver.onReceive()
  now = currentTimeMillis();  plan = PlanStore.load(ctx)
  last = prefs.lastHandledAt
  due   = boundaries(plan).filter { last < it.at && it.at <= now + 1_000 }
  fresh = due.filter { now − it.at <= 120_000 }
  post(fresh)                                   // §3
  for b in fresh where kind START → EventLog window_started (at = b.at)
  for b in fresh where kind END   → EventLog window_ended   (at = b.at)
  prefs.lastHandledAt = max(now, due.maxOf { it.at })
  Dnd.reconcile(ctx, plan, now)                 // §4
  BlockerService.recheck()
  armNext(ctx, plan, after = prefs.lastHandledAt)
```

**The one-second tolerance** lets an alarm Android delivers a moment early still count as
due. **Anything over two minutes late** is passed over without a word (D18), and
`lastHandledAt` moves past it so it is never looked at again.

Events are stamped with the boundary's own time, not `now`: a start delivered 40 seconds late
still started at 21:00.

## 3. Text, one notification per kind per minute

Group `fresh` by `(kind, at / 60_000)`. For each group, `names` is the habits joined *A*,
*A and B*, *A, B and C*.

| Kind | Title | Text |
|---|---|---|
| HEADS_UP | *Learning starts at 21:00* · *Learning and Reading start at 21:00* | *Instagram, YouTube will be blocked* — the union of labels; omitted when empty |
| START | *Learning has started* · *Learning and Reading have started* | *until 22:00* for one; *Learning until 22:00 · Reading until 21:30* for several |
| END | *Learning is done* · *Learning and Reading are done* | — |
| EXPIRY | *Open Habit Force to keep your habits running* | *The plan ends on Fri 13 Nov.* |

Channel `habits` (default importance) for the first three, `plan` for EXPIRY. Notification id
= `kind.ordinal × 1_000_000 + (at / 60_000) % 1_000_000`, so a re-fire of the same minute
replaces rather than repeats. Tapping opens the app.

## 4. Do Not Disturb (D17)

```kotlin
fun reconcile(ctx, plan, now)
  if !nm.isNotificationPolicyAccessGranted → return
  want = plan.windows.any { it.dnd && startAt(it) <= now < endAt(it) }
  cur  = nm.currentInterruptionFilter
  if want:
    if cur == INTERRUPTION_FILTER_ALL → nm.setInterruptionFilter(PRIORITY); dndSetByUs = true
  else if dndSetByUs:
    if cur == INTERRUPTION_FILTER_PRIORITY → nm.setInterruptionFilter(ALL)
    dndSetByUs = false
```

If the person changed the mode themselves while it was ours (to *alarms only*, say), `cur` is
no longer PRIORITY and it is left as they set it.

## 5. Channels

Created idempotently in `Notifier.ensureChannels`, called from `MainActivity.onCreate` and
before every post.

| Id | Name | Importance | Notes |
|---|---|---|---|
| `habits` | Habit start and end | DEFAULT | |
| `alarms` | Alarms | HIGH | No channel sound; the ring service plays it |
| `plan` | Schedule warnings | DEFAULT | |

## 6. Edge cases

| Case | Behaviour |
|---|---|
| Heads-up time before now when the plan is installed | Not due (it is before `lastHandledAt` or will be passed over as stale) |
| A habit edited to start one minute from now | The chain is re-armed; START fires in a minute |
| Window shorter than the heads-up | Heads-up still fires before it; nothing special |
| Two windows, one ends 22:00, other starts 22:00 | Two notifications at 22:00: one END, one START |
| Reboot at 21:30 inside a window | No START (stale); the blocker enforces from the plan anyway; DND reconciled on boot |

## 7. What to test

`boundaries` for a crossing window and a zero heads-up; the due/fresh split around both
thresholds; the grouping text for one, two and three names.
