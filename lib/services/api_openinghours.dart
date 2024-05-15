import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:map_flutter/models/OpeningHours.dart';
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:map_flutter/services/ApiRepository.dart';
import 'package:map_flutter/services/api_service.dart';
import 'package:provider/provider.dart';



class ApiOpeningHours extends ApiRepository<OpeningHours>{
  ApiOpeningHours() : super(
    path: 'parking/openinghours/',
    fromJson: OpeningHours.fromJson,
    toJson: (OpeningHours o) => o.toJson(),
  );



  
}

