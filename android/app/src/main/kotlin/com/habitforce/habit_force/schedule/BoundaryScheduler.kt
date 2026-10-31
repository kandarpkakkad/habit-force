package com.habitforce.habit_force.schedule

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import com.habitforce.habit_force.plan.Plan
import java.time.ZoneId

/** One exact alarm for the next boundary, re-armed each time it fires (D11). */
object BoundaryScheduler {
    private const val CODE = 200

    private fun pending(ctx: Context): PendingIntent = PendingIntent.getBroadcast(
        ctx, CODE, Intent(ctx, BoundaryReceiver::class.java),
        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
    )

    fun armNext(ctx: Context, plan: Plan, after: Long) {
        val am = ctx.getSystemService(AlarmManager::class.java)
        val b = Boundaries.next(plan, after, ZoneId.systemDefault())
        if (b == null) {
            am.cancel(pending(ctx))
            return
        }
        // Exact under USE_EXACT_ALARM (D3). If that is ever revoked, late is
        // better than never: offer the inexact one rather than nothing.
        if (am.canScheduleExactAlarms()) {
            am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, b.at, pending(ctx))
        } else {
            am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, b.at, pending(ctx))
        }
    }
}
