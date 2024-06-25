import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';
import 'package:map_flutter/common/widgets/notifications_alerts/error_message_dialog.dart';
import 'package:map_flutter/common/widgets/notifications_alerts/confirmation_dialog.dart';

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
          _buildInputField(emailController, icon: Icons.email, inputType: TextInputType.emailAddress),
          const SizedBox(height: 20),
          _buildGreyText("Número Telefónico"),
          _buildInputField(phoneController, icon: Icons.phone, inputType: TextInputType.number, maxLength: 8),
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

  Widget _buildInputField(TextEditingController controller, {IconData? icon, TextInputType inputType = TextInputType.text, int? maxLength}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      maxLength: maxLength,
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon) : null,
        counterText: '', // Hide the character counter
      ),
    );
  }

  Widget _buildPasswordInputField(TextEditingController controller, FocusNode focusNode, bool obscureText) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: TextInputType.visiblePassword,
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

  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool isPhoneNumberValid(String phone) {
    return phone.length == 8 && phone.startsWith(RegExp(r'^[267]'));
  }

  bool isPasswordValid(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorMessageDialog(
          title: title,
          message: message,
        );
      },
    );
  }

  void _showConfirmationDialog(String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: title,
          message: message,
          onConfirm: onConfirm,
        );
      },
    );
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

          // Validación de campos vacíos
          if (username.isEmpty || last_name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || phone.isEmpty) {
            _showErrorDialog('Campos Vacíos', 'Por favor, llena todos los campos.');
            return;
          }

          // Validación de correo electrónico
          if (!isEmailValid(email)) {
            _showErrorDialog('Correo Electrónico Inválido', 'Por favor, introduce un correo electrónico válido.');
            return;
          }

          // Validación de número telefónico
          if (!isPhoneNumberValid(phone)) {
            _showErrorDialog('Número Telefónico Inválido', 'El número telefónico debe tener 8 dígitos y comenzar con 2, 6 o 7.');
            return;
          }

          // Validación de contraseña
          if (!isPasswordValid(password)) {
            _showErrorDialog('Contraseña Inválida', 'La contraseña debe tener al menos 8 caracteres y estar compuesta por números y letras.');
            return;
          }

          // Validación de confirmación de contraseña
          if (password != confirmPassword) {
            _showErrorDialog('Error de Contraseña', 'Las contraseñas no coinciden.');
            return;
          }

          // Mostrar mensaje de registro exitoso y redirigir a la pantalla de inicio de sesión
          _showConfirmationDialog(
            'Registro exitoso',
            'Gracias por registrarte en estacionaT, ahora puedes iniciar sesión.',
            () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
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

          try {
            // Realizar la solicitud HTTP
            final response = await http.post(
              Uri.parse('https://estacionatbackend.onrender.com/api/v2/user/signup/'),
              body: jsonEncode(requestBody),
              headers: {
                'Content-Type': 'application/json',
              },
            );

            print('Status Code: ${response.statusCode}');
            print('Response Body: ${response.body}');

            // Ya no se muestra ningún error ni se maneja la respuesta del servidor
          } catch (e) {
            print('Error: $e');
            // Ya no se muestra ningún error
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
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
