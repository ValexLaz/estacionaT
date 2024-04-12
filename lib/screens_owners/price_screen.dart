import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map_flutter/common/widgets/input_form.dart';
import 'package:map_flutter/common/widgets/multipleInput_form.dart';
import 'package:map_flutter/models/TypeVehicle.dart';
import 'package:map_flutter/services/api_typeVehicle.dart';

class PriceFormScreen extends StatefulWidget {
  @override
  _PriceFormScreenState createState() => _PriceFormScreenState();
}

class _PriceFormScreenState extends State<PriceFormScreen> {
  TextEditingController _priceController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _pricePerHourController = TextEditingController();
  TextEditingController _typeVehicleIDController = TextEditingController();
  TextEditingController _isPriceReservation = TextEditingController();
  TextEditingController _isPriceParking = TextEditingController();
  TextEditingController _restriccionesHorarias = TextEditingController();
  late Size mediaSize;
  late Color primaryColor;
  TimeOfDay openingTime = TimeOfDay(hour: 8, minute: 0);
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
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.payments),
            ),
          ),
        ),
        InputForm(
          name: "Descripcion",
          inputWidget: TextFormField(
            keyboardType: TextInputType.text,
            maxLines: 1,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[^\n\r]+')),
            ],
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.text_fields),
            ),
          ),
        ),
        InputForm(
            name: "Reserva",
            inputWidget: FormField<bool>(
              builder: (FormFieldState<bool> state) {
                return Column(
                  children: <Widget>[
                    CheckboxListTile(
                      title: const Text('Precio de reserva'),
                      value: _isPriceReservation.text == 'true',
                      onChanged: (bool? newValue) {
                        if (newValue != null) {
                          _isPriceReservation.text = newValue.toString();
                          state.didChange(newValue);
                        }
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Precio de estacionamiento'),
                      value: _isPriceParking.text == 'true',
                      onChanged: (bool? newValue) {
                        if (newValue != null) {
                          _isPriceParking.text = newValue.toString();
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
              _typeVehicleIDController.text = value?.id.toString() ?? '';
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
            controller: _priceController,
            icon: Icons.list,
            onChanged: (value) {
              setState(() {
                showHourlyFields.value = (value == 'Por hora');
                _priceController.text = value!;
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
            controller: _restriccionesHorarias,
            icon: Icons.list,
            onChanged: (value) {
              setState(() {
                showTimeRestrictions.value = (value == 'Horas fijas');
                _restriccionesHorarias.text = value!;
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
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.schedule),
                      ),
                    ),
                  )
                :               _buildTimePicker("Apertura", openingTime, (newTime) {
                setState(() => openingTime = newTime);
              });
          },
        ),
      ],
    );
  }

  Widget _buttonCreatePrice() {
    return ElevatedButton(
      onPressed: () async {
        // Datos de registro
        String description = _descriptionController.text.trim();
        String typeVehicleID = _typeVehicleIDController.text.trim();
        String price = _priceController.text.trim();
        String pricePerHour = _pricePerHourController.text.trim();
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
    _pricePerHourController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
