package com.habitforce.habit_force.notify

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.pm.PackageManager
import com.habitforce.habit_force.R
import com.habitforce.habit_force.plan.Plan
import com.habitforce.habit_force.schedule.Boundary
import com.habitforce.habit_force.schedule.BoundaryKind
import com.habitforce.habit_force.schedule.BoundaryText

object Notifier {
    const val CH_HABITS = "habits"
    const val CH_ALARMS = "alarms"
    const val CH_PLAN = "plan"

    /** Idempotent; called at launch and before every post. */
    fun ensureChannels(ctx: Context) {
        val nm = ctx.getSystemService(NotificationManager::class.java)
        nm.createNotificationChannels(listOf(
            NotificationChannel(CH_HABITS, "Habit start and end", NotificationManager.IMPORTANCE_DEFAULT),
            NotificationChannel(CH_ALARMS, "Alarms", NotificationManager.IMPORTANCE_HIGH).apply {
                // The ring service plays the sound and drives the vibration;
                // the channel doing it too would double both.
                setSound(null, null)
                enableVibration(false)
            },
            NotificationChannel(CH_PLAN, "Schedule warnings", NotificationManager.IMPORTANCE_DEFAULT),
        ))
    }

    fun openApp(ctx: Context): PendingIntent = PendingIntent.getActivity(
        ctx, 0, ctx.packageManager.getLaunchIntentForPackage(ctx.packageName),
        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
    )

    /** One notification per kind per minute (notifications LLD §3). */
    fun postBoundaries(ctx: Context, fresh: List<Boundary>, plan: Plan) {
        if (fresh.isEmpty()) return
        if (ctx.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) return
        ensureChannels(ctx)
        val nm = ctx.getSystemService(NotificationManager::class.java)
        for ((key, group) in fresh.groupBy { it.kind to it.at / 60_000 }) {
            val (kind, minute) = key
            val windows = group.mapNotNull { it.window }
            if (kind != BoundaryKind.EXPIRY && windows.isEmpty()) continue
            val builder = Notification.Builder(ctx, if (kind == BoundaryKind.EXPIRY) CH_PLAN else CH_HABITS)
                .setSmallIcon(R.drawable.ic_stat_habit)
                .setContentTitle(BoundaryText.title(kind, windows))
                .setContentIntent(openApp(ctx))
                .setAutoCancel(true)
            BoundaryText.text(kind, windows, plan.horizon)?.let { builder.setContentText(it) }
            // A re-fire of the same minute replaces rather than repeats.
            nm.notify((kind.ordinal * 1_000_000 + minute % 1_000_000).toInt(), builder.build())
        }
    }
}
