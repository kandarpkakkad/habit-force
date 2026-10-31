package com.habitforce.habit_force.block

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.os.CountDownTimer
import android.text.Editable
import android.text.TextWatcher
import android.widget.LinearLayout
import android.window.OnBackInvokedDispatcher
import com.habitforce.habit_force.ui.NativeUi

/** The block screen: why the app went away, and the slow way to pause.
 *  docs/02-domain/blocking/lld.md §5 */
class BlockActivity : Activity() {
    companion object {
        const val EXTRA_WINDOW_KEY = "windowKey"
        const val EXTRA_HABIT_ID = "habitId"
        const val EXTRA_NAME = "name"
        const val EXTRA_HARD = "hard"
        const val EXTRA_END_AT = "endAt"
        const val EXTRA_END_LABEL = "endLabel"
        const val EXTRA_PACKAGE = "package"
        const val EXTRA_APP_LABEL = "appLabel"
        const val EXTRA_PAUSE_MINUTES = "pauseMinutes"
        const val EXTRA_COOLDOWN = "cooldown"
        const val EXTRA_PHRASE = "phrase"
    }

    private enum class State { INFO, COOLDOWN, TYPING }

    private lateinit var root: LinearLayout
    private var state = State.INFO
    private var timer: CountDownTimer? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        root = NativeUi.root(this)
        setContentView(root)
        onBackInvokedDispatcher.registerOnBackInvokedCallback(OnBackInvokedDispatcher.PRIORITY_DEFAULT) { goHome() }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        state = State.INFO
    }

    override fun onResume() {
        super.onResume()
        if (minutesLeft() <= 0) {
            // The window ended while this was on its way up.
            finish()
            return
        }
        render()
    }

    override fun onStop() {
        super.onStop()
        // The cooldown is not remembered: leave and come back, and it starts
        // again. That is the friction (D4), not an oversight.
        timer?.cancel()
        state = State.INFO
    }

    private fun minutesLeft(): Long {
        val endAt = intent.getLongExtra(EXTRA_END_AT, 0L)
        return (endAt - System.currentTimeMillis() + 59_999) / 60_000
    }

    private fun render() {
        root.removeAllViews()
        val name = intent.getStringExtra(EXTRA_NAME) ?: "This habit"
        val app = intent.getStringExtra(EXTRA_APP_LABEL) ?: "This app"
        val endLabel = intent.getStringExtra(EXTRA_END_LABEL) ?: ""
        val pauseMinutes = intent.getIntExtra(EXTRA_PAUSE_MINUTES, 5)

        root.addView(NativeUi.text(this, name, 34f))
        root.addView(NativeUi.text(this, "until $endLabel · ${minutesLeft()} min left", 18f, primary = false))
        root.addView(NativeUi.spacer(this, 24))

        when (state) {
            State.INFO -> {
                root.addView(NativeUi.text(this, "$app is blocked during this habit.", 16f))
                root.addView(NativeUi.spacer(this, 24))
                root.addView(NativeUi.primary(this, "Go to the home screen") { goHome() })
                root.addView(NativeUi.secondary(this, "Pause for $pauseMinutes minutes") {
                    state = State.COOLDOWN
                    render()
                })
            }
            State.COOLDOWN -> {
                val hard = intent.getBooleanExtra(EXTRA_HARD, false)
                val seconds = intent.getIntExtra(EXTRA_COOLDOWN, 60) * if (hard) 2 else 1
                root.addView(NativeUi.text(this, "Take a moment. Do you need $app right now?", 16f))
                val wait = NativeUi.secondary(this, waitLabel(seconds.toLong())) {}
                wait.isEnabled = false
                root.addView(wait)
                root.addView(NativeUi.primary(this, "Never mind — go home") { goHome() })
                timer?.cancel()
                timer = object : CountDownTimer(seconds * 1000L, 1000L) {
                    override fun onTick(left: Long) {
                        wait.text = waitLabel((left + 999) / 1000)
                    }

                    override fun onFinish() {
                        state = State.TYPING
                        render()
                    }
                }.start()
            }
            State.TYPING -> {
                val phrase = intent.getStringExtra(EXTRA_PHRASE) ?: ""
                root.addView(NativeUi.text(this, "Type this to pause:", 16f, primary = false))
                root.addView(NativeUi.text(this, phrase, 18f))
                val field = NativeUi.field(this, "Type the sentence", numeric = false)
                root.addView(field)
                val pause = NativeUi.primary(this, "Pause for $pauseMinutes minutes") { pause(pauseMinutes) }
                pause.isEnabled = false
                pause.alpha = 0.4f
                field.addTextChangedListener(object : TextWatcher {
                    override fun beforeTextChanged(s: CharSequence?, a: Int, b: Int, c: Int) = Unit
                    override fun onTextChanged(s: CharSequence?, a: Int, b: Int, c: Int) = Unit
                    override fun afterTextChanged(s: Editable?) {
                        val ok = NativeUi.normalise(s?.toString() ?: "") == NativeUi.normalise(phrase)
                        pause.isEnabled = ok
                        pause.alpha = if (ok) 1f else 0.4f
                    }
                })
                root.addView(pause)
                root.addView(NativeUi.secondary(this, "Never mind — go home") { goHome() })
            }
        }
    }

    private fun waitLabel(seconds: Long) = "Wait %d:%02d".format(seconds / 60, seconds % 60)

    private fun pause(minutes: Int) {
        val pkg = intent.getStringExtra(EXTRA_PACKAGE) ?: return
        Pause.start(
            this, minutes,
            habitId = intent.getStringExtra(EXTRA_HABIT_ID) ?: "",
            occurrence = intent.getStringExtra(EXTRA_WINDOW_KEY) ?: "",
            pkg = pkg,
        )
        packageManager.getLaunchIntentForPackage(pkg)?.let {
            startActivity(it.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
        }
        finish()
    }

    private fun goHome() {
        startActivity(
            Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
        )
        finish()
    }
}
