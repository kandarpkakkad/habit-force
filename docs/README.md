# Habit Force — design documentation

The [PRD](PRD.md) says **what** the product is. Everything here says **how** it is built.

```
docs/
  PRD.md                     the product definition — read this first
  00-overview/               whole-system view
    hld.md                   architecture, the Dart/Kotlin split, cross-cutting rules
    decisions.md             every decision made, and what it cost (D1…)
    glossary.md              terms used precisely throughout
  01-platform/               technical systems, no habit meaning
    storage/                 SQLite, settings, migrations, ids
    bridge/                  plan.json, events.jsonl, the method channel
    permissions/             the six permissions, read live
    versioning/              the version in two files
  02-domain/                 what the app is for
    habits/  schedule/  alarms/  blocking/  notifications/  history/
  03-frontend/
    design-system.md         colour, type, components, the native screens
    navigation.md            shell, tabs, routes
    screen-dsl.md            every screen, declared
```

## The code is the source of truth

These documents **describe** what is built; they do not define it. Where a document and the
code disagree, the code is right and the document is stale — fix the document in the same
commit. The schema lives in `lib/platform/storage/tables.dart`; the `schema.md` files
describe it.

| Area | State |
|---|---|
| storage, settings | built |
| bridge — plan install, events read/ack, apps list, permission status | built |
| schedule — overlap engine, planner, publisher | built, unit tested |
| habits — editor, overlap sheet, archive, apps picker | built |
| alarms — editor, scheduling, ringing, challenges, snooze, test | built. **Never run on a phone** |
| blocking — accessibility service, block screen, pause | built. **Never run on a phone** |
| notifications — boundary chain, batching, DND | built. **Never run on a phone** |
| history — collect, streaks, day view | built, streaks unit tested |
| setup checklist | built |
| CI — debug APK per push, signed release | written, **never run** |

**Nothing native has been observed on a device yet.** It compiles and the APK builds; that is
all that is known. The first install on a phone is the first real test of every row marked so.

## What each document type contains

| | |
|---|---|
| **HLD** | Purpose · responsibilities · what it owns · what it depends on · key decisions · failure modes · explicit non-goals |
| **schema** | Tables and stored file shapes as they exist in code: DDL, constraints, indexes, and what is deliberately *not* stored. Never duplicated in an HLD or LLD |
| **LLD** | Algorithms in pseudocode · function contracts · state transitions · validation · edge cases · what to test. **References `schema.md`; never restates it** |
| **Screens** | Every screen in a compact declarative notation |

## Before you change anything

[`../AGENTS.md`](../AGENTS.md) — how work is done here, and why the documents come first.

## Reading order

1. [PRD](PRD.md)
2. [Overview HLD](00-overview/hld.md)
3. [Decisions](00-overview/decisions.md)
4. [Bridge](01-platform/bridge/hld.md) — everything native hangs off it
5. Then whichever system you are about to touch.

## Rules that hold everywhere

- **Kotlin never opens the database** (D7). It reads the plan and appends events.
- **The plan is rebuilt whole** from the database on every change, never patched.
- **The plan speaks in dates and minutes**, never instants (D8).
- **Events are acknowledged after they are kept** (D10).
- **Every rule-break is recorded.** Pause, snooze, dismiss, miss, blocker off.
- **Times of day are integer minutes.** Instants are epoch milliseconds.
- **Habits are archived, never deleted** (D19).
- **Never gate a feature on a check.** Offer it; let it fail loudly and say why.
