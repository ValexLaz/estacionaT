import 'package:flutter/material.dart';
import 'package:map_flutter/screens_gerentes/create_account_gerente.dart';

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
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  FocusNode nameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  String vehicleType = 'Automóvil';

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF1b4ee4),
      body: Stack(
        children: [
          Positioned(bottom: 0, child: _buildBottom()),
        ],
      ),
    );
  }

  Widget _buildTop() {
    return Container(
      width: mediaSize.width,
      height: 200,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Logotipo.png'),
          fit: BoxFit.contain,
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
          "Crear cuenta",
          style: TextStyle(
            color: myColor,
            fontSize: 32,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        _buildGreyText("Nombre completo"),
        _buildInputField(nameController,
            icon: Icons.person, focusNode: nameFocusNode),
        const SizedBox(height: 20),
        _buildGreyText("Correo Electrónico"),
        _buildInputField(emailController,
            icon: Icons.email, focusNode: emailFocusNode),
        const SizedBox(height: 20),
        _buildGreyText("Número Telefónico"),
        _buildInputField(phoneController,
            icon: Icons.phone, focusNode: phoneFocusNode),
        const SizedBox(height: 20),
        _buildGreyText("Tipo de Vehículo"),
        _buildVehicleTypeDropdown(),
        const SizedBox(height: 20),
        _buildGreyText("Contraseña"),
        _buildPasswordInputField(passwordController, passwordFocusNode,
            "Contraseña", obscurePassword),
        const SizedBox(height: 20),
        _buildGreyText("Confirmar contraseña"),
        _buildPasswordInputField(
            confirmPasswordController,
            confirmPasswordFocusNode,
            "Confirmar contraseña",
            obscureConfirmPassword),
        const SizedBox(height: 40),
        _buildSignUpButton(),
        const SizedBox(height: 20),
        _buildParkingRegistrationButton(),
      ],
    );
  }

  Widget _buildGreyText(String text) {
    return Text(text, style: const TextStyle(color: Colors.grey));
  }

  Widget _buildInputField(TextEditingController controller,
      {IconData? icon, FocusNode? focusNode}) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        prefixIcon:
            focusNode!.hasFocus ? null : (icon != null ? Icon(icon) : null),
      ),
    );
  }

  Widget _buildPasswordInputField(TextEditingController controller,
      FocusNode focusNode, String label, bool obscureText) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: focusNode.hasFocus ? null : const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => obscureText = !obscureText),
        ),
      ),
    );
  }

  Widget _buildVehicleTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: vehicleType,
      items: <String>['Automóvil', 'Motocicleta', 'Cuadratrack', 'Bicicleta']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          vehicleType = newValue!;
        });
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.directions_car),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return ElevatedButton(
      onPressed: () {
        // Navegar a CreateAccountPage
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF1b4ee4),
        shape: const StadiumBorder(),
        elevation: 20,
        shadowColor: myColor,
        minimumSize: const Size.fromHeight(60),
      ),
      child: const Text(
        "Registrar",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildParkingRegistrationButton() {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => SignUpParkingPage()),
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

void main() {
  runApp(MaterialApp(
    home: SignUpPage(),
  ));
}
