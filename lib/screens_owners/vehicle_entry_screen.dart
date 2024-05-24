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
import 'package:map_flutter/services/car_api.dart';
import 'package:provider/provider.dart';

class VehicleEntryPage extends StatefulWidget {
  final String parkingId;

  const VehicleEntryPage({Key? key, required this.parkingId}) : super(key: key);

  @override
  State<VehicleEntryPage> createState() => _VehicleEntryPageState();
}

class _VehicleEntryPageState extends State<VehicleEntryPage> {
  late Color primaryColor = const Color(0xFF1b4ee4);
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
    } catch (e) {
      _showSnackBar('Error al cargar los tipos de vehículos');
    }
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

    mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar vehículo', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false, // Remove the back button
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: _buildVehicleEntryForm(),
        ),
      ),
    );
  }

  Widget _buildVehicleEntryForm() {
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
        _buildTypeVehicleDropdown(),
        const SizedBox(height: 20),
        _buildGreyText("Teléfono"),
        _buildPhoneInputField(phoneController),
        const SizedBox(height: 20),
        _buildGreyText("Precio"),
        _buildPriceDropdown(),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTimePicker("Hora de inicio", startTime, (newTime) {
              setState(() => startTime = newTime);
            }),
            _buildTimePicker("Hora de fin", endTime, (newTime) {
              setState(() => endTime = newTime);
            }),
          ],
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRegisterButton(),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildGreyText(String text) {
    return Text(text, style: const TextStyle(color: Colors.grey));
  }

  Widget _buildTimePicker(
      String label, TimeOfDay? time, ValueChanged<TimeOfDay> onTimeChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: time ?? TimeOfDay.now(),
              initialEntryMode: TimePickerEntryMode.input,
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    timePickerTheme: TimePickerThemeData(
                      dialHandColor: primaryColor,
                      entryModeIconColor: primaryColor,
                      dayPeriodTextColor: MaterialStateColor.resolveWith(
                          (states) => states.contains(MaterialState.selected)
                              ? Colors.white
                              : primaryColor),
                      dayPeriodColor: MaterialStateColor.resolveWith((states) =>
                          states.contains(MaterialState.selected)
                              ? primaryColor
                              : Colors.white),
                      dayPeriodShape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        side: BorderSide(color: Colors.blue),
                      ),
                      hourMinuteTextColor: MaterialStateColor.resolveWith(
                          (states) => states.contains(MaterialState.selected)
                              ? Colors.white
                              : primaryColor),
                      hourMinuteShape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        side: BorderSide(color: Colors.blue),
                      ),
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue),
                      ),
                    ),
                  ),
                  child: MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(alwaysUse24HourFormat: false),
                    child: child ?? Container(),
                  ),
                );
              },
            );
            if (picked != null && picked != time) {
              onTimeChanged(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time != null
                      ? "${time.hourOfPeriod.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}"
                      : 'Seleccionar',
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
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

  Widget _buildInputField(String label, TextEditingController controller,
      {bool isPlate = false}) {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          if (isPlate)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Image.asset(
                'assets/Icons/placa3.png',
                width: 40,
                height: 40,
              ),
            ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInputField(TextEditingController controller) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(Icons.phone, color: primaryColor, size: 30),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Número de teléfono',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor),
              ),
            ),
            keyboardType: TextInputType.phone,
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
        prefixIcon: Icon(Icons.directions_car, color: primaryColor),
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
      hint: Text('Selecciona un tipo de vehículo'),
    );
  }

  Widget _buildPriceDropdown() {
    return DropdownButtonFormField<Price>(
      value: _selectedPrice,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.attach_money, color: primaryColor),
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
      items: _typePrices.map((Price price) {
        return DropdownMenuItem<Price>(
          value: price,
          child: Text(price.price.toString()),
        );
      }).toList(),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: mediaSize.width * 0.8,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
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
                            // Update ParkingScreen
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MainScreen(parkingId: widget.parkingId),
                              ),
                            );
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Registrar",
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

  String capitalizeFirstLetter(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
}
