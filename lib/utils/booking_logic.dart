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
    List<int> selectedSeats,
  ) {
    int step;
    if (selectedRoute == null) {
      step = 0; // Stage 0: Nothing selected
    } else if (originIndex == null) {
      step = 1; // Stage 1: Route selected
    } else if (destinationIndex == null) {
      step = 2; // Stage 2: Pick up stop selected
    } else if (!hasSelectedDateTime) {
      step = 3; // Stage 3: Drop off stop selected, time not yet selected
    } else {
      step = 4; // Stage 4: Time selected (only when both stops AND time are selected)
    }
    
    print('🚗 BookingLogic.getCurrentStep: route=${selectedRoute?.name}, origin=$originIndex, dest=$destinationIndex, hasTime=$hasSelectedDateTime → step=$step');
    return step;
  }
}
