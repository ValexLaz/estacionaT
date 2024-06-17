import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class ApiRepository<T> {
  final String baseUrl = "https://estacionatbackend.onrender.com/api/v2/";
  final String path;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  ApiRepository(
      {required this.path, required this.fromJson, required this.toJson});

  String get completeUrl => baseUrl + path;

  Future<List<T>> getAll() async {
    final response = await http.get(Uri.parse(completeUrl));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList
          .map((jsonItem) => fromJson(jsonItem as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  Future<T> create(T item) async {
    final response = await http.post(Uri.parse(completeUrl),
        body: json.encode(toJson(item)),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 201) {
      return fromJson(json.decode(response.body));
    } else {
      // ignore: avoid_print
      print(response.body);
      throw Exception(
          'Failed to post data to API. Status code: ${response.statusCode}');
    }
  }

  Future<T> update(String id, T item) async {
    final response = await http.put(Uri.parse('$completeUrl$id/'),
        body: json.encode(toJson(item)),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to update data in API. Status code: ${response.statusCode}');
    }
  }

  Future<void> delete(String id) async {
    final response = await http.delete(Uri.parse('$completeUrl$id/'));
    if (response.statusCode != 204) {
      throw Exception(
          'Failed to delete data from API. Status code: ${response.statusCode}');
    }
  }

Future<List<T>> getAllByParam(String param) async {
  try {
    final response = await http.get(Uri.parse('$completeUrl$param'));
    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList
          .map((jsonItem) => fromJson(jsonItem as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load data from API');
    }
  } catch (e) {
    // Manejar el error aquí
    print('Error al obtener datos de la API: $e');
    rethrow;
  }
}
}
