class StopInfo {
  final String name;
  final double distanceFromPrevious; // Distance from previous stop in miles
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
    if (startIndex == endIndex) return '0 mi';

    int start = startIndex < endIndex ? startIndex : endIndex;
    int end = startIndex > endIndex ? startIndex : endIndex;

    double totalDistance = 0;
    for (int i = start + 1; i <= end; i++) {
      totalDistance += stops[i].distanceFromPrevious;
    }

    // Round to nearest whole number to match the format of the full route display
    int roundedDistance = totalDistance.round();
    return '$roundedDistance mi';
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
    distance: '95 mi',
    duration: '1h 40m',
    stops: [
      StopInfo(name: 'New York'),
      StopInfo(
        name: 'Newark',
        distanceFromPrevious: 10.5,
        durationFromPrevious: 15,
      ),
      StopInfo(
        name: 'Trenton',
        distanceFromPrevious: 28.7,
        durationFromPrevious: 25,
      ),
      StopInfo(
        name: 'Camden',
        distanceFromPrevious: 28.1,
        durationFromPrevious: 30,
      ),
      StopInfo(
        name: 'Philadelphia',
        distanceFromPrevious: 27.7,
        durationFromPrevious: 30,
      ),
    ],
  ),
  RouteInfo(
    name: 'Los Angeles - San Diego',
    distance: '120 mi',
    duration: '2h',
    stops: [
      StopInfo(name: 'Los Angeles'),
      StopInfo(
        name: 'Anaheim',
        distanceFromPrevious: 26.0,
        durationFromPrevious: 30,
      ),
      StopInfo(
        name: 'Irvine',
        distanceFromPrevious: 18.5,
        durationFromPrevious: 25,
      ),
      StopInfo(
        name: 'Oceanside',
        distanceFromPrevious: 42.7,
        durationFromPrevious: 35,
      ),
      StopInfo(
        name: 'San Diego',
        distanceFromPrevious: 32.8,
        durationFromPrevious: 30,
      ),
    ],
  ),
  RouteInfo(
    name: 'Chicago - Milwaukee',
    distance: '92 mi',
    duration: '1h 30m',
    stops: [
      StopInfo(name: 'Chicago'),
      StopInfo(
        name: 'Evanston',
        distanceFromPrevious: 12.3,
        durationFromPrevious: 15,
      ),
      StopInfo(
        name: 'Waukegan',
        distanceFromPrevious: 23.8,
        durationFromPrevious: 25,
      ),
      StopInfo(
        name: 'Racine',
        distanceFromPrevious: 28.4,
        durationFromPrevious: 30,
      ),
      StopInfo(
        name: 'Milwaukee',
        distanceFromPrevious: 27.5,
        durationFromPrevious: 20,
      ),
    ],
  ),
  RouteInfo(
    name: 'Houston - Dallas',
    distance: '240 mi',
    duration: '3h 45m',
    stops: [
      StopInfo(name: 'Houston'),
      StopInfo(
        name: 'Conroe',
        distanceFromPrevious: 40.5,
        durationFromPrevious: 40,
      ),
      StopInfo(
        name: 'Corsicana',
        distanceFromPrevious: 98.3,
        durationFromPrevious: 85,
      ),
      StopInfo(
        name: 'Ennis',
        distanceFromPrevious: 35.2,
        durationFromPrevious: 30,
      ),
      StopInfo(
        name: 'Dallas',
        distanceFromPrevious: 66.0,
        durationFromPrevious: 70,
      ),
    ],
  ),
  RouteInfo(
    name: 'San Francisco - Sacramento',
    distance: '88 mi',
    duration: '1h 30m',
    stops: [
      StopInfo(name: 'San Francisco'),
      StopInfo(
        name: 'Berkeley',
        distanceFromPrevious: 13.4,
        durationFromPrevious: 20,
      ),
      StopInfo(
        name: 'Vallejo',
        distanceFromPrevious: 20.3,
        durationFromPrevious: 25,
      ),
      StopInfo(
        name: 'Davis',
        distanceFromPrevious: 30.7,
        durationFromPrevious: 25,
      ),
      StopInfo(
        name: 'Sacramento',
        distanceFromPrevious: 23.6,
        durationFromPrevious: 20,
      ),
    ],
  ),
  RouteInfo(
    name: 'Boston - Providence',
    distance: '50 mi',
    duration: '1h',
    stops: [
      StopInfo(name: 'Boston'),
      StopInfo(
        name: 'Quincy',
        distanceFromPrevious: 8.6,
        durationFromPrevious: 12,
      ),
      StopInfo(
        name: 'Brockton',
        distanceFromPrevious: 12.5,
        durationFromPrevious: 15,
      ),
      StopInfo(
        name: 'Attleboro',
        distanceFromPrevious: 18.7,
        durationFromPrevious: 18,
      ),
      StopInfo(
        name: 'Providence',
        distanceFromPrevious: 10.2,
        durationFromPrevious: 15,
      ),
    ],
  ),
  RouteInfo(
    name: 'Atlanta - Charlotte',
    distance: '245 mi',
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
    distance: '175 mi',
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
    distance: '235 mi',
    duration: '3h 30m',
    stops: [
      StopInfo(name: 'Miami'),
      StopInfo(
        name: 'Fort Lauderdale',
        distanceFromPrevious: 28.5,
        durationFromPrevious: 35,
      ),
      StopInfo(
        name: 'West Palm Beach',
        distanceFromPrevious: 42.7,
        durationFromPrevious: 45,
      ),
      StopInfo(
        name: 'Kissimmee',
        distanceFromPrevious: 129.6,
        durationFromPrevious: 95,
      ),
      StopInfo(
        name: 'Orlando',
        distanceFromPrevious: 34.2,
        durationFromPrevious: 35,
      ),
    ],
  ),
  RouteInfo(
    name: 'Denver - Colorado Springs',
    distance: '70 mi',
    duration: '1h 10m',
    stops: [
      StopInfo(name: 'Denver'),
      StopInfo(
        name: 'Castle Rock',
        distanceFromPrevious: 30.7,
        durationFromPrevious: 25,
      ),
      StopInfo(
        name: 'Monument',
        distanceFromPrevious: 16.8,
        durationFromPrevious: 15,
      ),
      StopInfo(
        name: 'Fountain',
        distanceFromPrevious: 13.5,
        durationFromPrevious: 15,
      ),
      StopInfo(
        name: 'Colorado Springs',
        distanceFromPrevious: 9.0,
        durationFromPrevious: 15,
      ),
    ],
  ),
];
