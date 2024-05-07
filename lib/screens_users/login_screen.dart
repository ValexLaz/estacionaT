import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:map_flutter/models/MobileToken.dart';
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:map_flutter/services/api_mobileToken.dart';
import 'package:map_flutter/services/firebase/firebase_api.dart';
import 'package:provider/provider.dart';

import 'create_account_page.dart';
import 'forgot_password_screen.dart';
import 'navigation_bar_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late Color myColor;
  late Size mediaSize;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  bool rememberUser = false;
  bool obscurePassword = true;
  bool _isLoading =
      false; // Estado para controlar la visualización del indicador de carga

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF1b4ee4),
      body: Column(
        children: [
          _buildTop(),
          Expanded(child: _buildBottom()),
        ],
      ),
    );
  }

  Widget _buildTop() {
    return Container(
      width: mediaSize.width,
      height: mediaSize.height / 5,
      child: Center(
        child: AspectRatio(
          aspectRatio: 4 / 2,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Logotipo.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottom() {
    return Container(
      width: mediaSize.width,
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
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Bienvenido",
          style: TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.w500,
          ),
        ),
        _buildGreyText("Por favor inicia sesión con tus datos personales"),
        const SizedBox(height: 40),
        _buildGreyText("Nombre de usuario"),
        _buildInputField(emailController),
        const SizedBox(height: 40),
        _buildGreyText("Contraseña"),
        _buildPasswordInputField(),
        const SizedBox(height: 20),
        _buildRememberForgot(),
        const SizedBox(height: 20),
        _buildLoginButton(),
        const SizedBox(height: 20),
        _buildSignUpButton(),
      ],
    );
  }

  Widget _buildGreyText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.grey),
    );
  }

  Widget _buildInputField(TextEditingController controller, {IconData? icon}) {
    return TextField(
      controller: controller,
      focusNode: emailFocusNode,
      decoration: InputDecoration(
        prefixIcon:
            emailFocusNode.hasFocus ? null : (icon != null ? Icon(icon) : null),
      ),
    );
  }

  Widget _buildPasswordInputField() {
    return TextField(
      controller: passwordController,
      focusNode: passwordFocusNode,
      obscureText: obscurePassword,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              obscurePassword = !obscurePassword;
            });
          },
        ),
      ),
    );
  }

  Widget _buildRememberForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: rememberUser,
              onChanged: (value) {
                setState(() {
                  rememberUser = value!;
                });
              },
            ),
            _buildGreyText("Recuérdame"),
          ],
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
            );
          },
          child: _buildGreyText("Olvidé mi contraseña"),
        )
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _attemptLogin,
      child: _isLoading
          ? CircularProgressIndicator(color: Colors.white)
          : Text("Iniciar Sesión", style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF1b4ee4),
        shape: StadiumBorder(),
        elevation: 20,
        minimumSize: Size.fromHeight(60),
      ),
    );
  }

  Future<void> _attemptLogin() async {
  if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
    _showDialog('Error', 'Por favor, rellene todos los campos.');
    return;
  }

  setState(() {
    _isLoading = true;
  });

  String username = emailController.text.trim();
  String password = passwordController.text.trim();
  Map<String, String> requestBody = {
    'username': username,
    'password': password,
  };

  try {
    final response = await http.post(
      Uri.parse('https://estacionatbackend.onrender.com/api/v2/user/login/'),
      body: jsonEncode(requestBody),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final authToken = responseData['token'];
      final userId = responseData['user']['id'];

      if (!mounted) return;

      Provider.of<TokenProvider>(context, listen: false)
        ..token = authToken
        ..userId = userId
        ..username = username;
      FirebaseApi().initNotifications(userId);
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => NavigationBarScreen()),
          );
        }
      });
    } else {
      _handleErrorResponse(response);
    }
  } catch (e) {
    _showDialog('Error de conexión', 'No se pudo conectar al servidor.');
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}



  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _handleErrorResponse(http.Response response) {
    var responseData = jsonDecode(response.body);
    var message =
        'Se produjo un error al procesar su solicitud. Por favor, inténtalo de nuevo más tarde.';
    if (responseData.containsKey('detail')) {
      message = responseData['detail'];
    } else if (responseData.containsKey('error')) {
      message = responseData['error'];
    }

    _showDialog('Error de inicio de sesión', message);
  }

  Widget _buildSignUpButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const SignUpPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF1b4ee4),
        shape: StadiumBorder(),
        elevation: 20,
        minimumSize: Size.fromHeight(60),
      ),
      child: Text(
        "Crear cuenta",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }
}
