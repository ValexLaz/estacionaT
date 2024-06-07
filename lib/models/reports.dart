class Report {
  final int parking;
  final double totalEarnings;
  final int reservationVehicleCount;
  final int externalVehicleCount;

  Report({
    required this.parking,
    required this.totalEarnings,
    required this.reservationVehicleCount,
    required this.externalVehicleCount,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      parking: json['parking_id'] ?? 0,
      totalEarnings: json['total_earnings']?.toDouble() ?? 0.0,
      reservationVehicleCount: json['reservation_vehicle_count'] ?? 0,
      externalVehicleCount: json['external_vehicle_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parking': parking,
      'total_earnings': totalEarnings,
      'reservation_vehicle_count': reservationVehicleCount,
      'external_vehicle_count': externalVehicleCount,
    };
  }
}
