import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:map_flutter/models/Parking.dart';
import 'package:map_flutter/models/Reservation.dart';
import 'package:map_flutter/models/VehicleEntry.dart';
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:map_flutter/services/api_parking.dart';
import 'package:map_flutter/services/api_reservations.dart';
import 'package:map_flutter/services/api_vehicleEntry.dart';
import 'package:provider/provider.dart';

class ReservaScreen extends StatefulWidget {
  @override
  _ReservaScreenState createState() => _ReservaScreenState();
}

class _ReservaScreenState extends State<ReservaScreen> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref().child("parkingtime");
  late DatabaseReference reservationRef;
  Map<String, dynamic> reservationData = {};
  Timer? _timer;
  Duration _duration = Duration(hours: 2);
  double _progress = 1.0;
  Color textColor = Colors.black;
  Color lightGray = Colors.grey.shade300;

  late Reservation reservation;
  late VehicleEntry vehicleEntry;
  late Map<String, dynamic> vehicle;
  Future<Map<String,dynamic>>? parking;  
  late Map<String,dynamic> address;
  bool dataLoaded = false;

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  Duration parseDurationFromString(String durationString) {
    final parts = durationString.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final seconds = int.parse(parts[2]);
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  @override
  void initState() {
    super.initState();
    reservationRef = dbRef.child(Provider.of<TokenProvider>(context, listen: false).userId.toString());

    reservationRef.onValue.listen((event) async {
      if (event.snapshot.value != null) {
        Map<String, dynamic> newData = Map<String, dynamic>.from(event.snapshot.value as Map);

        setState(() {
          reservationData = newData;
          _duration = parseDurationFromString(reservationData['remaining_time'] ?? "00:00:00");
        });

        if (!dataLoaded && reservationData['reservation'] != null) {
          await loadData();
        }

        _timer?.cancel();
        startTimer();
      } else {
        setState(() {
          reservationData = {};
          _duration = Duration.zero;
        });
      }
    });
  }

  Future<void> loadData() async {
    try {
      reservation = await ApiReservation().getByID(reservationData['reservation']);
      vehicleEntry = await ApiVehicleEntry().getByID(reservation.vehicleEntry.toString());
      vehicle = await ApiVehicle().getVehicleDetailsById(vehicleEntry.vehicle.toString());
      address = await ApiParking().getParkingAddressById(vehicleEntry.parking.toString());
      parking = ApiParking().getByID(vehicleEntry.parking.toString()) ;
      

      setState(() {
        dataLoaded = true;
      });
    } catch (e) {
      print("Error al obtener datos: $e");
    }
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_duration.inSeconds > 0) {
          _duration = Duration(seconds: _duration.inSeconds - 1);
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  Widget buildDetailsReservation() {
    bool hasValidData = reservationData.isNotEmpty &&
        reservationData['remaining_time'] != "00:00:00" &&
        _duration.inSeconds > 0;

    return FutureBuilder<Map<String,dynamic>?>(
      future: hasValidData ? parking : Future.value(null),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && hasValidData) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading data'));
        } else if (!snapshot.hasData && hasValidData) {
          return Center(child: CircularProgressIndicator());
        } else {
          TextStyle detailsTextStyle = TextStyle(
            fontSize: 18,
            color: Colors.black,
          );

          String placeholderText = "- - - - -";
          Map<String,dynamic>? parkingData = snapshot.data;

          return Container(
            color: Colors.white,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 20),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 180,
                                    height: 180,
                                    child: CircularProgressIndicator(
                                      value: hasValidData ? _progress : 0,
                                      backgroundColor: Colors.grey.shade300,
                                      color: Color(0xFF1b4ee4),
                                      strokeWidth: 12,
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        formatDuration(_duration),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1b4ee4),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('Hr', style: TextStyle(color: Colors.black)),
                                          SizedBox(width: 12),
                                          Text('Min', style: TextStyle(color: Colors.black)),
                                          SizedBox(width: 12),
                                          Text('Sec', style: TextStyle(color: Colors.black)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 30),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  hasValidData && parkingData != null
                                      ? parkingData["name"]!
                                      : placeholderText,
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              Divider(color: Colors.grey),
                              ListTile(
                                title: Text('Direccion', style: detailsTextStyle),
                                trailing: Text(
                                    hasValidData
                                        ? address['street'] 
                                        : placeholderText,
                                    style: detailsTextStyle),
                              ),
                              ListTile(
                                title: Text('Mi Vehiculo', style: detailsTextStyle),
                                trailing: Text(
                                    hasValidData
                                        ? vehicle['brand']
                                        : placeholderText,
                                    style: detailsTextStyle),
                              ),
                              ListTile(
                                title: Text('Placa', style: detailsTextStyle),
                                trailing: Text(
                                    hasValidData
                                        ? vehicle['registration_plate']
                                        : placeholderText,
                                    style: detailsTextStyle),
                              ),
                              ListTile(
                                title: Text('Hora', style: detailsTextStyle),
                                trailing: Text(
                                    hasValidData
                                        ? '${reservation.startTime} - ${reservation.endTime}'
                                        : placeholderText,
                                    style: detailsTextStyle),
                              ),
                              ListTile(
                                title: Text('Horas Totales', style: detailsTextStyle),
                                trailing: Text(
                                    hasValidData
                                        ? '${reservation.getFormattedTotalHours()} '
                                        : placeholderText,
                                    style: detailsTextStyle),
                              ),
                              ListTile(
                                title: Text('Total', style: detailsTextStyle),
                                trailing: Text(
                                    hasValidData
                                        ? '${reservation.totalAmount} Bs'
                                        : placeholderText,
                                    style: detailsTextStyle),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildDetailsReservation(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
