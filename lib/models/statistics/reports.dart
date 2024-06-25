class Report {
  final int parkingId;
  final String date;
  final double totalEarnings;
  final int reservationVehicleCount;
  final int entryVehicleCount;
  final int externalVehicleCount;

  Report({
    required this.parkingId,
    required this.date,
    required this.totalEarnings,
    required this.reservationVehicleCount,
    required this.entryVehicleCount,
    required this.externalVehicleCount,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      parkingId: json['parking_id'] ?? 0,
      date: json['date'] ?? '',
      totalEarnings: json['total_earnings']?.toDouble() ?? 0.0,
      reservationVehicleCount: json['reservation_vehicle_count'] ?? 0,
      entryVehicleCount: json['entry_vehicle_count'] ?? 0,
      externalVehicleCount: json['external_vehicle_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parking_id': parkingId,
      'date': date,
      'total_earnings': totalEarnings,
      'reservation_vehicle_count': reservationVehicleCount,
      'entry_vehicle_count': entryVehicleCount,
      'external_vehicle_count': externalVehicleCount,
    };
  }
}
