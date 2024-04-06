import 'package:flutter/material.dart';
import 'package:map_flutter/screens_users/vehicle_details_screen.dart';
import 'package:map_flutter/screens_users/vehicle_registration.dart';
import 'package:map_flutter/services/api_parking.dart';

class ListVehicle extends StatefulWidget {
  const ListVehicle({super.key});

  @override
  State<ListVehicle> createState() => _ListVehicleState();
}

class _ListVehicleState extends State<ListVehicle> {
  final ApiVehicle apiVehicle = ApiVehicle();
  List<Map<String, dynamic>> vehicles = [];
  Color primaryColor = Color(0xFF1b4ee4);

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      List<Map<String, dynamic>> data =
          await apiVehicle.getAllVehiclesByUserID("2");
      setState(() {
        vehicles = data;
      });
    } catch (e) {
      print('Error al obtener datos de los vehículos: $e');
    }
  }
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Vehículos', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VehicleRegistrationPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              child: Text(
                'Agregar Vehículo',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  var vehicle = vehicles[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VehicleDetailsScreen(
                            vehicleId: vehicle['id'].toString(),
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Icon(Icons.directions_car, size: 100), // Icono de auto
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Marca: " + vehicle['brand'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1b4ee4),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          try {
                                            await apiVehicle.deleteVehicleByID(vehicle['id'].toString());
                                            fetchData();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Vehículo eliminado exitosamente')),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error al eliminar el vehículo: $e')),
                                            );
                                          }
                                        },
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "Modelo: " + vehicle['model'],
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  Text(
                                    "Placa: " + vehicle['registration_plate'],
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
