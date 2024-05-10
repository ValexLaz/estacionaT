import 'package:map_flutter/models/ReservationVehicleEntry.dart';
import 'package:map_flutter/services/ApiRepository.dart';

class ApiReservationVehicleEntry extends ApiRepository<ReservationVehicleEntry>{
  ApiReservationVehicleEntry() : super(
    path: 'reservation/reservations/',
    fromJson: ReservationVehicleEntry.fromJson,
    toJson: (ReservationVehicleEntry p) => p.toJson(),
  );
}