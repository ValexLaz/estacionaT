import 'package:map_flutter/models/Price.dart';
import 'package:map_flutter/services/ApiRepository.dart';
import 'package:map_flutter/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class ApiPrice extends ApiRepository<Price>{
  ApiPrice() : super(
    path: 'parking/price/',
    fromJson: Price.fromJson,
    toJson: (Price p) => p.toJson(),
  );
}


class TypePriceService extends ApiService {
  TypePriceService() : super("parking/price/parking/");

  Future<List<Price>> getAllPriceRecords(int parkingId) async {
    final response = await http.get(Uri.parse(completeUrl + parkingId.toString() + "/"));
    if (response.statusCode == 200) {
      List<dynamic> responseData = json.decode(response.body);
      return responseData.map((json) => Price.fromJson(json)).toList();
    } else {
        print(response.body);
      throw Exception('Failed to load data from API');
    }
  }
}

