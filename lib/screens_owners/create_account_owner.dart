import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:map_flutter/screens_owners/navigation_bar_owner.dart';
>>>>>>> 70248c4d57e7c2a6a0be2dde6eb3e0bf3d6d89be
import 'package:map_flutter/screens_owners/select_map_screen.dart';
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:map_flutter/services/api_parking.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD
// Asegúrate de importar la pantalla SelectMapScreen si no lo has hecho
=======
 // Asegúrate de importar la pantalla SelectMapScreen si no lo has hecho
>>>>>>> 70248c4d57e7c2a6a0be2dde6eb3e0bf3d6d89be

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
              const SizedBox(height: 20),
              _buildGreyText("Nombre del Parqueo"),
              _buildInputField(parkingNameController),
              const SizedBox(height: 20),
              _buildGreyText("Capacidad Total de Vehículos"),
              _buildInputField(capacityController),
              const SizedBox(height: 20),
              _buildGreyText("Número de Teléfono del Propietario"),
              _buildInputField(ownerPhoneController),
              const SizedBox(height: 20),
              _buildGreyText("Correo Electrónico"),
              _buildInputField(emailController),
              const SizedBox(height: 20),
              _buildGreyText("Espacios Disponibles"),
              _buildInputField(spacesAvailableController),
              const SizedBox(height: 20),
              _buildGreyText("URL de la Imagen"),
              _buildInputField(imageUrlController),
              const SizedBox(height: 20),
              _buildGreyText("Descripción"),
              _buildInputField(descriptionController),
              const SizedBox(height: 20),
              _buildTimePicker("Apertura", openingTime, (newTime) {
                setState(() => openingTime = newTime);
              }),
              const SizedBox(height: 20),
              _buildTimePicker("Cierre", closingTime, (newTime) {
                setState(() => closingTime = newTime);
              }),
              const SizedBox(height: 40),
              _buildSignUpButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreyText(String text) {
    return Text(text, style: const TextStyle(color: Colors.grey));
  }

  Widget _buildInputField(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(),
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
      onPressed: () async {
<<<<<<< HEAD
        final tokenProvider =
            Provider.of<TokenProvider>(context, listen: false);
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
          final parkingId = await apiParking.createRecord(
              parkingData); // Asumiendo que createRecord devuelve el ID del parqueo
          final currentContext = context; // Almacena el contexto aquí
          final parsedParkingId =
              int.parse(parkingId); // Convierte parkingId a int
          Navigator.push(
            currentContext,
            MaterialPageRoute(
              builder: (context) => SelectMapScreen(parkingId: parsedParkingId),
            ),
          );
        } catch (e) {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              // Cambia 'context' a 'dialogContext' aquí
              return AlertDialog(
                title: Text('Error de Registro'),
                content: Text('Error al registrar el parqueo: $e'),
                actions: [
                  TextButton(
                    child: Text('Cerrar'),
                    onPressed: () {
                      Navigator.pop(dialogContext); // Usa 'dialogContext' aquí
                    },
                  ),
                ],
              );
            },
          );
          print("Error al registrar el parqueo: $e");
        }
=======
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
    final parkingId = await apiParking.createRecord(parkingData); // Asumiendo que createRecord devuelve el ID del parqueo
    final currentContext = context; // Almacena el contexto aquí
    final parsedParkingId = int.parse(parkingId); // Convierte parkingId a int
    Navigator.push(
      currentContext,
      MaterialPageRoute(
        builder: (context) => SelectMapScreen(parkingId: parsedParkingId),
      ),
    );
  } catch (e) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // Cambia 'context' a 'dialogContext' aquí
        return AlertDialog(
          title: Text('Error de Registro'),
          content: Text('Error al registrar el parqueo: $e'),
          actions: [
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.pop(dialogContext); // Usa 'dialogContext' aquí
              },
            ),
          ],
        );
>>>>>>> 70248c4d57e7c2a6a0be2dde6eb3e0bf3d6d89be
      },
    );
    print("Error al registrar el parqueo: $e");
  }
},

      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF1b4ee4),
        shape: StadiumBorder(),
        elevation: 20,
        minimumSize: Size.fromHeight(60),
      ),
      child: const Text(
        "Registrar Parqueo",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SignUpParkingPage(),
  ));
}
