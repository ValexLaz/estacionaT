import 'package:flutter/material.dart';

class VehicleRegistrationPage extends StatefulWidget {
  const VehicleRegistrationPage({Key? key}) : super(key: key);

  @override
  _VehicleRegistrationPageState createState() =>
      _VehicleRegistrationPageState();
}

class _VehicleRegistrationPageState extends State<VehicleRegistrationPage> {
  late Color myColor;
  late Size mediaSize;

  TextEditingController brandController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController plateController = TextEditingController();

  FocusNode brandFocusNode = FocusNode();
  FocusNode modelFocusNode = FocusNode();
  FocusNode plateFocusNode = FocusNode();

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
            child: _buildVehicleRegistrationForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleRegistrationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Registrar vehículo",
          style: TextStyle(
            color: myColor,
            fontSize: 32,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        _buildGreyText("Marca del vehículo"),
        _buildInputField(brandController,
            icon: Icons.directions_car, focusNode: brandFocusNode),
        const SizedBox(height: 20),
        _buildGreyText("Modelo"),
        _buildInputField(modelController,
            icon: Icons.car_rental, focusNode: modelFocusNode),
        const SizedBox(height: 20),
        _buildGreyText("Placa"),
        _buildInputField(plateController,
            icon: Icons.confirmation_number, focusNode: plateFocusNode),
        const SizedBox(height: 40),
        _buildRegisterVehicleButton(),
        const SizedBox(height: 20),
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

  Widget _buildRegisterVehicleButton() {
    return ElevatedButton(
      onPressed: () {
        // Lógica de registro de vehículo
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF1b4ee4),
        shape: StadiumBorder(),
        elevation: 20,
        minimumSize: Size.fromHeight(60),
      ),
      child: Text(
        "Registrar vehículo",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
