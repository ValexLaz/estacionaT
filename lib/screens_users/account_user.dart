import 'package:flutter/material.dart';
import 'package:map_flutter/screens_users/edit_profile_screen.dart';
import 'package:map_flutter/screens_users/list_parking.dart';
import 'package:map_flutter/screens_users/list_vehicle.dart';
import 'package:map_flutter/screens_users/login_screen.dart';
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:provider/provider.dart';

class CuentaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.black;
    Color lightGray = Colors.grey.shade300; // Color gris claro

    // Obtener el nombre de usuario del TokenProvider utilizando Provider.of
    final username = Provider.of<TokenProvider>(context).username;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Cuenta', style: TextStyle(color: textColor)),
        iconTheme: IconThemeData(color: textColor),
        automaticallyImplyLeading: false, // Quitar la flecha de atrás
      ),
      body: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 20,
              child: Icon(Icons.person, size: 20, color: Colors.blue),
              backgroundColor: lightGray, // Fondo gris claro para el icono
            ),
            title: Text(
              username!,
              style: TextStyle(
                fontSize: 20,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildListTile(
                  title: 'Editar datos personales',
                  icon: Icons.edit,
                  textColor: textColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfileScreen()),
                    );
                  },
                ),
                Divider(color: lightGray),
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
                  title: 'Mis Vehículos',
                  icon: Icons.directions_car,
                  textColor: textColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ListVehicle()),
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
                      MaterialPageRoute(builder: (context) => ListParkings()),
                    );
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
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
