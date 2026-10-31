package com.habitforce.habit_force.ui

import android.app.Activity
import android.content.Context
import android.graphics.drawable.GradientDrawable
import android.text.InputType
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.WindowInsets
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.TextView
import com.habitforce.habit_force.R

/** The two native screens' look, by hand (D16), from
 *  docs/03-frontend/design-system.md §5. */
object NativeUi {
    fun dp(ctx: Context, v: Int): Int = (v * ctx.resources.displayMetrics.density).toInt()

    private fun color(ctx: Context, id: Int) = ctx.getColor(id)

    /** A full-screen column. Pads itself for the system bars and the keyboard:
     *  at targetSdk 36 the window is edge to edge whether we like it or not. */
    fun root(activity: Activity): LinearLayout = LinearLayout(activity).apply {
        orientation = LinearLayout.VERTICAL
        gravity = Gravity.CENTER
        setBackgroundColor(color(activity, R.color.native_background))
        val side = dp(activity, 24)
        setOnApplyWindowInsetsListener { v, insets ->
            val bars = insets.getInsets(WindowInsets.Type.systemBars() or WindowInsets.Type.ime())
            v.setPadding(side + bars.left, side + bars.top, side + bars.right, side + bars.bottom)
            WindowInsets.CONSUMED
        }
    }

    fun text(ctx: Context, value: String, sp: Float, primary: Boolean = true): TextView = TextView(ctx).apply {
        text = value
        setTextSize(TypedValue.COMPLEX_UNIT_SP, sp)
        setTextColor(color(ctx, if (primary) R.color.native_text else R.color.native_text_secondary))
        gravity = Gravity.CENTER
        fontFeatureSettings = "tnum"
        layoutParams = full(ctx, top = 8)
    }

    fun primary(ctx: Context, label: String, onClick: () -> Unit): Button =
        button(ctx, label, R.color.native_accent, R.color.native_on_accent, onClick)

    fun secondary(ctx: Context, label: String, onClick: () -> Unit): Button =
        button(ctx, label, R.color.native_field, R.color.native_text, onClick)

    private fun button(ctx: Context, label: String, bg: Int, fg: Int, onClick: () -> Unit) = Button(ctx).apply {
        text = label
        isAllCaps = false
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
        setTextColor(color(ctx, fg))
        background = GradientDrawable().apply {
            cornerRadius = dp(ctx, 28).toFloat()
            setColor(color(ctx, bg))
        }
        stateListAnimator = null
        layoutParams = full(ctx, top = 16, height = dp(ctx, 56))
        setOnClickListener { onClick() }
    }

    fun field(ctx: Context, hint: String, numeric: Boolean): EditText = EditText(ctx).apply {
        this.hint = hint
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 18f)
        setTextColor(color(ctx, R.color.native_text))
        setHintTextColor(color(ctx, R.color.native_text_secondary))
        gravity = Gravity.CENTER
        inputType = if (numeric) InputType.TYPE_CLASS_NUMBER or InputType.TYPE_NUMBER_FLAG_SIGNED
        else InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS
        background = GradientDrawable().apply {
            cornerRadius = dp(ctx, 12).toFloat()
            setColor(color(ctx, R.color.native_field))
        }
        val p = dp(ctx, 12)
        setPadding(p, p, p, p)
        layoutParams = full(ctx, top = 16)
    }

    fun spacer(ctx: Context, height: Int): View = View(ctx).apply {
        layoutParams = LinearLayout.LayoutParams(1, dp(ctx, height))
    }

    private fun full(ctx: Context, top: Int, height: Int = ViewGroup.LayoutParams.WRAP_CONTENT) =
        LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, height).apply { topMargin = dp(ctx, top) }

    /** Trimmed, lower-cased, runs of space collapsed: a typed sentence is
     *  matched on its words, not its spacing (alarms LLD §5). */
    fun normalise(s: String): String = s.trim().lowercase().replace(Regex("\\s+"), " ")
}
