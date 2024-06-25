import 'dart:math';

import 'package:flutter/material.dart';
import 'package:map_flutter/services/api_parking.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

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
  List<Map<String, dynamic>> filteredVehicleEntries = [];
  bool isLoading = true;
  int vehiclesCount = 0;
  TextEditingController searchController = TextEditingController();
  String filterType = "name"; // Default filter type

  @override
  void initState() {
    super.initState();
    _fetchData();
    searchController.addListener(_filterVehicles);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterVehicles);
    searchController.dispose();
    super.dispose();
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
        filteredVehicleEntries = vehicleEntriesList;
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

  void _filterVehicles() {
    String query = searchController.text.toLowerCase();
    setState(() {
      if (filterType == "name") {
        filteredVehicleEntries = vehicleEntries.where((entry) {
          return entry['vehicle']['brand']
              .toString()
              .toLowerCase()
              .contains(query);
        }).toList();
      } else if (filterType == "minutes") {
        filteredVehicleEntries = vehicleEntries.where((entry) {
          int remainingTime = Random().nextInt(120);
          return remainingTime.toString().contains(query);
        }).toList();
      }
    });
  }

  Widget getVehicleIcon(int type) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Color(0xFF4285f4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          type == 1
              ? Icons.directions_car
              : type == 2
                  ? Icons.local_shipping
                  : type == 3
                      ? Icons.directions_car_filled
                      : type == 4
                          ? Icons.airport_shuttle
                          : type == 5
                              ? Icons.motorcycle
                              : Icons.directions_car,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Future<bool?> _confirmDeleteVehicle(int index) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Está seguro de que desea eliminar este vehículo?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          parkingDetails['name'] ?? 'Parking Name',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: isLoading ? _buildLoadingScreen() : _buildParkingScreen(),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4285f4)),
      ),
    );
  }

  Widget _buildParkingScreen() {
    int maxCapacity = parkingDetails['capacity'] ?? 100;
    int occupiedSpaces = parkingDetails['occupiedSpaces'] ?? vehiclesCount;
    int freeSpaces = maxCapacity - occupiedSpaces;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCapacityInfo(maxCapacity, occupiedSpaces, freeSpaces),
          SizedBox(height: 20),
          _buildSearchBar(),
          SizedBox(height: 20),
          Text(
            'Vehículos Registrados',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(child: _buildVehiclesList()),
        ],
      ),
    );
  }

  Widget _buildCapacityInfo(
      int maxCapacity, int occupiedSpaces, int freeSpaces) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          SimpleCircularProgressBar(
            size: 150,
            progressStrokeWidth: 20,
            backStrokeWidth: 20,
            maxValue: maxCapacity.toDouble(),
            valueNotifier: ValueNotifier(occupiedSpaces.toDouble()),
            progressColors: [Color(0xFF4285f4)],
            backColor: Colors.grey[300]!,
            onGetText: (double value) {
              return Text(
                '$freeSpaces/$maxCapacity\nEspacios',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  "Vehículos con reserva",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  "0",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  "Vehículos sin reserva",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  "0",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: Container(
        height: 40,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar por placa',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  filled: false,
                ),
                style: TextStyle(color: Colors.black),
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.filter_list, color: Colors.grey),
              onSelected: (String result) {
                setState(() {
                  filterType = result;
                  _filterVehicles();
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'name',
                  child: Text('Filtrar por nombre'),
                ),
                const PopupMenuItem<String>(
                  value: 'minutes',
                  child: Text('Filtrar por minutos'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehiclesList() {
    if (filteredVehicleEntries.isEmpty) {
      return Center(
        child: Text(
          'No hay vehículos registrados en este parqueo.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredVehicleEntries.length,
      itemBuilder: (context, index) {
        var entry = filteredVehicleEntries[index];
        int remainingTime = Random().nextInt(120);
        return Dismissible(
          key: Key(entry['vehicle']['registration_plate']),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await _confirmDeleteVehicle(index);
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            leading: getVehicleIcon(entry['vehicle']['type_vehicle']),
            title: Text(
              "${entry['vehicle']['brand']} ${entry['vehicle']['model']}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Color(0xFF4285f4)),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Text(
                    entry['vehicle']['registration_plate'],
                    style: TextStyle(
                      color: Color(0xFF4285f4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "$remainingTime mins",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
