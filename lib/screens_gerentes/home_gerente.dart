import 'dart:math';

import 'package:flutter/material.dart';

class ParkingScreen extends StatefulWidget {
  const ParkingScreen({Key? key}) : super(key: key);

  @override
  _ParkingScreenState createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
  late String parkingName;
  final int maxCapacity = 100;
  late int occupiedSpaces;
  late int freeSpaces;

  @override
  void initState() {
    super.initState();
    parkingName = "Parqueo ${Random().nextInt(100)}";
    occupiedSpaces = 50; // For example, half of the capacity
    freeSpaces = maxCapacity - occupiedSpaces;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(parkingName),
        backgroundColor: Color(0xFF1b4ee4),
      ),
      body: Column(
        children: [
          _buildCapacityInfo(),
          Expanded(child: _buildVehiclesList()),
        ],
      ),
    );
  }

  Widget _buildCapacityInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text("Capacidad Máxima: $maxCapacity"),
          SizedBox(height: 10),
          LinearProgressIndicator(
            value: occupiedSpaces / maxCapacity,
            minHeight: 20,
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
    return ListView.builder(
      itemCount: occupiedSpaces,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: Icon(Icons.directions_car),
            title: Text("Vehículo ${index + 1}"),
            subtitle: Text("Tiempo restante: ${Random().nextInt(120)} mins"),
          ),
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ParkingScreen(),
  ));
}
