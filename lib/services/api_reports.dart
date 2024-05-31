// api_reports.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:map_flutter/models/reports.dart';

class ReportRepository {
  final String baseUrl = "https://estacionatbackend.onrender.com/api/v2/";

  Future<List<Report>> fetchReports() async {
    final response =
        await http.get(Uri.parse('${baseUrl}reservation/parking-earnings/'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((jsonItem) => Report.fromJson(jsonItem)).toList();
    } else {
      print(response.body);
      throw Exception('Failed to load reports');
    }
  }
}
