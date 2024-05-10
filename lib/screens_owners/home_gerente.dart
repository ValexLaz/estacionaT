import 'dart:math';

import 'package:flutter/material.dart';
import 'package:map_flutter/services/api_parking.dart';

class ParkingScreen extends StatefulWidget {
  final String parkingId;

  const ParkingScreen({Key? key, required this.parkingId}) : super(key: key);

  @override
  _ParkingScreenState createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
  final ApiParking apiParking = ApiParking();
  Map<String, dynamic> parkingDetails = {};
  List<Map<String, dynamic>> vehicleEntries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      await Future.wait([fetchParkingData(), fetchVehicleEntries()]);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar los datos.'),
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
  }

  Future<void> fetchVehicleEntries() async {
    try {
      vehicleEntries = await apiParking
          .getVehicleEntriesByParkingId(int.parse(widget.parkingId));

      setState(() {
        isLoading = false;
      });
      if (vehicleEntries.isNotEmpty) {
        print('Registros de vehículos encontrados:');
        vehicleEntries.forEach((entry) {
          print(entry);
        });
      }
    } catch (e) {
      print('Error fetching vehicle entries: $e');
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar los registros de vehículos.'),
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
  }

  Future<void> fetchParkingData() async {
    try {
      parkingDetails = await apiParking.getParkingDetailsById(widget.parkingId);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching parking data: $e');
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar los datos del parqueo.'),
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parqueo ${widget.parkingId}'),
        backgroundColor: Color(0xFF1b4ee4),
      ),
      body: isLoading ? _buildLoadingScreen() : _buildParkingScreen(),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildParkingScreen() {
    int maxCapacity = parkingDetails['maxCapacity'] ?? 100;
    int occupiedSpaces = parkingDetails['occupiedSpaces'] ?? 50;
    int freeSpaces = maxCapacity - occupiedSpaces;

    return Column(
      children: [
        _buildCapacityInfo(maxCapacity, occupiedSpaces, freeSpaces),
        Expanded(child: _buildVehiclesList()),
      ],
    );
  }

  Widget _buildCapacityInfo(
      int maxCapacity, int occupiedSpaces, int freeSpaces) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            parkingDetails['name'] ?? 'Parking Name',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Capacidad Total:',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${parkingDetails['capacity'] ?? 'N/A'}',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
          SizedBox(height: 10),
          LinearProgressIndicator(
            value: occupiedSpaces / maxCapacity,
            minHeight: 10,
            backgroundColor: Colors.grey[300],
            color: Colors.blue,
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Espacios libres: $freeSpaces"),
              Text("Espacios ocupados: $occupiedSpaces"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesList() {
    if (vehicleEntries.isEmpty) {
      return Center(
        child: Text('No hay vehículos registrados en este parqueo.'),
      );
    }

    return ListView.builder(
      itemCount: vehicleEntries.length,
      itemBuilder: (context, index) {
        var entry = vehicleEntries[index];
        return Card(
          child: ListTile(
            leading: Icon(Icons.directions_car),
            title: Text("Vehículo ${entry['vehicle']}"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ID de entrada: ${entry['id']}"),
                Text("Tiempo restante: ${Random().nextInt(120)} mins"),
              ],
            ),
          ),
        );
      },
    );
  }
}
