import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:provider/provider.dart';
import 'package:map_flutter/common/widgets/notifications_alerts/error_message_dialog.dart';
import 'package:map_flutter/common/widgets/notifications_alerts/confirmation_dialog.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = Provider.of<TokenProvider>(context, listen: false).userId;
    final url = Uri.parse('https://estacionatbackend.onrender.com/api/v2/user/users/$userId/');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Token ${Provider.of<TokenProvider>(context, listen: false).token}',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        setState(() {
          _usernameController.text = userData['username'];
          _lastNameController.text = userData['last_name'];
          _emailController.text = userData['email'];
          _phoneController.text = userData['phone'];
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error loading user data: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorMessageDialog(
            title: 'Error',
            message: 'Hubo un error al cargar los datos del usuario.',
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Mi Perfil"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField(_usernameController, "Nombre de Usuario",
                        Icons.person, _usernameFocusNode,
                        enabled: _isEditing),
                    const SizedBox(height: 20),
                    _buildInputField(_lastNameController, "Apellido", Icons.person,
                        _lastNameFocusNode,
                        enabled: _isEditing),
                    const SizedBox(height: 20),
                    _buildInputField(_emailController, "Correo Electrónico",
                        Icons.email, _emailFocusNode,
                        enabled: _isEditing),
                    const SizedBox(height: 20),
                    _buildInputField(_phoneController, "Número de Teléfono",
                        Icons.phone, _phoneFocusNode,
                        enabled: _isEditing),
                    const SizedBox(height: 40),
                    Center(
                      child: Column(
                        children: [
                          _isEditing ? _buildSaveButton() : _buildEditButton(),
                          if (_isEditing) _buildCancelButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCancelButton() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _isEditing = false;
              _loadUserData(); // Cargar de nuevo los datos originales al cancelar
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String labelText,
      IconData icon, FocusNode focusNode,
      {bool enabled = true}) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
      ),
      enabled: enabled,
    );
  }

  Widget _buildEditButton() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _isEditing = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4285f4),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: Icon(Icons.edit, color: Colors.white),
          label: Text(
            'Editar Perfil',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: ElevatedButton.icon(
          onPressed: () {
            _updateProfile(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4285f4),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
      ),
    );
  }

  void _updateProfile(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final userId = Provider.of<TokenProvider>(context, listen: false).userId;
    final url = Uri.parse('https://estacionatbackend.onrender.com/api/v2/user/users/$userId/');

    final requestBody = {
      'username': _usernameController.text,
      'last_name': _lastNameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
    };

    final response = await http.put(
      url,
      headers: <String, String>{
        'Authorization': 'Token ${Provider.of<TokenProvider>(context, listen: false).token}',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      setState(() {
        _isEditing = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConfirmationDialog(
            title: 'Éxito',
            message: 'Datos actualizados exitosamente.',
            onConfirm: () {
              Navigator.of(context).pop();
            },
          );
        },
      );
    } else {
      print('Error en la solicitud: ${response.statusCode}');
      print('Mensaje de error: ${response.body}');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorMessageDialog(
            title: 'Error',
            message: 'Hubo un error al actualizar los datos del usuario.',
          );
        },
      );
    }
  }
}
