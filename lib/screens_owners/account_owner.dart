import 'package:flutter/material.dart';
import 'package:map_flutter/screens_owners/ParkingPricesScreen.dart';
import 'package:map_flutter/screens_owners/opening_hours_screen.dart';
import 'package:map_flutter/screens_owners/parking_description.dart';
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
    Color lightGray = Colors.grey.shade300;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Parqueo',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando detalles del parqueo...',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      parkingDetails['name'] ?? 'Nombre del parqueo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  _buildListTile(
                    title: 'Detalles del parqueo',
                    icon: Icons.directions_car,
                    textColor: textColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ParkingDetailsScreen(
                            parkingId: widget.parkingId,
                          ),
                        ),
                      );
                    },
                  ),
                  Divider(color: lightGray),
                  _buildListTile(
                    title: 'Precios',
                    icon: Icons.attach_money,
                    textColor: textColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ParkingPricesScreen(
                            parkingId: widget.parkingId,
                          ),
                        ),
                      );
                    },
                  ),
                  Divider(color: lightGray),
                  _buildListTile(
                    title: 'Gestionar plazas de parqueo',
                    icon: Icons.directions_car,
                    textColor: textColor,
                    onTap: () {
                      // Lógica para gestionar plazas de parqueo
                    },
                  ),
                  Divider(color: lightGray),
                  _buildListTile(
                    title: 'Ver historial de reservas',
                    icon: Icons.history,
                    textColor: textColor,
                    onTap: () {
                      // Lógica para ver historial de reservas
                    },
                  ),
                  Divider(color: lightGray),
                  _buildSubtitle('Configuración', textColor),
                  _buildListTile(
                    title: 'Horarios de atención',
                    icon: Icons.access_time,
                    textColor: textColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OpeningHoursScreen(
                            parkingId: int.parse(widget.parkingId),
                          ),
                        ),
                      );
                    },
                  ),

                  Divider(color: lightGray),
                  _buildListTile(
                    title: 'Cerrar sesión',
                    icon: Icons.exit_to_app,
                    textColor: Colors.red,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSubtitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      onTap: onTap,
    );
  }
}
