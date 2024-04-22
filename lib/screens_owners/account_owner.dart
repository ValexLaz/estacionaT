import 'package:flutter/material.dart';
import 'package:map_flutter/screens_owners/price_screen.dart';
import 'package:map_flutter/screens_users/login_screen.dart';
import 'package:map_flutter/services/api_parking.dart';

class ParkingOwnerScreen extends StatefulWidget {
  final String parkingId;
  const ParkingOwnerScreen({Key? key, required this.parkingId})
      : super(key: key);
  @override
  _ParkingOwnerScreenState createState() => _ParkingOwnerScreenState();
}

class _ParkingOwnerScreenState extends State<ParkingOwnerScreen> {
  final ApiParking apiParking = ApiParking();
  Map<String, dynamic> parkingDetails = {};
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchParkingData();
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
    Color primaryColor = Color(0xFF1b4ee4);
    Color textColor = Colors.black;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(color: primaryColor),
              ),
              Expanded(
                flex: 3,
                child: Container(color: Colors.white),
              ),
            ],
          ),
          Column(
            children: [
              Expanded(
                flex: 1,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.local_parking,
                            size: 60, color: primaryColor),
                        backgroundColor: Colors.white,
                      ),
                      SizedBox(height: 20),
                      Text(
                        parkingDetails['name'] ?? 'Parking Name',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Card(
                    color: Colors.white,
                    elevation: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildListTile(
                            title: 'Gestionar plazas de parqueo',
                            icon: Icons.directions_car,
                            textColor: textColor,
                            onTap: () {
                              // Lógica para gestionar plazas de parqueo
                            },
                          ),
                          _buildListTile(
                            title: 'Ver historial de reservas',
                            icon: Icons.history,
                            textColor: textColor,
                            onTap: () {
                              // Lógica para ver historial de reservas
                            },
                          ),
                          _buildListTile(
                            title: 'Configuraciones de la cuenta',
                            icon: Icons.settings,
                            textColor: textColor,
                            onTap: () {
                              // Lógica para configuraciones de la cuenta
                            },
                          ),
                          _buildListTile(
                            title: 'Precios',
                            icon: Icons.settings,
                            textColor: textColor,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PriceFormScreen()));
                            },
                          ),
                          _buildListTile(
                            title: 'Cerrar sesión',
                            icon: Icons.exit_to_app,
                            textColor: Colors.red,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    required Color textColor,
    required Function onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      trailing: Icon(Icons.keyboard_arrow_right, color: textColor),
      onTap: () => onTap(),
    );
  }
}
