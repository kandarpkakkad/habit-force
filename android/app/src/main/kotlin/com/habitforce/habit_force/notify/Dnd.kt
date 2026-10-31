package com.habitforce.habit_force.notify

import android.app.NotificationManager
import android.content.Context
import com.habitforce.habit_force.Prefs
import com.habitforce.habit_force.plan.Plan
import java.time.ZoneId

/** Do Not Disturb as a state to reconcile, not a switch to flip (D17).
 *  docs/02-domain/notifications/lld.md §4 */
object Dnd {
    fun reconcile(ctx: Context, plan: Plan, now: Long) {
        val nm = ctx.getSystemService(NotificationManager::class.java)
        if (!nm.isNotificationPolicyAccessGranted) return
        val prefs = Prefs.of(ctx)
        val zone = ZoneId.systemDefault()
        val want = plan.windows.any { it.dnd && it.isRunning(now, zone) }
        val cur = nm.currentInterruptionFilter
        if (want) {
            // DND the person already has on is theirs; it is not taken over.
            if (cur == NotificationManager.INTERRUPTION_FILTER_ALL) {
                nm.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_PRIORITY)
                prefs.edit().putBoolean(Prefs.DND_SET_BY_US, true).apply()
            }
        } else if (prefs.getBoolean(Prefs.DND_SET_BY_US, false)) {
            // Changed by hand while it was ours (to alarms-only, say): leave it
            // as they set it, and stop thinking of it as ours.
            if (cur == NotificationManager.INTERRUPTION_FILTER_PRIORITY) {
                nm.setInterruptionFilter(NotificationManager.INTERRUPTION_FILTER_ALL)
            }
            prefs.edit().putBoolean(Prefs.DND_SET_BY_US, false).apply()
        }
    }
}
