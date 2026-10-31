package com.habitforce.habit_force.bridge

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import com.habitforce.habit_force.alarm.AlarmScheduler
import com.habitforce.habit_force.block.Allowed
import com.habitforce.habit_force.history.EventLog
import com.habitforce.habit_force.perms.Permissions
import com.habitforce.habit_force.plan.PlanAlarm
import com.habitforce.habit_force.plan.PlanInvalid
import com.habitforce.habit_force.plan.PlanStore
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.IOException

/** The one channel. Contract: docs/01-platform/bridge/lld.md §1. Every error
 *  carries the native exception's own message: it is what reaches the screen. */
class NativeChannel(private val activity: Activity, messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, "habit_force/native")

    fun register() = channel.setMethodCallHandler(this)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val ctx = activity.applicationContext
        try {
            when (call.method) {
                "installPlan" -> {
                    val plan = PlanStore.install(ctx, call.arguments as String)
                    result.success(mapOf("windows" to plan.windows.size, "alarms" to plan.alarms.size))
                }
                "planStatus" -> result.success(PlanStore.status(ctx))
                "readEvents" -> {
                    val (events, torn) = EventLog.read(ctx)
                    result.success(mapOf("events" to events, "torn" to torn))
                }
                "ackEvents" -> {
                    val ids = call.argument<List<String>>("ids").orEmpty().toSet()
                    val torn = call.argument<List<String>>("torn").orEmpty().toSet()
                    result.success(EventLog.ack(ctx, ids, torn))
                }
                "listApps" -> result.success(listApps())
                "permissionStatus" -> result.success(Permissions.status(ctx))
                "openPermission" -> {
                    Permissions.open(activity, call.arguments as String)
                    result.success(null)
                }
                "openAppInfo" -> {
                    Permissions.openAppInfo(activity)
                    result.success(null)
                }
                "testAlarm" -> result.success(AlarmScheduler.armTest(ctx, PlanAlarm.parse(call.arguments as String)))
                else -> result.notImplemented()
            }
        } catch (e: PlanInvalid) {
            result.error("plan_invalid", e.message, null)
        } catch (e: IOException) {
            val code = when (call.method) {
                "installPlan" -> "plan_write"
                "readEvents" -> "events_read"
                else -> "events_write"
            }
            result.error(code, e.message, null)
        } catch (e: android.content.ActivityNotFoundException) {
            result.error("no_settings_page", e.message, null)
        } catch (e: Exception) {
            result.error("native_error", "${e.javaClass.simpleName}: ${e.message}", null)
        }
    }

    /** Launchable apps, minus everything the blocker never blocks — offering
     *  those would promise a block that cannot happen (habits LLD §5). */
    private fun listApps(): List<Map<String, String>> {
        val pm = activity.packageManager
        val skip = Allowed.compute(activity)
        val launcher = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        return pm.queryIntentActivities(launcher, PackageManager.ResolveInfoFlags.of(0L))
            .map { it.activityInfo.packageName to it.loadLabel(pm).toString() }
            .filter { (pkg, _) -> pkg !in skip }
            .distinctBy { it.first }
            .sortedBy { it.second.lowercase() }
            .map { (pkg, label) -> mapOf("package" to pkg, "label" to label) }
    }
}
