import 'dart:convert';

import 'package:http/http.dart' as http;

class Car {
  final String make;
  final String model;
  final int year;

  Car({required this.make, required this.model, required this.year});

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      make: json['make'],
      model: json['model'],
      year: json['year'],
    );
  }
}

class CarApi {
  static const String apiKey = 'CeBPRQI/BtlQKEA3vonTuQ==xYum5O5cgYNBrowl';
  static const String apiUrl = 'https://api.api-ninjas.com/v1/cars';

  static Future<List<Car>> fetchCars(String make, String model) async {
    final response = await http.get(
      Uri.parse('$apiUrl?make=$make&model=$model'),
      headers: {'X-Api-Key': apiKey},
    );

    if (response.statusCode == 200) {
      List<dynamic> carsJson = json.decode(response.body);
      return carsJson.map((json) => Car.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cars');
    }
  }

  static Future<List<String>> fetchCarMakes(String query) async {
    final response = await http.get(
      Uri.parse('$apiUrl?make=$query'),
      headers: {'X-Api-Key': apiKey},
    );

    if (response.statusCode == 200) {
      List<dynamic> carsJson = json.decode(response.body);
      List<String> makes = carsJson
          .map<String>((json) => json['make']
              .toString()
              .split(' ')
              .map((word) => word[0].toUpperCase() + word.substring(1))
              .join(' '))
          .toSet()
          .toList();
      return makes;
    } else {
      throw Exception('Failed to load car makes');
    }
  }

  static Future<List<String>> fetchCarModels(String make, String query) async {
    final response = await http.get(
      Uri.parse('$apiUrl?make=$make&model=$query'),
      headers: {'X-Api-Key': apiKey},
    );

    if (response.statusCode == 200) {
      List<dynamic> carsJson = json.decode(response.body);
      List<String> models = carsJson
          .map<String>((json) => json['model']
              .toString()
              .split(' ')
              .map((word) => word[0].toUpperCase() + word.substring(1))
              .join(' '))
          .toSet()
          .toList();
      return models;
    } else {
      throw Exception('Failed to load car models');
    }
  }
}
