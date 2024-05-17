import 'package:flutter/material.dart';


class OpeningHours{
    int? id;
    String? day;
    int? parking;
    String? open_time;
    String? close_time;
    OpeningHours({
        this.id,
        this.day,
        this.open_time,
        this.parking,
        this.close_time,
    });
    factory OpeningHours.fromJson(Map<String, dynamic> json) {
        return OpeningHours(
            id: json['id'],
            day: json['day'],
            parking: json['parking'],
            open_time: json['open_time'],
            close_time: json['close_time'],
        );
    }
    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'day': day,
            'parking': parking,
            'open_time': open_time,
            'close_time': close_time,
        };
    }
}
