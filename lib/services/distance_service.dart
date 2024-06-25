import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

const String MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1Ijoia2VuZGFsNjk2IiwiYSI6ImNsdnJvZ3o3cjBlbWQyanBqcGh1b3ZhbTcifQ.d5h3QddVskl61Rr8OGmnQQ';

class DistanceService {
  static double calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371;

    double dLat = _radians(end.latitude - start.latitude);
    double dLng = _radians(end.longitude - start.longitude);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_radians(start.latitude)) * cos(_radians(end.latitude)) * sin(dLng / 2) * sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _radians(double degree) {
    return degree * pi / 180;
  }

  static Future<void> calculateRoutesForAllParkings(
      List<Map<String, dynamic>> parkings, LatLng userLocation) async {
    for (var parking in parkings) {
      if (parking['latitude'] != 'No disponible' &&
          parking['longitude'] != 'No disponible') {
        double latitude = double.tryParse(parking['latitude'].toString()) ?? 0.0;
        double longitude = double.tryParse(parking['longitude'].toString()) ?? 0.0;
        LatLng parkingLocation = LatLng(latitude, longitude);

        String url =
            'https://api.mapbox.com/directions/v5/mapbox/driving/${userLocation.longitude},${userLocation.latitude};${longitude},${latitude}?steps=true&geometries=geojson&access_token=$MAPBOX_ACCESS_TOKEN';

        var response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          var jsonResponse = json.decode(response.body);
          var duration = jsonResponse['routes'][0]['duration'];
          var distance = jsonResponse['routes'][0]['distance'];

          int durationMinutes = (duration / 60).round();
          double distanceKm = distance / 1000;
          parking['eta'] = "$durationMinutes min.";
          parking['distance'] = "${distanceKm.toStringAsFixed(2)} km";
        } else {
          print('Request failed with status: ${response.statusCode}.');
        }
      }
    }
  }

  static Future<String> calculateEta(LatLng start, LatLng end) async {
    String url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?steps=true&geometries=geojson&access_token=$MAPBOX_ACCESS_TOKEN';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      var duration = jsonResponse['routes'][0]['duration'];

      int durationMinutes = (duration / 60).round();
      return "$durationMinutes min.";
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return "No disponible";
    }
  }
}




