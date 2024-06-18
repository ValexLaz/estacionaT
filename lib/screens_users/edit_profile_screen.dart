import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late Color myColor;
  late Size mediaSize;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  FocusNode _usernameFocusNode = FocusNode();
  FocusNode _lastNameFocusNode = FocusNode();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _phoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = Provider.of<TokenProvider>(context, listen: false).userId;
    final url = Uri.parse(
        'https://estacionatbackend.onrender.com/api/v2/user/users/$userId/');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization':
              'Token ${Provider.of<TokenProvider>(context, listen: false).token}',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        _usernameController.text = userData['username'];
        _lastNameController.text = userData['last_name'];
        _emailController.text = userData['email'];
        _phoneController.text = userData['phone'];
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error loading user data: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Hubo un error al cargar los datos del usuario.'),
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

  @override
  Widget build(BuildContext context) {
    myColor = Colors.blue;
    mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Perfil"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField(_usernameController, "Nombre de Usuario",
                  Icons.person, _usernameFocusNode),
              const SizedBox(height: 20),
              _buildInputField(_lastNameController, "Apellido", Icons.person,
                  _lastNameFocusNode),
              const SizedBox(height: 20),
              _buildInputField(_emailController, "Correo Electrónico",
                  Icons.email, _emailFocusNode),
              const SizedBox(height: 20),
              _buildInputField(_phoneController, "Número de Teléfono",
                  Icons.phone, _phoneFocusNode),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(child: _buildSaveButton()),
                  SizedBox(width: 16),
                  Expanded(child: _buildCancelButton()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String labelText,
      IconData icon, FocusNode focusNode) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () {
          _updateProfile(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4285f4),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 100),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: Icon(Icons.save, color: Colors.white),
        label: Text(
          'Guardar Cambios',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 100),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: Icon(Icons.cancel, color: Colors.white),
        label: Text(
          'Cancelar',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
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
        'Authorization':
            'Token ${Provider.of<TokenProvider>(context, listen: false).token}',
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
