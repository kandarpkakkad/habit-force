package com.habitforce.habit_force.alarm

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.widget.LinearLayout
import android.window.OnBackInvokedDispatcher
import com.habitforce.habit_force.plan.Time
import com.habitforce.habit_force.ui.NativeUi
import kotlin.random.Random

/** Over the lock screen: snooze within the limit, or meet the challenge to
 *  dismiss. Back does nothing. docs/02-domain/alarms/lld.md §5 */
class AlarmActivity : Activity() {
    private companion object {
        const val WAKE_PHRASE = "I am awake and getting up"
    }

    private lateinit var root: LinearLayout
    private var a = 0
    private var b = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setShowWhenLocked(true)
        setTurnScreenOn(true)
        root = NativeUi.root(this)
        setContentView(root)
        onBackInvokedDispatcher.registerOnBackInvokedCallback(OnBackInvokedDispatcher.PRIORITY_DEFAULT) {}
    }

    override fun onResume() {
        super.onResume()
        AlarmRingService.onStopped = { runOnUiThread { finish() } }
        if (!AlarmRingService.isRinging) {
            // It timed out, or was answered elsewhere.
            finish()
            return
        }
        showMain()
    }

    override fun onPause() {
        super.onPause()
        AlarmRingService.onStopped = null
    }

    private fun showMain() {
        val r = AlarmRingService.current ?: return finish()
        root.removeAllViews()
        root.addView(NativeUi.text(this, Time.hhmm(r.entry.minute), 72f))
        root.addView(NativeUi.text(this, r.entry.label.ifEmpty { "Alarm" }, 20f, primary = false))
        root.addView(NativeUi.spacer(this, 32))
        root.addView(NativeUi.primary(this, "Dismiss") { startChallenge(r) })
        val left = r.entry.snoozeLimit - r.snoozeNo
        if (left > 0) {
            val times = if (left == 1) "1 left" else "$left left"
            root.addView(NativeUi.secondary(this, "Snooze ${r.entry.snoozeMinutes} min · $times") {
                send(AlarmRingService.ACTION_SNOOZE, null)
            })
        }
    }

    private fun startChallenge(r: Ringing) {
        when (r.entry.challenge) {
            "sum" -> showSum()
            "phrase" -> showPhrase()
            else -> send(AlarmRingService.ACTION_DISMISS, "none")
        }
    }

    private fun showSum() {
        a = Random.nextInt(10, 100)
        b = Random.nextInt(10, 100)
        root.removeAllViews()
        root.addView(NativeUi.text(this, "$a + $b = ?", 40f))
        val field = NativeUi.field(this, "Answer", numeric = true)
        root.addView(field)
        root.addView(NativeUi.primary(this, "Dismiss") {
            if (field.text.toString().trim().toIntOrNull() == a + b) {
                send(AlarmRingService.ACTION_DISMISS, "sum")
            } else {
                // A new pair each time: no getting there by guessing one sum.
                showSum()
            }
        })
        root.addView(NativeUi.secondary(this, "Back") { showMain() })
        field.requestFocus()
    }

    private fun showPhrase() {
        root.removeAllViews()
        root.addView(NativeUi.text(this, "Type this to dismiss:", 16f, primary = false))
        root.addView(NativeUi.text(this, WAKE_PHRASE, 22f))
        val field = NativeUi.field(this, "Type the sentence", numeric = false)
        root.addView(field)
        root.addView(NativeUi.primary(this, "Dismiss") {
            if (NativeUi.normalise(field.text.toString()) == NativeUi.normalise(WAKE_PHRASE)) {
                send(AlarmRingService.ACTION_DISMISS, "phrase")
            }
        })
        root.addView(NativeUi.secondary(this, "Back") { showMain() })
        field.requestFocus()
    }

    private fun send(action: String, detail: String?) {
        startService(
            Intent(this, AlarmRingService::class.java).setAction(action).putExtra(AlarmRingService.EXTRA_DETAIL, detail),
        )
        finish()
    }
}
