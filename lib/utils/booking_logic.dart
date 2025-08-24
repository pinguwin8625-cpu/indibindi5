import '../models/routes.dart';

class BookingLogic {
  /// Compute greyed stops based on route and selected origin/destination
  static List<int> computeGreyedStops(
    RouteInfo? selectedRoute,
    int? originIndex,
    int? destinationIndex,
  ) {
    List<int> greyedStops = [];
    if (selectedRoute != null &&
        originIndex != null &&
        destinationIndex != null) {
      int start = originIndex < destinationIndex ? originIndex : destinationIndex;
      int end = originIndex > destinationIndex ? originIndex : destinationIndex;
      for (int i = 0; i < selectedRoute.stops.length; i++) {
        if (i < start || i > end) {
          greyedStops.add(i);
        }
      }
    }
    return greyedStops;
  }

  /// Determine the current step in the booking process
  static int getCurrentStep(
    RouteInfo? selectedRoute,
    int? originIndex,
    int? destinationIndex,
    bool hasSelectedDateTime,
    List<int> selectedSeats,
  ) {
    if (selectedRoute == null) return 0;
    if (originIndex == null) return 1;
    if (destinationIndex == null) return 2;
    if (!hasSelectedDateTime) return 3;
    if (selectedSeats.isEmpty) return 4;
    return 4; // All steps completed
  }
}
