class RouteInfo {
  final String name;
  final String distance;
  final String duration;
  final List<String> stops;
  const RouteInfo({
    required this.name,
    required this.distance,
    required this.duration,
    required this.stops,
  });
}

const List<RouteInfo> predefinedRoutes = [
  RouteInfo(
    name: 'new york - philadelphia',
    distance: '95 mi',
    duration: '1h 40m',
    stops: ['New York', 'Newark', 'Trenton', 'Camden', 'Philadelphia'],
  ),
  RouteInfo(
    name: 'los angeles - san diego',
    distance: '120 mi',
    duration: '2h',
    stops: ['Los Angeles', 'Anaheim', 'Irvine', 'Oceanside', 'San Diego'],
  ),
  RouteInfo(
    name: 'chicago - milwaukee',
    distance: '92 mi',
    duration: '1h 30m',
    stops: ['Chicago', 'Evanston', 'Waukegan', 'Racine', 'Milwaukee'],
  ),
  RouteInfo(
    name: 'houston - dallas',
    distance: '240 mi',
    duration: '3h 45m',
    stops: ['Houston', 'Conroe', 'Corsicana', 'Ennis', 'Dallas'],
  ),
  RouteInfo(
    name: 'san francisco - sacramento',
    distance: '88 mi',
    duration: '1h 30m',
    stops: ['San Francisco', 'Berkeley', 'Vallejo', 'Davis', 'Sacramento'],
  ),
  RouteInfo(
    name: 'boston - providence',
    distance: '50 mi',
    duration: '1h',
    stops: ['Boston', 'Quincy', 'Brockton', 'Attleboro', 'Providence'],
  ),
  RouteInfo(
    name: 'atlanta - charlotte',
    distance: '245 mi',
    duration: '3h 45m',
    stops: ['Atlanta', 'Athens', 'Greenville', 'Gastonia', 'Charlotte'],
  ),
  RouteInfo(
    name: 'seattle - portland',
    distance: '175 mi',
    duration: '2h 45m',
    stops: ['Seattle', 'Tacoma', 'Olympia', 'Vancouver', 'Portland'],
  ),
  RouteInfo(
    name: 'miami - orlando',
    distance: '235 mi',
    duration: '3h 30m',
    stops: [
      'Miami',
      'Fort Lauderdale',
      'West Palm Beach',
      'Kissimmee',
      'Orlando',
    ],
  ),
  RouteInfo(
    name: 'denver - colorado springs',
    distance: '70 mi',
    duration: '1h 10m',
    stops: [
      'Denver',
      'Castle Rock',
      'Monument',
      'Fountain',
      'Colorado Springs',
    ],
  ),
];
