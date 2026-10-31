package com.habitforce.habit_force.perms

import android.Manifest
import android.app.Activity
import android.app.AlarmManager
import android.app.NotificationManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.PowerManager
import android.provider.Settings
import com.habitforce.habit_force.Prefs
import com.habitforce.habit_force.block.BlockerService

/** Read live, every time; never cached (permissions HLD).
 *  docs/01-platform/permissions/lld.md §2–3 */
object Permissions {
    fun status(ctx: Context): Map<String, Boolean> {
        val nm = ctx.getSystemService(NotificationManager::class.java)
        return mapOf(
            "notifications" to (ctx.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED),
            "exactAlarms" to ctx.getSystemService(AlarmManager::class.java).canScheduleExactAlarms(),
            "fullScreen" to nm.canUseFullScreenIntent(),
            "accessibility" to blockerEnabled(ctx),
            "dnd" to nm.isNotificationPolicyAccessGranted,
            "battery" to ctx.getSystemService(PowerManager::class.java).isIgnoringBatteryOptimizations(ctx.packageName),
        )
    }

    private fun blockerEnabled(ctx: Context): Boolean {
        val mine = ComponentName(ctx, BlockerService::class.java)
        val enabled = Settings.Secure.getString(ctx.contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES)
            ?: return false
        return enabled.split(':').any { ComponentName.unflattenFromString(it) == mine }
    }

    /** Throws ActivityNotFoundException when the page does not exist here. */
    fun open(activity: Activity, key: String) {
        val pkg = Uri.parse("package:${activity.packageName}")
        val intent = when (key) {
            "notifications" -> {
                val prefs = Prefs.of(activity)
                if (!prefs.getBoolean(Prefs.ASKED_NOTIFICATIONS, false)) {
                    prefs.edit().putBoolean(Prefs.ASKED_NOTIFICATIONS, true).apply()
                    activity.requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 41)
                    return
                }
                Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                    .putExtra(Settings.EXTRA_APP_PACKAGE, activity.packageName)
            }
            "exactAlarms" -> Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, pkg)
            "fullScreen" -> Intent(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT, pkg)
            "accessibility" -> Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            "dnd" -> Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
            "battery" -> Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS, pkg)
            else -> throw IllegalArgumentException("unknown permission '$key'")
        }
        activity.startActivity(intent)
    }

    fun openAppInfo(activity: Activity) {
        activity.startActivity(
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:${activity.packageName}")),
        )
    }
}
