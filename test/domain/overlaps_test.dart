import 'package:flutter_test/flutter_test.dart';
import 'package:habit_force/common/dates.dart';
import 'package:habit_force/domain/schedule/overlaps.dart';
import 'package:habit_force/domain/schedule/week.dart';

import '../support/support.dart';

// docs/02-domain/schedule/lld.md §2 and §6.

void main() {
  group('clashes', () {
    test('hard against hard is refused', () {
      final r = checkOverlaps(
        habit('work', start: '09:00', end: '17:00', hard: true),
        [habit('class', start: '16:00', end: '18:00', hard: true)],
        15,
      );
      expect(r, isA<Refused>());
    });

    test('Sunday night into Monday is found through the week wrap', () {
      final r = checkOverlaps(
        habit('late', start: '23:00', end: '01:00', days: dayMask([6]), hard: true),
        [habit('early', start: '00:30', end: '02:00', days: dayMask([0]), hard: true)],
        0,
      );
      expect(r, isA<Refused>());
      expect(describeSpans((r as Refused).clashes.single.common), ['Mon 00:30–01:00']);
    });

    test('a soft habit inside the buffer before a hard one gives way', () {
      final r = checkOverlaps(
        habit('learning', start: '21:00', end: '22:50'),
        [habit('sleep', start: '23:00', end: '06:30', hard: true)],
        15,
      );
      expect(r, isA<NeedsChoice>());
      expect((r as NeedsChoice).sections.single.isCandidate, isTrue);
    });

    test('ending exactly where the buffer starts is clean', () {
      final r = checkOverlaps(
        habit('learning', start: '21:00', end: '22:45'),
        [habit('sleep', start: '23:00', end: '06:30', hard: true)],
        15,
      );
      expect(r, isA<Clean>());
    });

    test('two hard habits back to back do not clash (D14)', () {
      final r = checkOverlaps(
        habit('work', start: '09:00', end: '17:00', hard: true),
        [habit('commute', start: '17:00', end: '18:00', hard: true)],
        15,
      );
      expect(r, isA<Clean>());
    });

    test('disabled habits are not checked', () {
      final r = checkOverlaps(
        habit('learning', start: '21:00', end: '22:00'),
        [habit('reading', start: '21:30', end: '22:30', enabled: false)],
        0,
      );
      expect(r, isA<Clean>());
    });
  });

  group('who gives way', () {
    test('equal soft priorities: the habit being saved, with keep-both offered', () {
      final r = checkOverlaps(
        habit('new', start: '21:00', end: '22:00'),
        [habit('old', start: '21:30', end: '22:30')],
        0,
      ) as NeedsChoice;
      final s = r.sections.single;
      expect(s.isCandidate, isTrue);
      expect(s.proposals.whereType<KeepBoth>(), hasLength(1));
    });

    test('a lower-priority existing habit gives way to the one being saved', () {
      final r = checkOverlaps(
        habit('new', start: '21:00', end: '22:00', priority: 3),
        [habit('old', start: '21:30', end: '22:30', priority: 1)],
        0,
      ) as NeedsChoice;
      expect(r.sections.single.yielder.id, 'old');
    });

    test('saving a hard habit moves the existing soft one (D13)', () {
      final r = checkOverlaps(
        habit('gym', start: '21:30', end: '22:30', hard: true),
        [habit('learning', start: '21:00', end: '22:00')],
        15,
      ) as NeedsChoice;
      final s = r.sections.single;
      expect(s.isCandidate, isFalse);
      expect(s.yielder.id, 'learning');
      // Clear of gym and its buffer, [21:15, 22:30).
      expect(s.proposals.map((p) => p.sentence), [
        'Shift to 22:30–23:30',
        'Shift to 20:15–21:15',
        'Trim to 21:00–21:15',
      ]);
    });
  });

  group('proposals', () {
    test('a shift must be free on every day of the habit', () {
      final r = checkOverlaps(
        habit('learning', start: '21:00', end: '22:00', days: kWeekdays),
        [habit('class', start: '21:30', end: '23:00', days: dayMask([2]), hard: true)],
        0,
      ) as NeedsChoice;
      final shifts = r.sections.single.proposals.whereType<Shift>().map((p) => p.sentence);
      // 22:00 would suit four days of five; Wednesday needs 23:00.
      expect(shifts, ['Shift to 23:00–00:00', 'Shift to 20:30–21:30']);
    });

    test('no free time anywhere blocks the save', () {
      final r = checkOverlaps(
        habit('learning', start: '21:00', end: '22:00'),
        [habit('everything', start: '00:00', end: '23:30', hard: true)],
        0,
      ) as NeedsChoice;
      expect(r.sections.single.blocked, isTrue);
    });
  });
}
