package com.habitforce.habit_force.alarm

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.habitforce.habit_force.plan.PlanAlarm
import com.habitforce.habit_force.plan.PlanInvalid
import com.habitforce.habit_force.plan.PlanStore
import java.time.ZoneId

/** An alarm's minute has come: start the ringing, then arm the next one.
 *  docs/02-domain/alarms/lld.md §3 */
class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(ctx: Context, intent: Intent) {
        val json = intent.getStringExtra(AlarmScheduler.EXTRA_ENTRY) ?: return
        val entry = try {
            PlanAlarm.parse(json)
        } catch (e: PlanInvalid) {
            null
        }
        if (entry != null) {
            ctx.startForegroundService(
                Intent(ctx, AlarmRingService::class.java)
                    .setAction(AlarmRingService.ACTION_RING)
                    .putExtra(AlarmScheduler.EXTRA_ENTRY, json)
                    .putExtra(AlarmScheduler.EXTRA_SNOOZE_NO, intent.getIntExtra(AlarmScheduler.EXTRA_SNOOZE_NO, 0)),
            )
        }
        if (intent.getBooleanExtra(AlarmScheduler.EXTRA_CHAIN, false)) {
            val zone = ZoneId.systemDefault()
            val after = maxOf(System.currentTimeMillis(), entry?.at(zone) ?: 0L)
            AlarmScheduler.armNext(ctx, PlanStore.load(ctx), after)
        }
    }
}
