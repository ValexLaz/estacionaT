import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:map_flutter/models/statistics/popular_price.dart';
import 'package:map_flutter/models/statistics/reports.dart';

class ReportRepository {
  final String baseUrl = "https://estacionatbackend.onrender.com/api/v2/";

  Future<List<Report>> fetchReports(int parkingId) async {
    final url = Uri.parse(
        baseUrl + "reservation/parking-earnings/" + parkingId.toString() + "/");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        List<Report> reports =
            jsonResponse.map((json) => Report.fromJson(json)).toList();
        return reports;
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load reports');
      }
    } catch (e) {
      print('Error in fetchReports: $e');
      throw Exception('Failed to load reports');
    }
  }

  Future<PopularPrices> fetchPopularPrices(String parkingID,
      {DateTime? date, int? year}) async {
    final url = Uri.parse(
        baseUrl + "reservation/parking/" + parkingID + "/popular-prices/");

    Map<String, dynamic> body = {};

    if (date != null) {
      // Si se proporciona una fecha específica, usamos esa fecha para el rango
      body['start_date'] = date.toIso8601String().split('T')[0];
      body['end_date'] = date.toIso8601String().split('T')[0];
    } else if (year != null) {
      // Si se proporciona un año, lo usamos para filtrar
      body['year'] = year;
    }

    try {
      final response = await http.post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(body));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        PopularPrices popularPrices = PopularPrices.fromJson(jsonResponse);
        return popularPrices;
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load popular prices');
      }
    } catch (e) {
      print('Error in fetchPopularPrices: $e');
      throw Exception('Failed to load popular prices');
    }
  }

}
