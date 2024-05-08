import 'package:flutter/material.dart';
import 'package:map_flutter/models/TypeVehicle.dart';
import 'package:map_flutter/services/api_parking.dart';
import 'package:provider/provider.dart';
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:map_flutter/services/api_typeVehicle.dart';

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
  TextEditingController _typeVehicleIDCtrl = TextEditingController();
  TypeVehicle? _selectedTypeVehicle;
  List<TypeVehicle> _typeVehicles = [];
  FocusNode brandFocusNode = FocusNode();
  FocusNode modelFocusNode = FocusNode();
  FocusNode plateFocusNode = FocusNode();

  @override
  initState() {
    super.initState();
    _fetchTypeVehicles();
  }

  Future<void> _fetchTypeVehicles() async {
    try {
      final typeVehicleApiService = TypeVehicleApiService();
      final typeVehicles = await typeVehicleApiService.getAllVehicleRecords();
      setState(() {
        _typeVehicles = typeVehicles;
      });
    } catch (e) {
    }
  }


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
        const SizedBox(height: 20),
        _buildGreyText("Tipo de vehículo"), // Añadido
        DropdownButtonFormField<TypeVehicle>(
          value: _selectedTypeVehicle,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.directions_car),
          ),
          onChanged: (TypeVehicle? value) {
            setState(() {
              _selectedTypeVehicle = value;
            });
            _typeVehicleIDCtrl.text = value?.id.toString() ?? '';
          },
          validator: (value) {
            if (value == null) {
              return 'Por favor, selecciona un tipo de vehículo';
            }
            return null;
          },
          items: [
            DropdownMenuItem(
              value: null,
              child: Text('Selecciona un tipo de vehículo'),
            ),
            ..._typeVehicles.map((TypeVehicle typeVehicle) {
              return DropdownMenuItem<TypeVehicle>(
                value: typeVehicle,
                child: Text(typeVehicle.name),
              );
            }).toList(),
          ],
        ), // Añadido
        const SizedBox(height: 40),
        _buildRegisterVehicleButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  bool _validateInputs() {
    if (brandController.text.isEmpty ||
        modelController.text.isEmpty ||
        plateController.text.isEmpty) {
      _showSnackBar('Por favor complete todos los campos antes de continuar.');
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
        backgroundColor: myColor,
      ),
      onPressed: () async {
        if (_validateInputs()) {
          final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
          final userId = tokenProvider.userId;
          Map<String, dynamic> vehicleData = {
            "brand": brandController.text,
            "model": modelController.text,
            "registration_plate": plateController.text,
            "user": userId,
            "type_vehicle": _selectedTypeVehicle?.id, 
            "is_userexternal": false,
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
        }
      },
      child: Text(
        "Registrar vehículo",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
