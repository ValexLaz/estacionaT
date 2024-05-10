import 'package:flutter/foundation.dart';

class ParkingState extends ChangeNotifier {
  int _vehiclesCount = 0;

  int get vehiclesCount => _vehiclesCount;

  void updateVehiclesCount(int count) {
    _vehiclesCount = count;
    notifyListeners();
  }
}
