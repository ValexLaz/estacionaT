import 'package:map_flutter/models/VehicleEntry.dart';
import 'package:map_flutter/services/ApiRepository.dart';

class ApiVehicleEntry extends ApiRepository<VehicleEntry>{
  ApiVehicleEntry() : super(
    path: 'parking/vehicleentry/',
    fromJson: VehicleEntry.fromJson,
    toJson: (VehicleEntry p) => p.toJson(),
  );
}