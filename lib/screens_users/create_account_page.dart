import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late Color myColor;
  late Size mediaSize;
  TextEditingController nameController = TextEditingController();
  TextEditingController last_nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  FocusNode nameFocusNode = FocusNode();
  FocusNode last_nameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Crear cuenta"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white, 
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildGreyText("Nombre (este también será tu nombre de usuario)"),
          _buildInputField(nameController, icon: Icons.person),
          const SizedBox(height: 20),
          _buildGreyText("Apellido"),
          _buildInputField(last_nameController, icon: Icons.person),
          const SizedBox(height: 20),
          _buildGreyText("Correo Electrónico"),
          _buildInputField(emailController, icon: Icons.email),
          const SizedBox(height: 20),
          _buildGreyText("Número Telefónico"),
          _buildInputField(phoneController, icon: Icons.phone),
          const SizedBox(height: 20),
          _buildGreyText("Contraseña"),
          _buildPasswordInputField(passwordController, passwordFocusNode, obscurePassword),
          const SizedBox(height: 20),
          _buildGreyText("Confirmar Contraseña"),
          _buildPasswordInputField(confirmPasswordController, confirmPasswordFocusNode, obscureConfirmPassword),
          const SizedBox(height: 40),
          _buildSignUpButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGreyText(String text) {
    return Text(text, style: const TextStyle(color: Colors.grey));
  }

  Widget _buildInputField(TextEditingController controller, {IconData? icon}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
    );
  }

  Widget _buildPasswordInputField(TextEditingController controller, FocusNode focusNode, bool obscureText) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() {
            if (focusNode == passwordFocusNode) {
              obscurePassword = !obscurePassword;
            } else if (focusNode == confirmPasswordFocusNode) {
              obscureConfirmPassword = !obscureConfirmPassword;
            }
          }),
        ),
      ),
    );
  }

  bool isPasswordValid(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  Widget _buildSignUpButton() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () async {
          // Datos de registro
          String username = nameController.text.trim();
          String last_name = last_nameController.text.trim();
          String email = emailController.text.trim();
          String password = passwordController.text.trim();
          String confirmPassword = confirmPasswordController.text.trim();
          String phone = phoneController.text.trim();

          if (!isPasswordValid(password)) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Contraseña inválida'),
                  content: Text('La contraseña debe tener al menos 8 caracteres y estar compuesta por números y letras.'),
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
            return;
          }

          if (password != confirmPassword) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Error de contraseña'),
                  content: Text('Las contraseñas no coinciden.'),
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
            return;
          }

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Creando cuenta'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Por favor espera...'),
                  ],
                ),
              );
            },
          );

          // Crear el cuerpo de la solicitud
          Map<String, String> requestBody = {
            'username': username,
            'last_name': last_name,
            'email': email,
            'password': password,
            'phone': phone,
          };

          // Realizar la solicitud HTTP
          final response = await http.post(
            Uri.parse('https://estacionatbackend.onrender.com/api/v2/user/signup/'),
            body: jsonEncode(requestBody),
            headers: {
              'Content-Type': 'application/json',
            },
          );
          Navigator.of(context).pop(); // Cerrar el loader

          // Verificar el código de respuesta
          if (response.statusCode == 201) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Registro exitoso'),
                  content: Text('Gracias por registrarte en estacionaT, ahora puedes iniciar sesión.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text('Cerrar'),
                    ),
                  ],
                );
              },
            );
          } else {
            // Si la solicitud falla, puedes mostrar
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Error de registro'),
                  content: Text('Hubo un error al registrar el usuario. Por favor, inténtalo de nuevo más tarde.'),
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
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4285f4),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 100),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Registrar',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildParkingRegistrationButton() {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => SignUpPage()),
        );
      },
      child: Center(
        child: Text(
          "Registrar mi parqueo",
          style: TextStyle(
            color: myColor,
            fontSize: 18,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

