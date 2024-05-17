import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:map_flutter/common/managers/ParkingManager.dart';
import 'package:map_flutter/common/managers/ReservationManager.dart';
import 'package:map_flutter/common/widgets/time_picker.dart';
import 'package:map_flutter/models/Payment.dart';
import 'package:map_flutter/models/Price.dart';
import 'package:map_flutter/models/Reservation.dart';
import 'package:map_flutter/models/ReservationVehicleEntry.dart';
import 'package:map_flutter/models/VehicleEntry.dart';
import 'package:map_flutter/screens_users/navigation_bar_screen.dart';
import 'package:map_flutter/screens_users/parkingDetails/parking_details.dart';
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:map_flutter/services/api_reservationVehicleEntry.dart';
import 'package:map_flutter/services/api_reservations.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
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

  final _totalAmountController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate:
          DateTime.now(), // Solo fechas desde mañana
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

  void _submitForm() {
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
      );
      ReservationManager().setReservation(newReservation);

      makePayment(totalAmount).then((payment) {
        if (payment != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: Text('Payment'),
                        leading: IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () async {
                              final response = await http.get(
                                Uri.parse(
                                    'https://api-sbx.dlocalgo.com/v1/payments/${payment.id}'),
                                headers: {
                                  'Authorization':
                                      'Bearer RtJZkjQOcgoaXEJaJsRsSjtmPVSSsmmL:4NVVLk2gf4g5KJZHgT0Fvt7olF7iKnmoqZdjgMXT',
                                },
                              );

                              if (response.statusCode == 200) {
                                var data = jsonDecode(response.body);
                                if (data['status'] == 'PAID') {
                                  //ApiReservation().create(newReservation);

                                  ApiReservationVehicleEntry().create(
                                      ReservationVehicleEntry(
                                          reservationData: newReservation,
                                          vehicleEntryData: VehicleEntry(
                                              user: Provider.of<TokenProvider>(
                                                      context,
                                                      listen: false)
                                                  .userId!,
                                              vehicle: 2,
                                              parking: ParkingManager
                                                  .instance.parking!.id!,
                                             )));

                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              NavigationBarScreen()));
                                } else {
                                  Navigator.pop(context);
                                }
                              } else {
                                print('Failed to check payment status');
                              }
                            }),
                      ),
                      body: WebView(
                        initialUrl: payment.redirectUrl,
                        javascriptMode: JavascriptMode.unrestricted,
                      ),
                    )),
          );
        }
      });
    }
  }

  Future<Payment?> makePayment(double totalAmount) async {
    double totalARG = double.parse((totalAmount * 128.33).toStringAsFixed(2));
    final response = await http.post(
      Uri.parse('https://api-sbx.dlocalgo.com/v1/payments'),
      headers: {
        'authorization':
            'Bearer RtJZkjQOcgoaXEJaJsRsSjtmPVSSsmmL:4NVVLk2gf4g5KJZHgT0Fvt7olF7iKnmoqZdjgMXT',
        'content-type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'amount': totalARG,
        'currency': 'ARS',
        'country': 'AR',
      }),
    );
    if (response.statusCode == 200) {
      return Payment.fromJson(jsonDecode(response.body));
    } else {
      print(totalAmount);
      print(totalARG);
      print(jsonDecode(response.body));
      print('Failed to load payment');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              CustomTimePicker(
                startTime: TimeOfDay(hour: 8, minute: 0),
                endTime: TimeOfDay(hour: 22, minute: 0),
                onTimeSelected: (time) =>
                    setState(() => selectedStartTime = time),
              ),
              CustomTimePicker(
                startTime: TimeOfDay(hour: 8, minute: 0),
                endTime: TimeOfDay(hour: 22, minute: 0),
                onTimeSelected: (time) =>
                    setState(() => selectedEndTime = time),
              ),
              ListTile(
                title: Text('Fecha de reservación: ${selectedDate.toLocal()}'
                    .split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: () {
                  _selectDate(context);
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Registrar Reservación'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
