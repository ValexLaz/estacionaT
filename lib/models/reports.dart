class Report {
  final int parking;
  final double totalEarnings;
  final int vehicleCount;

  Report({
    required this.parking,
    required this.totalEarnings,
    required this.vehicleCount,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      parking: json['parking'],
      totalEarnings: json['total_earnings'],
      vehicleCount: json['vehicle_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parking': parking,
      'total_earnings': totalEarnings,
      'vehicle_count': vehicleCount,
    };
  }
}
