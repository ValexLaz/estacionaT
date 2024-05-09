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
  TextEditingController priceController = TextEditingController(
      text: 'Option 1'); // Establece un valor predeterminado
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF1b4ee4),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottom(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottom() {
    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Scrollbar(
          thumbVisibility: true,
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
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
        const SizedBox(height: 20),
        _buildGreyText("Precio"),
        _buildPriceDropdownField(),
        const SizedBox(height: 20),
        _buildGreyText("Hora de inicio"),
        _buildStartTimeField(),
        const SizedBox(height: 20),
        _buildGreyText("Hora de fin"),
        _buildEndTimeField(),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCancelButton(),
            _buildRegisterButton(),
          ],
        ),
        const SizedBox(
            height:
                40), // Agregar espacio al final para que el botón no quede oculto al desplazar
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

  Widget _buildPriceDropdownField() {
    return DropdownButtonFormField<String>(
      value: priceController.text,
      onChanged: (newValue) {
        setState(() {
          priceController.text = newValue!;
        });
      },
      items: <String>['Option 1', 'Option 2', 'Option 3', 'Option 4']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildStartTimeField() {
    return GestureDetector(
      onTap: () {
        _selectStartTime(context);
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(startTime != null
            ? startTime!.format(context)
            : 'Seleccionar hora de inicio'),
      ),
    );
  }

  Widget _buildEndTimeField() {
    return GestureDetector(
      onTap: () {
        _selectEndTime(context);
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(endTime != null
            ? endTime!.format(context)
            : 'Seleccionar hora de fin'),
      ),
    );
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        startTime = selectedTime;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        endTime = selectedTime;
      });
    }
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
