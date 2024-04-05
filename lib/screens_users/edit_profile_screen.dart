import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late Color myColor;
  late Size mediaSize;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Nombre de Usuario'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Apellido'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Número de Teléfono'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _updateProfile(context);
              },
              child: Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateProfile(BuildContext context) async {
    final userId = Provider.of<TokenProvider>(context, listen: false).userId;
    final url = Uri.parse(
        'https://estacionatbackend.onrender.com/api/v2/user/users/$userId/');

    final requestBody = {
      'username': _usernameController.text,
      'last_name': _lastNameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
    };

    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      // Datos actualizados exitosamente
      // Puedes mostrar un mensaje o navegar a otra pantalla si lo deseas
    } else {
      // Manejar errores
      print('Error en la solicitud: ${response.statusCode}');
      print('Mensaje de error: ${response.body}');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Hubo un error al actualizar los datos del usuario.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    }
  }
}
