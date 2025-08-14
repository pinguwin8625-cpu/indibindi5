class RouteInfo {
  final String name;
  final String distance;
  final String duration;
  const RouteInfo({
    required this.name,
    required this.distance,
    required this.duration,
  });
}

const List<RouteInfo> predefinedRoutes = [
  RouteInfo(
    name: 'new york - philadelphia',
    distance: '95 mi',
    duration: '1h 40m',
  ),
  RouteInfo(
    name: 'los angeles - san diego',
    distance: '120 mi',
    duration: '2h',
  ),
  RouteInfo(name: 'chicago - milwaukee', distance: '92 mi', duration: '1h 30m'),
  RouteInfo(name: 'houston - dallas', distance: '240 mi', duration: '3h 45m'),
  RouteInfo(
    name: 'san francisco - sacramento',
    distance: '88 mi',
    duration: '1h 30m',
  ),
  RouteInfo(name: 'boston - providence', distance: '50 mi', duration: '1h'),
  RouteInfo(
    name: 'atlanta - charlotte',
    distance: '245 mi',
    duration: '3h 45m',
  ),
  RouteInfo(name: 'seattle - portland', distance: '175 mi', duration: '2h 45m'),
  RouteInfo(name: 'miami - orlando', distance: '235 mi', duration: '3h 30m'),
  RouteInfo(
    name: 'denver - colorado springs',
    distance: '70 mi',
    duration: '1h 10m',
  ),
];
