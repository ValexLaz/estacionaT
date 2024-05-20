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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detalles del Parqueo',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
            Divider(color: Colors.grey),
          ],
        ),
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
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                    ),
                    child: parkingDetails['urlImage'] != null &&
                            parkingDetails['urlImage'].isNotEmpty
                        ? Image.network(
                            parkingDetails['urlImage'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/Logotipo.png',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/Logotipo.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                _buildUserTile(
                  username: parkingDetails['name'] ?? 'Parking Name',
                  textColor: textColor,
                  lightGray: lightGray,
                  onTap: () {},
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _buildSubtitle('Información', textColor),
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
                        title: 'Registrar Precios',
                        icon: Icons.attach_money,
                        textColor: textColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PriceFormScreen(),
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
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
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

  Widget _buildUserTile({
    required String username,
    required Color textColor,
    required Color lightGray,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        child: Icon(Icons.person, size: 20, color: Colors.blue),
        backgroundColor: lightGray,
      ),
      title: Text(
        username,
        style: TextStyle(
          fontSize: 20,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
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
