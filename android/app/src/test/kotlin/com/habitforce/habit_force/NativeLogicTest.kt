package com.habitforce.habit_force

import com.habitforce.habit_force.block.BlockDecision
import com.habitforce.habit_force.plan.Plan
import com.habitforce.habit_force.plan.PlanApp
import com.habitforce.habit_force.plan.PlanSettings
import com.habitforce.habit_force.plan.PlanWindow
import com.habitforce.habit_force.plan.Time
import com.habitforce.habit_force.schedule.Boundaries
import com.habitforce.habit_force.schedule.BoundaryKind
import com.habitforce.habit_force.schedule.BoundaryText
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertNull
import org.junit.Test
import java.time.LocalDate
import java.time.ZoneId
import java.time.ZonedDateTime

// The pure parts of the native half: notifications LLD §7, blocking LLD §8,
// bridge LLD §8. Dates are relative to a today the test picks, never literals.

class NativeLogicTest {
    private val zone = ZoneId.of("Asia/Kolkata")
    private val today = LocalDate.now(zone)

    private fun window(
        key: String, start: Int, end: Int, date: LocalDate = today,
        hard: Boolean = false, priority: Int = 2, apps: List<String> = listOf("com.instagram.android"),
    ) = PlanWindow(key, key, key.replaceFirstChar { it.uppercase() }, hard, priority, false, date, start, end,
        apps.map { PlanApp(it, it.substringAfterLast('.')) })

    private fun plan(vararg w: PlanWindow, headsUp: Int = 10) =
        Plan(0, today.minusDays(1), today.plusDays(13), PlanSettings(headsUp, 5, 60, "phrase here"), w.toList(), emptyList())

    private fun at(minute: Int, date: LocalDate = today) = Time.instant(date, minute, zone)

    @Test fun `a window crossing midnight ends the next day`() {
        val b = Boundaries.of(plan(window("sleep", 23 * 60, 24 * 60 + 390), headsUp = 0), zone)
        val end = b.single { it.kind == BoundaryKind.END }
        assertEquals(at(390, today.plusDays(1)), end.at)
        assertEquals(0, b.count { it.kind == BoundaryKind.HEADS_UP })
    }

    @Test fun `boundaries due inside the tolerance count, stale ones are dropped`() {
        val p = plan(window("learning", 21 * 60, 22 * 60), headsUp = 0)
        val start = at(21 * 60)
        val early = Boundaries.due(p, start - 60_000, start - 500, zone)
        assertEquals(listOf(BoundaryKind.START), early.map { it.kind })

        val late = start + Boundaries.STALE_MS + 1
        val due = Boundaries.due(p, start - 60_000, late, zone)
        assertEquals(1, due.size)
        assertEquals(0, Boundaries.fresh(due, late).size)
        assertEquals(1, Boundaries.fresh(due, start + Boundaries.STALE_MS).size)
    }

    @Test fun `next skips everything already handled`() {
        val p = plan(window("learning", 21 * 60, 22 * 60))
        val next = Boundaries.next(p, at(21 * 60), zone)!!
        assertEquals(BoundaryKind.END, next.kind)
    }

    @Test fun `notification text for one, two and three habits`() {
        val a = window("learning", 21 * 60, 22 * 60)
        val b = window("reading", 21 * 60, 21 * 60 + 30, apps = emptyList())
        val c = window("gym", 21 * 60, 22 * 60, apps = emptyList())
        assertEquals("Learning starts at 21:00", BoundaryText.title(BoundaryKind.HEADS_UP, listOf(a)))
        assertEquals("Learning and Reading have started", BoundaryText.title(BoundaryKind.START, listOf(a, b)))
        assertEquals("Learning, Reading and Gym are done", BoundaryText.title(BoundaryKind.END, listOf(a, b, c)))
        assertEquals("until 22:00", BoundaryText.text(BoundaryKind.START, listOf(a), null))
        assertEquals("Learning until 22:00 · Reading until 21:30", BoundaryText.text(BoundaryKind.START, listOf(a, b), null))
        assertEquals("android will be blocked", BoundaryText.text(BoundaryKind.HEADS_UP, listOf(a), null))
        assertNull(BoundaryText.text(BoundaryKind.HEADS_UP, listOf(b), null))
    }

    @Test fun `the hard window is named over the soft one, and a pause lets everything through`() {
        val soft = window("learning", 21 * 60, 23 * 60, priority = 3)
        val hard = window("sleep", 21 * 60 + 30, 22 * 60 + 30, hard = true)
        val p = plan(soft, hard)
        val now = at(22 * 60)
        val pkg = "com.instagram.android"
        assertEquals("sleep", BlockDecision.top(p, pkg, now, 0, emptySet(), zone)?.key)
        assertNull(BlockDecision.top(p, pkg, now, now + 1, emptySet(), zone))
        assertNull(BlockDecision.top(p, pkg, now, 0, setOf(pkg), zone))
        assertNull(BlockDecision.top(p, "com.other", now, 0, emptySet(), zone))
        assertNull(BlockDecision.top(p, pkg, at(23 * 60), 0, emptySet(), zone))
    }

    @Test fun `one blocked event per app, window and minute`() {
        val w = window("learning", 21 * 60, 22 * 60)
        val t = at(21 * 60 + 5)
        assertEquals(BlockDecision.throttleKey("x", w, t), BlockDecision.throttleKey("x", w, t + 30_000))
        assertNotEquals(BlockDecision.throttleKey("x", w, t), BlockDecision.throttleKey("x", w, t + 60_000))
    }

    @Test fun `a window across a DST change keeps its clock times`() {
        val ny = ZoneId.of("America/New_York")
        // The next spring-forward day: the second Sunday of March.
        var d = LocalDate.of(today.year + 1, 3, 1)
        while (d.dayOfWeek.value != 7) d = d.plusDays(1)
        d = d.plusDays(7)
        val start = ZonedDateTime.ofInstant(java.time.Instant.ofEpochMilli(Time.instant(d, 60, ny)), ny)
        val end = ZonedDateTime.ofInstant(java.time.Instant.ofEpochMilli(Time.instant(d, 4 * 60, ny)), ny)
        assertEquals(1, start.hour)
        assertEquals(4, end.hour)
        // 01:00 to 04:00 on the clock is two hours long that night.
        assertEquals(2 * 3_600_000L, end.toInstant().toEpochMilli() - start.toInstant().toEpochMilli())
    }
}
