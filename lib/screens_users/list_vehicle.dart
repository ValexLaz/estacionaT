import 'package:flutter/material.dart';
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:map_flutter/screens_users/vehicle_registration.dart';
import 'package:map_flutter/services/api_parking.dart';
import 'package:provider/provider.dart';
import 'package:map_flutter/common/widgets/notifications_alerts/confirmation_dialog.dart';
import 'package:map_flutter/screens_users/vehicle_details_screen.dart';

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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConfirmationDialog(
            title: 'Éxito',
            message: 'Vehículo eliminado exitosamente',
            onConfirm: () {
              setState(() {
                vehicles.removeWhere((vehicle) => vehicle['id'].toString() == vehicleId);
              });
            },
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el vehículo: $e')),
      );
    }
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  Widget getVehicleIcon(int type) {
    switch (type) {
      case 5:
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
      case 4:
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
      case 2:
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
      case 1:
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
        title: Text('Mis Vehículos', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
                    color: Colors.white,
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
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(
                                        color: Colors.grey, width: 1),
                                  ),
                                  color: Colors.transparent,
                                  elevation: 0,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: getVehicleIcon(
                                            vehicle['type_vehicle']),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${vehicle['brand']} - ${vehicle['model']}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 4, horizontal: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                      color: Colors.blue,
                                                      width: 2),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  "${vehicle['registration_plate']}",
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.blue),
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
                        _createRoute(VehicleRegistrationPage()),
                      ).then((_) {
                        fetchData(
                          Provider.of<TokenProvider>(context, listen: false)
                              .token,
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4285f4),
                      padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 100), // Increase horizontal padding
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
