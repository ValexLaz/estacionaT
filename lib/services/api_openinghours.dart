import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:map_flutter/models/OpeningHours.dart';
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:map_flutter/services/ApiRepository.dart';
import 'package:map_flutter/services/api_service.dart';
import 'package:provider/provider.dart';

class ApiOpeningHours extends ApiRepository<OpeningHours> {
  static final ApiOpeningHours _instance = ApiOpeningHours._internal();

  factory ApiOpeningHours() {
    return _instance;
  }

  ApiOpeningHours._internal()
      : super(
          path: 'parking/openinghours/',
          fromJson: OpeningHours.fromJson,
          toJson: (OpeningHours o) => o.toJson(),
        );

  Future<List<OpeningHours>> getOpeningHoursByParkingId(int parkingId) async {
    final response =
        await http.get(Uri.parse('${completeUrl}parking/$parkingId/'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList
          .map((jsonItem) => fromJson(jsonItem as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load opening hours');
    }
  }

  Future<void> updateOpeningHour(
      int openingHourId, OpeningHours updatedHour) async {
    final response = await http.put(
      Uri.parse('$completeUrl$openingHourId/'),
      body: json.encode(toJson(updatedHour)),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      print(response.body);
      throw Exception('Failed to update opening hour');
    }
  }

  Future<void> deleteOpeningHour(int openingHourId) async {
    final response =
        await http.delete(Uri.parse('$completeUrl$openingHourId/'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete opening hour');
    }
  }
}
