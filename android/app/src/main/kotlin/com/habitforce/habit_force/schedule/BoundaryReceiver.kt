package com.habitforce.habit_force.schedule

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.habitforce.habit_force.Prefs
import com.habitforce.habit_force.block.BlockerService
import com.habitforce.habit_force.history.EventLog
import com.habitforce.habit_force.notify.Dnd
import com.habitforce.habit_force.notify.Notifier
import com.habitforce.habit_force.plan.PlanStore
import java.time.ZoneId

/** A link in the boundary chain. docs/02-domain/notifications/lld.md §2 */
class BoundaryReceiver : BroadcastReceiver() {
    override fun onReceive(ctx: Context, intent: Intent) {
        val now = System.currentTimeMillis()
        val zone = ZoneId.systemDefault()
        val plan = PlanStore.load(ctx)
        val prefs = Prefs.of(ctx)
        val last = prefs.getLong(Prefs.LAST_HANDLED_AT, now)

        val due = Boundaries.due(plan, last, now, zone)
        val fresh = Boundaries.fresh(due, now)
        Notifier.postBoundaries(ctx, fresh, plan)
        for (b in fresh) {
            val w = b.window ?: continue
            // Stamped with the boundary's own time: a start delivered 40
            // seconds late still started at 21:00.
            when (b.kind) {
                BoundaryKind.START -> EventLog.append(ctx, "window_started", w.habitId, w.key, at = b.at)
                BoundaryKind.END -> EventLog.append(ctx, "window_ended", w.habitId, w.key, at = b.at)
                else -> Unit
            }
        }

        val handled = maxOf(now, due.maxOfOrNull { it.at } ?: now)
        prefs.edit().putLong(Prefs.LAST_HANDLED_AT, handled).apply()
        Dnd.reconcile(ctx, plan, now)
        BlockerService.recheck()
        BoundaryScheduler.armNext(ctx, plan, handled)
    }
}
