import '../../common/clock_time.dart';
import '../habits/habit.dart';
import 'week.dart';

// The overlap engine. Pure: same habits in, same report out. Algorithm and
// rules: docs/02-domain/schedule/lld.md §2.

class Clash {
  final Habit other;
  final List<Span> common;

  /// Hard against hard: cannot be resolved, only refused.
  final bool refused;

  /// The habit that gives way — the candidate or [other] (D13). Null when
  /// [refused].
  final Habit? yielder;

  /// Both soft: the only kind of clash that may be kept (D12).
  final bool softSoft;

  const Clash({
    required this.other,
    required this.common,
    required this.refused,
    this.yielder,
    required this.softSoft,
  });
}

sealed class Proposal {
  const Proposal();
  String get sentence;
}

class Shift extends Proposal {
  final ClockTime start;
  final ClockTime end;

  const Shift(this.start, this.end);

  @override
  String get sentence => 'Shift to ${start.label}–${end.label}';
}

class Trim extends Proposal {
  final ClockTime start;
  final ClockTime end;

  const Trim(this.start, this.end);

  @override
  String get sentence => 'Trim to ${start.label}–${end.label}';
}

class KeepBoth extends Proposal {
  const KeepBoth();

  @override
  String get sentence => 'Keep both — both block during the overlap';
}

/// One habit that has to give way, and what it could do instead.
class Section {
  final Habit yielder;
  final bool isCandidate;
  final List<Clash> clashes;
  final List<Proposal> proposals;

  const Section({
    required this.yielder,
    required this.isCandidate,
    required this.clashes,
    required this.proposals,
  });

  /// Nothing to choose: the save cannot go ahead until the habit is edited.
  bool get blocked => proposals.isEmpty;
}

sealed class OverlapReport {
  const OverlapReport();
}

class Clean extends OverlapReport {
  const Clean();
}

class Refused extends OverlapReport {
  final List<Clash> clashes;

  const Refused(this.clashes);
}

class NeedsChoice extends OverlapReport {
  final List<Clash> clashes;
  final List<Section> sections;

  const NeedsChoice(this.clashes, this.sections);
}

/// Every clash between [h] and [against], by the rules in §2.1.
List<Clash> clashesOf(Habit h, Iterable<Habit> against, int buffer) {
  final out = <Clash>[];
  for (final o in against) {
    if (o.id == h.id || !o.active) continue;
    if (h.hard && o.hard) {
      final common = intersect(spansOf(h), spansOf(o));
      if (common.isNotEmpty) out.add(Clash(other: o, common: common, refused: true, softSoft: false));
    } else if (h.hard != o.hard) {
      final soft = h.hard ? o : h;
      final hard = h.hard ? h : o;
      final common = intersect(spansOf(soft), bufferedOf(hard, buffer));
      if (common.isNotEmpty) {
        out.add(Clash(other: o, common: common, refused: false, yielder: soft, softSoft: false));
      }
    } else {
      final common = intersect(spansOf(h), spansOf(o));
      // On a tie the habit being checked gives way.
      final yielder = o.priority < h.priority ? o : h;
      if (common.isNotEmpty) {
        out.add(Clash(other: o, common: common, refused: false, yielder: yielder, softSoft: true));
      }
    }
  }
  return out;
}

OverlapReport checkOverlaps(Habit candidate, List<Habit> others, int buffer) {
  final pool = [for (final o in others) if (o.id != candidate.id && o.active) o];
  final clashes = clashesOf(candidate, pool, buffer);
  if (clashes.isEmpty) return const Clean();
  if (clashes.any((c) => c.refused)) return Refused(clashes);

  // If the candidate gives way anywhere, only the candidate moves: saving a
  // habit by moving a third one would be a surprise (§2.2).
  if (clashes.any((c) => c.yielder!.id == candidate.id)) {
    return NeedsChoice(clashes, [
      Section(
        yielder: candidate,
        isCandidate: true,
        clashes: clashes,
        proposals: [
          ...proposalsFor(candidate, pool, buffer),
          if (clashes.every((c) => c.softSoft)) const KeepBoth(),
        ],
      ),
    ]);
  }

  final sections = <Section>[];
  for (final c in clashes) {
    final o = c.other;
    final against = [for (final p in pool) if (p.id != o.id) p, candidate];
    sections.add(Section(
      yielder: o,
      isCandidate: false,
      clashes: [c],
      proposals: [
        ...proposalsFor(o, against, buffer),
        if (c.softSoft) const KeepBoth(),
      ],
    ));
  }
  return NeedsChoice(clashes, sections);
}

/// Shift (later, earlier) and trim for a soft habit [y], each clear of
/// everything in [against] on every one of its days (§2.3).
List<Proposal> proposalsFor(Habit y, List<Habit> against, int buffer) {
  final forbidden = <Span>[
    for (final o in against)
      if (o.id != y.id && o.active) ...(o.hard ? bufferedOf(o, buffer) : spansOf(o)),
  ];
  bool fits(int start, int length) => !intersects(weekly(y.days, start, length), forbidden);

  final length = y.duration;
  final s0 = y.start.minutes;
  bool ok(int t) => (y.crossesMidnight || t + length <= kDay) && fits(t, length);
  ClockTime at(int m) => ClockTime(m % kDay);

  final out = <Proposal>[];

  for (var t = (s0 ~/ 5 + 1) * 5; t < kDay; t += 5) {
    if (ok(t)) {
      out.add(Shift(at(t), at(t + length)));
      break;
    }
  }
  for (var t = s0 % 5 == 0 ? s0 - 5 : s0 - s0 % 5; t >= 0; t -= 5) {
    if (ok(t)) {
      out.add(Shift(at(t), at(t + length)));
      break;
    }
  }

  var bestStart = 0, bestLength = 0, runStart = 0, run = 0;
  for (var r = 0; r < length; r++) {
    if (fits(s0 + r, 1)) {
      if (run == 0) runStart = r;
      run++;
      if (run > bestLength) {
        bestLength = run;
        bestStart = runStart;
      }
    } else {
      run = 0;
    }
  }
  if (bestLength >= 15 && bestLength < length) {
    out.add(Trim(at(s0 + bestStart), at(s0 + bestStart + bestLength)));
  }
  return out;
}

/// [h] with a proposal applied. Keep-both changes nothing.
Habit applyProposal(Habit h, Proposal p) => switch (p) {
      Shift(:final start, :final end) => h.copyWith(start: start, end: end),
      Trim(:final start, :final end) => h.copyWith(start: start, end: end),
      KeepBoth() => h,
    };
