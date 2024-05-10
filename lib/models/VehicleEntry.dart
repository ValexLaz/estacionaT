import 'package:flutter/material.dart';


class VehicleEntry {
  final int user; 
  final int vehicle;
  final int parking;
  
  VehicleEntry({
    required this.user,
    required this.vehicle,
    required this.parking,
  });

  factory VehicleEntry.fromJson(Map<String, dynamic> json) {
    return VehicleEntry(
      user: json['user'],
      vehicle: json['vehicle'],
      parking: json['parking'],
    
    );
  }

  Map<String, dynamic> toJson() {
    return {
       'user' : user,
      'vehicle': vehicle,
      'parking': parking
    };
  }
}
