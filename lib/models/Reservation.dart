import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:map_flutter/models/VehicleEntry.dart';

class Reservation {
  final int? id;
  final String startTime;
  final String endTime;
  final double totalAmount;
  final int priceId;
  final int? extraTime;
  final String reservationDate;
  final int? userId;
  ReservationState _state;
  int vehicleEntry;
  Reservation({
    this.id,
    required this.startTime,
    required this.endTime,
    required this.totalAmount,
    required this.priceId,
    this.extraTime,
    required this.reservationDate,
    this.userId,
    required ReservationState state,
    this.vehicleEntry = 0,
  }) : _state = state;

  ReservationState get state => _state;

  set state(ReservationState newState) => _state = newState;

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      totalAmount: json['total_amount'].toDouble(),
      priceId: json['price'],
      extraTime: json['extra_time'],
      vehicleEntry: json['vehicle_entry'],
      reservationDate: json['reservation_date'],
      userId: json['user'],
      state: ReservationState.values
          .byName((json['state'] ?? '').toString().toLowerCase()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state': state.value,
      'start_time': startTime,
      'end_time': endTime,
      'total_amount': totalAmount,
      'price': priceId,
      'reservation_date': reservationDate,
      'user': userId,
      if (extraTime != null) 'extra_time': extraTime,
    };
  }

  double getTotalHours() {
    final format = DateFormat('HH:mm:ss');
    final start = format.parse(startTime);
    final end = format.parse(endTime);
    final difference = end.difference(start);
    return difference.inHours + difference.inMinutes / 60.0;
  }

  static List<Reservation> parseList(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<Reservation>((json) => Reservation.fromJson(json))
        .toList();
  }

  String getFormattedTotalHours() {
    final format = DateFormat('HH:mm:ss');
    final start = format.parse(startTime);
    final end = format.parse(endTime);
    final difference = end.difference(start);

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '$hours h $minutes min';
    } else if (hours > 0) {
      return '$hours h';
    } else {
      return '$minutes min';
    }
  }
}

enum ReservationState {
  pending,
  confirmed,
  active,
  completed,
  cancelled,
  no_Show,
  modified,
}

extension ReservationStateExtension on ReservationState {
  String get value => name.toUpperCase();
   String get spanish {
    switch (this) {
      case ReservationState.pending:
        return 'Pendiente';
      case ReservationState.confirmed:
        return 'Confirmado';
      case ReservationState.active:
        return 'Activo';
      case ReservationState.completed:
        return 'Completado';
      case ReservationState.cancelled:
        return 'Cancelado';
      case ReservationState.no_Show:
        return 'No Asistió';
      case ReservationState.modified:
        return 'Modificado';
      default:
        return name; 
    }
  }
}
