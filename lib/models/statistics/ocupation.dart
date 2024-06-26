class OcupationParking {
  final double avgReservationTimeHours;
  final double avgDetailsTimeHours;
  final double totalReservationTimeHours;
  final double totalDetailsTimeHours;

  OcupationParking({
    required this.avgReservationTimeHours,
    required this.avgDetailsTimeHours,
    required this.totalReservationTimeHours,
    required this.totalDetailsTimeHours,
  });

  factory OcupationParking.fromJson(Map<String, dynamic> json) {
    return OcupationParking(
      avgReservationTimeHours: json['avg_reservation_time_hours'].toDouble(),
      avgDetailsTimeHours: json['avg_details_time_hours'].toDouble(),
      totalReservationTimeHours:
          json['total_reservation_time_hours'].toDouble(),
      totalDetailsTimeHours: json['total_details_time_hours'].toDouble(),
    );
  }
  String getAverageReservation() {
    int hours = avgReservationTimeHours.floor();
    int minutes = ((avgDetailsTimeHours - hours) * 60).round();
    return '${hours}h ${minutes}min';
  }
    String getAverageVehicleEntry() {
    int hours = avgDetailsTimeHours.floor();
    int minutes = ((avgDetailsTimeHours - hours) * 60).round();
    return '${hours}h ${minutes}min';
  }
}
