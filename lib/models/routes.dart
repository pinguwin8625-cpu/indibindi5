class StopInfo {
  final String name;
  final double distanceFromPrevious; // Distance from previous stop in kilometers
  final int durationFromPrevious; // Duration from previous stop in minutes

  const StopInfo({
    required this.name,
    this.distanceFromPrevious = 0, // 0 for the first stop
    this.durationFromPrevious = 0, // 0 for the first stop
  });
}

class RouteInfo {
  final String name;
  final String distance;
  final String duration;
  final List<StopInfo> stops;

  const RouteInfo({
    required this.name,
    required this.distance,
    required this.duration,
    required this.stops,
  });

  // Helper method to get just the stop names
  List<String> get stopNames => stops.map((stop) => stop.name).toList();

  // Helper method to calculate distance between two stop indexes
  String calculateDistance(int startIndex, int endIndex) {
    if (startIndex == endIndex) return '0 km';

    int start = startIndex < endIndex ? startIndex : endIndex;
    int end = startIndex > endIndex ? startIndex : endIndex;

    double totalDistance = 0;
    for (int i = start + 1; i <= end; i++) {
      totalDistance += stops[i].distanceFromPrevious;
    }

    // Round to nearest whole number to match the format of the full route display
    int roundedDistance = totalDistance.round();
    return '$roundedDistance km';
  }

  // Helper method to calculate duration between two stop indexes
  String calculateDuration(int startIndex, int endIndex) {
    if (startIndex == endIndex) return '0 min';

    int start = startIndex < endIndex ? startIndex : endIndex;
    int end = startIndex > endIndex ? startIndex : endIndex;

    int totalMinutes = 0;
    for (int i = start + 1; i <= end; i++) {
      totalMinutes += stops[i].durationFromPrevious;
    }

    if (totalMinutes >= 60) {
      int hours = totalMinutes ~/ 60;
      int minutes = totalMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }

    return '$totalMinutes min';
  }
}

const List<RouteInfo> predefinedRoutes = [
  RouteInfo(
    name: 'New York - Philadelphia',
    distance: '241 km',
    duration: '2h 30m',
    stops: [
      StopInfo(name: 'New York - Times Square'),
      StopInfo(
        name: 'New York - Penn Station',
        distanceFromPrevious: 3.4,
        durationFromPrevious: 5,
      ),
      StopInfo(
        name: 'Secaucus Junction',
        distanceFromPrevious: 9.3,
        durationFromPrevious: 8,
      ),
      StopInfo(
        name: 'Newark Penn Station',
        distanceFromPrevious: 6.8,
        durationFromPrevious: 7,
      ),
      StopInfo(
        name: 'Elizabeth',
        distanceFromPrevious: 10.1,
        durationFromPrevious: 10,
      ),
      StopInfo(
        name: 'Rahway',
        distanceFromPrevious: 9.2,
        durationFromPrevious: 8,
      ),
      StopInfo(
        name: 'Metropark',
        distanceFromPrevious: 13.0,
        durationFromPrevious: 12,
      ),
      StopInfo(
        name: 'New Brunswick',
        distanceFromPrevious: 15.1,
        durationFromPrevious: 14,
      ),
      StopInfo(
        name: 'Princeton Junction',
        distanceFromPrevious: 20.3,
        durationFromPrevious: 18,
      ),
      StopInfo(
        name: 'Trenton',
        distanceFromPrevious: 24.6,
        durationFromPrevious: 20,
      ),
      StopInfo(
        name: 'Morrisville',
        distanceFromPrevious: 6.8,
        durationFromPrevious: 6,
      ),
      StopInfo(
        name: 'Levittown',
        distanceFromPrevious: 14.0,
        durationFromPrevious: 12,
      ),
      StopInfo(
        name: 'Bristol',
        distanceFromPrevious: 11.1,
        durationFromPrevious: 10,
      ),
      StopInfo(
        name: 'Camden',
        distanceFromPrevious: 29.3,
        durationFromPrevious: 25,
      ),
      StopInfo(
        name: 'Philadelphia - Center City',
        distanceFromPrevious: 9.3,
        durationFromPrevious: 12,
      ),
    ],
  ),
  RouteInfo(
    name: 'Los Angeles - San Diego',
    distance: '290 km',
    duration: '2h 45m',
    stops: [
      StopInfo(name: 'Los Angeles - Downtown'),
      StopInfo(
        name: 'Los Angeles - LAX Airport',
        distanceFromPrevious: 29.3,
        durationFromPrevious: 20,
      ),
      StopInfo(
        name: 'El Segundo',
        distanceFromPrevious: 8.2,
        durationFromPrevious: 8,
      ),
      StopInfo(
        name: 'Torrance',
        distanceFromPrevious: 14.0,
        durationFromPrevious: 12,
      ),
      StopInfo(
        name: 'Long Beach',
        distanceFromPrevious: 24.6,
        durationFromPrevious: 18,
      ),
      StopInfo(
        name: 'Anaheim',
        distanceFromPrevious: 36.1,
        durationFromPrevious: 25,
      ),
      StopInfo(
        name: 'Irvine',
        distanceFromPrevious: 29.8,
        durationFromPrevious: 20,
      ),
      StopInfo(
        name: 'San Juan Capistrano',
        distanceFromPrevious: 41.2,
        durationFromPrevious: 25,
      ),
      StopInfo(
        name: 'Oceanside',
        distanceFromPrevious: 51.7,
        durationFromPrevious: 30,
      ),
      StopInfo(
        name: 'San Diego - Airport',
        distanceFromPrevious: 57.0,
        durationFromPrevious: 35,
      ),
    ],
  ),
  RouteInfo(
    name: 'Chicago - Milwaukee',
    distance: '225 km',
    duration: '2h 15m',
    stops: [
      StopInfo(name: 'Chicago - Union Station'),
      StopInfo(
        name: 'Chicago - O\'Hare Airport',
        distanceFromPrevious: 28.2,
        durationFromPrevious: 20,
      ),
      StopInfo(
        name: 'Des Plaines',
        distanceFromPrevious: 13.2,
        durationFromPrevious: 10,
      ),
      StopInfo(
        name: 'Schaumburg',
        distanceFromPrevious: 19.5,
        durationFromPrevious: 15,
      ),
      StopInfo(
        name: 'Palatine',
        distanceFromPrevious: 9.7,
        durationFromPrevious: 12,
      ),
      StopInfo(
        name: 'Barrington',
        distanceFromPrevious: 8.9,
        durationFromPrevious: 11,
      ),
      StopInfo(
        name: 'Crystal Lake',
        distanceFromPrevious: 15.3,
        durationFromPrevious: 18,
      ),
      StopInfo(
        name: 'Woodstock',
        distanceFromPrevious: 11.6,
        durationFromPrevious: 14,
      ),
      StopInfo(
        name: 'Harvard',
        distanceFromPrevious: 13.2,
        durationFromPrevious: 16,
      ),
      StopInfo(
        name: 'Walworth',
        distanceFromPrevious: 8.4,
        durationFromPrevious: 10,
      ),
      StopInfo(
        name: 'Lake Geneva',
        distanceFromPrevious: 12.7,
        durationFromPrevious: 15,
      ),
      StopInfo(
        name: 'Burlington',
        distanceFromPrevious: 18.3,
        durationFromPrevious: 20,
      ),
      StopInfo(
        name: 'Racine',
        distanceFromPrevious: 16.8,
        durationFromPrevious: 18,
      ),
      StopInfo(
        name: 'Kenosha',
        distanceFromPrevious: 11.5,
        durationFromPrevious: 14,
      ),
      StopInfo(
        name: 'Milwaukee - Downtown',
        distanceFromPrevious: 19.2,
        durationFromPrevious: 22,
      ),
    ],
  ),
  RouteInfo(
    name: 'Houston - Dallas',
    distance: '451 km',
    duration: '3h 15m',
    stops: [
      StopInfo(name: 'Houston - Downtown'),
      StopInfo(
        name: 'Houston - Bush Airport',
        distanceFromPrevious: 23.1,
        durationFromPrevious: 25,
      ),
      StopInfo(
        name: 'Spring',
        distanceFromPrevious: 18.7,
        durationFromPrevious: 20,
      ),
      StopInfo(
        name: 'Conroe',
        distanceFromPrevious: 15.2,
        durationFromPrevious: 18,
      ),
      StopInfo(
        name: 'Huntsville',
        distanceFromPrevious: 38.4,
        durationFromPrevious: 35,
      ),
      StopInfo(
        name: 'Madisonville',
        distanceFromPrevious: 32.6,
        durationFromPrevious: 30,
      ),
      StopInfo(
        name: 'Centerville',
        distanceFromPrevious: 28.3,
        durationFromPrevious: 25,
      ),
      StopInfo(
        name: 'Corsicana',
        distanceFromPrevious: 45.1,
        durationFromPrevious: 40,
      ),
      StopInfo(
        name: 'Ennis',
        distanceFromPrevious: 35.2,
        durationFromPrevious: 30,
      ),
      StopInfo(
        name: 'Dallas - DFW Airport',
        distanceFromPrevious: 42.8,
        durationFromPrevious: 35,
      ),
    ],
  ),
  RouteInfo(
    name: 'San Francisco - Sacramento',
    distance: '225 km',
    duration: '2h 10m',
    stops: [
      StopInfo(name: 'San Francisco - Fisherman\'s Wharf'),
      StopInfo(
        name: 'San Francisco - Financial District',
        distanceFromPrevious: 3.2,
        durationFromPrevious: 8,
      ),
      StopInfo(
        name: 'Oakland',
        distanceFromPrevious: 8.7,
        durationFromPrevious: 12,
      ),
      StopInfo(
        name: 'Berkeley',
        distanceFromPrevious: 6.1,
        durationFromPrevious: 10,
      ),
      StopInfo(
        name: 'Richmond',
        distanceFromPrevious: 8.5,
        durationFromPrevious: 12,
      ),
      StopInfo(
        name: 'San Rafael',
        distanceFromPrevious: 12.3,
        durationFromPrevious: 15,
      ),
      StopInfo(
        name: 'Petaluma',
        distanceFromPrevious: 18.4,
        durationFromPrevious: 18,
      ),
      StopInfo(
        name: 'Santa Rosa',
        distanceFromPrevious: 15.6,
        durationFromPrevious: 16,
      ),
      StopInfo(
        name: 'Sebastopol',
        distanceFromPrevious: 12.8,
        durationFromPrevious: 14,
      ),
      StopInfo(
        name: 'Vallejo',
        distanceFromPrevious: 22.1,
        durationFromPrevious: 20,
      ),
      StopInfo(
        name: 'Fairfield',
        distanceFromPrevious: 14.7,
        durationFromPrevious: 16,
      ),
      StopInfo(
        name: 'Vacaville',
        distanceFromPrevious: 11.2,
        durationFromPrevious: 13,
      ),
      StopInfo(
        name: 'Dixon',
        distanceFromPrevious: 15.8,
        durationFromPrevious: 18,
      ),
      StopInfo(
        name: 'Davis',
        distanceFromPrevious: 12.4,
        durationFromPrevious: 15,
      ),
      StopInfo(
        name: 'Sacramento - Downtown',
        distanceFromPrevious: 16.3,
        durationFromPrevious: 18,
      ),
    ],
  ),
  RouteInfo(
    name: 'Boston - Providence',
    distance: '105 km',
    duration: '1h 20m',
    stops: [
      StopInfo(name: 'Boston - Back Bay'),
      StopInfo(
        name: 'Boston - South Station',
        distanceFromPrevious: 2.1,
        durationFromPrevious: 5,
      ),
      StopInfo(
        name: 'Dedham',
        distanceFromPrevious: 8.3,
        durationFromPrevious: 12,
      ),
      StopInfo(
        name: 'Westwood',
        distanceFromPrevious: 6.4,
        durationFromPrevious: 8,
      ),
      StopInfo(
        name: 'Norwood',
        distanceFromPrevious: 4.7,
        durationFromPrevious: 7,
      ),
      StopInfo(
        name: 'Walpole',
        distanceFromPrevious: 5.2,
        durationFromPrevious: 8,
      ),
      StopInfo(
        name: 'Foxborough',
        distanceFromPrevious: 7.8,
        durationFromPrevious: 10,
      ),
      StopInfo(
        name: 'Mansfield',
        distanceFromPrevious: 6.1,
        durationFromPrevious: 9,
      ),
      StopInfo(
        name: 'Attleboro',
        distanceFromPrevious: 9.5,
        durationFromPrevious: 12,
      ),
      StopInfo(
        name: 'Providence - Downtown',
        distanceFromPrevious: 14.9,
        durationFromPrevious: 18,
      ),
    ],
  ),
  RouteInfo(
    name: 'Atlanta - Charlotte',
    distance: '394 km',
    duration: '3h 45m',
    stops: [
      StopInfo(name: 'Atlanta'),
      StopInfo(
        name: 'Athens',
        distanceFromPrevious: 72.0,
        durationFromPrevious: 65,
      ),
      StopInfo(
        name: 'Greenville',
        distanceFromPrevious: 76.8,
        durationFromPrevious: 70,
      ),
      StopInfo(
        name: 'Gastonia',
        distanceFromPrevious: 68.2,
        durationFromPrevious: 60,
      ),
      StopInfo(
        name: 'Charlotte',
        distanceFromPrevious: 28.0,
        durationFromPrevious: 30,
      ),
    ],
  ),
  RouteInfo(
    name: 'Seattle - Portland',
    distance: '282 km',
    duration: '2h 45m',
    stops: [
      StopInfo(name: 'Seattle'),
      StopInfo(
        name: 'Tacoma',
        distanceFromPrevious: 33.1,
        durationFromPrevious: 35,
      ),
      StopInfo(
        name: 'Olympia',
        distanceFromPrevious: 28.7,
        durationFromPrevious: 30,
      ),
      StopInfo(
        name: 'Vancouver',
        distanceFromPrevious: 73.8,
        durationFromPrevious: 60,
      ),
      StopInfo(
        name: 'Portland',
        distanceFromPrevious: 39.4,
        durationFromPrevious: 40,
      ),
    ],
  ),
  RouteInfo(
    name: 'Miami - Orlando',
    distance: '451 km',
    duration: '4h 15m',
    stops: [
      StopInfo(name: 'Miami - South Beach'),
      StopInfo(
        name: 'Miami - Airport (MIA)',
        distanceFromPrevious: 12.3,
        durationFromPrevious: 15,
      ),
      StopInfo(
        name: 'Hollywood',
        distanceFromPrevious: 15.7,
        durationFromPrevious: 18,
      ),
      StopInfo(
        name: 'Fort Lauderdale',
        distanceFromPrevious: 8.4,
        durationFromPrevious: 12,
      ),
      StopInfo(
        name: 'Pompano Beach',
        distanceFromPrevious: 9.6,
        durationFromPrevious: 14,
      ),
      StopInfo(
        name: 'Boca Raton',
        distanceFromPrevious: 18.2,
        durationFromPrevious: 20,
      ),
      StopInfo(
        name: 'Delray Beach',
        distanceFromPrevious: 7.8,
        durationFromPrevious: 10,
      ),
      StopInfo(
        name: 'West Palm Beach',
        distanceFromPrevious: 12.1,
        durationFromPrevious: 15,
      ),
      StopInfo(
        name: 'Jupiter',
        distanceFromPrevious: 20.4,
        durationFromPrevious: 22,
      ),
      StopInfo(
        name: 'Stuart',
        distanceFromPrevious: 18.6,
        durationFromPrevious: 20,
      ),
      StopInfo(
        name: 'Fort Pierce',
        distanceFromPrevious: 22.3,
        durationFromPrevious: 25,
      ),
      StopInfo(
        name: 'Melbourne',
        distanceFromPrevious: 45.7,
        durationFromPrevious: 50,
      ),
      StopInfo(
        name: 'Lakeland',
        distanceFromPrevious: 68.2,
        durationFromPrevious: 65,
      ),
      StopInfo(
        name: 'Kissimmee',
        distanceFromPrevious: 35.4,
        durationFromPrevious: 30,
      ),
      StopInfo(
        name: 'Orlando - Downtown',
        distanceFromPrevious: 25.3,
        durationFromPrevious: 25,
      ),
    ],
  ),
  RouteInfo(
    name: 'Denver - Colorado Springs',
    distance: '137 km',
    duration: '1h 30m',
    stops: [
      StopInfo(name: 'Denver - Downtown'),
      StopInfo(
        name: 'Denver - Tech Center',
        distanceFromPrevious: 8.4,
        durationFromPrevious: 12,
      ),
      StopInfo(
        name: 'Centennial',
        distanceFromPrevious: 6.7,
        durationFromPrevious: 8,
      ),
      StopInfo(
        name: 'Littleton',
        distanceFromPrevious: 4.9,
        durationFromPrevious: 7,
      ),
      StopInfo(
        name: 'Chatfield',
        distanceFromPrevious: 5.8,
        durationFromPrevious: 8,
      ),
      StopInfo(
        name: 'Castle Rock',
        distanceFromPrevious: 12.3,
        durationFromPrevious: 15,
      ),
      StopInfo(
        name: 'Larkspur',
        distanceFromPrevious: 8.6,
        durationFromPrevious: 10,
      ),
      StopInfo(
        name: 'Monument',
        distanceFromPrevious: 11.4,
        durationFromPrevious: 12,
      ),
      StopInfo(
        name: 'Fountain',
        distanceFromPrevious: 15.7,
        durationFromPrevious: 16,
      ),
      StopInfo(
        name: 'Colorado Springs - Downtown',
        distanceFromPrevious: 11.2,
        durationFromPrevious: 12,
      ),
    ],
  ),
];

class RideInfo {
  final String id;
  final RouteInfo route;
  final String driverName;
  final String driverPhoto;
  final double driverRating;
  final DateTime departureTime;
  final int originIndex;
  final int destinationIndex;
  final int availableSeats;
  final String price;

  const RideInfo({
    required this.id,
    required this.route,
    required this.driverName,
    required this.driverPhoto,
    required this.driverRating,
    required this.departureTime,
    required this.originIndex,
    required this.destinationIndex,
    required this.availableSeats,
    required this.price,
  });
}
