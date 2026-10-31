import 'package:intl/intl.dart';

/// *45 min*, *1 h*, *1 h 30 min*.
String durationLabel(int minutes) {
  if (minutes < 60) return '$minutes min';
  final h = minutes ~/ 60, m = minutes % 60;
  return m == 0 ? '$h h' : '$h h $m min';
}

/// *Sat 31 Oct*.
String dateLabel(DateTime d) => DateFormat('EEE d MMM').format(d);

/// *A*, *A and B*, *A, B and C*.
String joinNames(List<String> names) {
  if (names.isEmpty) return '';
  if (names.length == 1) return names.single;
  return '${names.sublist(0, names.length - 1).join(', ')} and ${names.last}';
}

/// *5 min before*, *at*, *10 min after*.
String offsetLabel(int offset) {
  if (offset == 0) return 'At';
  final d = durationLabel(offset.abs());
  return offset < 0 ? '$d before' : '$d after';
}
