import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://estacionatbackend.onrender.com/api/v2/";
  String path;
  ApiService(this.path);

  Future<List<Map<String, dynamic>>> getAllRecords() async {
    final response = await http.get(Uri.parse('$baseUrl$path'));
    print(response.body);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  Future<void> createRecord(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to post data to API');
    }
  }

  Future<void> updateRecordByID(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path$id/'),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update data in API');
    }
  }

  Future<void> deleteRecordByID(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl$path$id/'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete data from API');
    }
  }
 
}