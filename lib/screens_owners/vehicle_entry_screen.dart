import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:map_flutter/models/Price.dart';
import 'package:map_flutter/models/TypeVehicle.dart';
import 'package:map_flutter/screens_owners/navigation_bar_owner.dart';
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:map_flutter/services/api_parking.dart';
import 'package:map_flutter/services/api_price.dart';
import 'package:map_flutter/services/api_typeVehicle.dart';
import 'package:provider/provider.dart';

class VehicleEntryPage extends StatefulWidget {
  final String parkingId;

  const VehicleEntryPage({Key? key, required this.parkingId}) : super(key: key);

  @override
  State<VehicleEntryPage> createState() => _VehicleEntryPageState();
}

class _VehicleEntryPageState extends State<VehicleEntryPage> {
  late Color myColor;
  late Size mediaSize;
  final ApiVehicle apiVehicle = ApiVehicle();
  TextEditingController brandController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController plateController = TextEditingController();
  TextEditingController _typeVehicleIDCtrl = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  late ScrollController _scrollController;
  TypeVehicle? _selectedTypeVehicle;
  List<TypeVehicle> _typeVehicles = [];
  Price? _selectedPrice;
  List<Price> _typePrices = [];
  String? _selectedCountryCode = '+591';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fetchTypeVehicles();
    _fetchPrices();
  }

  Future<void> _fetchTypeVehicles() async {
    try {
      final typeVehicleApiService = TypeVehicleApiService();
      final typeVehicles = await typeVehicleApiService.getAllVehicleRecords();
      setState(() {
        _typeVehicles = typeVehicles;
      });
    } catch (e) {}
  }

  Future<void> _fetchPrices() async {
    try {
      final priceApiService = TypePriceService();
      final prices =
          await priceApiService.getAllPriceRecords(int.parse(widget.parkingId));
      setState(() {
        _typePrices = prices;
      });
      print('Precios obtenidos correctamente: $_typePrices');
    } catch (e) {
      print('Error al obtener precios: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('El parkingId es: ${widget.parkingId}');

    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: _buildForm(),
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
        _buildGreyText("Tipo de Vehículo"),
        _buildTypeVehicleDropdown(),
        const SizedBox(height: 20),
        _buildGreyText("Teléfono"),
        _buildPhoneInputField(phoneController),
        const SizedBox(height: 20),
        _buildGreyText("Precio"),
        _buildPriceDropdown(),
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
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: myColor),
        ),
      ),
    );
  }

  Widget _buildPhoneInputField(TextEditingController controller) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<String>(
            value: _selectedCountryCode,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: myColor),
              ),
            ),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCountryCode = newValue;
              });
            },
            items: [
              DropdownMenuItem(
                value: '+591',
                child: Text('Bolivia (+591)'),
              ),
              DropdownMenuItem(
                value: '+54',
                child: Text('Argentina (+54)'),
              ),
              DropdownMenuItem(
                value: '+55',
                child: Text('Brasil (+55)'),
              ),
              DropdownMenuItem(
                value: '+56',
                child: Text('Chile (+56)'),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: myColor),
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            maxLength: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeVehicleDropdown() {
    return DropdownButtonFormField<TypeVehicle>(
      value: _selectedTypeVehicle,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.directions_car, color: myColor),
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
    );
  }

  Widget _buildPriceDropdown() {
    return DropdownButtonFormField<Price>(
      value: _selectedPrice,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.attach_money, color: myColor),
      ),
      onChanged: (Price? value) {
        setState(() {
          _selectedPrice = value;
        });
        _priceController.text = value?.id.toString() ?? '';
      },
      validator: (value) {
        if (value == null) {
          return 'Por favor, selecciona un precio';
        }
        return null;
      },
      items: [
        DropdownMenuItem(
          value: null,
          child: Text('Selecciona el precio'),
        ),
        ..._typePrices.map((Price price) {
          return DropdownMenuItem<Price>(
            value: price,
            child: Text(price.price.toString()),
          );
        }).toList(),
      ],
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
        onPressed: () async {
          if (brandController.text.isEmpty ||
              modelController.text.isEmpty ||
              plateController.text.isEmpty ||
              _typeVehicleIDCtrl.text.isEmpty ||
              phoneController.text.isEmpty ||
              startTime == null ||
              endTime == null) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Error'),
                  content: Text('Por favor, llene todas las casillas.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Aceptar'),
                    ),
                  ],
                );
              },
            );
          } else {
            final tokenProvider =
                Provider.of<TokenProvider>(context, listen: false);
            final userId = tokenProvider.userId;
            final vehicleData = {
              "vehicle_data": {
                "brand": brandController.text,
                "model": modelController.text,
                "registration_plate": plateController.text,
                "type_vehicle": int.parse(_typeVehicleIDCtrl.text),
                "user": userId,
                "is_userexternal": false
              },
              "vehicle_entry_data": {
                "phone": phoneController.text
                    .replaceAll(' ', ''), // Eliminar espacios
                "parking": int.parse(widget.parkingId),
                "is_reserva": false,
                "is_userexternal": true
              },
              "details_data": [
                {
                  "starttime": startTime != null
                      ? "${DateTime.now().toString().split(' ')[0]} ${startTime!.hour}:${startTime!.minute}:00"
                      : '',
                  "endtime": endTime != null
                      ? "${DateTime.now().toString().split(' ')[0]} ${endTime!.hour}:${endTime!.minute}:00"
                      : '',
                  "totalamount": 50.0,
                  "price": 4
                }
              ]
            };

            final url = Uri.parse(
                'https://estacionatbackend.onrender.com/api/v2/parking/DetailsCustom/save_details');

            try {
              final response = await http.post(
                url,
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                },
                body: jsonEncode(vehicleData),
              );

              if (response.statusCode == 201) {
                print(response.body);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Registro exitoso'),
                      content: Text('Los datos se han guardado exitosamente.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Aceptar'),
                        ),
                      ],
                    );
                  },
                );
              } else {
                print(
                    'Error al guardar los datos. Código de estado: ${response.statusCode}');
                print(response.body);
              }
            } catch (e) {
              print('Error al realizar la solicitud HTTP: $e');
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: myColor,
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
