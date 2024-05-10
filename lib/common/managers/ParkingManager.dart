import 'package:map_flutter/models/Parking.dart';

class ParkingManager {
  static ParkingManager? _instance;
  Parking? parking;
  ParkingManager._internal();

  static ParkingManager get instance {
    _instance ??= ParkingManager._internal();
    return _instance!;
  }
  void setParking(Parking newParking) => parking = newParking;
  Parking? getParking () => parking;
}