import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_force/domain/history/history.dart';
import 'package:habit_force/platform/storage/database.dart';

import '../support/support.dart';

// docs/02-domain/history/lld.md §2 and §4.

EventRow ev(String id, String kind, String occ, DateTime at) =>
    EventRow(id: id, at: at.millisecondsSinceEpoch, kind: kind, habitId: 'h', occurrence: occ);

void main() {
  final now = DateTime.now();
  DateTime daysAgo(int n) => now.subtract(Duration(days: n));

  group('streak', () {
    test('counts finished windows until a pause', () {
      final events = [
        ev('1', 'window_started', 'h@3', daysAgo(3)),
        ev('2', 'paused', 'h@3', daysAgo(3)),
        ev('3', 'window_started', 'h@2', daysAgo(2)),
        ev('4', 'window_ended', 'h@2', daysAgo(2)),
        ev('5', 'window_started', 'h@1', daysAgo(1)),
        ev('6', 'window_ended', 'h@1', daysAgo(1)),
      ];
      expect(streak('h', events, now), 2);
    });

    test('a running window is not counted yet, but a pause in it ends the streak', () {
      final running = now.subtract(const Duration(minutes: 10));
      final base = [
        ev('1', 'window_started', 'h@1', daysAgo(1)),
        ev('2', 'window_ended', 'h@1', daysAgo(1)),
        ev('3', 'window_started', 'h@0', running),
      ];
      expect(streak('h', base, now), 1);
      expect(streak('h', [...base, ev('4', 'paused', 'h@0', now)], now), 0);
    });

    test('a window whose end was missed counts once a day has passed', () {
      expect(streak('h', [ev('1', 'window_started', 'h@2', daysAgo(2))], now), 1);
    });

    test('nothing started, nothing counted (D20)', () {
      expect(streak('h', const [], now), 0);
    });
  });

  group('collect', () {
    late AppDatabase db;
    late FakeNativeBridge bridge;
    late HistoryRepository history;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      bridge = FakeNativeBridge();
      history = HistoryRepository(db, bridge);
    });
    tearDown(() => db.close());

    test('keeps, acknowledges, and ignores a duplicate (D10)', () async {
      final e = {'id': 'x', 'at': now.millisecondsSinceEpoch, 'kind': 'paused', 'habitId': 'h'};
      bridge.pendingEvents = [e];
      expect((await history.collect()).inserted, 1);
      expect(bridge.acked, ['x']);

      // The same line again, as after a crash between insert and acknowledge.
      bridge.pendingEvents = [e];
      expect((await history.collect()).inserted, 0);
      final rows = await history.watchSince(daysAgo(1)).first;
      expect(rows.map((r) => r.id), ['x']);
    });

    test('an event of a kind this build does not know is acknowledged, not kept', () async {
      bridge.pendingEvents = [
        {'id': 'y', 'at': now.millisecondsSinceEpoch, 'kind': 'from_the_future'},
      ];
      final r = await history.collect();
      expect(r.inserted, 0);
      expect(r.torn, 1);
      expect(bridge.acked, ['y']);
    });
  });
}
