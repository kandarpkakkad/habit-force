package com.habitforce.habit_force.block

import android.content.Context
import com.habitforce.habit_force.Prefs
import com.habitforce.habit_force.history.EventLog

/** A pause covers every running window: it is the person stepping out, not
 *  one habit loosening. Always recorded (D4). docs/02-domain/blocking/lld.md §4 */
object Pause {
    fun until(ctx: Context): Long = Prefs.of(ctx).getLong(Prefs.PAUSED_UNTIL, 0L)

    fun start(ctx: Context, minutes: Int, habitId: String, occurrence: String, pkg: String) {
        val until = System.currentTimeMillis() + minutes * 60_000L
        Prefs.of(ctx).edit().putLong(Prefs.PAUSED_UNTIL, until).apply()
        EventLog.append(ctx, "paused", habitId, occurrence, pkg = pkg, detail = minutes.toString())
        // The pause ending produces no accessibility event, so the service
        // has to look again by itself.
        BlockerService.instance?.recheckAt(until + 500)
    }
}
