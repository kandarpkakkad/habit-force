package com.habitforce.habit_force

import android.content.Context
import android.content.SharedPreferences

/** Native-only state. One home for each key: docs/01-platform/bridge/schema.md. */
object Prefs {
    const val PAUSED_UNTIL = "pausedUntil"
    const val LAST_HANDLED_AT = "lastHandledAt"
    const val DND_SET_BY_US = "dndSetByUs"
    const val ASKED_NOTIFICATIONS = "askedNotifications"

    fun of(ctx: Context): SharedPreferences =
        ctx.getSharedPreferences("habit_force_native", Context.MODE_PRIVATE)
}
