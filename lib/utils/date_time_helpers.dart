import '../models/routes.dart';

bool isTodayDate(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

bool isTomorrowDate(DateTime date) {
  final tomorrow = DateTime.now().add(const Duration(days: 1));
  return date.year == tomorrow.year &&
      date.month == tomorrow.month &&
      date.day == tomorrow.day;
}

int nearestFiveMinuteIndex(int minute) => (minute / 5).ceil();

String formatTimeHHmm(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final roundedMinute = (date.minute / 5).round() * 5;
  final adjustedMinute = roundedMinute == 60 ? 0 : roundedMinute;
  final minute = adjustedMinute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

int _segmentMinutes(RouteInfo route, int start, int end) {
  int total = 0;
  for (int i = start + 1; i <= end; i++) {
    total += route.stops[i].durationFromPrevious;
  }
  return total;
}

DateTime calculateArrivalTime(
  DateTime departureTime,
  RouteInfo route,
  int originIndex,
  int destinationIndex,
) {
  final start = originIndex < destinationIndex ? originIndex : destinationIndex;
  final end = originIndex > destinationIndex ? originIndex : destinationIndex;
  final totalMinutes = _segmentMinutes(route, start, end);
  return departureTime.add(Duration(minutes: totalMinutes));
}

DateTime calculateDepartureTime(
  DateTime arrivalTime,
  RouteInfo route,
  int originIndex,
  int destinationIndex,
) {
  final start = originIndex < destinationIndex ? originIndex : destinationIndex;
  final end = originIndex > destinationIndex ? originIndex : destinationIndex;
  final totalMinutes = _segmentMinutes(route, start, end);
  return arrivalTime.subtract(Duration(minutes: totalMinutes));
}
