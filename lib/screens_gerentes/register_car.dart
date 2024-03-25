import 'package:flutter/material.dart';

class SignUpCarPage extends StatefulWidget {
  const SignUpCarPage({Key? key}) : super(key: key);

  @override
  State<SignUpCarPage> createState() => _SignUpCarPageState();
}

class _SignUpCarPageState extends State<SignUpCarPage> {
  late Color myColor;
  late Size mediaSize;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController vehiclePlateController = TextEditingController();
  TimeOfDay entryTime = TimeOfDay(hour: 8, minute: 0);
  TimeOfDay exitTime = TimeOfDay(hour: 20, minute: 0);
  List<String> rates = ['10', '20', '30', '40']; // Example rates
  String selectedRate = '10';
  List<String> vehicleTypes = [
    'Automóvil',
    'Cuadratrack',
    'Motocicleta',
    'Bicicleta'
  ];
  String selectedVehicleType = 'Automóvil';

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
          "Registro de Autos",
          style: TextStyle(
            color: myColor,
            fontSize: 32,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        _buildGreyText("Nombre Completo"),
        _buildInputField(fullNameController),
        const SizedBox(height: 20),
        _buildGreyText("Número de Teléfono"),
        _buildInputField(phoneNumberController),
        const SizedBox(height: 20),
        _buildGreyText("Placa del Vehículo"),
        _buildInputField(vehiclePlateController),
        const SizedBox(height: 20),
        _buildTimePicker("Hora de Entrada", entryTime, (newTime) {
          setState(() => entryTime = newTime);
        }),
        const SizedBox(height: 20),
        _buildTimePicker("Hora de Salida", exitTime, (newTime) {
          setState(() => exitTime = newTime);
        }),
        const SizedBox(height: 20),
        _buildDropdown("Tarifa", rates, selectedRate, (newValue) {
          setState(() => selectedRate = newValue);
        }),
        const SizedBox(height: 20),
        _buildDropdown("Tipo de Vehículo", vehicleTypes, selectedVehicleType,
            (newValue) {
          setState(() => selectedVehicleType = newValue);
        }),
        const SizedBox(height: 40),
        _buildConfirmButton(),
      ],
    );
  }

  Widget _buildGreyText(String text) {
    return Text(text, style: const TextStyle(color: Colors.grey));
  }

  Widget _buildInputField(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
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

  Widget _buildDropdown(String label, List<String> items, String selectedItem,
      ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        DropdownButton<String>(
          value: selectedItem,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            onChanged(newValue!);
          },
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: () {
        // Aquí iría la lógica para registrar el auto
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF1b4ee4),
        shape: const StadiumBorder(),
        elevation: 20,
        shadowColor: myColor,
        minimumSize: const Size.fromHeight(60),
      ),
      child: const Text(
        "Confirmar Registro",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SignUpCarPage(),
  ));
}
