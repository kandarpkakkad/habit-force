package com.habitforce.habit_force.block

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.view.accessibility.AccessibilityEvent
import com.habitforce.habit_force.history.EventLog
import com.habitforce.habit_force.plan.PlanStore
import com.habitforce.habit_force.plan.PlanWindow
import com.habitforce.habit_force.plan.Time
import java.lang.ref.WeakReference
import java.time.ZoneId

/** Sends a blocked app away the moment it comes to the front.
 *  docs/02-domain/blocking/lld.md */
class BlockerService : AccessibilityService() {
    companion object {
        @Volatile private var ref: WeakReference<BlockerService>? = null

        val instance: BlockerService? get() = ref?.get()

        /** A window started, a pause ended, or the plan changed: none of these
         *  is an accessibility event, so look at what is on screen now. */
        fun recheck() {
            instance?.let { s -> s.handler.post { s.recheckNow() } }
        }
    }

    private val handler = Handler(Looper.getMainLooper())
    private var allowed: Set<String> = emptySet()
    private var lastBlockedKey: String? = null

    override fun onServiceConnected() {
        super.onServiceConnected()
        ref = WeakReference(this)
        // Read on connect and kept until the next one: the home app and the
        // dialler change rarely, and a stale value fails safe — it allows.
        allowed = Allowed.compute(this)
        EventLog.append(this, "enforcer_on")
        recheckNow()
    }

    override fun onUnbind(intent: Intent?): Boolean {
        // Also fires on an app update, which then reconnects. History shows
        // the off/on pair; that is true, so it stays.
        EventLog.append(this, "enforcer_off")
        ref = null
        handler.removeCallbacksAndMessages(null)
        return super.onUnbind(intent)
    }

    override fun onInterrupt() = Unit

    override fun onAccessibilityEvent(e: AccessibilityEvent) {
        if (e.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        enforce(e.packageName?.toString() ?: return)
    }

    fun recheckNow() {
        enforce(rootInActiveWindow?.packageName?.toString() ?: return)
    }

    fun recheckAt(at: Long) {
        handler.postDelayed({ recheckNow() }, maxOf(0L, at - System.currentTimeMillis()))
    }

    private fun enforce(pkg: String) {
        val now = System.currentTimeMillis()
        val zone = ZoneId.systemDefault()
        val plan = PlanStore.load(this)
        val top = BlockDecision.top(plan, pkg, now, Pause.until(this), allowed, zone) ?: return
        performGlobalAction(GLOBAL_ACTION_HOME)
        startActivity(blockIntent(top, pkg, plan.settings.pauseMinutes, plan.settings.pauseCooldownSeconds,
            plan.settings.pausePhrase, zone))
        val key = BlockDecision.throttleKey(pkg, top, now)
        if (key != lastBlockedKey) {
            lastBlockedKey = key
            EventLog.append(this, "blocked", top.habitId, top.key, pkg = pkg)
        }
    }

    private fun blockIntent(
        w: PlanWindow, pkg: String, pauseMinutes: Int, cooldown: Int, phrase: String, zone: ZoneId,
    ) = Intent(this, BlockActivity::class.java)
        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
        .putExtra(BlockActivity.EXTRA_WINDOW_KEY, w.key)
        .putExtra(BlockActivity.EXTRA_HABIT_ID, w.habitId)
        .putExtra(BlockActivity.EXTRA_NAME, w.name)
        .putExtra(BlockActivity.EXTRA_HARD, w.hard)
        .putExtra(BlockActivity.EXTRA_END_AT, w.endAt(zone))
        .putExtra(BlockActivity.EXTRA_END_LABEL, Time.hhmm(w.end))
        .putExtra(BlockActivity.EXTRA_PACKAGE, pkg)
        .putExtra(BlockActivity.EXTRA_APP_LABEL, w.apps.firstOrNull { it.pkg == pkg }?.label ?: pkg)
        .putExtra(BlockActivity.EXTRA_PAUSE_MINUTES, pauseMinutes)
        .putExtra(BlockActivity.EXTRA_COOLDOWN, cooldown)
        .putExtra(BlockActivity.EXTRA_PHRASE, phrase)
}
