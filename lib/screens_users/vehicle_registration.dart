import 'package:flutter/material.dart';
import 'package:map_flutter/models/TypeVehicle.dart';
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:map_flutter/services/api_parking.dart';
import 'package:map_flutter/services/api_typeVehicle.dart';
import 'package:map_flutter/services/car_api.dart';
import 'package:provider/provider.dart';
import 'package:map_flutter/common/widgets/notifications_alerts/error_message_dialog.dart';
import 'package:map_flutter/common/widgets/notifications_alerts/confirmation_dialog.dart';
import 'package:map_flutter/screens_users/list_vehicle.dart';

class VehicleRegistrationPage extends StatefulWidget {
  const VehicleRegistrationPage({Key? key}) : super(key: key);

  @override
  _VehicleRegistrationPageState createState() =>
      _VehicleRegistrationPageState();
}

class _VehicleRegistrationPageState extends State<VehicleRegistrationPage> {
  late Color myColor = const Color(0xFF4285f4);
  late Size mediaSize;
  final ApiVehicle apiVehicle = ApiVehicle();
  TextEditingController brandController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController plateController = TextEditingController();
  TypeVehicle? _selectedTypeVehicle;
  List<TypeVehicle> _typeVehicles = [];
  FocusNode brandFocusNode = FocusNode();
  FocusNode modelFocusNode = FocusNode();
  FocusNode plateFocusNode = FocusNode();
  List<Car> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
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
      _showErrorDialog('Error al cargar los tipos de vehículos: $e');
    }
  }

  void _searchCars() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cars =
          await CarApi.fetchCars(brandController.text, modelController.text);
      setState(() {
        _searchResults = cars;
      });
    } catch (e) {
      _showErrorDialog('Error al buscar vehículos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar vehículo', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
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
        _buildAutoCompleteField(
          "Marca del vehículo",
          brandController,
          (query) => CarApi.fetchCarMakes(query),
        ),
        const SizedBox(height: 20),
        _buildAutoCompleteField(
          "Modelo",
          modelController,
          (query) => CarApi.fetchCarModels(brandController.text, query),
        ),
        const SizedBox(height: 20),
        _buildInputField("Placa", plateController, isPlate: true),
        const SizedBox(height: 20),
        DropdownButtonFormField<TypeVehicle>(
          value: _selectedTypeVehicle,
          decoration: InputDecoration(
            labelText: 'Selecciona un tipo de vehículo',
            border: OutlineInputBorder(),
          ),
          onChanged: (TypeVehicle? value) {
            setState(() {
              _selectedTypeVehicle = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Por favor, selecciona un tipo de vehículo';
            }
            return null;
          },
          items: _typeVehicles.map((TypeVehicle typeVehicle) {
            return DropdownMenuItem<TypeVehicle>(
              value: typeVehicle,
              child: Row(
                children: [
                  _getVehicleIcon(typeVehicle.name),
                  const SizedBox(width: 10),
                  Text(typeVehicle.name),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        _buildRegisterVehicleButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAutoCompleteField(
    String label,
    TextEditingController controller,
    Future<List<String>> Function(String) optionsBuilder,
  ) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return await optionsBuilder(textEditingValue.text);
      },
      onSelected: (String selection) {
        controller.text = capitalizeFirstLetter(selection);
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController fieldTextEditingController,
        FocusNode fieldFocusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return SizedBox(
          height: 50,
          child: TextField(
            controller: fieldTextEditingController,
            focusNode: fieldFocusNode,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
            ),
            onChanged: (text) {
              controller.value = controller.value.copyWith(
                text: capitalizeFirstLetter(text),
                selection: TextSelection.fromPosition(
                  TextPosition(offset: text.length),
                ),
              );
            },
            onEditingComplete: () {
              controller.text = capitalizeFirstLetter(controller.text);
            },
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Text('No se encontraron vehículos.');
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final car = _searchResults[index];
          return ListTile(
            title: Text('${car.make} ${car.model}'),
            subtitle: Text('Año: ${car.year}'),
          );
        },
      );
    }
  }

  Widget _getVehicleIcon(String typeName) {
    switch (typeName.toLowerCase()) {
      case 'sedan':
        return Image.asset(
          'assets/Icons/sedan.png',
          width: 44,
          height: 44,
        );
      case 'camioneta':
        return Image.asset(
          'assets/Icons/camioneta.png',
          width: 44,
          height: 44,
        );
      case 'jeep':
        return Image.asset(
          'assets/Icons/jeep.png',
          width: 44,
          height: 44,
        );
      case 'vagoneta':
        return Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Image.asset(
            'assets/Icons/vagoneta.png',
            width: 24,
            height: 24,
          ),
        );
      case 'moto':
        return Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Icon(
            Icons.motorcycle,
            size: 24,
          ),
        );
      default:
        return Icon(
          Icons.directions_car,
          size: 24,
        );
    }
  }

  String capitalizeFirstLetter(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  bool _validateInputs() {
    brandController.text = capitalizeFirstLetter(brandController.text);
    modelController.text = capitalizeFirstLetter(modelController.text);

    print('Brand: ${brandController.text}');
    print('Model: ${modelController.text}');
    print('Plate: ${plateController.text}');
    print('Selected Type Vehicle: ${_selectedTypeVehicle?.name}');

    if (brandController.text.isEmpty ||
        modelController.text.isEmpty ||
        plateController.text.isEmpty ||
        _selectedTypeVehicle == null) {
      _showErrorDialog('Por favor, complete todos los campos antes de continuar.');
      return false;
    }

    if (!_validatePlate(plateController.text)) {
      _showPlateErrorDialog();
      return false;
    }

    return true;
  }

  bool _validatePlate(String plate) {
    final plateRegExp = RegExp(r'^[0-9]{3}[A-Z]{3,4}$');
    return plateRegExp.hasMatch(plate);
  }

  void _showPlateErrorDialog() {
    _showErrorDialog(
      'Por favor, introduzca un formato de placa correcto. Ejemplo: "321ABCD"',
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorMessageDialog(
          title: 'Error',
          message: message,
        );
      },
    );
  }

 void _showConfirmationDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ConfirmationDialog(
        title: '¡Registro Exitoso!',
        message: 'El vehículo ha sido registrado exitosamente.',
        onConfirm: () {
          Navigator.of(context).pop(); // Volver atrás a la lista de vehículos
        },
      );
    },
  );
}


  Widget _buildInputField(String label, TextEditingController controller,
      {bool isPlate = false}) {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType:
                  isPlate ? TextInputType.visiblePassword : TextInputType.text,
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                controller.value = controller.value.copyWith(
                  text: isPlate ? text.toUpperCase() : capitalizeFirstLetter(text),
                  selection: TextSelection.fromPosition(
                    TextPosition(offset: text.length),
                  ),
                );
              },
              onEditingComplete: () {
                if (isPlate) {
                  controller.text = controller.text.toUpperCase();
                } else {
                  controller.text = capitalizeFirstLetter(controller.text);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterVehicleButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4285f4),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () async {
          if (_validateInputs()) {
            final tokenProvider =
                Provider.of<TokenProvider>(context, listen: false);
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
              _showConfirmationDialog(); // Mostrar confirmación de registro exitoso
            } catch (e) {
              _showErrorDialog('Error al registrar el vehículo: $e');
              print("Error al registrar el vehículo: $e");
            }
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Agregar",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Icon(
              Icons.add,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
