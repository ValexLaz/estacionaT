import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

// Constante para el token de acceso de Mapbox
const MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoicGl0bWFjIiwiYSI6ImNsY3BpeWxuczJhOTEzbnBlaW5vcnNwNzMifQ.ncTzM4bW-jpq-hUFutnR1g';

class SelectMapScreen extends StatefulWidget {
  final int parkingId;
  const SelectMapScreen({Key? key, required this.parkingId}) : super(key: key);

  @override
  _SelectMapScreenState createState() => _SelectMapScreenState();
}

class _SelectMapScreenState extends State<SelectMapScreen> {
  LatLng? myPosition;

  // Método para obtener la ubicación actual del usuario
  Future<void> getCurrentLocation() async {
    try {
      Position position = await determinePosition();
      if (mounted) {
        setState(() {
          myPosition = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      // Maneja la excepción aquí, posiblemente mostrando un mensaje de error al usuario
      print('Error obteniendo la ubicación: $e');
    }
  }

  // Método para determinar la posición actual del usuario
  Future<Position> determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permiso de ubicación denegado');
      }
    }
    return Geolocator.getCurrentPosition();
  }


Future<void> saveLocation(double latitude, double longitude) async {
  try {
    final response = await http.post(
      Uri.parse('https://estacionatbackend.onrender.com/api/v2/parking/address/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'latitude': latitude,
        'longitude': longitude,
        'city': 'santacruz',
        'street': 'NombreDeTuCalle',
        'parking': widget.parkingId,
      }),
    );
    if (response.statusCode == 201) {
      print('Ubicación guardada exitosamente en la API');
    } else {
      print('Error al guardar la ubicación en la API: ${response.body}');
    }
  } catch (e) {
    print('Error al guardar la ubicación en la API: $e');
  }
}

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Ubicación en el Mapa'),
      ),
      body: myPosition == null
          ? const CircularProgressIndicator()
          : FlutterMap(
              options: MapOptions(
                center: myPosition,
                minZoom: 5,
                maxZoom: 25,
                zoom: 18,
                onTap: (tapPosition, latLng) {
                  // Llama al método para guardar la ubicación
                  saveLocation(latLng.latitude, latLng.longitude);
                },
              ),
              nonRotatedChildren: [
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                  additionalOptions: {
                    'accessToken': MAPBOX_ACCESS_TOKEN,
                    'id': 'mapbox/streets-v12',
                  },
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: myPosition!,
                      builder: (ctx) => const Icon(
                        Icons.person_pin,
                        color: Colors.blueAccent,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Al presionar el botón flotante, pasa la ubicación junto con el ID del parqueo
          Navigator.pop(context, {'position': myPosition, 'parkingId': widget.parkingId});
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
