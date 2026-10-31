package com.habitforce.habit_force.plan

import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.ZoneId
import java.time.format.DateTimeParseException

// The plan Dart hands over: dates and minutes, never instants (D8). Shapes:
// docs/01-platform/bridge/schema.md. A field added there is added here and to
// Dart's PlanCodec in the same commit; a field this file does not know is
// ignored, so an older native side survives a newer Dart side.

class PlanInvalid(message: String) : Exception(message)

data class PlanApp(val pkg: String, val label: String)

data class PlanSettings(
    val headsUpMinutes: Int,
    val pauseMinutes: Int,
    val pauseCooldownSeconds: Int,
    val pausePhrase: String,
) {
    companion object {
        val DEFAULT = PlanSettings(10, 5, 60, "I am choosing to break my own rule")
    }
}

data class PlanWindow(
    val key: String,
    val habitId: String,
    val name: String,
    val hard: Boolean,
    val priority: Int,
    val dnd: Boolean,
    val date: LocalDate,
    val start: Int,
    val end: Int,
    val apps: List<PlanApp>,
) {
    val packages: Set<String> = apps.mapTo(HashSet()) { it.pkg }

    fun startAt(zone: ZoneId): Long = Time.instant(date, start, zone)
    fun endAt(zone: ZoneId): Long = Time.instant(date, end, zone)
    fun isRunning(now: Long, zone: ZoneId): Boolean = startAt(zone) <= now && now < endAt(zone)
}

data class PlanAlarm(
    val key: String,
    val alarmIds: List<String>,
    val label: String,
    val date: LocalDate,
    val minute: Int,
    val vibrate: Boolean,
    val snoozeMinutes: Int,
    val snoozeLimit: Int,
    val challenge: String,
) {
    fun at(zone: ZoneId): Long = Time.instant(date, minute, zone)

    /** The entry travels as JSON in alarm intents, so a snooze or a test
     *  never depends on the plan still containing it (alarms LLD §2). */
    fun toJson(): String = JSONObject()
        .put("key", key)
        .put("alarmIds", JSONArray(alarmIds))
        .put("label", label)
        .put("date", date.toString())
        .put("minute", minute)
        .put("vibrate", vibrate)
        .put("snoozeMinutes", snoozeMinutes)
        .put("snoozeLimit", snoozeLimit)
        .put("challenge", challenge)
        .toString()

    companion object {
        fun parse(json: String): PlanAlarm = guarded { from(JSONObject(json)) }

        internal fun from(o: JSONObject): PlanAlarm {
            val challenge = o.getString("challenge")
            if (challenge !in setOf("none", "sum", "phrase")) throw PlanInvalid("unknown challenge '$challenge'")
            val ids = o.getJSONArray("alarmIds")
            return PlanAlarm(
                key = o.getString("key"),
                alarmIds = List(ids.length()) { ids.getString(it) },
                label = o.optString("label", ""),
                date = LocalDate.parse(o.getString("date")),
                minute = o.getInt("minute"),
                vibrate = o.optBoolean("vibrate", true),
                snoozeMinutes = o.getInt("snoozeMinutes"),
                snoozeLimit = o.getInt("snoozeLimit"),
                challenge = challenge,
            )
        }
    }
}

data class Plan(
    val generatedAt: Long,
    val firstDate: LocalDate?,
    val horizon: LocalDate?,
    val settings: PlanSettings,
    val windows: List<PlanWindow>,
    val alarms: List<PlanAlarm>,
) {
    companion object {
        const val VERSION = 1

        /** A real plan with nothing in it. Every caller can use whatever
         *  PlanStore.load returns without a null check — an unreadable file
         *  must never take the blocker or the alarm path down with it. */
        val EMPTY = Plan(0, null, null, PlanSettings.DEFAULT, emptyList(), emptyList())

        fun parse(json: String): Plan = guarded {
            val o = JSONObject(json)
            val version = o.getInt("version")
            if (version != VERSION) throw PlanInvalid("plan version $version, this build reads $VERSION")
            val s = o.getJSONObject("settings")
            val windows = o.getJSONArray("windows")
            val alarms = o.getJSONArray("alarms")
            Plan(
                generatedAt = o.getLong("generatedAt"),
                firstDate = LocalDate.parse(o.getString("firstDate")),
                horizon = LocalDate.parse(o.getString("horizon")),
                settings = PlanSettings(
                    headsUpMinutes = s.getInt("headsUpMinutes"),
                    pauseMinutes = s.getInt("pauseMinutes"),
                    pauseCooldownSeconds = s.getInt("pauseCooldownSeconds"),
                    pausePhrase = s.getString("pausePhrase"),
                ),
                windows = List(windows.length()) { window(windows.getJSONObject(it)) },
                alarms = List(alarms.length()) { PlanAlarm.from(alarms.getJSONObject(it)) },
            )
        }

        private fun window(o: JSONObject): PlanWindow {
            val start = o.getInt("start")
            val end = o.getInt("end")
            if (start !in 0..1439) throw PlanInvalid("window start $start outside 0..1439")
            if (end <= start || end > start + 1439) throw PlanInvalid("window end $end does not follow start $start")
            val apps = o.getJSONArray("apps")
            return PlanWindow(
                key = o.getString("key"),
                habitId = o.getString("habitId"),
                name = o.getString("name"),
                hard = o.getBoolean("hard"),
                priority = o.getInt("priority"),
                dnd = o.optBoolean("dnd", false),
                date = LocalDate.parse(o.getString("date")),
                start = start,
                end = end,
                apps = List(apps.length()) {
                    val a = apps.getJSONObject(it)
                    PlanApp(a.getString("package"), a.optString("label", a.getString("package")))
                },
            )
        }
    }
}

private inline fun <T> guarded(block: () -> T): T = try {
    block()
} catch (e: JSONException) {
    throw PlanInvalid(e.message ?: "not valid JSON")
} catch (e: DateTimeParseException) {
    throw PlanInvalid("bad date '${e.parsedString}'")
}

object Time {
    /** Wall-clock minutes, not elapsed ones (D8): plusMinutes moves the clock
     *  face, then atZone resolves a DST gap forward and an overlap to the
     *  earlier offset. The zone is read every time, never cached, so a zone
     *  change is picked up by the next call. docs/01-platform/bridge/lld.md §3 */
    fun instant(date: LocalDate, minute: Int, zone: ZoneId = ZoneId.systemDefault()): Long =
        LocalDateTime.of(date, LocalTime.MIDNIGHT).plusMinutes(minute.toLong())
            .atZone(zone).toInstant().toEpochMilli()

    fun hhmm(minutes: Int): String {
        val m = Math.floorMod(minutes, 1440)
        return "%02d:%02d".format(m / 60, m % 60)
    }
}
