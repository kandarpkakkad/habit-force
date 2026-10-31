package com.habitforce.habit_force.alarm

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import com.habitforce.habit_force.MainActivity
import com.habitforce.habit_force.plan.Plan
import com.habitforce.habit_force.plan.PlanAlarm
import java.time.ZoneId

/** Three pending intents, by request code, so each replaces only itself.
 *  docs/02-domain/alarms/lld.md §2 */
object AlarmScheduler {
    private const val NEXT = 100
    private const val SNOOZE = 101
    private const val TEST = 102

    const val EXTRA_ENTRY = "entry"
    const val EXTRA_SNOOZE_NO = "snoozeNo"
    const val EXTRA_CHAIN = "chain"

    private fun pending(ctx: Context, code: Int, entry: PlanAlarm?, snoozeNo: Int, chain: Boolean): PendingIntent {
        val i = Intent(ctx, AlarmReceiver::class.java)
            .putExtra(EXTRA_SNOOZE_NO, snoozeNo)
            .putExtra(EXTRA_CHAIN, chain)
        entry?.let { i.putExtra(EXTRA_ENTRY, it.toJson()) }
        return PendingIntent.getBroadcast(ctx, code, i, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
    }

    private fun show(ctx: Context): PendingIntent = PendingIntent.getActivity(
        ctx, 0, Intent(ctx, MainActivity::class.java), PendingIntent.FLAG_IMMUTABLE,
    )

    /** setAlarmClock, not an exact alarm: the API Android keeps for alarms a
     *  person set — exempt from Doze and shown in the status bar. */
    private fun arm(ctx: Context, at: Long, op: PendingIntent) {
        val am = ctx.getSystemService(AlarmManager::class.java)
        try {
            am.setAlarmClock(AlarmManager.AlarmClockInfo(at, show(ctx)), op)
        } catch (e: SecurityException) {
            // Exact alarms revoked. Ringing late beats not ringing.
            am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, op)
        }
    }

    fun armNext(ctx: Context, plan: Plan, after: Long) {
        val zone = ZoneId.systemDefault()
        val e = plan.alarms.firstOrNull { it.at(zone) > after }
        if (e == null) {
            ctx.getSystemService(AlarmManager::class.java).cancel(pending(ctx, NEXT, null, 0, true))
            return
        }
        arm(ctx, e.at(zone), pending(ctx, NEXT, e, 0, true))
    }

    fun armSnooze(ctx: Context, e: PlanAlarm, snoozeNo: Int) {
        arm(ctx, System.currentTimeMillis() + e.snoozeMinutes * 60_000L, pending(ctx, SNOOZE, e, snoozeNo, false))
    }

    fun armTest(ctx: Context, e: PlanAlarm): Long {
        val at = System.currentTimeMillis() + 10_000L
        arm(ctx, at, pending(ctx, TEST, e, 0, false))
        return at
    }
}
