# Notifications — HLD

Saying, before and as it happens, what the routine is about to do — and switching Do Not
Disturb with it.

## Purpose

No window should start as a surprise, and none should end without the person knowing they
are free.

## Responsibilities

- The boundary chain: heads-up, start, end, and the plan-expiry warning — armed one at a time
  (D11), acted on when fired, the next one armed.
- One notification per kind per minute, naming every habit in it.
- Do Not Disturb, reconciled at every boundary (D17).
- Recording `window_started` and `window_ended`.

## Owns

Natively: `lastHandledAt` (how far the chain has acted) and `dndSetByUs`, in preferences.
Three notification channels: `habits`, `alarms`, `plan`.

## Depends on

The plan (bridge); the blocker, which it tells to re-check at a start.

## Key decisions

**Exact alarms for boundaries.** `setExactAndAllowWhileIdle` under `USE_EXACT_ALARM` (D3).
A start that arrives five minutes late is five minutes of Instagram.

**Batching by minute.** Two habits starting at 21:00 are one *Learning and Reading have
started*. Volume follows distinct minutes, not habit count.

**Late boundaries are dropped, not replayed (D18).** Anything due more than two minutes ago
when the chain fires is skipped: no notification, no event.

**DND is a state, not a toggle (D17).** At each boundary: if a running window wants DND and
access is granted, ensure priority-only and remember that we set it; if none wants it and we
set it, restore *all*. If the person changed DND themselves meanwhile, leave it alone.

**The expiry warning is just another boundary.** At 20:00 two days before the horizon:
*Open Habit Force to keep your habits running.* Opening the app moves the horizon, and the
warning with it.

## Failure modes

| | |
|---|---|
| Notifications denied | No heads-up, start or end. Windows are still enforced; DND still switches |
| DND access missing | DND ignored; Setup shows the row amber |
| The chain is lost (force-stop) | Re-armed on next open, boot, or time change. Force-stop also stops the blocker until the app is opened — Android's rule, not ours |

## Non-goals

- Notification actions (snooze a habit, end early).
- Per-habit heads-up times. One setting for all.
