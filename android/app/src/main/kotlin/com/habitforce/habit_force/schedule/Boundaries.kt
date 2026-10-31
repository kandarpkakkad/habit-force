package com.habitforce.habit_force.schedule

import com.habitforce.habit_force.plan.Plan
import com.habitforce.habit_force.plan.PlanWindow
import com.habitforce.habit_force.plan.Time
import java.time.LocalDate
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Locale

enum class BoundaryKind { HEADS_UP, START, END, EXPIRY }

data class Boundary(val at: Long, val kind: BoundaryKind, val window: PlanWindow?)

/** Pure: the moments the chain acts on, from a plan and a zone.
 *  docs/02-domain/notifications/lld.md §1–2 */
object Boundaries {
    /** An alarm delivered a moment early still counts as due. */
    const val TOLERANCE_MS = 1_000L

    /** Anything later than this is passed over without a word (D18). */
    const val STALE_MS = 120_000L

    fun of(plan: Plan, zone: ZoneId): List<Boundary> {
        val out = ArrayList<Boundary>()
        val headsUp = plan.settings.headsUpMinutes * 60_000L
        for (w in plan.windows) {
            val s = w.startAt(zone)
            if (headsUp > 0) out += Boundary(s - headsUp, BoundaryKind.HEADS_UP, w)
            out += Boundary(s, BoundaryKind.START, w)
            out += Boundary(w.endAt(zone), BoundaryKind.END, w)
        }
        plan.horizon?.let { out += Boundary(Time.instant(it.minusDays(2), 20 * 60, zone), BoundaryKind.EXPIRY, null) }
        return out.sortedWith(compareBy<Boundary>({ it.at }, { it.kind.ordinal }))
    }

    fun next(plan: Plan, after: Long, zone: ZoneId): Boundary? = of(plan, zone).firstOrNull { it.at > after }

    fun due(plan: Plan, last: Long, now: Long, zone: ZoneId): List<Boundary> =
        of(plan, zone).filter { it.at > last && it.at <= now + TOLERANCE_MS }

    fun fresh(due: List<Boundary>, now: Long): List<Boundary> = due.filter { now - it.at <= STALE_MS }
}

/** One notification per kind per minute, naming every habit in it.
 *  docs/02-domain/notifications/lld.md §3 */
object BoundaryText {
    private val dateFormat = DateTimeFormatter.ofPattern("EEE d MMM", Locale.ENGLISH)

    fun names(list: List<String>): String = when (list.size) {
        0 -> ""
        1 -> list[0]
        else -> list.dropLast(1).joinToString(", ") + " and " + list.last()
    }

    fun title(kind: BoundaryKind, windows: List<PlanWindow>): String {
        val names = names(windows.map { it.name }.distinct())
        val one = windows.map { it.name }.distinct().size == 1
        return when (kind) {
            BoundaryKind.HEADS_UP ->
                "$names ${if (one) "starts" else "start"} at ${Time.hhmm(windows.first().start)}"
            BoundaryKind.START -> "$names ${if (one) "has" else "have"} started"
            BoundaryKind.END -> "$names ${if (one) "is" else "are"} done"
            BoundaryKind.EXPIRY -> "Open Habit Force to keep your habits running"
        }
    }

    /** Null when there is nothing worth a second line — never the word "null". */
    fun text(kind: BoundaryKind, windows: List<PlanWindow>, horizon: LocalDate?): String? = when (kind) {
        BoundaryKind.HEADS_UP -> {
            val labels = windows.flatMap { w -> w.apps.map { it.label } }.distinct()
            if (labels.isEmpty()) null else "${labels.joinToString(", ")} will be blocked"
        }
        BoundaryKind.START ->
            if (windows.size == 1) "until ${Time.hhmm(windows[0].end)}"
            else windows.joinToString(" · ") { "${it.name} until ${Time.hhmm(it.end)}" }
        BoundaryKind.END -> null
        BoundaryKind.EXPIRY -> horizon?.let { "The plan ends on ${it.format(dateFormat)}." }
    }
}
