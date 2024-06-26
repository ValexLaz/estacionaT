import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_flutter/screens_users/navigation_bar_screen.dart';
import 'package:map_flutter/screens_users/parkingDetails/parking_details.dart';
import 'package:map_flutter/services/api_parking.dart';
import 'package:map_flutter/services/distance_service.dart';

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
  LatLng? userLocation;
  bool isLoading = true;
  bool isSearchVisible = true;
  ScrollController _scrollController = ScrollController();
  double lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _determinePosition().then((_) => fetchData());
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > lastScrollOffset) {
      if (isSearchVisible) {
        setState(() {
          isSearchVisible = false;
        });
      }
    } else if (_scrollController.offset < lastScrollOffset) {
      if (!isSearchVisible) {
        setState(() {
          isSearchVisible = true;
        });
      }
    }
    lastScrollOffset = _scrollController.offset;
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
        var address = addresses.firstWhere((addr) => addr['parking'] == parking['id'], orElse: () => {});
        parking['latitude'] = address['latitude'] ?? 'No disponible';
        parking['longitude'] = address['longitude'] ?? 'No disponible';
        parking['street'] = address['street']?.isNotEmpty == true ? address['street'] : 'Ubicación no disponible';
        parking['distance_to_user'] = 'Calculando...'; // Placeholder for distance
        parking['eta'] = 'Calculando...'; // Placeholder for ETA

        return parking;
      }).toList();

      setState(() {
        parkings = data;
        filteredParkings = data;
        isLoading = false;
      });
      filterParkings(selectedFilterIndex);

      await DistanceService.calculateRoutesForAllParkings(data, userLocation!);
      data = await Future.wait(data.map((parking) async {
        if (userLocation != null &&
            parking['latitude'] != 'No disponible' &&
            parking['longitude'] != 'No disponible') {
          double latitude = double.tryParse(parking['latitude'].toString()) ?? 0.0;
          double longitude = double.tryParse(parking['longitude'].toString()) ?? 0.0;
          LatLng parkingLocation = LatLng(latitude, longitude);
          double distance = DistanceService.calculateDistance(userLocation!, parkingLocation);
          parking['distance_to_user'] = '${distance.toStringAsFixed(2)} km';
          parking['eta'] = await DistanceService.calculateEta(userLocation!, parkingLocation);
        } else {
          parking['distance_to_user'] = 'No disponible';
          parking['eta'] = 'No disponible';
        }
        return parking;
      }).toList());

      setState(() {
        parkings = data;
        filteredParkings = data;
      });
      filterParkings(selectedFilterIndex);
    } catch (e) {
      print('Error al obtener datos de parqueos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterParkings(int index) {
    setState(() {
      selectedFilterIndex = index;
    });
    switch (index) {
      case 0:
        filteredParkings = List.from(parkings)
          ..sort((a, b) => (a['distance_to_user'] as double).compareTo(b['distance_to_user'] as double));
        break;
      case 1:
        filteredParkings = parkings.where((p) => p['spaces_available'] > 0).toList();
        break;
      case 2:
        filteredParkings = parkings.where((p) => p['spaces_available'] <= 0).toList();
        break;
      case 3:
        filteredParkings = parkings;
        break;
      default:
        filteredParkings = parkings;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Parqueos', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
              Divider(color: Colors.grey),
            ],
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Column(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: isSearchVisible ? 60.0 : 0.0,
              child: Padding(
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
                      controller: _scrollController,
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
                          child: Container(
                            color: Colors.grey[200],
                            child: Card(
                              color: Colors.white,
                              child: Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15.0),
                                      child: parking['url_image'] != null &&
                                              parking['url_image'].isNotEmpty
                                          ? Image.network(
                                              parking['url_image'],
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
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
                                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.directions_car,
                                                  color: Colors.black,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 4),
                                                parking['eta'] == 'Calculando...'
                                                  ? SizedBox(
                                                      height: 14,
                                                      width: 14,
                                                      child: CircularProgressIndicator(strokeWidth: 1.5),
                                                    )
                                                  : Text(
                                                      parking['eta'] ?? 'Calculando...',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                Container(
                                                  width: 1.0,
                                                  height: 20.0,
                                                  color: Colors.black,
                                                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                                ),
                                                Icon(
                                                  Icons.check_circle,
                                                  color: isAvailable ? Colors.green : Colors.red,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  availabilityText,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: isAvailable ? Colors.green : Colors.red,
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
                                        if (parking.containsKey('distance_to_user'))
                                          Text(
                                            parking['distance_to_user'] ?? 'Calculando...',
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
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
