import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:map_flutter/screens_users/navigation_bar_screen.dart';
import 'package:map_flutter/screens_users/parkingDetails/parking_details.dart';
import 'package:map_flutter/services/api_parking.dart';

const String MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1Ijoia2VuZGFsNjk2IiwiYSI6ImNsdnJvZ3o3cjBlbWQyanBqcGh1b3ZhbTcifQ.d5h3QddVskl61Rr8OGmnQQ';

class ParkingsScreen extends StatefulWidget {
  const ParkingsScreen({Key? key}) : super(key: key);

  @override
  State<ParkingsScreen> createState() => _ParkingsScreenState();
}

class _ParkingsScreenState extends State<ParkingsScreen> {
  final ApiParking apiParking = ApiParking();
  List<Map<String, dynamic>> parkings = [];
  List<Map<String, dynamic>> filteredParkings = [];
  List<Map<String, dynamic>> searchFilteredParkings = [];
  TextEditingController searchController = TextEditingController();
  int selectedFilterIndex = 1;
  final Random random = Random();
  LatLng? userLocation;
  bool isLoading = true; // Nueva bandera para indicar el estado de carga

  double calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371; // Radio de la tierra en kilómetros

    double dLat = radians(end.latitude - start.latitude);
    double dLng = radians(end.longitude - start.longitude);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(radians(start.latitude)) *
            cos(radians(end.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Distancia en kilómetros
  }

  double radians(double degree) {
    return degree * pi / 180;
  }

  @override
  void initState() {
    super.initState();
    _determinePosition().then((_) => fetchData());
  }

  Future<void> _determinePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> fetchData() async {
    try {
      List<Map<String, dynamic>> data = await apiParking.getAllParkings();
      List<Map<String, dynamic>> addresses = await apiParking.getAllParkingAddresses();

      data = data.map((parking) {
        var address = addresses.firstWhere(
            (addr) => addr['parking'] == parking['id'],
            orElse: () => {});
        parking['latitude'] = address['latitude'] ?? 'No disponible';
        parking['longitude'] = address['longitude'] ?? 'No disponible';
        parking['street'] = address['street']?.isNotEmpty == true
            ? address['street']
            : 'Ubicación no disponible';

        if (userLocation != null &&
            parking['latitude'] != 'No disponible' &&
            parking['longitude'] != 'No disponible') {
          double latitude = double.tryParse(parking['latitude'].toString()) ?? 0.0;
          double longitude = double.tryParse(parking['longitude'].toString()) ?? 0.0;
          LatLng parkingLocation = LatLng(latitude, longitude);
          double distance = calculateDistance(userLocation!, parkingLocation);
          parking['distance_to_user'] = distance;
        } else {
          parking['distance_to_user'] = double.infinity;
        }

        return parking;
      }).toList();

      await calculateRoutesForAllParkings(data);

      setState(() {
        parkings = data;
        filteredParkings = data;
        isLoading = false; // Datos cargados, se desactiva el loader
      });
      filterParkings(selectedFilterIndex);
    } catch (e) {
      print('Error al obtener datos de parqueos: $e');
      setState(() {
        isLoading = false; // Desactiva el loader en caso de error
      });
    }
  }

  Future<void> calculateRoutesForAllParkings(List<Map<String, dynamic>> parkings) async {
    if (userLocation == null) return;

    for (var parking in parkings) {
      if (parking['latitude'] != 'No disponible' &&
          parking['longitude'] != 'No disponible') {
        double latitude =
            double.tryParse(parking['latitude'].toString()) ?? 0.0;
        double longitude =
            double.tryParse(parking['longitude'].toString()) ?? 0.0;
        LatLng parkingLocation = LatLng(latitude, longitude);

        String url =
            'https://api.mapbox.com/directions/v5/mapbox/driving/${userLocation!.longitude},${userLocation!.latitude};${longitude},${latitude}?steps=true&geometries=geojson&access_token=$MAPBOX_ACCESS_TOKEN';

        var response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          var jsonResponse = json.decode(response.body);
          var duration =
              jsonResponse['routes'][0]['duration']; // Duración en segundos
          var distance =
              jsonResponse['routes'][0]['distance']; // Distancia en metros

          int durationMinutes = (duration / 60).round();
          double distanceKm = distance / 1000; // Convertir a kilómetros
          parking['eta'] = "$durationMinutes min.";
          parking['distance'] = "${distanceKm.toStringAsFixed(2)} km";
        } else {
          print('Request failed with status: ${response.statusCode}.');
        }
      }
    }
  }

  void filterParkings(int index) {
    setState(() {
      selectedFilterIndex = index;
    });
    switch (index) {
      case 0: // Cerca de ti
        filteredParkings = List.from(parkings)
          ..sort((a, b) => (a['distance_to_user'] as double).compareTo(b['distance_to_user'] as double));
        break;
      case 1: // Disponibles
        filteredParkings = parkings.where((p) => p['spaces_available'] > 0).toList();
        break;
      case 2: // No Disponibles
        filteredParkings = parkings.where((p) => p['spaces_available'] <= 0).toList();
        break;
      case 3: // Todos
        filteredParkings = parkings;
        break;
      default:
        filteredParkings = parkings;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Parqueos',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
            Divider(color: Colors.grey),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Container(
              color: Colors.white,
              height: 48,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar parqueos...',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: PopupMenuButton<int>(
                    onSelected: (int index) {
                      filterParkings(index);
                    },
                    icon: Icon(Icons.filter_list),
                    itemBuilder: (context) => [
                      PopupMenuItem<int>(
                        value: 0,
                        child: Text('Cerca de ti'),
                      ),
                      PopupMenuItem<int>(
                        value: 1,
                        child: Text('Disponibles'),
                      ),
                      PopupMenuItem<int>(
                        value: 2,
                        child: Text('No Disponibles'),
                      ),
                      PopupMenuItem<int>(
                        value: 3,
                        child: Text('Todos'),
                      ),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                ),
                onChanged: (value) {
                  searchFilteredParkings = filteredParkings.where((parking) {
                    String parkingName = parking['name'].toLowerCase();
                    return parkingName.contains(value.toLowerCase());
                  }).toList();
                  setState(() {});
                },
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Cargando parqueos...'),
                    ],
                  )
                : ListView.builder(
                    itemCount: searchController.text.isNotEmpty
                        ? searchFilteredParkings.length
                        : filteredParkings.length,
                    itemBuilder: (context, index) {
                      var parking = searchController.text.isNotEmpty
                          ? searchFilteredParkings[index]
                          : filteredParkings[index];
                      int spacesAvailable = parking['spaces_available'];
                      bool isAvailable = spacesAvailable > 0;
                      String availabilityText =
                          isAvailable ? 'Disponible' : 'Sin espacios';

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ParkingDetailsScreen2(
                                parkingId: parking['id'].toString(),
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: Colors.white,
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    left: 8.0, top: 8.0, bottom: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: parking['url_image'] != null &&
                                          parking['url_image'].isNotEmpty
                                      ? Image.network(
                                          parking['url_image'],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                              'assets/images/Logotipo.png',
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        )
                                      : Image.asset(
                                          'assets/images/Logotipo.png',
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        parking['name'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        parking['street'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      if (parking.containsKey('eta') &&
                                          parking.containsKey('distance'))
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.directions_car,
                                                color: Colors.black,
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                '${parking['eta']}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              Container(
                                                width: 1.0,
                                                height: 20.0,
                                                color: Colors.black,
                                                margin: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 8.0),
                                              ),
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: 16,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                isAvailable
                                                    ? 'Disponible'
                                                    : 'Sin espacios',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isAvailable
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 18.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.blue,
                                      size: 24,
                                    ),
                                    if (parking.containsKey('distance'))
                                      Text(
                                        parking['distance'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 40.0,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => NavigationBarScreen(),
            ));
          },
          label: Text(
            'Ver mapa',
            style: TextStyle(
              color: Colors.blue,
            ),
          ),
          icon: Icon(
            Icons.map,
            color: Colors.blue,
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
