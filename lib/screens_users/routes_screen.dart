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
  String distanceText = '';
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

        if (userLocation != null && parkingLocation != null) {
          await _getRoute();
          _fitMapToBounds();
        }

        setState(() {
          parkingDetails = details;
        });
        print('Parking details loaded: $parkingDetails');
      } else {
        throw Exception("Latitude and/or longitude data is missing or invalid");
      }
    } catch (e) {
      print('Failed to load parking details: $e');
    }
  }

  Future<void> _getRoute() async {
    if (userLocation == null || parkingLocation == null) {
      print('User location or parking location is null');
      return;
    }

    String url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/${userLocation!.longitude},${userLocation!.latitude};${parkingLocation!.longitude},${parkingLocation!.latitude}?alternatives=false&steps=true&geometries=geojson&access_token=$MAPBOX_ACCESS_TOKEN';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      var coordinates = jsonResponse['routes'][0]['geometry']['coordinates'];
      var duration = jsonResponse['routes'][0]['duration'];
      var distance = jsonResponse['routes'][0]['distance'];

      setState(() {
        routePoints = coordinates
            .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
            .toList();
        int durationMinutes = (duration / 60).round();
        double distanceKm = distance / 1000;
        etaText = "$durationMinutes min";
        distanceText = "${distanceKm.toStringAsFixed(1)} km";
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<void> _getAlternativeRoute() async {
    if (userLocation == null || parkingLocation == null) {
      print('User location or parking location is null');
      return;
    }

    String url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/${userLocation!.longitude},${userLocation!.latitude};${parkingLocation!.longitude},${parkingLocation!.latitude}?alternatives=true&steps=true&geometries=geojson&access_token=$MAPBOX_ACCESS_TOKEN';

    try {
      print('Fetching alternative route with URL: $url');
      var response = await http.get(Uri.parse(url));
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        print('JSON Response: $jsonResponse');
        if (jsonResponse['routes'] != null &&
            jsonResponse['routes'].length > 1) {
          var alternativeRoute =
              jsonResponse['routes'][1]; // Use the alternative route
          var coordinates = alternativeRoute['geometry']['coordinates'];
          var duration = alternativeRoute['duration'];
          var distance = alternativeRoute['distance'];

          setState(() {
            routePoints = coordinates
                .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
                .toList();
            int durationMinutes = (duration / 60).round();
            double distanceKm = distance / 1000;
            etaText = "$durationMinutes min";
            distanceText = "${distanceKm.toStringAsFixed(1)} km";
          });
          _fitMapToBounds();
          print('Alternative route found and state updated');
        } else {
          print('No alternative route found.');
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Error fetching alternative route: $e');
    }
  }

  void _fitMapToBounds() {
    if (userLocation != null && parkingLocation != null) {
      LatLngBounds bounds = LatLngBounds(userLocation!, parkingLocation!);
      mapController.fitBounds(
        bounds,
        options: FitBoundsOptions(
          padding: EdgeInsets.all(50),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Navegación',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Stack(
        children: [
          userLocation == null || parkingLocation == null
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
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routePoints,
                          strokeWidth: 4.0,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: userLocation!,
                          builder: (ctx) => Container(
                            child: Icon(
                              Icons.navigation,
                              color: Colors.white,
                              size: 20,
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(4.0),
                          ),
                        ),
                        Marker(
                          point: parkingLocation!,
                          builder: (ctx) => Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.blue,
                            ),
                            child: Icon(
                              Icons.local_parking,
                              color: Colors.white,
                              size: 25,
                            ),
                            padding: EdgeInsets.all(4.0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              margin: EdgeInsets.zero,
              color: Colors.blueAccent,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            etaText.isEmpty
                                ? 'Calculando Ruta...'
                                : "${etaText} (${distanceText})",
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold, // Added fontWeight
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Según tu ubicación actual',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: IconButton(
                            onPressed: _getAlternativeRoute,
                            icon: Icon(
                              Icons.alt_route,
                              color: Colors.blue,
                              size: 30,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.blue,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 124, // Aligns with the bottom padding of the Card
            right: 16, // Places the button in the bottom right corner
            child: FloatingActionButton(
              onPressed: () {
                if (userLocation != null) {
                  mapController.move(userLocation!, 13.0);
                }
              },
              backgroundColor: Colors.white,
              child: Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
