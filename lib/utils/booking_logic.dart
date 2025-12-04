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
      int start = originIndex < destinationIndex
          ? originIndex
          : destinationIndex;
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
    List<int> selectedSeats, {
    bool hasSelectedRole = false,
    bool isActionCompleted = false,
  }) {
    int step;
    if (!hasSelectedRole) {
      step = 0; // Stage 0: Role not selected
    } else if (selectedRoute == null) {
      step = 1; // Stage 1: Role selected, no route yet
    } else if (originIndex == null) {
      step = 2; // Stage 2: Route selected
    } else if (destinationIndex == null) {
      step = 3; // Stage 3: Pick up stop selected
    } else if (!hasSelectedDateTime) {
      step = 4; // Stage 4: Drop off stop selected, time not yet selected
    } else if (!isActionCompleted) {
      step = 5; // Stage 5: Time selected, ready to post/book
    } else {
      step = 6; // Stage 6: Ride posted or booked (completed)
    }
    
    print('🚗 BookingLogic.getCurrentStep: hasRole=$hasSelectedRole, route=${selectedRoute?.name}, origin=$originIndex, dest=$destinationIndex, hasTime=$hasSelectedDateTime, completed=$isActionCompleted → step=$step');
    return step;
  }
}
