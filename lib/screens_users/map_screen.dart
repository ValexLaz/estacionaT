import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_flutter/screens_users/parkingDetails/parking_details.dart';
import 'package:map_flutter/screens_users/routes_screen.dart';
import 'package:map_flutter/services/api_parking.dart';

const String MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1Ijoia2VuZGFsNjk2IiwiYSI6ImNsdnJvZ3o3cjBlbWQyanBqcGh1b3ZhbTcifQ.d5h3QddVskl61Rr8OGmnQQ';
const String MAPBOX_STYLE = 'mapbox/streets-v12';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  TextEditingController searchController = TextEditingController();
  LatLng? myPosition;
  bool _showParkingDetails = false; // Estado para mostrar/ocultar detalles
  Map<String, dynamic> _currentParkingDetails = {};
  List<Marker> markers = []; // Lista para almacenar marcadores
  Marker? userLocationMarker;
  final MapController _mapController = MapController();

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
            builder: (ctx) => Container(
              child: Icon(
                Icons.location_on,
                color: Colors.red,
                size: 40,
              ),
            ),
          );
          // Mueve el mapa a la ubicación actual
          _mapController.move(myPosition!, 18.0);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error obtaining location: $e'),
          duration: Duration(seconds: 3),
        ));
      }
    }
  }

  void fetchAndShowParkingInfo(BuildContext context, String parkingId) async {
    try {
      Map<String, dynamic> parkingDetails =
          await ApiParking().getParkingDetailsById(parkingId);
      if (mounted) {
        setState(() {
          _currentParkingDetails = parkingDetails;
          _showParkingDetails = true; // Mostrar el panel con detalles
        });
      }
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
                  builder: (context) => ParkingDetailsScreen2(
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
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ParkingMapScreen(
                    parkingId:
                        details['id'].toString(), // Pasar solo el parkingId
                  ),
                ),
              );
            },
            child: Text('Ver en Mapa'),
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

  Future<void> searchAndHighlightParking(String query) async {
    for (var marker in markers) {
      if (marker.key.toString().toLowerCase().contains(query.toLowerCase())) {
        _mapController.move(marker.point, 18.0);
        setState(() {
          markers = markers.map((m) {
            if (m.point == marker.point) {
              return Marker(
                point: m.point,
                width: 40,
                height: 40,
                builder: (ctx) => Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No se encontró ningún parqueo con ese nombre.')),
    );
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
      body: Stack(
        children: [
          buildMap(),
          Positioned(
            top: 64.0,
            left: 16.0,
            right: 16.0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
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
                      decoration: InputDecoration(
                        hintText: 'Buscar parqueo...',
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.black),
                      ),
                      onSubmitted: (value) {
                        // Lógica para buscar parqueos basado en el valor ingresado
                        // Puedes implementar tu propia lógica de búsqueda aquí
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: _centerOnUserLocation,
                    icon: Icon(Icons.my_location, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          if (_showParkingDetails) // Mostrar detalles solo si es necesario
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: buildParkingDetailsPanel(context, _currentParkingDetails),
            ),
        ],
      ),
    );
  }

  Widget buildParkingDetailsPanel(
      BuildContext context, Map<String, dynamic> details) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black26,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: (details['url_image'] != null &&
                            details['url_image'].isNotEmpty)
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
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${details['spaces_available'] ?? 'N/A'} espacios disponibles',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.green),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              '10 Bs/hora',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 10),
                            Container(
                              width: 1,
                              height: 20,
                              color: Colors.black,
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.access_time),
                            Text(
                              '9:00 - 21:00',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
       
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10,right: 10),
                    child:  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ParkingDetailsScreen2(
                                parkingId: details['id'].toString(),
                              ),
                            ),
                          );
                        },
                        child: Text('Ver más detalles',
                            style: TextStyle(color: Colors.blue)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.blue),
                          ),
                          minimumSize: Size(150, 50),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ParkingMapScreen(
                                parkingId: details['id'].toString(),
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.directions, color: Colors.white),
                        label: Text('Cómo llegar',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: Size(150, 50),
                        ),
                      ),
                    ],
                  ),
                  
                  ),
                 SizedBox(height: 20),
                ],
              ),
            
          ],
        ),
      ),
    );
  }

  Widget buildMap() {
    return FlutterMap(
      mapController: _mapController,
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
                    builder: (context) => ParkingDetailsScreen2(
                      parkingId: details['parkingId'].toString(),
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
