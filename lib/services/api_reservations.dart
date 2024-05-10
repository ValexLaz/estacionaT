import 'package:map_flutter/models/Reservation.dart';
import 'package:map_flutter/services/ApiRepository.dart';

class ApiReservation extends ApiRepository<Reservation>{
  ApiReservation() : super(
    path: 'reservation/reservations/',
    fromJson: Reservation.fromJson,
    toJson: (Reservation p) => p.toJson(),
  );
}