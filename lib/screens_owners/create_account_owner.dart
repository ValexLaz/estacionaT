import 'package:flutter/material.dart';
import 'package:map_flutter/screens_owners/select_map_screen.dart';
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:map_flutter/services/api_parking.dart';
import 'package:provider/provider.dart';

class SignUpParkingPage extends StatefulWidget {
  const SignUpParkingPage({Key? key}) : super(key: key);

  @override
  State<SignUpParkingPage> createState() => _SignUpParkingPageState();
}

class _SignUpParkingPageState extends State<SignUpParkingPage> {
  final ApiParking apiParking = ApiParking();
  late Color myColor;
  late Size mediaSize;
  TextEditingController parkingNameController = TextEditingController();
  TextEditingController capacityController = TextEditingController();
  TextEditingController ownerPhoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController spacesAvailableController = TextEditingController();
  TextEditingController imageUrlController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TimeOfDay openingTime = TimeOfDay(hour: 8, minute: 0);
  TimeOfDay closingTime = TimeOfDay(hour: 20, minute: 0);

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Registro de Parqueo"),
        backgroundColor: Color(0xFF1b4ee4),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField("Nombre del Parqueo", parkingNameController),
              const SizedBox(height: 20),
              _buildInputField(
                  "Capacidad Total de Vehículos", capacityController),
              const SizedBox(height: 20),
              _buildInputField(
                  "Número de Teléfono del Propietario", ownerPhoneController),
              const SizedBox(height: 20),
              _buildInputField("Correo Electrónico", emailController),
              const SizedBox(height: 20),
              _buildInputField(
                  "Espacios Disponibles", spacesAvailableController),
              const SizedBox(height: 20),
              _buildInputField("URL de la Imagen", imageUrlController),
              const SizedBox(height: 20),
              _buildInputField("Descripción", descriptionController),
              const SizedBox(height: 20),
              _buildTimePicker("Apertura", openingTime, (newTime) {
                setState(() => openingTime = newTime);
              }),
              _buildTimePicker("Cierre", closingTime, (newTime) {
                setState(() => closingTime = newTime);
              }),
              const SizedBox(height: 20),
              _buildSignUpButton(),
            ],
          ),
        ),
      ),
    );
  }
bool _validateInputs() {
    // Validación básica para email
    bool emailValid = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailController.text);

    if (parkingNameController.text.isEmpty ||
        capacityController.text.isEmpty ||
        ownerPhoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        !emailValid ||
        spacesAvailableController.text.isEmpty ||
        imageUrlController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      _showSnackBar('Por favor, complete todos los campos correctamente antes de continuar.');
      return false;
    }
    if (int.tryParse(capacityController.text) == null ||
        int.tryParse(spacesAvailableController.text) == null) {
      _showSnackBar('Ingrese un número válido en los campos de capacidad y espacios disponibles.');
      return false;
    }
    return true;
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  Widget _buildGreyText(String text) {
    return Text(text, style: const TextStyle(color: Colors.grey));
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildTimePicker(
      String label, TimeOfDay time, ValueChanged<TimeOfDay> onTimeChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
        IconButton(
          icon: const Icon(Icons.timer),
          onPressed: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: time,
            );
            if (picked != null && picked != time) {
              onTimeChanged(picked);
            }
          },
        ),
        Text(
          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
          style: TextStyle(color: myColor, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: myColor,
        shape: StadiumBorder(),
        elevation: 20,
        minimumSize: Size.fromHeight(60),
      ),
      onPressed: () async {
        if (_validateInputs()) {
          final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
          final userId = tokenProvider.userId;

          Map<String, dynamic> parkingData = {
            "name": parkingNameController.text,
            "capacity": int.tryParse(capacityController.text) ?? 0,
            "phone": ownerPhoneController.text,
            "email": emailController.text,
            "user": userId,
            "spaces_available": int.tryParse(spacesAvailableController.text) ?? 0,
            "url_image": imageUrlController.text,
            "description": descriptionController.text,
            "opening_time": "${openingTime.hour}:${openingTime.minute}",
            "closing_time": "${closingTime.hour}:${closingTime.minute}",
          };

          try {
            final parkingId = await apiParking.createRecord(parkingData);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SelectMapScreen(parkingId: int.parse(parkingId)),
              ),
            );
          } catch (e) {
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: Text('Error de Registro'),
                  content: Text('Error al registrar el parqueo: $e'),
                  actions: [
                    TextButton(
                      child: Text('Cerrar'),
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                    ),
                  ],
                );
              },
            );
            print("Error al registrar el parqueo: $e");
          }
        }
      },
      child: const Text(
        "Registrar Parqueo",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
