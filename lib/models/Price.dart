import 'package:flutter/material.dart';

class Price {
  int? typeVehicleID;
  String? typeVehicle;
  double price;
  int parkingId;
  bool isReservation;
  bool isPriceHour;
  bool isEntryFee;
  PriceHour? priceHour;

  Price(
      {this.typeVehicleID,
      required this.price,
      required this.parkingId,
      this.isReservation = false,
      this.isPriceHour = false,
      this.isEntryFee = true,
      this.priceHour,
      this.typeVehicle});

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      typeVehicle: json['type_vehicle'].toString(),
      price: json['price'].toDouble(),
      parkingId: json['parking'],
      isReservation: json['is_reservation'],
      isPriceHour: json['is_pricehour'],
      isEntryFee: json['is_entry_fee'],
      priceHour: json['price_hour'] != null
          ? PriceHour.fromJson(json['price_hour'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'is_entry_fee': isEntryFee,
      'type_vehicle': typeVehicleID,
      'price': price,
      'parking': parkingId,
      'is_reservation': isReservation,
      'is_pricehour': isPriceHour,
    };

    if (priceHour != null) {
      data['price_hour'] = priceHour!.toJson();
    }

    return data;
  }
}

class PriceHour {
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  int? totalTime;
  int? priceId;

  PriceHour({
    this.startTime,
    this.endTime,
    this.totalTime,
    this.priceId,
  });

  factory PriceHour.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('end_time') && json.containsKey('start_time') &&
    json['end_time'] != null && json['start_time'] != null) {
      DateTime startTime = DateTime.parse("1970-01-01 ${json['start_time']}");
      DateTime endTime = DateTime.parse("1970-01-01 ${json['end_time']}");

      TimeOfDay startTimeOfDay =
          TimeOfDay(hour: startTime.hour, minute: startTime.minute);
      TimeOfDay endTimeOfDay =
          TimeOfDay(hour: endTime.hour, minute: endTime.minute);

      return PriceHour(
        startTime: startTimeOfDay,
        endTime: endTimeOfDay,
        totalTime: json['total_time'],
        priceId: json['price'],
      );
    } else {
      return PriceHour(
        totalTime: json['total_time'],
        priceId: json['price'],
      );
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'total_time': totalTime,
    };

    if (startTime != null && endTime != null) {
      json['start_time'] = '${startTime!.hour}:${startTime!.minute}';
      json['end_time'] = '${endTime!.hour}:${endTime!.minute}';
    }

    return json;
  }
}
