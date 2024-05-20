import 'package:flutter/material.dart';
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:map_flutter/screens_users/vehicle_details_screen.dart';
import 'package:map_flutter/screens_users/vehicle_registration.dart';
import 'package:map_flutter/services/api_parking.dart';
import 'package:provider/provider.dart';

class ListVehicle extends StatefulWidget {
  const ListVehicle({super.key});
  @override
  State<ListVehicle> createState() => _ListVehicleState();
}

class _ListVehicleState extends State<ListVehicle> {
  final ApiVehicle apiVehicle = ApiVehicle();
  List<Map<String, dynamic>> vehicles = [];
  Color primaryColor = Color(0xFF1b4ee4);
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String? authToken =
        Provider.of<TokenProvider>(context, listen: false).token;
    fetchData(authToken);
  }

  Future<void> fetchData(String? token) async {
    setState(() {
      isLoading = true;
    });
    try {
      List<Map<String, dynamic>> data =
          await apiVehicle.getAllVehiclesByUserID(token!);
      setState(() {
        vehicles = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error al obtener datos de los vehículos: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await apiVehicle.deleteVehicleByID(vehicleId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vehículo eliminado exitosamente')),
      );
      setState(() {
        vehicles
            .removeWhere((vehicle) => vehicle['id'].toString() == vehicleId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el vehículo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Vehículos', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando vehículos...', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.grey[100],
                    child: vehicles.isEmpty
                        ? Center(
                            child: Text(
                              'No tienes vehículos registrados',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : ListView.builder(
                            itemCount: vehicles.length,
                            itemBuilder: (context, index) {
                              var vehicle = vehicles[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          VehicleDetailsScreen(
                                        vehicleId: vehicle['id'].toString(),
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.all(16),
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.directions_car,
                                          size: 50,
                                          color: primaryColor,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                vehicle['brand'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryColor,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                "Modelo: ${vehicle['model']}",
                                                style: TextStyle(
                                                    color: Colors.black87),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                "Placa: ${vehicle['registration_plate']}",
                                                style: TextStyle(
                                                    color: Colors.black87),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: primaryColor),
                                        onPressed: () async {
                                          await deleteVehicle(
                                              vehicle['id'].toString());
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VehicleRegistrationPage(),
                        ),
                      ).then((_) {
                        fetchData(
                          Provider.of<TokenProvider>(context, listen: false)
                              .token,
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(Icons.add, color: Colors.white),
                    label: Text(
                      'Agregar Vehículo',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
