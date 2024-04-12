import 'package:flutter/material.dart';
import 'package:map_flutter/services/api_parking.dart';

class VehicleRegistrationPage extends StatefulWidget {
  const VehicleRegistrationPage({Key? key}) : super(key: key);

  @override
  _VehicleRegistrationPageState createState() =>
      _VehicleRegistrationPageState();
}

class _VehicleRegistrationPageState extends State<VehicleRegistrationPage> {
  late Color myColor =
      const Color(0xFF1b4ee4); // Azul usado anteriormente como color de fondo
  late Size mediaSize;
  final ApiVehicle apiVehicle = ApiVehicle();
  TextEditingController brandController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController plateController = TextEditingController();

  FocusNode brandFocusNode = FocusNode();
  FocusNode modelFocusNode = FocusNode();
  FocusNode plateFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Registrar vehículo', style: TextStyle(color: Colors.white)),
        backgroundColor: myColor,
      ),
      backgroundColor: Colors.white, // Color de fondo blanco
      body: SingleChildScrollView(
        // Eliminé Stack y Positioned para simplificar el layout
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: _buildVehicleRegistrationForm(),
        ),
      ),
    );
  }

  Widget _buildVehicleRegistrationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      style: ElevatedButton.styleFrom(
        backgroundColor: myColor, // Color azul para el botón
      ),
      onPressed: () async {
        Map<String, dynamic> vehicleData = {
          "brand": brandController.text,
          "model": modelController.text,
          "registration_plate": plateController.text,
          "user": 2,
          "type_vehicle": 1
        };

        try {
          await apiVehicle.createRecord(vehicleData);
          Navigator.pop(context);
        } catch (e) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error de Registro'),
                content: Text('Error al registrar el vehículo: $e'),
                actions: [
                  TextButton(
                    child: Text('Cerrar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          print("Error al registrar el vehículo: $e");
        }
      },
      child: Text(
        "Registrar vehículo",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
