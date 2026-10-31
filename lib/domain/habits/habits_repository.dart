import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../../platform/storage/database.dart';
import '../schedule/overlaps.dart';
import '../settings/settings.dart';
import 'habit.dart';

sealed class SaveOutcome {
  const SaveOutcome();
}

class Saved extends SaveOutcome {
  const Saved();
}

class Invalid extends SaveOutcome {
  final Map<String, String> errors;

  const Invalid(this.errors);
}

class SaveRefused extends SaveOutcome {
  final Refused report;

  const SaveRefused(this.report);
}

class SaveNeedsChoice extends SaveOutcome {
  final NeedsChoice report;

  const SaveNeedsChoice(this.report);
}

class HabitsRepository {
  final AppDatabase db;
  final SettingsRepository settings;

  /// Set by boot: republish the plan (docs/02-domain/schedule/lld.md §4).
  Future<void> Function() onChanged = () async {};

  HabitsRepository(this.db, this.settings);

  // A join, so a change to either table reaches every screen watching.
  Stream<List<Habit>> watchAll() {
    final q = db.select(db.habits).join([
      leftOuterJoin(db.habitApps, db.habitApps.habitId.equalsExp(db.habits.id)),
    ]);
    return q.watch().map(_group);
  }

  /// Not archived: what the Habits tab lists.
  Stream<List<Habit>> watchCurrent() =>
      watchAll().map((all) => [for (final h in all) if (h.archivedAt == null) h]);

  Future<List<Habit>> loadAll() async {
    final q = db.select(db.habits).join([
      leftOuterJoin(db.habitApps, db.habitApps.habitId.equalsExp(db.habits.id)),
    ]);
    return _group(await q.get());
  }

  List<Habit> _group(List<TypedResult> rows) {
    final byId = <String, (HabitRow, List<HabitAppRow>)>{};
    for (final r in rows) {
      final h = r.readTable(db.habits);
      final entry = byId.putIfAbsent(h.id, () => (h, <HabitAppRow>[]));
      final app = r.readTableOrNull(db.habitApps);
      if (app != null) entry.$2.add(app);
    }
    final out = [
      for (final (h, apps) in byId.values)
        Habit.fromRows(h, apps.sortedBy((a) => a.label.toLowerCase())),
    ];
    out.sort((a, b) {
      final enabled = (b.enabled ? 1 : 0).compareTo(a.enabled ? 1 : 0);
      return enabled != 0 ? enabled : a.start.compareTo(b.start);
    });
    return out;
  }

  /// The only way a habit is written, enabled, or moved by a resolution
  /// (AGENTS.md §2, *One entry point per transition*).
  /// docs/02-domain/habits/lld.md §3.
  Future<SaveOutcome> save(Habit draft, {Map<String, Proposal>? resolution}) async {
    if (draft.hard && draft.priority != kPriorityNormal) {
      draft = draft.copyWith(priority: kPriorityNormal);
    }
    draft = draft.copyWith(name: draft.name.trim());

    final errors = validateHabit(draft);
    if (errors.isNotEmpty) return Invalid(errors);

    if (!draft.enabled) {
      await _write([draft]);
      await onChanged();
      return const Saved();
    }

    final buffer = (await settings.get()).hardBufferMinutes;
    final others = [for (final h in await loadAll()) if (h.id != draft.id && h.active) h];
    final NeedsChoice report;
    switch (checkOverlaps(draft, others, buffer)) {
      case Clean():
        await _write([draft]);
        await onChanged();
        return const Saved();
      case final Refused refused:
        return SaveRefused(refused);
      case final NeedsChoice needs:
        if (resolution == null) return SaveNeedsChoice(needs);
        report = needs;
    }

    // Apply the choices, then check again from scratch. The proposals were
    // computed against the habits as they were when the sheet opened; this
    // keeps "nothing clashing is written without a keep-both" true regardless.
    final keptWith = <String>{};
    var candidate = draft;
    final moved = <String, Habit>{};
    for (final section in report.sections) {
      final choice = resolution[section.yielder.id];
      if (choice == null) return SaveNeedsChoice(report);
      if (choice is KeepBoth) {
        if (section.isCandidate) {
          keptWith.addAll(section.clashes.map((c) => c.other.id));
        } else {
          keptWith.add(section.yielder.id);
        }
      } else if (section.isCandidate) {
        candidate = applyProposal(candidate, choice);
      } else {
        moved[section.yielder.id] = applyProposal(section.yielder, choice);
      }
    }

    final resolvedOthers = [for (final o in others) moved[o.id] ?? o];
    final remaining = clashesOf(candidate, resolvedOthers, buffer)
        .where((c) => !(c.softSoft && keptWith.contains(c.other.id)))
        .toList();
    final movedStillClash = moved.values.any((m) => clashesOf(
          m,
          [for (final o in resolvedOthers) if (o.id != m.id) o, candidate],
          buffer,
        ).isNotEmpty);
    if (remaining.isNotEmpty || movedStillClash) {
      final fresh = checkOverlaps(candidate, resolvedOthers, buffer);
      return switch (fresh) {
        Refused() => SaveRefused(fresh),
        NeedsChoice() => SaveNeedsChoice(fresh),
        // The candidate is clear; a moved habit now clashes with something
        // else. Nothing better to offer than the sheet already shown.
        Clean() => SaveNeedsChoice(report),
      };
    }

    // Both habits in one transaction (D13).
    await _write([candidate, ...moved.values]);
    await onChanged();
    return const Saved();
  }

  Future<SaveOutcome> setEnabled(Habit h, bool enabled) => save(h.copyWith(enabled: enabled));

  /// Archived habits are not planned and not listed, and keep their name in
  /// History (D19). There is no unarchive and no delete.
  Future<void> archive(String id) async {
    await (db.update(db.habits)..where((t) => t.id.equals(id))).write(HabitsCompanion(
      archivedAt: Value(DateTime.now().millisecondsSinceEpoch),
      enabled: const Value(false),
    ));
    await onChanged();
  }

  Future<void> _write(List<Habit> habits) => db.transaction(() async {
        for (final h in habits) {
          await db.into(db.habits).insertOnConflictUpdate(HabitsCompanion.insert(
                id: h.id,
                name: h.name,
                days: h.days,
                startMinute: h.start.minutes,
                endMinute: h.end.minutes,
                strictness: h.strictness.name,
                priority: Value(h.priority),
                dnd: Value(h.dnd),
                enabled: Value(h.enabled),
                createdAt: h.createdAt.millisecondsSinceEpoch,
                archivedAt: Value(h.archivedAt?.millisecondsSinceEpoch),
              ));
          await (db.delete(db.habitApps)..where((t) => t.habitId.equals(h.id))).go();
          for (final a in h.apps) {
            await db.into(db.habitApps).insert(
                  HabitAppsCompanion.insert(habitId: h.id, package: a.package, label: a.label),
                );
          }
        }
      });
}
