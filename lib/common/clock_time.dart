/// Minutes in a day. Times of day are integer minutes everywhere, 0..1439.
const kDay = 1440;

/// A time of day. Never an instant: which day it falls on is someone else's
/// business (D8).
class ClockTime implements Comparable<ClockTime> {
  final int minutes;

  const ClockTime(this.minutes) : assert(minutes >= 0 && minutes < kDay);

  factory ClockTime.hm(int hour, int minute) => ClockTime(hour * 60 + minute);

  int get hour => minutes ~/ 60;
  int get minute => minutes % 60;

  String get label => hhmm(minutes);

  @override
  int compareTo(ClockTime other) => minutes.compareTo(other.minutes);

  @override
  bool operator ==(Object other) => other is ClockTime && other.minutes == minutes;

  @override
  int get hashCode => minutes.hashCode;

  @override
  String toString() => label;
}

/// `HH:MM` for any minute count, including ones past midnight (1500 → 01:00)
/// and before it (−20 → 23:40), which is what a window's end or an alarm's
/// offset produces.
String hhmm(int minutes) {
  final m = minutes % kDay;
  return '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
}
