import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map_flutter/screens_owners/navigation_bar_owner.dart';

class VehicleEntryPage extends StatefulWidget {
  final String parkingId;

  const VehicleEntryPage({Key? key, required this.parkingId}) : super(key: key);

  @override
  State<VehicleEntryPage> createState() => _VehicleEntryPageState();
}

class _VehicleEntryPageState extends State<VehicleEntryPage> {
  late Color myColor;
  late Size mediaSize;
  TextEditingController brandController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController plateController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

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
        Text("Registro de Vehículo",
            style: TextStyle(
                color: myColor, fontSize: 32, fontWeight: FontWeight.w500)),
        const SizedBox(height: 20),
        _buildGreyText("Marca"),
        _buildInputField(brandController),
        const SizedBox(height: 20),
        _buildGreyText("Modelo"),
        _buildInputField(modelController),
        const SizedBox(height: 20),
        _buildGreyText("Placa del Vehículo"),
        _buildInputField(plateController),
        const SizedBox(height: 20),
        _buildGreyText("Teléfono"),
        _buildPhoneInputField(phoneController),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCancelButton(),
            _buildRegisterButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildGreyText(String text) {
    return Text(text, style: const TextStyle(color: Colors.grey));
  }

  Widget _buildInputField(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(border: OutlineInputBorder()),
    );
  }

  Widget _buildPhoneInputField(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(border: OutlineInputBorder()),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      maxLength: 8,
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: mediaSize.width * 0.4,
      child: ElevatedButton(
        onPressed: () {
          // Lógica para registrar el vehículo
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF1b4ee4),
          shape: const StadiumBorder(),
          elevation: 20,
          shadowColor: myColor,
          minimumSize: const Size.fromHeight(60),
        ),
        child: const Text("Registrar", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: mediaSize.width * 0.4,
      child: OutlinedButton(
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) =>
                      MainScreen(parkingId: widget.parkingId)),
              (Route<dynamic> route) => false);
        },
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          side: BorderSide(color: myColor),
          minimumSize: const Size.fromHeight(60),
        ),
        child: const Text("Cancelar", style: TextStyle(color: Colors.black)),
      ),
    );
  }
}
