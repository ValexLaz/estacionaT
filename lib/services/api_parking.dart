import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:map_flutter/services/api_service.dart';
import 'package:provider/provider.dart';

class ApiParking {
  String baseUrl;
  final String path = "parking/parking/";

  ApiParking({this.baseUrl = "https://estacionatbackend.onrender.com/api/v2/"});

  void setBaseUrl(String url) {
    baseUrl = url;
  }

  Future<void> deleteParkingById(String parkingId) async {
    final response = await http.delete(Uri.parse('$baseUrl$path$parkingId/'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final bool deleted = responseData['deleted'];
      if (deleted) {
        print('Parqueo eliminado exitosamente');
      } else {
        throw Exception('Error al eliminar el parqueo');
      }
    } else if (response.statusCode == 404) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String error = responseData['error'];
      throw Exception(error);
    } else {
      throw Exception('Error desconocido al eliminar el parqueo');
    }
  }

  Future<List<Map<String, dynamic>>> getAllParkings() async {
    final response = await http.get(Uri.parse('$baseUrl$path'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  Future<List<Map<String, dynamic>>> getParkingsByUserId(String token) async {
    print(token);
    final response = await http.get(
      Uri.parse(baseUrl + path + 'user/'),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      print(response.body);
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  Future<List<Map<String, dynamic>>> getAllParkingAddresses() async {
    final String url = '${baseUrl}parking/address/';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      print(
          'Failed to load parking addresses with status code: ${response.statusCode}');
      throw Exception('Failed to load parking addresses: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getParkingAddressById(String parkingId) async {
    final String path = "parking/address/parking/$parkingId/";
    final response = await http.get(Uri.parse('$baseUrl$path'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load parking address details from API');
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
      final String parkingId = responseData['id'].toString();
      return parkingId;
    } else {
      throw Exception('Failed to post data to API: ${response.body}');
    }
  }

  Future<List<String>> getParkingPrices(int parkingId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl' + 'parking/price/parking/$parkingId'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        return responseData.map((json) => json['price'].toString()).toList();
      } else {
        throw Exception('Failed to load parking prices from API');
      }
    } catch (e) {
      throw Exception('Error fetching parking prices: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getVehicleEntriesByParkingId(
      int parkingId) async {
    final response =
        await http.get(Uri.parse('$baseUrl' + 'parking/vehicleentry/'));
    if (response.statusCode == 200) {
      List<Map<String, dynamic>> allVehicleEntries =
          List<Map<String, dynamic>>.from(json.decode(response.body));
      List<Map<String, dynamic>> filteredEntries = allVehicleEntries
          .where((entry) => entry['parking'] == parkingId)
          .toList();
      return filteredEntries;
    } else {
      throw Exception('Failed to load vehicle entries from API');
    }
  }
}

class ApiUser extends ApiService {
  ApiUser() : super("user/user/");
}

class ApiVehicle extends ApiService {
  ApiVehicle() : super("vehicles/vehicle/");

  Future<List<Map<String, dynamic>>> getAllVehiclesByUserID(
      String token) async {
    String user = "user";
    print(token);
    final response = await http.get(
        Uri.parse(
            'https://estacionatbackend.onrender.com/api/v2/vehicles/vehicle/user/'),
        headers: {
          'Authorization': 'Token $token',
        });
    if (response.statusCode == 200) {
      List<Map<String, dynamic>> allVehicles =
          List<Map<String, dynamic>>.from(json.decode(response.body));
      //filtro para vehiculos del propietario, no del parqueo
      List<Map<String, dynamic>> ownParkingFalseVehicles = allVehicles
          .where((vehicle) => vehicle['is_ownparking'] == false)
          .toList();
      return ownParkingFalseVehicles;
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  Future<void> deleteVehicleByID(String vehicleID) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl$path$vehicleID/'));
      if (response.statusCode != 200) {
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
