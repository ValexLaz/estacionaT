import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:map_flutter/models/reports.dart';

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
}
