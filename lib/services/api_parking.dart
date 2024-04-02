import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:map_flutter/services/api_service.dart';

class ApiParking {
  final String baseUrl = "https://estacionatbackend.onrender.com/api/v2/";
  final String path = "parking/parking/";

  Future<List<Map<String, dynamic>>> getAllParkings() async {
    final response = await http.get(Uri.parse('$baseUrl$path'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  Future<Map<String, dynamic>> getParkingDetailsById(String parkingId) async {
    final response = await http.get(Uri.parse('$baseUrl$path$parkingId/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load parking details from API');
    }
  }
}

class ApiUser extends ApiService {
  ApiUser() : super("user/user/");
}

class ApiVehicle extends ApiService {
  ApiVehicle() : super("vehicles/vehicle/");

  Future<List<Map<String, dynamic>>> getAllVehiclesByUserID(String id) async {
    String user = "user";
    final response = await http.get(Uri.parse('$baseUrl$path$user/$id/'));
    print(response.body);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load data from API');
    }
  }
}
