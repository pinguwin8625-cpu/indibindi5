// Common date label constants and helpers.

const List<String> kMonthAbbr = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const List<String> kWeekdayAbbr = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

/// Returns Today / Tomorrow or formatted like '16 Aug Sat'.
String formatRelativeDay(DateTime date, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final diffDays = target.difference(today).inDays;
  if (diffDays == 0) return 'Today';
  if (diffDays == 1) return 'Tomorrow';
  return '${date.day} ${kMonthAbbr[date.month - 1]} ${kWeekdayAbbr[date.weekday - 1]}';
}
