import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_flutter/screens_users/parking_details_screen.dart';
import 'package:map_flutter/services/api_parking.dart';

const String MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1IjoicGl0bWFjIiwiYSI6ImNsY3BpeWxuczJhOTEzbnBlaW5vcnNwNzMifQ.ncTzM4bW-jpq-hUFutnR1g';
const String MAPBOX_STYLE = 'mapbox/streets-v12';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? myPosition;
  List<Marker> markers = []; // Lista para almacenar marcadores
  Marker? userLocationMarker;
  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    loadParkingAddresses();
  }

  void fetchAndShowParkingInfo(BuildContext context, String parkingId) async {
    try {
      Map<String, dynamic> parkingDetails =
          await ApiParking().getParkingDetailsById(parkingId);
      showModalBottomSheet(
        context: context,
        builder: (ctx) => buildParkingDetailsSheet(ctx, parkingDetails),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to load parking details: $e'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  Widget buildParkingDetailsSheet(
      BuildContext context, Map<String, dynamic> details) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Text(
            details['name'] ?? 'Parking Unknown',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Espacios disponibles: ${details['spaces_available'] ?? 'N/A'}',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 4),
          Text(
            'Tarifa: 10 Bs/hora',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            'Descripción:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            details['description'] ?? 'No description available',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ParkingDetailsScreen(
                    parkingId: details['id']
                        .toString(), // Asegúrate de que 'details' contiene 'id'
                  ),
                ),
              );
            },
            child: Text('Ver más detalles'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadParkingAddresses() async {
    ApiParking apiParking = ApiParking();
    try {
      List<Map<String, dynamic>> addresses =
          await apiParking.getAllParkingAddresses();
      setState(() {
        markers = addresses.map((address) {
          LatLng position = LatLng(double.parse(address['latitude']),
              double.parse(address['longitude']));
          String parkingId =
              address['parking'].toString(); // Usa el 'parking' como parkingId
          return createMarker(position, parkingId, address);
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading parking addresses: $e')),
      );
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await determinePosition();
      setState(() {
        myPosition = LatLng(position.latitude, position.longitude);
        // Crea el marcador para la ubicación actual
        userLocationMarker = Marker(
          point: myPosition!,
          width: 30,
          height: 30,
          builder: (ctx) => Container(
            child: Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40,
            ),
          ),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error obtaining location: $e'),
        duration: Duration(seconds: 3),
      ));
    }
  }

  Future<Position> determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }
    return Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: myPosition == null || markers.isEmpty
          ? Center(child: CircularProgressIndicator())
          : buildMap(),
    );
  }

  Widget buildMap() {
    return FlutterMap(
      options: MapOptions(
        center: myPosition,
        zoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
          additionalOptions: {
            'accessToken': MAPBOX_ACCESS_TOKEN,
            'id': MAPBOX_STYLE,
          },
        ),
        MarkerLayer(
            markers: userLocationMarker != null
                ? [userLocationMarker!, ...markers]
                : markers),
      ],
    );
  }

  Marker createMarker(
      LatLng position, String parkingId, Map<String, dynamic> data) {
    return Marker(
      point: position,
      width: 32,
      height: 32,
      builder: (ctx) => GestureDetector(
        onTap: () => fetchAndShowParkingInfo(ctx, parkingId),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.local_parking,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  void showParkingInfo(
      BuildContext context, LatLng position, Map<String, dynamic> details) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
            Text(
              details['name'] ?? 'Parking Desconocido',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Detalles del parqueo:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(details['description'] ?? 'Descripción no disponible'),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParkingDetailsScreen(
                      parkingId: details['parkingId']
                          .toString(), // Asegúrate de que el parkingId se maneja correctamente
                    ),
                  ),
                );
              },
              child: Text('Ver más detalles'),
            ),
          ],
        ),
      ),
    );
  }
}
