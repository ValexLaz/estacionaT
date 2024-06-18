import 'package:flutter/material.dart';
import 'package:map_flutter/screens_users/list_parking.dart';
import 'package:map_flutter/screens_users/list_vehicle.dart';
import 'package:map_flutter/screens_users/login_screen.dart';
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:map_flutter/screens_users/user_profile.dart';
import 'package:provider/provider.dart';

class CuentaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.black;
    Color lightGray = Colors.grey.shade300;

    final username = Provider.of<TokenProvider>(context).username;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cuenta',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
            Divider(color: Colors.grey),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserTile(
            username: username!,
            textColor: textColor,
            lightGray: lightGray,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
          Expanded(
            child: ListView(
              children: [
                _buildSubtitle('Información', textColor),
                _buildListTile(
                  title: 'Mis Vehículos',
                  icon: Icons.directions_car,
                  textColor: textColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      _createRoute(ListVehicle()),
                    );
                  },
                ),
                Divider(color: lightGray),
                _buildListTile(
                  title: 'Mis Parqueos',
                  icon: Icons.local_parking,
                  textColor: textColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      _createRoute(ListParkings()),
                    );
                  },
                ),
                Divider(color: lightGray),
                _buildSubtitle('Configuración', textColor),
                _buildListTile(
                  title: 'Notificaciones',
                  icon: Icons.notifications,
                  textColor: textColor,
                  onTap: () {
                    // Lógica para notificaciones
                  },
                ),
                Divider(color: lightGray),
                _buildListTile(
                  title: 'Soporte y ayuda',
                  icon: Icons.help_outline,
                  textColor: textColor,
                  onTap: () {
                    // Lógica para soporte y ayuda
                  },
                ),
                Divider(color: lightGray),
                _buildListTile(
                  title: 'Cerrar sesión',
                  icon: Icons.exit_to_app,
                  textColor: Colors.red,
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                      (Route<dynamic> route) => false,
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
        backgroundColor: lightGray,
        child: Icon(Icons.person_2, size: 40, color: Colors.white),
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
      trailing: Icon(Icons.arrow_forward_ios, color: textColor, size: 16),
      onTap: onTap,
    );
  }
}
