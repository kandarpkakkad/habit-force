package com.habitforce.habit_force.block

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.telecom.TelecomManager
import com.habitforce.habit_force.plan.Plan
import com.habitforce.habit_force.plan.PlanWindow
import java.time.ZoneId

/** Pure: is this app blocked right now, and by which window?
 *  docs/02-domain/blocking/lld.md §3 */
object BlockDecision {
    fun top(plan: Plan, pkg: String, now: Long, pausedUntil: Long, allowed: Set<String>, zone: ZoneId): PlanWindow? {
        if (pkg in allowed) return null
        val blocking = plan.windows.filter { pkg in it.packages && it.isRunning(now, zone) }
        if (blocking.isEmpty() || pausedUntil > now) return null
        // Two windows at once block the union (D12); the one named is the one
        // that matters most.
        return blocking.sortedWith(
            compareByDescending<PlanWindow> { it.hard }
                .thenByDescending { it.priority }
                .thenByDescending { it.endAt(zone) },
        ).first()
    }

    /** One `blocked` event per app per window per minute. */
    fun throttleKey(pkg: String, window: PlanWindow, now: Long) = "$pkg|${window.key}|${now / 60_000}"
}

/** Never blocked, whatever a habit says — so an emergency call is always
 *  possible and the permission pages are always reachable (D4).
 *  docs/02-domain/blocking/lld.md §2 */
object Allowed {
    fun compute(ctx: Context): Set<String> {
        val out = mutableSetOf(
            ctx.packageName,
            "android",
            "com.android.systemui",
            "com.android.settings",
            "com.android.permissioncontroller",
            "com.google.android.permissioncontroller",
        )
        val home = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
        ctx.packageManager.resolveActivity(
            home, PackageManager.ResolveInfoFlags.of(PackageManager.MATCH_DEFAULT_ONLY.toLong()),
        )?.activityInfo?.packageName?.let { out += it }
        ctx.getSystemService(TelecomManager::class.java)?.defaultDialerPackage?.let { out += it }
        return out
    }
}
