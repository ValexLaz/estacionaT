import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF1b4ee4),
      body: Stack(
        children: [
          Positioned(top: 80, child: _buildTop()),
          Positioned(bottom: 0, child: _buildBottom()),
        ],
      ),
    );
  }

  Widget _buildTop() {
    return Container(
      width: mediaSize.width,
      height: 200, // Ajusta la altura según necesites
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Logotipo.png'),
          fit: BoxFit
              .contain, // Esto hará que la imagen cubra todo el contenedor
        ),
      ),
    );
  }

  Widget _buildBottom() {
    return SizedBox(
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
          child: _buildForm(),
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
      onPressed: () async {
        // Datos de inicio de sesión
        String username = emailController.text.trim();
        String password = passwordController.text.trim();

        // Crear el cuerpo de la solicitud
        Map<String, String> requestBody = {
          'username': username,
          'password': password,
        };

        // Realizar la solicitud HTTP
        final response = await http.post(
          Uri.parse(
              'https://estacionatbackend.onrender.com/api/v2/user/login/'),
          body: jsonEncode(requestBody),
          headers: {
            'Content-Type': 'application/json',
          },
        );
        print(response.body);
        // Verificar el código de respuesta
        if (response.statusCode == 200) {
          // Éxito en la solicitud, puedes procesar la respuesta aquí
          final responseData = jsonDecode(response.body);
          // Guardar el token de autenticación para futuras solicitudes
          final authToken = responseData['token'];
          // Navegar a la pantalla asignada después del inicio de sesión exitoso
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => NavigationBarScreen()),
          );
        } else {
          // Si la solicitud falla, puedes mostrar un mensaje de error
          if (response.headers['content-type']?.contains('application/json') ??
              false) {
            final errorMessage = jsonDecode(response.body)['error'];
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Error de inicio de sesión'),
                  content: Text(errorMessage),
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
          } else {
            // Si la respuesta no es JSON válido, muestra un mensaje genérico de error
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Error de inicio de sesión'),
                  content: Text(
                      'Se produjo un error al procesar su solicitud. Por favor, inténtalo de nuevo más tarde.'),
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
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF1b4ee4),
        shape: StadiumBorder(),
        elevation: 20,
        minimumSize: Size.fromHeight(60),
      ),
      child: Text(
        "Iniciar Sesión",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return ElevatedButton(
      onPressed: () {
        // Navegar a CreateAccountPage
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

void main() {
  runApp(MaterialApp(
    home: LoginPage(),
  ));
}
