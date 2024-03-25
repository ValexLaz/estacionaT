import 'package:flutter/material.dart';
import 'package:map_flutter/screens_gerentes/navigation_bar_owner.dart';
import 'package:map_flutter/screens_users/map_screen.dart';

class SignUpParkingPage extends StatefulWidget {
  const SignUpParkingPage({Key? key}) : super(key: key);

  @override
  State<SignUpParkingPage> createState() => _SignUpParkingPageState();
}

class _SignUpParkingPageState extends State<SignUpParkingPage> {
  late Color myColor;
  late Size mediaSize;
  TextEditingController parkingNameController = TextEditingController();
  TextEditingController ownerPhoneController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String? selectedRate; // Variable para la tarifa seleccionada
  List<String> rates = [
    '5 BS',
    '10 BS',
    '15 BS',
    '20 BS'
  ]; // Opciones de tarifa
  TextEditingController locationController = TextEditingController();
  TimeOfDay openingTime = TimeOfDay(hour: 8, minute: 0);
  TimeOfDay closingTime = TimeOfDay(hour: 20, minute: 0);

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
          "Registro de Parqueo",
          style: TextStyle(
            color: myColor,
            fontSize: 32,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        _buildGreyText("Nombre del Parqueo"),
        _buildInputField(parkingNameController, icon: Icons.local_parking),
        const SizedBox(height: 20),
        _buildGreyText("Número de Teléfono del Propietario"),
        _buildInputField(ownerPhoneController, icon: Icons.phone),
        const SizedBox(height: 20),
        _buildGreyText("Descripción"),
        _buildInputField(descriptionController, icon: Icons.description),
        const SizedBox(height: 20),
        _buildGreyText("Tarifa"),
        _buildRateDropdown(),
        const SizedBox(height: 20),
        _buildGreyText("Ubicación"),
        _buildLocationInputField(locationController),
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

  Widget _buildLocationInputField(TextEditingController controller) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => MapScreen()),
        );
      },
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: const InputDecoration(
          hintText: "Seleccionar ubicación",
          prefixIcon: Icon(Icons.map),
        ),
      ),
    );
  }

  Widget _buildRateDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedRate,
      hint: const Text("Seleccionar Tarifa"),
      icon: const Icon(Icons.arrow_drop_down),
      onChanged: (String? newValue) {
        setState(() {
          selectedRate = newValue!;
        });
      },
      items: rates.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
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
      onPressed: () {
        // Aquí iría la lógica para registrar el parqueo
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => MainScreen()),
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
