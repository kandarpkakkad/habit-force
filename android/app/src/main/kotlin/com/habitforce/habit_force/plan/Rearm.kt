package com.habitforce.habit_force.plan

import android.content.Context
import com.habitforce.habit_force.Prefs
import com.habitforce.habit_force.alarm.AlarmScheduler
import com.habitforce.habit_force.block.BlockerService
import com.habitforce.habit_force.notify.Dnd
import com.habitforce.habit_force.schedule.BoundaryScheduler

/** Everything Android may have forgotten, re-armed from the stored plan.
 *  Called on install, boot, time and zone changes, and app update
 *  (docs/01-platform/bridge/lld.md §5). Idempotent: re-arming replaces. */
object Rearm {
    fun all(ctx: Context, plan: Plan = PlanStore.load(ctx), now: Long = System.currentTimeMillis()) {
        BoundaryScheduler.armNext(ctx, plan, Prefs.of(ctx).getLong(Prefs.LAST_HANDLED_AT, now))
        AlarmScheduler.armNext(ctx, plan, now)
        Dnd.reconcile(ctx, plan, now)
        BlockerService.recheck()
    }
}
