import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:map_flutter/screens_owners/map_next.dart';

const String MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1Ijoia2VuZGFsNjk2IiwiYSI6ImNsdnJvZ3o3cjBlbWQyanBqcGh1b3ZhbTcifQ.d5h3QddVskl61Rr8OGmnQQ';
const String MAPBOX_STYLE = 'mapbox/streets-v12';

class SelectMapScreen extends StatefulWidget {
  final int parkingId;
  SelectMapScreen({Key? key, required this.parkingId}) : super(key: key);

  @override
  _SelectMapScreenState createState() => _SelectMapScreenState();
}

class _SelectMapScreenState extends State<SelectMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _centerPosition; // Now it can be null
  TextEditingController _streetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _centerPosition = LatLng(position.latitude, position.longitude);
        if (_centerPosition != null) {
          _mapController.move(
              _centerPosition!, 15); // Safe to use ! here after null check
        }
      });
    } catch (e) {
      print('Error obteniendo la ubicación: $e');
      // Si no se puede obtener la ubicación actual, establece una ubicación predeterminada
      setState(() {
        _centerPosition = LatLng(0, 0); // Ubicación predeterminada
        _mapController.move(_centerPosition!, 15);
      });
    }
  }

  Future<void> saveLocation() async {
    if (_centerPosition != null) {
      // Check if _centerPosition is not null
      try {
        final response = await http.post(
          Uri.parse(
              'https://estacionatbackend.onrender.com/api/v2/parking/address/'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'latitude': _centerPosition!.latitude,
            'longitude': _centerPosition!.longitude,
            'city': 'Santa Cruz',
            'street': _streetController.text,
            'parking': widget.parkingId,
          }),
        );
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Parqueo registrado exitosamente')));
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      PriceParkingFormScreen(parkingId: widget.parkingId)));
        } else {
          print('Error al guardar la ubicación: ${response.body}');
        }
      } catch (e) {
        print('Error al guardar la ubicación: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selecciona la ubicación de tu parqueo"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _streetController,
              decoration: InputDecoration(
                labelText: 'Nombre de la calle',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _centerPosition ??
                        LatLng(0, 0), // Default position if null
                    zoom: 15,
                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture) {
                        setState(() {
                          _centerPosition = position.center;
                        });
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}",
                      additionalOptions: {
                        'accessToken': MAPBOX_ACCESS_TOKEN,
                        'id': MAPBOX_STYLE,
                      },
                    ),
                  ],
                ),
                Center(
                  child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Code for previous action
                      },
                      child: Container(
                        height: 50,
                        color: Colors.white,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back, size: 20),
                              SizedBox(width: 5),
                              Text(
                                "Anterior",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.black,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: saveLocation,
                      child: Container(
                        height: 50,
                        color: Colors.white,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Siguiente",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
