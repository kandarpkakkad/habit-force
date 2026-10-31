package com.habitforce.habit_force.history

import android.content.Context
import org.json.JSONException
import org.json.JSONObject
import java.io.File
import java.io.IOException
import java.util.UUID

/** files/events.jsonl: appended here, read and acknowledged by Dart (D10).
 *  Every writer is in this one process, so one JVM lock orders them.
 *  docs/01-platform/bridge/lld.md §4 */
object EventLog {
    private val lock = Any()

    private fun file(ctx: Context) = File(ctx.filesDir, "events.jsonl")

    fun append(
        ctx: Context,
        kind: String,
        habitId: String? = null,
        occurrence: String? = null,
        alarmId: String? = null,
        pkg: String? = null,
        detail: String? = null,
        at: Long = System.currentTimeMillis(),
    ) {
        // Absent fields are omitted, not written as null.
        val o = JSONObject()
            .put("id", UUID.randomUUID().toString())
            .put("at", at)
            .put("kind", kind)
        habitId?.let { o.put("habitId", it) }
        occurrence?.let { o.put("occurrence", it) }
        alarmId?.let { o.put("alarmId", it) }
        pkg?.let { o.put("package", it) }
        detail?.let { o.put("detail", it) }
        synchronized(lock) { file(ctx).appendText(o.toString() + "\n", Charsets.UTF_8) }
    }

    /** (events, torn): lines that parse as an object with a string id, and
     *  lines that do not — a power cut mid-append leaves one of those. */
    fun read(ctx: Context): Pair<List<String>, List<String>> {
        val lines = synchronized(lock) {
            val f = file(ctx)
            if (f.exists()) f.readLines(Charsets.UTF_8).filter { it.isNotBlank() } else emptyList()
        }
        val events = ArrayList<String>()
        val torn = ArrayList<String>()
        for (line in lines) if (idOf(line) != null) events += line else torn += line
        return events to torn
    }

    /** Removes exactly those lines, by id or by raw text. Lines appended
     *  since the read are untouched: this goes by id, not by position. */
    fun ack(ctx: Context, ids: Set<String>, torn: Set<String>): Int = synchronized(lock) {
        val f = file(ctx)
        if (!f.exists()) return 0
        val lines = f.readLines(Charsets.UTF_8).filter { it.isNotBlank() }
        val keep = lines.filterNot { line -> line in torn || idOf(line)?.let { it in ids } == true }
        val tmp = File(ctx.filesDir, "events.jsonl.tmp")
        tmp.writeText(keep.joinToString("") { it + "\n" }, Charsets.UTF_8)
        // Failing here leaves every line in place; the next collect re-reads
        // them and the inserts ignore the ones already kept.
        if (!tmp.renameTo(f)) throw IOException("could not replace ${f.path}")
        lines.size - keep.size
    }

    private fun idOf(line: String): String? = try {
        JSONObject(line).optString("id").takeIf { it.isNotEmpty() }
    } catch (e: JSONException) {
        null
    }
}
