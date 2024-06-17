import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_flutter/screens_users/parkingDetails/parking_details.dart';
import 'package:map_flutter/screens_users/routes_screen.dart';
import 'package:map_flutter/services/api_parking.dart';
import 'package:map_flutter/services/api_price.dart'; // Asegúrate de importar esto
import 'package:map_flutter/models/Price.dart'; // Asegúrate de importar esto

const String MAPBOX_ACCESS_TOKEN = 'pk.eyJ1Ijoia2VuZGFsNjk2IiwiYSI6ImNsdnJvZ3o3cjBlbWQyanBqcGh1b3ZhbTcifQ.d5h3QddVskl61Rr8OGmnQQ';
const String MAPBOX_STYLE = 'mapbox/streets-v12';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController searchController = TextEditingController();
  LatLng? myPosition;
  bool _showParkingDetails = false;
  Map<String, dynamic> _currentParkingDetails = {};
  List<Marker> markers = [];
  Marker? userLocationMarker;
  final MapController _mapController = MapController();
  List<Map<String, dynamic>> parkingAddresses = [];
  List<String> suggestions = [];
  double? _lowestPrice;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    loadParkingAddresses();
  }

  void _centerOnUserLocation() {
    if (myPosition != null) {
      _mapController.move(myPosition!, 18.0);
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await determinePosition();
      if (mounted) {
        setState(() {
          myPosition = LatLng(position.latitude, position.longitude);
          userLocationMarker = Marker(
            point: myPosition!,
            width: 30,
            height: 30,
            builder: (ctx) => const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40,
            ),
          );
          _mapController.move(myPosition!, 18.0);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error obteniendo la ubicación: $e'),
          duration: const Duration(seconds: 3),
        ));
      }
    }
  }

  Future<void> fetchAndShowParkingInfo(BuildContext context, String parkingId) async {
    try {
      Map<String, dynamic> parkingDetails = await ApiParking().getParkingDetailsById(parkingId);
      List<Price> parkingPrices = await ApiPrice().getAllByParam('parking/$parkingId/');
      double lowestPrice = parkingPrices.isNotEmpty
          ? parkingPrices.map((price) => price.price).reduce((a, b) => a < b ? a : b)
          : double.infinity;
      if (mounted) {
        setState(() {
          _currentParkingDetails = parkingDetails;
          _showParkingDetails = true;
          _lowestPrice = lowestPrice == double.infinity ? null : lowestPrice;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al cargar los detalles del parqueo: $e'),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  Future<void> loadParkingAddresses() async {
    try {
      List<Map<String, dynamic>> addresses = await ApiParking().getAllParkingAddresses();
      setState(() {
        parkingAddresses = addresses;
        markers = addresses.map((address) {
          LatLng position = LatLng(double.parse(address['latitude']), double.parse(address['longitude']));
          String parkingId = address['parking'].toString();
          return createMarker(position, parkingId);
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cargando las direcciones de parqueos: $e')));
    }
  }

  Future<void> searchAndHighlightParking(String query) async {
    for (var address in parkingAddresses) {
      if (address['name'].toString().toLowerCase().contains(query.toLowerCase())) {
        LatLng position = LatLng(double.parse(address['latitude']), double.parse(address['longitude']));
        _mapController.move(position, 18.0);
        setState(() {
          markers = markers.map((m) {
            if (m.point == position) {
              return Marker(
                point: m.point,
                width: 40,
                height: 40,
                builder: (ctx) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_parking,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              );
            }
            return m;
          }).toList();
        });
        return;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se encontró ningún parqueo con ese nombre.')));
  }

  void updateSuggestions(String input) {
    setState(() {
      suggestions = parkingAddresses
          .where((address) => address['name'].toString().toLowerCase().contains(input.toLowerCase()))
          .map((address) => address['name'].toString())
          .toList();
    });
  }

  Future<Position> determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Los permisos de ubicación están permanentemente denegados');
    }
    return Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          buildMap(),
          Positioned(
            top: 64.0,
            left: 16.0,
            right: 16.0,
            child: Column(
              children: [
                buildSearchBar(),
                if (suggestions.isNotEmpty) buildSuggestionsList(),
              ],
            ),
          ),
          if (_showParkingDetails) buildParkingDetailsPanel(context, _currentParkingDetails),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar parqueo...',
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.black),
              ),
              onChanged: updateSuggestions,
              onSubmitted: searchAndHighlightParking,
            ),
          ),
          IconButton(
            onPressed: _centerOnUserLocation,
            icon: const Icon(Icons.my_location, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget buildSuggestionsList() {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(suggestions[index]),
            onTap: () {
              searchController.text = suggestions[index];
              searchAndHighlightParking(suggestions[index]);
              setState(() {
                suggestions.clear();
              });
            },
          );
        },
      ),
    );
  }

  Widget buildParkingDetailsPanel(BuildContext context, Map<String, dynamic> details) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildParkingDetailsHeader(details),
            buildParkingDetailsActions(context, details),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildParkingDetailsHeader(Map<String, dynamic> details) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (details['url_image'] != null && details['url_image'].isNotEmpty)
                ? Image.network(
                    details['url_image'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/default_placeholder.png',
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    'assets/images/Logo.png',
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        details['name'] ?? 'Parking Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _showParkingDetails = false;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${details['spaces_available'] ?? 'N/A'} espacios disponibles',
                          style: const TextStyle(fontSize: 16, color: Colors.green),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      _lowestPrice != null ? '$_lowestPrice Bs/hora' : 'N/A',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    Container(width: 1, height: 20, color: Colors.black),
                    const SizedBox(width: 10),
                    const Icon(Icons.access_time),
                    const Text(
                      '9:00 - 21:00',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildParkingDetailsActions(BuildContext context, Map<String, dynamic> details) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ParkingDetailsScreen2(parkingId: details['id'].toString()),
                    ),
                  );
                },
                child: const Text('Ver más detalles', style: TextStyle(color: Colors.blue)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.blue),
                  ),
                  minimumSize: const Size(150, 50),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ParkingMapScreen(parkingId: details['id'].toString()),
                    ),
                  );
                },
                icon: const Icon(Icons.directions, color: Colors.white),
                label: const Text('Cómo llegar', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(150, 50),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(center: myPosition, zoom: 18),
      children: [
        TileLayer(
          urlTemplate: 'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
          additionalOptions: {
            'accessToken': MAPBOX_ACCESS_TOKEN,
            'id': MAPBOX_STYLE,
          },
        ),
        MarkerLayer(
          markers: userLocationMarker != null ? [userLocationMarker!, ...markers] : markers,
        ),
      ],
    );
  }

  Marker createMarker(LatLng position, String parkingId) {
    return Marker(
      point: position,
      width: 32,
      height: 32,
      builder: (ctx) => GestureDetector(
        onTap: () => fetchAndShowParkingInfo(ctx, parkingId),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.local_parking,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
