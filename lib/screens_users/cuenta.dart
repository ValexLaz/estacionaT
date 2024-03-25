import 'package:flutter/material.dart';

class CuentaScreen extends StatefulWidget {
  @override
  _CuentaScreenState createState() => _CuentaScreenState();
}

class _CuentaScreenState extends State<CuentaScreen> {
  bool _darkTheme = false;

  @override
  Widget build(BuildContext context) {
    Color primaryColor =
        Color(0xFF1b4ee4); // Color principal utilizado en LoginPage
    Color backgroundColor = Color(
        0xFFe6e7f8); // Un color de fondo más claro que combine con el azul
    Color textColor =
        Colors.black; // Texto oscuro para contrastar con el fondo claro

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cuenta',
          style: TextStyle(color: textColor),
        ),
        backgroundColor: primaryColor,
      ),
      body: Container(
        color: backgroundColor, // Aplicar un color de fondo claro
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 60, color: textColor),
              backgroundColor: primaryColor,
            ),
            SizedBox(height: 10),
            Text(
              'Nombre Completo',
              style: TextStyle(
                  fontSize: 20, color: textColor, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
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
              title: 'Autos',
              icon: Icons.directions_car,
              textColor: textColor,
              onTap: () {
                // Lógica para autos
              },
            ),
            ListTile(
              title: Text(
                'Dark theme',
                style: TextStyle(color: textColor),
              ),
              trailing: Switch(
                value: _darkTheme,
                onChanged: (value) {
                  setState(() {
                    _darkTheme = value;
                  });
                  // Lógica para cambiar el tema
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

  Widget _buildListTile(
      {required String title,
      required IconData icon,
      required Color textColor,
      required Function onTap}) {
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
