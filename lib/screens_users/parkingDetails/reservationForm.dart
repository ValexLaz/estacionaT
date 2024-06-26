import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:map_flutter/common/managers/ReservationManager.dart';
import 'package:map_flutter/common/managers/VehicleManager.dart';
import 'package:map_flutter/common/widgets/input_form.dart';
import 'package:map_flutter/common/widgets/time_picker.dart';
import 'package:map_flutter/models/Payment.dart';
import 'package:map_flutter/models/Price.dart';
import 'package:map_flutter/models/Reservation.dart';
import 'package:map_flutter/screens_users/parkingDetails/paymentDetails.dart';
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:map_flutter/services/api_parking.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ReservationFormScreen extends StatefulWidget {
  final Price price;

  const ReservationFormScreen({super.key, required this.price});

  @override
  _ReservationFormScreenState createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime selectedDate =
      DateTime.now().add(Duration(days: 1)); // Inicia desde mañana
  TimeOfDay selectedStartTime =
      TimeOfDay(hour: 8, minute: 0); // Hora de inicio predeterminada
  TimeOfDay selectedEndTime =
      TimeOfDay(hour: 18, minute: 0); // Hora de fin predeterminada
  final ApiVehicle apiVehicle = ApiVehicle();
  final _totalAmountController = TextEditingController();
  Map<String,dynamic>? _selectedTypeVehicle;
    TextEditingController _vehicleIDCtrl = TextEditingController();
  
  List<Map<String, dynamic>> vehicles = [];
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(), // Solo fechas desde mañana
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _totalAmountController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final tokenProvider = Provider.of<TokenProvider>(context, listen: false);
      final userId = tokenProvider.userId;
      double totalAmount;

      if (widget.price.isPriceHour) {
        final int startMinutes =
            selectedStartTime.hour * 60 + selectedStartTime.minute;
        final int endMinutes =
            selectedEndTime.hour * 60 + selectedEndTime.minute;
        final double hours = (endMinutes - startMinutes) / 60;
        totalAmount = widget.price.price * hours;
      } else {
        totalAmount = widget.price.price;
      }

      var newReservation = Reservation(
        startTime: selectedStartTime.format(context),
        endTime: selectedEndTime.format(context),
        totalAmount: totalAmount,
        priceId: widget.price.id!,
        reservationDate:
            '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
        userId: userId,
        state: ReservationState.pending,
      );

      ReservationManager().setReservation(newReservation);
      VehicleManager.instance.setId(int.parse(_vehicleIDCtrl.text.trim()));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentDetails(reservation: newReservation),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    String? authToken =
        Provider.of<TokenProvider>(context, listen: false).token;
    fetchData(authToken);
  }

  Future<void> fetchData(String? token) async {
    try {
      List<Map<String, dynamic>> data =
          await apiVehicle.getAllVehiclesByUserID(token!);
      setState(() {
        vehicles = data;
      });
    } catch (e) {
      print('Error al obtener datos de los vehículos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Reservación'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Text("Hora Inicio"),
              CustomTimePicker(
                startTime: TimeOfDay(hour: 8, minute: 0),
                endTime: TimeOfDay(hour: 22, minute: 0),
                onTimeSelected: (time) =>
                    setState(() => selectedStartTime = time),
              ),
              Divider(color: Colors.grey),
              Text("Hora Final"),
              CustomTimePicker(
                startTime: TimeOfDay(hour: 8, minute: 0),
                endTime: TimeOfDay(hour: 22, minute: 0),
                onTimeSelected: (time) =>
                    setState(() => selectedEndTime = time),
              ),
              Divider(color: Colors.grey),
              ListTile(
                title: Text('Fecha de reservación: ${selectedDate.toLocal()}'
                    .split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: () {
                  _selectDate(context);
                },
              ),
              SizedBox(height: 20),
              InputForm(
                name: "Mi vehiculo",
                inputWidget: DropdownButtonFormField<Map<String,dynamic>>(
                  value: _selectedTypeVehicle,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.directions_car)),
                  onChanged: (Map<String,dynamic>? value) {
                    setState(() {
                      _selectedTypeVehicle = value;
                    });
                    _vehicleIDCtrl.text = value?["id"].toString() ?? '';
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecciona un vehículo';
                    }
                    return null;
                  },
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Selecciona un vehículo'),
                    ),
                    ...vehicles.map((Map<String,dynamic> vehicle) {
                      return DropdownMenuItem<Map<String,dynamic>>(
                        value: vehicle,
                        child: Text(vehicle["model"]),
                      );
                    }).toList(),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: screenWidth *
                    0.8, // Adjust the width according to the screen size
                margin: EdgeInsets.symmetric(
                    vertical: 16, horizontal: screenWidth * 0.1),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4285f4),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Registrar Reservación',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
