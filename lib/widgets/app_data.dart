import 'package:flutter/foundation.dart';
import '../models/routes.dart';

// A simple in-memory store for ride offers.
// In a real app, this would be replaced by a database or API service.
class AppData {
  static final AppData _instance = AppData._internal();
  factory AppData() {
    return _instance;
  }
  AppData._internal();

  final ValueNotifier<List<RideInfo>> rideOffers = ValueNotifier<List<RideInfo>>([]);

  void addRide(RideInfo ride) {
    rideOffers.value = [...rideOffers.value, ride];
  }
}