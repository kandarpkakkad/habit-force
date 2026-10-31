import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_force/domain/habits/habits_repository.dart';
import 'package:habit_force/domain/schedule/overlaps.dart';
import 'package:habit_force/domain/settings/settings.dart';
import 'package:habit_force/platform/storage/database.dart';

import '../support/support.dart';

// docs/02-domain/habits/lld.md §3 and §7. The real schema, in memory, so the
// CHECKs are the real ones.

void main() {
  late AppDatabase db;
  late HabitsRepository habits;
  var published = 0;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    habits = HabitsRepository(db, SettingsRepository(db))..onChanged = () async => published++;
    published = 0;
  });
  tearDown(() => db.close());

  test('invalid drafts are not written', () async {
    final r = await habits.save(habit('h', start: '21:00', end: '21:00', days: 0, name: ' '));
    expect(r, isA<Invalid>());
    expect((r as Invalid).errors.keys, containsAll(['name', 'days', 'time']));
    expect(await habits.watchAll().first, isEmpty);
    expect(published, 0);
  });

  test('a refused save writes nothing', () async {
    await habits.save(habit('sleep', start: '23:00', end: '06:30', hard: true));
    final r = await habits.save(habit('night', start: '05:00', end: '07:00', hard: true));
    expect(r, isA<SaveRefused>());
    expect((await habits.watchAll().first).map((h) => h.id), ['sleep']);
  });

  test('a resolution that moves the existing habit writes both, and publishes once (D13)', () async {
    await habits.save(habit('learning', start: '21:00', end: '22:00'));
    published = 0;

    final gym = habit('gym', start: '21:30', end: '22:30', hard: true);
    final first = await habits.save(gym);
    expect(first, isA<SaveNeedsChoice>());
    final shift = (first as SaveNeedsChoice).report.sections.single.proposals.whereType<Shift>().first;

    expect(await habits.save(gym, resolution: {'learning': shift}), isA<Saved>());
    final all = {for (final h in await habits.watchAll().first) h.id: h};
    expect(all.keys, containsAll(['learning', 'gym']));
    expect(all['learning']!.start.label, '22:30');
    expect(published, 1);
  });

  test('a stale resolution is caught by the re-check', () async {
    await habits.save(habit('learning', start: '21:00', end: '22:00'));
    final gym = habit('gym', start: '21:30', end: '22:30', hard: true);
    final report = (await habits.save(gym) as SaveNeedsChoice).report;
    final shift = report.sections.single.proposals.whereType<Shift>().first;

    // Something new lands where the proposal pointed while the sheet was open.
    await habits.save(habit('reading', start: '22:45', end: '23:15', hard: true));

    expect(await habits.save(gym, resolution: {'learning': shift}), isA<SaveNeedsChoice>());
    expect((await habits.watchAll().first).map((h) => h.id), isNot(contains('gym')));
  });

  test('a disabled habit is saved without an overlap check', () async {
    await habits.save(habit('sleep', start: '23:00', end: '06:30', hard: true));
    final r = await habits.save(habit('night', start: '05:00', end: '07:00', hard: true, enabled: false));
    expect(r, isA<Saved>());
  });
}
