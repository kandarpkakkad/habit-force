package com.habitforce.habit_force.plan

import android.content.Context
import com.habitforce.habit_force.Prefs
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.time.LocalDate

/** Kotlin's copy of the plan, in files/plan.json. Written only by install(),
 *  whole and atomically; read by everything else. docs/01-platform/bridge/lld.md §2 */
object PlanStore {
    @Volatile private var cached: Plan? = null
    @Volatile private var cachedStamp = -1L
    @Volatile private var lastError: String? = null

    private fun file(ctx: Context) = File(ctx.filesDir, "plan.json")

    /** Throws PlanInvalid (nothing written) or IOException (old plan kept). */
    @Synchronized
    fun install(ctx: Context, json: String): Plan {
        val plan = Plan.parse(json)
        val target = file(ctx)
        val tmp = File(ctx.filesDir, "plan.json.tmp")
        FileOutputStream(tmp).use {
            it.write(json.toByteArray(Charsets.UTF_8))
            it.fd.sync()
        }
        // A rename on one filesystem is atomic: a reader sees the old file or
        // the new one, never half of either.
        if (!tmp.renameTo(target)) throw IOException("could not replace ${target.path}")
        cached = plan
        cachedStamp = target.lastModified()
        lastError = null

        val prefs = Prefs.of(ctx)
        if (prefs.getLong(Prefs.LAST_HANDLED_AT, 0L) == 0L) {
            // First install: there is no "before" to replay (D18).
            prefs.edit().putLong(Prefs.LAST_HANDLED_AT, System.currentTimeMillis()).apply()
        }
        Rearm.all(ctx, plan)
        return plan
    }

    fun load(ctx: Context): Plan {
        val f = file(ctx)
        if (!f.exists()) {
            lastError = null
            return Plan.EMPTY
        }
        val stamp = f.lastModified()
        cached?.let { if (stamp == cachedStamp) return it }
        return try {
            Plan.parse(f.readText(Charsets.UTF_8)).also {
                cached = it
                cachedStamp = stamp
                lastError = null
            }
        } catch (e: Exception) {
            lastError = e.message ?: e.javaClass.simpleName
            Plan.EMPTY
        }
    }

    fun status(ctx: Context): Map<String, Any?> {
        if (!file(ctx).exists()) return mapOf("state" to "missing")
        val plan = load(ctx)
        lastError?.let { return mapOf("state" to "unreadable", "error" to it) }
        val horizon = plan.horizon
        val state = if (horizon != null && horizon.isBefore(LocalDate.now())) "expired" else "ok"
        return mapOf("state" to state, "horizon" to horizon?.toString(), "generatedAt" to plan.generatedAt)
    }
}
