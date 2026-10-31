import '../../common/clock_time.dart';
import '../../common/dates.dart';
import '../habits/habit.dart';

/// Monday 00:00 = 0. Every weekly overlap question becomes interval
/// intersection in these units, and the Sunday-night-into-Monday wrap stops
/// being a special case (docs/02-domain/schedule/lld.md §1).
const kWeek = 7 * kDay;

/// `[start, end)` in week minutes, within `[0, kWeek]`.
class Span {
  final int start;
  final int end;

  const Span(this.start, this.end);

  int get length => end - start;

  @override
  bool operator ==(Object other) => other is Span && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => '[$start, $end)';
}

int _mod(int a, int m) => ((a % m) + m) % m;

/// On every day in [days], a run of [length] minutes starting [offset]
/// minutes into that day. [offset] may be negative or past midnight.
List<Span> weekly(int days, int offset, int length) {
  final out = <Span>[];
  for (var d = 0; d < 7; d++) {
    if (!hasDay(days, d)) continue;
    final a = _mod(d * kDay + offset, kWeek);
    final b = a + length;
    if (b <= kWeek) {
      out.add(Span(a, b));
    } else {
      out
        ..add(Span(a, kWeek))
        ..add(Span(0, b - kWeek));
    }
  }
  return out;
}

List<Span> spansOf(Habit h) => weekly(h.days, h.start.minutes, h.duration);

/// A hard habit with the buffer before it that soft habits may not use (D14).
List<Span> bufferedOf(Habit h, int buffer) =>
    weekly(h.days, h.start.minutes - buffer, h.duration + buffer);

List<Span> intersect(List<Span> a, List<Span> b) {
  final out = <Span>[];
  for (final x in a) {
    for (final y in b) {
      final s = x.start > y.start ? x.start : y.start;
      final e = x.end < y.end ? x.end : y.end;
      if (s < e) out.add(Span(s, e));
    }
  }
  return out;
}

bool intersects(List<Span> a, List<Span> b) {
  for (final x in a) {
    for (final y in b) {
      if (x.start < y.end && y.start < x.end) return true;
    }
  }
  return false;
}

/// *Mon–Fri 21:45–22:00*, *Sun 23:00–01:00*. Spans that touch across the
/// week's end are joined first, so a Sunday-night overlap reads as one.
List<String> describeSpans(List<Span> spans) {
  final sorted = [...spans]..sort((x, y) => x.start.compareTo(y.start));
  final merged = <Span>[];
  for (final s in sorted) {
    if (merged.isNotEmpty && merged.last.end >= s.start) {
      final last = merged.removeLast();
      merged.add(Span(last.start, s.end > last.end ? s.end : last.end));
    } else {
      merged.add(s);
    }
  }
  if (merged.length > 1 && merged.first.start == 0 && merged.last.end == kWeek) {
    final head = merged.removeAt(0);
    final tail = merged.removeLast();
    merged.add(Span(tail.start, kWeek + head.end));
  }

  // Same clock range on several days → one line.
  final byRange = <String, List<int>>{};
  for (final s in merged) {
    final day = s.start ~/ kDay;
    final from = s.start % kDay;
    final range = '${hhmm(from)}–${hhmm(from + s.length)}';
    (byRange[range] ??= []).add(day % 7);
  }
  return [
    for (final e in byRange.entries)
      '${daysLabel(e.value.fold(0, (m, d) => m | (1 << d)))} ${e.key}',
  ];
}
