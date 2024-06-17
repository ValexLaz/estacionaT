import 'dart:convert';

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
      reservationDate: json['reservation_date'],
      userId: json['user'],
           state: ReservationState.values.byName((json['state'] ?? '').toString().toLowerCase()),


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

  static List<Reservation> parseList(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Reservation>((json) => Reservation.fromJson(json)).toList();
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
}