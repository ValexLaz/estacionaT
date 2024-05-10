import 'package:map_flutter/models/Reservation.dart';

class ReservationManager {
  static final ReservationManager _instance = ReservationManager._internal();
  factory ReservationManager() => _instance;
  Reservation? reservation;
  ReservationManager._internal();
  void setReservation(Reservation newReservation) => reservation = newReservation;  Reservation? getReservation() => reservation;
}
