import 'package:flutter/material.dart';
import 'package:map_flutter/screens_gerentes/create_account_gerente.dart';
import 'package:map_flutter/screens_users/list_parking.dart';
import 'package:map_flutter/screens_users/list_vehicle.dart';
import 'package:map_flutter/screens_users/login_screen.dart';
import 'package:map_flutter/screens_users/vehicle_registration.dart';

class CuentaScreen extends StatefulWidget {
  @override
  _CuentaScreenState createState() => _CuentaScreenState();
}

class _CuentaScreenState extends State<CuentaScreen> {
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
                        child:
                            Icon(Icons.person, size: 60, color: primaryColor),
                        backgroundColor: Colors.white,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Nombre Completo',
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
                            title: 'Editar datos personales',
                            icon: Icons.edit,
                            textColor: textColor,
                            onTap: () {
                              // Lógica para editar datos personales
                            },
                          ),
                          _buildListTile(
                            title: 'Notificaciones',
                            icon: Icons.notifications,
                            textColor: textColor,
                            onTap: () {
                              // Lógica para notificaciones
                            },
                          ),
                          _buildListTile(
                            title: 'Mis Vehiculos',
                            icon: Icons.directions_car,
                            textColor: textColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                       ListVehicle()),
                              );
                            },
                          ),
                          _buildListTile(
                            title: 'Mis Parqueos',
                            icon: Icons.local_parking,
                            textColor: textColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ListParkings()),
                              );
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
