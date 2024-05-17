import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:map_flutter/services/api_parking.dart';

const String MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoicGl0bWFjIiwiYSI6ImNsY3BpeWxuczJhOTEzbnBlaW5vcnNwNzMifQ.ncTzM4bW-jpq-hUFutnR1g';
const String MAPBOX_STYLE = 'mapbox/streets-v12';

class ParkingMapScreen extends StatefulWidget {
  final String parkingId;

  ParkingMapScreen({Key? key, required this.parkingId}) : super(key: key);

  @override
  _ParkingMapScreenState createState() => _ParkingMapScreenState();
}

class _ParkingMapScreenState extends State<ParkingMapScreen> {
  LatLng? userLocation;
  LatLng? parkingLocation;
  List<LatLng> routePoints = [];
  String etaText = '';
  String _distanceText = '';
  String _instructions = '';
  Map<String, dynamic>? parkingDetails;
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _determinePosition().then((_) => _loadParkingDetails());
  }

  Future<void> _determinePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _loadParkingDetails() async {
    try {
      ApiParking apiParking = ApiParking();
      var details = await apiParking.getParkingDetailsById(widget.parkingId);
      var addressDetails =
          await apiParking.getParkingAddressById(widget.parkingId);

      if (addressDetails.containsKey('latitude') &&
          addressDetails.containsKey('longitude')) {
        double latitude =
            double.tryParse(addressDetails['latitude'].toString()) ?? 0.0;
        double longitude =
            double.tryParse(addressDetails['longitude'].toString()) ?? 0.0;
        parkingLocation = LatLng(latitude, longitude);

        // Ensure both locations are set before fetching the route
        if (userLocation != null && parkingLocation != null) {
          await _getRoute();
        }

        setState(() {
          parkingDetails = details;
        });
      } else {
        throw Exception("Latitude and/or longitude data is missing or invalid");
      }
    } catch (e) {
      print('Failed to load parking details: $e');
    }
  }

  Future<void> _getRoute() async {
    String url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/${userLocation!.longitude},${userLocation!.latitude};${parkingLocation!.longitude},${parkingLocation!.latitude}?steps=true&geometries=geojson&access_token=$MAPBOX_ACCESS_TOKEN';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      var coordinates = jsonResponse['routes'][0]['geometry']['coordinates'];
      var duration =
          jsonResponse['routes'][0]['duration']; // Duración en segundos
      var distance =
          jsonResponse['routes'][0]['distance']; // Distancia en metros
      List<String> instructions = []; // Lista para almacenar instrucciones

      for (var leg in jsonResponse['routes'][0]['legs']) {
        for (var step in leg['steps']) {
          instructions.add(step['maneuver']['instruction']);
        }
      }

      setState(() {
        routePoints = coordinates
            .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
            .toList();
        int durationMinutes = (duration / 60).round();
        double distanceKm = distance / 1000; // Convertir a kilómetros
        etaText = "$durationMinutes minutos";
        _instructions =
            instructions.join('\n'); // Juntar instrucciones con salto de línea
        _distanceText =
            "${distanceKm.toStringAsFixed(2)} km"; // Formatear distancia
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parking Map'),
      ),
      body: Stack(
        children: [
          userLocation == null || parkingLocation == null || routePoints.isEmpty
              ? Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    center: userLocation,
                    zoom: 13.0,
                  ),
                  children: <Widget>[
                    TileLayer(
                      urlTemplate:
                          'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                      additionalOptions: {
                        'accessToken': MAPBOX_ACCESS_TOKEN,
                        'id': MAPBOX_STYLE,
                      },
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: userLocation!,
                          builder: (ctx) => Container(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Icon(
                                  Icons.navigation,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Marker(
                          point: parkingLocation!,
                          builder: (ctx) => Container(
                            width:
                                48, // Ajusta el tamaño del cuadrado según sea necesario
                            height:
                                48, // Ajusta el tamaño del cuadrado según sea necesario
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.local_parking,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routePoints,
                          strokeWidth: 4.0,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
          Positioned(
            top: 20,
            left: 20,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      etaText.isEmpty
                          ? 'Calculando Tiempo...'
                          : 'Tiempo: $etaText',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      _distanceText.isEmpty
                          ? 'Calculando Distance...'
                          : 'Distancia: $_distanceText',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
