# Decisions

Each decision, what it bought, and what it cost. Numbered for reference from other documents
and from comments in the code. When a decision is reversed, it stays here with the reversal
written under it — the reversal is usually the more useful half.

---

### D1 · No server, no network
**Chose:** everything on the phone. The release build does not declare `INTERNET`.
**Bought:** nothing to run, nothing to pay for, nothing that can leak, and a blocker that
works in flight mode.
**Cost:** no plain-English entry, no update check — a new version is something you go and
fetch.

### D2 · No sync, no backup
**Chose:** one phone, one SQLite file, gone with the app.
**Rejected:** little-loaf's Drive journal model. It solves a two-phone problem this app does
not have, and costs a sign-in, a network, and the hardest code in that repository.
**Cost:** a lost phone loses the habits. They take minutes to re-enter; the history does not
come back.
**Revisit when:** history becomes something worth keeping across phones.

### D3 · Side-loaded from GitHub, not the Play Store
**Chose:** a debug APK per push to `main`, a signed release APK on demand — the little-loaf
pipeline.
**Bought:** `USE_EXACT_ALARM` granted at install, full-screen alarms without a policy
declaration, and an accessibility service nobody has to approve.
**Cost:** Android 13+ greys out accessibility for side-loaded apps until *Allow restricted
settings* is used. Setup has to say so (permissions HLD).

### D4 · Friction and a log, not a lock
**Chose:** a pause is always possible — after a wait and a typed sentence — and is always
recorded. Hard habits wait twice as long.
**Rejected:** device admin and refusing pauses outright. A blocker you cannot escape is a
blocker you uninstall the first time it is wrong; the log is what keeps you honest.
**Cost:** someone determined can always get through. That is accepted.

### D5 · Android 16 and above only
**Chose:** `minSdk 36`, `targetSdk 36`.
**Bought:** every API used — `canUseFullScreenIntent`, `canScheduleExactAlarms`,
foreground-service types, `Notification.Builder` — is platform, not compat. No `androidx.core`.
**Cost:** nothing older installs it. One user, one phone: accepted.

### D6 · Flutter for the app, Kotlin for everything that runs while it is closed
**Chose:** Dart draws the screens and owns the data. Kotlin owns the accessibility blocker,
exact alarms, ringing, notifications and DND.
**Rejected:** all-Kotlin (one language, no bridge) — the owner chose Flutter to match
little-loaf. And all-Dart through plugins — a blocker and an alarm screen must start without
waiting for a Flutter engine, and no plugin does either well.
**Cost:** two languages and a contract between them. The contract is kept to two files and
one channel ([bridge HLD](../01-platform/bridge/hld.md)).

### D7 · Dart owns SQLite; Kotlin never opens it
**Chose:** Kotlin gets what it needs as a plan file, and reports back as an event file.
**Rejected:** Kotlin reading the database directly. drift ships its own SQLite; Android's
framework ships another. Two SQLite libraries on one file in one process do not share POSIX
locks, which is SQLite's own documented route to corruption.
**Cost:** Kotlin cannot answer a question the plan did not anticipate.

### D8 · The plan is dates and minutes, not instants
**Chose:** each window is `(date, startMinute, endMinute)` in wall-clock terms. Kotlin turns
them into instants with the time zone of the moment it uses them.
**Bought:** a time-zone change or a DST jump re-arms correctly from the same file, with no Dart.
**Rejected:** epoch milliseconds, which bake in the zone at planning time; and weekly rules,
which would make Kotlin interpret habits — midnight crossings, overlaps, one-off alarms —
twice, in two languages.

### D9 · A 14-day horizon, renewed whenever the app opens
**Chose:** the plan covers yesterday (for windows crossing into today) through 13 days ahead.
Every launch and resume rebuilds it. Two days before it runs out, a notification says so.
**Rejected:** a headless Flutter engine woken nightly to re-plan. It works, and it is the most
fragile thing that could be added; a notification you can act on is not.
**Revisit when:** the warning is ever actually seen in practice.

### D10 · Events are a file Kotlin appends and Dart acknowledges
**Chose:** `events.jsonl`, one JSON object per line, each with its own id. Dart reads all,
inserts with `INSERT OR IGNORE`, then acknowledges exactly the ids it inserted.
**Rejected:** read-and-truncate in one call. A crash between the read and the insert would
lose the very events that say a rule was broken.

### D11 · One boundary armed at a time, chained
**Chose:** Kotlin arms only the next boundary and the next alarm. Each, when it fires, arms the
one after.
**Bought:** two pending intents instead of hundreds; nothing to cancel by id when the plan
changes — re-arming replaces both.
**Cost:** if a chain link is lost, the chain stops. Every install, boot, time change and
app open re-arms it.

### D12 · Overlaps are settled when a habit is saved
**Chose:** the overlap engine runs before the write. At run time, two windows at once simply
block the union of their apps.
**Bought:** Kotlin needs no conflict logic, and the user decides once rather than being
surprised at 21:00.

### D13 · The habit that gives way may be the one already saved
**Chose:** the yielding habit is decided by strictness and priority, not by which one is being
edited. A resolution may rewrite the other habit; both are written in one transaction.
**Rejected:** "the one you are editing always moves". Saving a hard habit over a soft one
would then be impossible without first editing the soft one by hand.

### D14 · A buffer before hard habits, not between them
**Chose:** a soft habit may not run into the *N* minutes before a hard one starts (default 15).
Two hard habits may sit back to back.
**Why:** the buffer exists so *learning* does not end at the second *sleep* starts. Two hard
commitments back to back are a schedule, not a mistake.

### D15 · Alarms are instants; the same minute rings once
**Chose:** alarms never take part in overlap checks. Two alarms at one minute are merged:
labels joined, the hardest challenge, the fewest snoozes, vibrate if either does.

### D16 · The block screen and the alarm screen are native
**Chose:** plain Kotlin activities, not Flutter.
**Bought:** they appear instantly from a cold process — no engine start between a tap on
Instagram and the block screen, and none between the alarm and the screen that stops it.
**Cost:** two screens styled to match by hand. Their look is in the design system.

### D17 · Do Not Disturb is reconciled, not toggled
**Chose:** at every boundary, Kotlin computes whether a DND window is running and makes the
phone agree — turning DND off only if Habit Force turned it on.
**Rejected:** on at start, off at end. A missed end would leave DND on for good; DND the user
set themselves would be switched off under them.

### D18 · A boundary more than two minutes late is skipped
**Chose:** when the chain fires, boundaries due in the last two minutes are acted on; older
ones are dropped silently.
**Why:** after a reboot or a long Doze, a burst of yesterday's *Learning has started* is noise,
and a `window_started` stamped when nothing was enforced would be a lie in History.

### D19 · Habits are archived, never deleted
**Chose:** `archived_at`. Archived habits are not planned, not shown in Habits, and keep their
name in History.

### D20 · A window that never started neither counts nor breaks a streak
**Chose:** a streak is read from `window_started` events, not from the rules.
**Why:** a phone switched off through a habit did not keep it and did not break it; the app
cannot know which, so it does not guess.

### D21 · Ids: UUID v7 in Dart, random UUIDs in Kotlin events
**Chose:** rows Dart creates get UUID v7 (time-ordered). Events from Kotlin carry
`UUID.randomUUID()`; they are ordered by their `at`, never by id.
