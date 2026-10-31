# Working on Habit Force

An offline Flutter app with a native Kotlin half that holds one person to their routine:
habits block chosen apps for their window, and alarms ring like a clock app's. No server, no
sync, no backup. Android 16+.

## Memory, first and last

**Read memory before you start. Write memory before you finish.** Every task, both ends. The
`neo4j-memory` MCP server holds what this repository cannot: what is half-finished, what broke
last time, what the owner has already decided against.

- **First**, `search_memory` — by keyword, or with no arguments to list everything. Do it
  before asking the owner a question and before writing code.
- **Last**, `save_memory` for something new, or `update_memory` for something already tracked.
  Do it before you report back, not after.

Memories about this project are the `habit-force-*` namespace, hanging off the `habit-force`
hub:

| id | holds |
|---|---|
| `habit-force` | what the product is, its scope and its hard constraints |
| `habit-force-architecture` | the Dart/Kotlin split, the bridge, and decisions not yet in `docs/` |
| `habit-force-device-findings` | what has actually been observed on a phone — and what has not |
| `habit-force-release-pipeline` | workflows, signing keys, distribution |
| `habit-force-working-agreements` | how the owner wants work done here |
| `habit-force-state-<date>` | current state and open items. Dated, and the first thing to go stale |

**Keep the line between memory and the repository.** This file and `docs/` are authoritative
for conventions, design and decisions. Memory is for what has no home here: the state of
things now, problems found but not fixed, what the owner asked for and turned down.

**If the server is not connected, say so.** Its absence means it failed to start, not that
memory does not apply.

---

Read [`docs/README.md`](docs/README.md) first, then
[`docs/00-overview/decisions.md`](docs/00-overview/decisions.md). Decisions are numbered
(D1, D2 …) and the code cites them in comments. When you touch something with a decision
behind it, read the decision.

---

## 1. Documents before code

**Write the design down first, then build to it.**

Every system has up to three documents under `docs/`:

| | Holds | Never holds |
|---|---|---|
| `hld.md` | Purpose, what it owns, key decisions, failure modes, explicit non-goals | Algorithms, DDL |
| `lld.md` | Algorithms, function contracts, state transitions, validation, edge cases | The schema — it *references* `schema.md` |
| `schema.md` | Tables, constraints, indexes, stored file shapes, what is deliberately **not** stored | Anything repeated from the HLD |

The order of work:

1. **Update `hld.md`** — what is changing and *why*.
2. **Update `schema.md`** if a shape changes — a column, or a field in `plan.json` or
   `events.jsonl`.
3. **Update `lld.md`** — the algorithm and the edge cases.
4. **Then write the code**, to match.
5. Update [`docs/README.md`](docs/README.md) if the built/not-built table moves.

**Code is the source of truth; documents must reflect it.** When the implementation has to
diverge from the design, change the document in the *same commit*, saying what you learned. A
document describing something never built is worse than none.

---

## 2. How code is written here

### Comments explain why, never what

A comment earns its place by saying why the code is like that, what it protects against, or
what was tried and failed. Cite the decision or the document: `(D8)`,
`docs/02-domain/schedule/lld.md §2.3`. Match the density of the file you are in.

### Two languages, one contract

Dart decides what habits mean; Kotlin acts on dates and minutes. **Kotlin never opens the
database** (D7) and never interprets a habit — if Kotlin needs to know something, it goes in
the plan, worked out in Dart, with a test.

A change to the plan or event shape changes **three** things in one commit:
`docs/01-platform/bridge/schema.md`, `PlanCodec` in Dart, and `Plan.parse` in Kotlin. Kotlin
ignores fields it does not know, so add fields freely; never change what an existing one means.

### Never gate a feature on a check you cannot run

A permission check, an installed-app lookup, a "can this intent resolve" — each can answer
wrongly on some phone. Platform detections belong in the *handling* of a failure, never in the
*decision to offer*. The DND switch is offered whether or not access is granted; Setup says it
will be ignored.

### An error message says the reason, not the fact

`BridgeException` carries the native exception's message. Put it on screen. *Could not save*
next to a swallowed exception costs an afternoon.

### Never interpolate a nullable into a string

Dart will happily print `null`; Kotlin will happily print `null` into a notification. Drop the
clause or supply the word.

### A placeholder is guidance; a value is content

Style hints with `hintStyle`. A hint is a shape or an instruction, never real-looking data. Do
not seed a field with a literal default to mean "nothing" — leave it empty and apply the
default on save.

### Times

Times of day are `int` minutes 0–1439 (`ClockTime` in Dart). Instants are epoch ms. The plan
holds **dates and minutes, never instants** (D8); Kotlin converts with `ZoneId.systemDefault()`
at the moment of use, every time.

**Never mint a date as a literal in a test.** Build dates relative to a `today` the test chooses
and passes in. Every engine takes `today`/`now` as a parameter for exactly this reason; none
reads the clock inside.

### Assert on `watch()`, not `get()`

Screens use streams. A test that reads back with `get()` passes while every open screen keeps
showing the old rows.

### One entry point per transition

`HabitsRepository.save` is the only way a habit is written, enabled or moved by a resolution.
Add a transition to it, never alongside it.

---

## 3. Schema changes

- `kSchemaVersion` in `lib/platform/storage/database.dart`, one entry per version in `_steps`,
  forward-only. Additive by default.
- Regenerate drift code (no Flutter needed on the host):

```bash
tool/codegen_in_docker.sh
```

which runs `dart run build_runner build --delete-conflicting-outputs --force-jit`.
`--force-jit` is required.

- **Grep for a renamed or dropped name before you finish**, including in Kotlin and in the
  plan codec — the analyser cannot see across the bridge.

---

## 4. Tests

```bash
tool/test_in_docker.sh      # flutter analyze + flutter test, in the pipeline's Flutter image
tool/build_in_docker.sh     # the debug APK — proves the Kotlin compiles
```

Both run in a throwaway container. Both must be clean before anything is called done.

**Every command is time-limited.** The scripts wrap Docker in `timeout` (20 min for
tests and codegen, 60 min for the build — override with `HABIT_FORCE_TIMEOUT=90m`),
kill and remove the container when it fires, and exit 124. CI jobs carry
`timeout-minutes`. A wait loop is always bounded — `timeout 1500 bash -c 'until …'`,
never a bare `until`. A command that can hang will, eventually, and nothing should
be able to run for ever on the owner's machine.

What is tested: the pure engines (overlaps, planner, streaks, codec) and the version guard.
What is not: anything native at run time. **There are no device or end-to-end tests** — the
owner tests on a phone.

So: when you change behaviour a screen triggers, **check the screen calls the thing you
tested.** Grep the call sites. A well-tested function with no caller is not a feature.

---

## 5. Verifying, and what you may claim

- `flutter analyze` clean, `flutter test` passing — say the number.
- The APK builds — say so, and say that is **all** it proves about Kotlin.
- **Never describe device behaviour you have not observed.** The blocker, the alarm screen,
  the boundary chain and DND have been written without touching a phone until someone records
  otherwise in `habit-force-device-findings`.
- Report failures with their output. A skipped step is said out loud.
- **Verify locally. Do not watch CI.** The local suite runs the same checks in a fraction of
  the time.

---

## 6. Build and release

- Every push to `main` **bumps the patch version**, commits it, and builds a debug APK named for
  that version. Docs-only pushes are skipped by `paths-ignore`.
- Releasing is Actions → **Release** → level `minor`: bump, commit, tag, and build a debug APK
  and a signed release APK.
- The version lives in `pubspec.yaml` and `lib/platform/versioning/version.dart`. Move them
  with `tool/bump_version.sh`, never by hand. A test fails the build if they drift.
- **Do not put the skip-ci marker in a commit message** — GitHub reads it anywhere, including a
  sentence about it. Refer to it by name.
- **A `run:` value must never begin with a quote.** `run: bash "$X" …`, not `run: "$X" …`.
  Parse workflows before pushing:

```sh
ruby -ryaml -e 'Dir[".github/workflows/*.yml"].each { |f| YAML.load_file(f) }'
```

---

## 7. Editing style

- **Surgical diffs.** Never run `dart format` across the repository. Match the file you are in.
- Do not reorganise code you are not changing.
- Remove dead code you have just orphaned, in the same change.
- Commit messages: a short imperative subject, then prose explaining *why* and what was learned.

---

## 8. Things that are deliberately absent

Do not add these back without being asked:

| | Why |
|---|---|
| A server, an account, the `INTERNET` permission in release | D1 |
| Sync, backup, export | D2 |
| A Flutter engine in the background | D9. Kotlin enforces and rings without Dart |
| `androidx.core` / compat libraries | D5. `minSdk 36` |
| Kotlin reading SQLite | D7 |
| Device admin, a pause that cannot be taken | D4 |
| Analytics, crash reporting | Nothing leaves the phone |
