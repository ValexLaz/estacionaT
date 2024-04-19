import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map_flutter/common/managers/ParkingManager.dart';
import 'package:map_flutter/common/widgets/AlertSnackBar.dart';
import 'package:map_flutter/common/widgets/input_form.dart';
import 'package:map_flutter/common/widgets/multipleInput_form.dart';
import 'package:map_flutter/models/Parking.dart';
import 'package:map_flutter/models/Price.dart';
import 'package:map_flutter/models/TypeVehicle.dart';
import 'package:map_flutter/services/api_price.dart';
import 'package:map_flutter/services/api_typeVehicle.dart';

class PriceFormScreen extends StatefulWidget {
  @override
  _PriceFormScreenState createState() => _PriceFormScreenState();
}

class _PriceFormScreenState extends State<PriceFormScreen> {
  TextEditingController _priceController = TextEditingController();
  TextEditingController _isPricePerHourCtrl = TextEditingController();
  TextEditingController _isPriceReservationCtrl = TextEditingController();
  TextEditingController _isPriceParkingCtrl = TextEditingController();
  TextEditingController _typeVehicleIDCtrl = TextEditingController();
  TextEditingController _restriccionesHorariasCtrl = TextEditingController();
  TextEditingController _totalHoursCtrl = TextEditingController();
  late Size mediaSize;
  late Color primaryColor;
  TimeOfDay openingTime = TimeOfDay(hour: 8, minute: 0);
  TimeOfDay closeTime = TimeOfDay(hour: 12, minute: 0);
  ValueNotifier<bool> showHourlyFields = ValueNotifier(false);
  ValueNotifier<bool> showTimeRestrictions = ValueNotifier(false);

  TypeVehicle? _selectedTypeVehicle;
  List<TypeVehicle> _typeVehicles = [];
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
      // Manejar el error según sea necesario
    }
  }

  @override
  Widget build(BuildContext context) {
    primaryColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          Positioned.fill(top: 80, child: _buildBottom()),
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
          "Agregar un nuevo paquete",
          style: TextStyle(
            color: primaryColor,
            fontSize: 32,
            fontWeight: FontWeight.w500,
          ),
        ),
        InputForm(
          name: "Precio",
          inputWidget: TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.payments),
            ),
          ),
        ),
        InputForm(
            name: "Categoria",
            inputWidget: FormField<bool>(
              builder: (FormFieldState<bool> state) {
                return Column(
                  children: <Widget>[
                    CheckboxListTile(
                      title: const Text('Precio de reserva'),
                      value: _isPriceReservationCtrl.text == 'true',
                      onChanged: (bool? newValue) {
                        if (newValue != null) {
                          _isPriceReservationCtrl.text = newValue.toString();
                          state.didChange(newValue);
                        }
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Precio de estacionamiento'),
                      value: _isPriceParkingCtrl.text == 'true',
                      onChanged: (bool? newValue) {
                        if (newValue != null) {
                          _isPriceParkingCtrl.text = newValue.toString();
                          state.didChange(newValue);
                        }
                      },
                    ),
                  ],
                );
              },
            )),
        InputForm(
          name: "Tipo de vehiculo",
          inputWidget: DropdownButtonFormField<TypeVehicle>(
            value: _selectedTypeVehicle,
            decoration:
                const InputDecoration(prefixIcon: Icon(Icons.directions_car)),
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
              const DropdownMenuItem(
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
          ),
        ),
        InputForm(
          name: "Tipo de precio",
          inputWidget: InputMultipleOptions(
            options: const ['Por hora', 'Por dia'],
            controller: _isPricePerHourCtrl,
            icon: Icons.list,
            onChanged: (value) {
              setState(() {
                showHourlyFields.value = (value == 'Por hora');
              });
            },
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: showHourlyFields,
          builder: (context, value, child) {
            return value ? _hourlyPriceFields() : const SizedBox.shrink();
          },
        ),
        const SizedBox(height: 40),
        _buttonCreatePrice(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _hourlyPriceFields() {
    return Column(
      children: [
        InputForm(
          name: "Restricciones horarios",
          inputWidget: InputMultipleOptions(
            options: const ['Horas fijas', 'Horario'],
            controller: _restriccionesHorariasCtrl,
            icon: Icons.list,
            onChanged: (value) {
              setState(() {
                showTimeRestrictions.value = (value == 'Horas fijas');
              });
            },
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: showTimeRestrictions,
          builder: (context, value, child) {
            return value
                ? InputForm(
                    name: "Horas",
                    inputWidget: TextFormField(
                      controller: _totalHoursCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.schedule),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      InputForm(
                          name: "Hora",
                          inputWidget: _buildTimePicker("Inicio", openingTime,
                              (newTime) {
                            setState(() => openingTime = newTime);
                          })),
                      InputForm(
                          name: "Hora",
                          inputWidget:
                              _buildTimePicker("Fin", closeTime, (newTime) {
                            setState(() => closeTime = newTime);
                          }))
                    ],
                  );
          },
        ),
      ],
    );
  }

  Widget _buttonCreatePrice() {
    return ElevatedButton(
      onPressed: () async {
        try {
          Parking? parking = ParkingManager.instance.getParking();
          Price price = Price(
              price: double.parse(_priceController.text.trim()),
              parkingId: parking!.id!);
          price.isEntryFee = _isPriceParkingCtrl.text.trim() == "true";
          price.isReservation = _isPriceReservationCtrl.text.trim() == "true";
          price.typeVehicleID = int.parse(_typeVehicleIDCtrl.text.trim());

          if (showHourlyFields.value) {
            price.isPriceHour = showHourlyFields.value;
            if (showTimeRestrictions.value) {
              price.priceHour =
                  PriceHour(totalTime: int.parse(_totalHoursCtrl.text));
            } else {
              int openingMinutes = openingTime.hour * 60 + openingTime.minute;
              int closeMinutes = closeTime.hour * 60 + closeTime.minute;
              int totalMinutes = closeMinutes - openingMinutes;
              price.priceHour = PriceHour(
                  startTime: openingTime,
                  endTime: closeTime,
                  totalTime: totalMinutes);
            }
          }
          await ApiPrice().create(price);
          ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '¡Precio Guardado Exitosamente!',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(right: 16.0),
                ),
          );
        } on Exception catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '¡Precio No Guardado!',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(right: 16.0),
                ),
          );
          print(e.toString());
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF1b4ee4),
        shape: StadiumBorder(),
        elevation: 20,
        minimumSize: Size.fromHeight(60),
      ),
      child: Text(
        "Registrar",
        style: TextStyle(color: Colors.white),
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
          style: TextStyle(color: Colors.blue, fontSize: 16),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _isPricePerHourCtrl.dispose();
    _isPriceReservationCtrl.dispose();
    _isPriceParkingCtrl.dispose();
    _typeVehicleIDCtrl.dispose();
    _restriccionesHorariasCtrl.dispose();
    _totalHoursCtrl.dispose();
    super.dispose();
  }
}
