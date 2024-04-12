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

  Future<void> updateParkingById(
      String parkingId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path$parkingId/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update parking details: ${response.body}');
    }
  }

Future<String> createRecord(Map<String, dynamic> data) async {
  final response = await http.post(
    Uri.parse('$baseUrl$path'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(data),
  );

  if (response.statusCode == 201) {
    final Map<String, dynamic> responseData = json.decode(response.body);
    final String parkingId = responseData['id'].toString(); // Convierte el ID del parqueo a String
    return parkingId;
  } else {
    throw Exception('Failed to post data to API: ${response.body}');
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
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  Future<void> deleteVehicleByID(String vehicleID) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl$path$vehicleID/'));
      if (response.statusCode != 200) {
        //aclarando que no hay ningun codigo de error asi que pongo eso
        throw Exception('Failed to delete vehicle');
      }
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }

  Future<Map<String, dynamic>> getVehicleDetailsById(String vehicleId) async {
    final response = await http.get(Uri.parse('$baseUrl$path$vehicleId/'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load vehicle details from API');
    }
  }
}
