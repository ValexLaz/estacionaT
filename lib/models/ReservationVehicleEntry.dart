import 'dart:convert';

import 'package:map_flutter/models/Reservation.dart';
import 'package:map_flutter/models/VehicleEntry.dart';

class ReservationVehicleEntry {
  final Reservation reservationData;
  final VehicleEntry vehicleEntryData;

  ReservationVehicleEntry({
    required this.reservationData,
    required this.vehicleEntryData,
  });

  Map<String, dynamic> toJson() {
    return {
      'reservation': reservationData.toJson(),
      'vehicle_entry': vehicleEntryData.toJson(),
    };
  }

  factory ReservationVehicleEntry.fromJson(Map<String, dynamic> json) {
    return ReservationVehicleEntry(
      reservationData: Reservation.fromJson(json['reservation']),
      vehicleEntryData: VehicleEntry.fromJson(json['vehicle_entry']),
    );
  }
}

