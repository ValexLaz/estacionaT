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
  int vehiclesCount = 0;

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
      List<Map<String, dynamic>> vehicleEntriesList =
          await apiParking.getVehicleEntryById(widget.parkingId.toString());

      setState(() {
        vehicleEntries = vehicleEntriesList;
        vehiclesCount = vehicleEntries.length;
      });

      if (vehicleEntries.isNotEmpty) {
        print('Registros de vehículos encontrados:');
        vehicleEntries.forEach((entry) {
          print(entry);
        });
      } else {
        print(
            'No se encontraron registros de vehículos para el parqueo ${widget.parkingId}');
      }
    } catch (e) {
      print('Error fetching vehicle entries: $e');
      setState(() {
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
      setState(() {});
    } catch (e) {
      print('Error fetching parking data: $e');
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar los datos del parqueo.'),
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
  }

  Widget getVehicleIcon(int type) {
    switch (type) {
      case 1:
        return Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Image.asset('assets/Icons/sedan.png', color: Colors.white),
          ),
        );
      case 2:
        return Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child:
                Image.asset('assets/Icons/camioneta.png', color: Colors.white),
          ),
        );
      case 3:
        return Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Image.asset('assets/Icons/jeep.png', color: Colors.white),
          ),
        );
      case 4:
        return Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child:
                  Image.asset('assets/Icons/vagoneta.png', color: Colors.white),
            ),
          ),
        );
      case 5:
        return Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(Icons.motorcycle, size: 32, color: Colors.white),
          ),
        );
      default:
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(Icons.directions_car, size: 32, color: Colors.white),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalles de Parqueo',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
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
    int maxCapacity = parkingDetails['capacity'] ?? 100;
    int occupiedSpaces = parkingDetails['occupiedSpaces'] ?? vehiclesCount;
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
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
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
              Text(
                "Espacios libres: $freeSpaces",
                style: TextStyle(color: Colors.green),
              ),
              Text(
                "Espacios ocupados: $occupiedSpaces",
                style: TextStyle(color: Colors.red),
              ),
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
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: ListTile(
            leading: getVehicleIcon(entry['vehicle']['type_vehicle']),
            title: Text(
              "${entry['vehicle']['brand']} ${entry['vehicle']['model']}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Placa: ${entry['vehicle']['registration_plate']}"),
                Text("Tiempo restante: ${Random().nextInt(120)} mins"),
              ],
            ),
          ),
        );
      },
    );
  }
}
