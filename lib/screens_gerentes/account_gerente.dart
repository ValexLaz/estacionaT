import 'package:flutter/material.dart';

class ParkingOwnerScreen extends StatefulWidget {
  @override
  _ParkingOwnerScreenState createState() => _ParkingOwnerScreenState();
}

class _ParkingOwnerScreenState extends State<ParkingOwnerScreen> {
  bool _notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Color(0xFF1b4ee4);
    Color backgroundColor = Color(0xFFe6e7f8);
    Color textColor = Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cuenta del Dueño',
          style: TextStyle(color: textColor),
        ),
        backgroundColor: primaryColor,
      ),
      body: Container(
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              child: Icon(Icons.local_parking, size: 60, color: textColor),
              backgroundColor: primaryColor,
            ),
            SizedBox(height: 10),
            Text(
              'Dueño del Parqueo',
              style: TextStyle(fontSize: 20, color: textColor, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
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
            ListTile(
              title: Text(
                'Notificaciones',
                style: TextStyle(color: textColor),
              ),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  // Lógica para cambiar el estado de las notificaciones
                },
                activeColor: primaryColor,
              ),
            ),
            _buildListTile(
              title: 'Cerrar sesión',
              icon: Icons.exit_to_app,
              textColor: textColor,
              onTap: () {
                // Lógica para cerrar sesión
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({required String title, required IconData icon, required Color textColor, required Function onTap}) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      trailing: Icon(icon, color: textColor),
      onTap: () => onTap(),
    );
  }
}
