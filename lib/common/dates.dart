/// Dates are local calendar days, held as a `DateTime` at local midnight.
/// Arithmetic goes through the calendar (`DateTime(y, m, d + n)`), never
/// through `Duration(days: n)`, which is 24 hours and lands on 23:00 the day
/// before across a DST change.
DateTime dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);

DateTime addDays(DateTime date, int days) => DateTime(date.year, date.month, date.day + days);

String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseIsoDate(String s) =>
    DateTime(int.parse(s.substring(0, 4)), int.parse(s.substring(5, 7)), int.parse(s.substring(8, 10)));

int minuteOfDay(DateTime t) => t.hour * 60 + t.minute;

// ── weekday masks ─────────────────────────────────────────────────────────
// Monday = bit 0 … Sunday = bit 6, matching the schema.

const kEveryDay = 127;
const kWeekdays = 31;
const kWeekends = 96;
const kDayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const kDayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

int weekdayIndex(DateTime date) => date.weekday - 1;

bool hasDay(int mask, int index) => mask & (1 << index) != 0;

/// *Every day*, *Mon–Fri*, *Weekends*, *Tue–Thu*, or *Mon, Wed, Fri*.
String daysLabel(int mask) {
  if (mask == kEveryDay) return 'Every day';
  if (mask == kWeekdays) return 'Mon–Fri';
  if (mask == kWeekends) return 'Weekends';
  final days = [for (var i = 0; i < 7; i++) if (hasDay(mask, i)) i];
  if (days.isEmpty) return 'No days';
  final contiguous = days.last - days.first == days.length - 1;
  if (contiguous && days.length >= 3) return '${kDayNames[days.first]}–${kDayNames[days.last]}';
  return days.map((i) => kDayNames[i]).join(', ');
}
