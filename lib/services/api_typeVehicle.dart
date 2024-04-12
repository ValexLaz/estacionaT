import 'dart:convert';
import 'package:map_flutter/models/TypeVehicle.dart';
import 'package:map_flutter/services/api_service.dart';
import 'package:http/http.dart' as http;

class TypeVehicleApiService extends ApiService {
  TypeVehicleApiService() : super("vehicles/typevehicle/");

  Future<List<TypeVehicle>> getAllVehicleRecords() async {
    final response = await http.get(Uri.parse(completeUrl));
    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      return responseData.map((json) => TypeVehicle.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load data from API');
    }
  }
}