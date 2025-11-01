class Ride {
  final String id;
  final String driverName;
  final String origin;
  final String destination;
  final DateTime dateTime;
  final int seatsAvailable;

  Ride({
    required this.id,
    required this.driverName,
    required this.origin,
    required this.destination,
    required this.dateTime,
    required this.seatsAvailable,
  });
}
