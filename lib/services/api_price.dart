import 'package:map_flutter/models/Price.dart';
import 'package:map_flutter/services/ApiRepository.dart';

class ApiPrice extends ApiRepository<Price>{
  ApiPrice() : super(
    path: 'parking/price/',
    fromJson: Price.fromJson,
    toJson: (Price p) => p.toJson(),
  );
}