import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:map_flutter/services/firebase/firebase_api.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_account_page.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.location.request();
    await Permission.notification.request();
  }

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).colorScheme.primary;
    mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF4285F3),
      body: SafeArea(
        child: Column(
          children: [
            _buildTop(),
            const SizedBox(height: 20), // Espacio entre la imagen y el card
            _buildBottom(),
          ],
        ),
      ),
    );
  }

  Widget _buildTop() {
    return Container(
      margin: EdgeInsets.only(top: 1),
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
    return Expanded(
      child: Container(
        width: mediaSize.width,
        child: Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
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
        _buildRememberMe(),
        const SizedBox(height: 20),
        _buildLoginButton(),
        const SizedBox(height: 20),
        Center(child: _buildSignUpText()), // Centrar el texto
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

  Widget _buildRememberMe() {
    return Row(
      children: [
        Checkbox(
          value: rememberUser,
          onChanged: (value) {
            setState(() {
              rememberUser = value!;
            });
          },
        ),
        _buildGreyText("Mantener inicio de sesión"),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _attemptLogin,
      child: _isLoading
          ? CircularProgressIndicator(color: Colors.white)
          : Text("Iniciar Sesión",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18)), // Aumenta el tamaño de la fuente a 18
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        shape: StadiumBorder(),
        elevation: 0, // Sin sombra
        minimumSize: Size.fromHeight(55),
      ),
    );
  }

  Future<void> _attemptLogin() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
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

        if (rememberUser) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', authToken);
        }

        Provider.of<TokenProvider>(context, listen: false)
          ..token = authToken
          ..userId = userId
          ..username = username;

        FirebaseApi firebaseApi = FirebaseApi();
        firebaseApi.initNotifications(userId.toString());
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
        'Se produjo un error al procesar su solicitud. Por favor, inténtelo de nuevo más tarde.';
    
    if (response.statusCode == 400) {
      message = 'Usuario o contraseña incorrectos.';
    } else if (responseData.containsKey('detail')) {
      message = responseData['detail'];
    } else if (responseData.containsKey('error')) {
      message = responseData['error'];
    } else if (response.statusCode == 401) {
      message = 'No autorizado. Verifique sus credenciales.';
    } else if (response.statusCode == 500) {
      message = 'Error interno del servidor. Por favor, inténtelo más tarde.';
    } else if (response.statusCode == 404) {
      message = 'Servicio no encontrado. Por favor, inténtelo más tarde.';
    }

    _showDialog('Error de inicio de sesión', message);
  }

  Widget _buildSignUpText() {
    return RichText(
      textAlign: TextAlign.center, // Centrar el texto
      text: TextSpan(
        text: '¿Aún no tienes una cuenta? ',
        style: TextStyle(color: Colors.black, fontSize: 14), // Tamaño de texto más pequeño
        children: [
          TextSpan(
            text: 'Crea una aquí',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline, // Subrayar el texto
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
          ),
        ],
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
