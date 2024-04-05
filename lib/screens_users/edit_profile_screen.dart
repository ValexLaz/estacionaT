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
      backgroundColor: const Color(0xFF1b4ee4),
      body: Stack(
        children: [
          _buildBackgroundImage(),
          _buildEditProfileCard(),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Logotipo.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildEditProfileCard() {
    return Positioned(
      top: 200, // Ajusta esta posición según sea necesario
      left: 0,
      right: 0,
      bottom: 0,
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Editar perfil de usuario",
                  style: TextStyle(
                    color: myColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputField(_usernameController, 'Nombre de Usuario'),
                const SizedBox(height: 10),
                _buildInputField(_lastNameController, 'Apellido'),
                const SizedBox(height: 10),
                _buildInputField(_emailController, 'Correo Electrónico'),
                const SizedBox(height: 10),
                _buildInputField(_phoneController, 'Número de Teléfono'),
                const SizedBox(height: 20),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _updateProfile(context);
        },
        child: Text('Guardar Cambios'),
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
