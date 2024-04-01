import 'package:flutter/material.dart';
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
      print('Error al obtener datos de parqueos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Vehiculos', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1b4ee4),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(
                vertical:
                    16), // Ajusta el margen superior e inferior según sea necesario
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
                'Agregar Vehiculo',
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
                  return Card(
                    margin: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Image.network(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQNW-m5rK0oxc2mHo2tfJhNoE-LUeFf-zsMxOFQRAy34D7fPK9ddTF8QKBj4VpBu4vtYMQ&usqp=CAU', 
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "marca : " + vehicle['brand'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1b4ee4),
                                  ),
                                ),
                                Text(
                                  "modelo : " + vehicle['model'],
                                  style: TextStyle(color: Colors.black),
                                ),
                                Text(
                                  "placa : " + vehicle['registration_plate'],
                                  style: TextStyle(color: Colors.black),
                                ),
                                
                        
                              ],
                            ),
                          ),
                        ),
                      ],
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
