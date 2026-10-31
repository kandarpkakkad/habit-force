package com.habitforce.habit_force.schedule

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.habitforce.habit_force.notify.Notifier
import com.habitforce.habit_force.plan.Rearm

/** Boot, clock and zone changes, and app updates all leave Android's alarms
 *  pointing at the wrong instants or at nothing. The plan holds dates and
 *  minutes (D8), so re-arming from it is all any of them needs. */
class SystemEventsReceiver : BroadcastReceiver() {
    override fun onReceive(ctx: Context, intent: Intent) {
        Notifier.ensureChannels(ctx)
        Rearm.all(ctx)
    }
}
