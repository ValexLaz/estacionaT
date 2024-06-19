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
  final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref().child("parkingtime");
  late DatabaseReference reservationRef;
  Map<String, dynamic> reservationData = {};
  Timer _timer = Timer.periodic(Duration(seconds: 1), (timer) {});
  Duration _duration = Duration(hours: 2);
  double _progress = 1.0;
  Color textColor = Colors.black;
  Color lightGray = Colors.grey.shade300;
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  late Reservation reservation;
  late VehicleEntry vehicleEntry;
  late Map<String,dynamic> vehicle;
  late Future<Parking> parking;
  
  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _duration = Duration(seconds: _duration.inSeconds - 1);
        if (_duration.inSeconds == 0) {
          _duration = Duration(hours: 0); // Reinicia el temporizador a 2 horas
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    reservationRef = dbRef.child(
        Provider.of<TokenProvider>(context, listen: false).userId.toString());

    reservationRef.onValue.listen((event) async {
      reservationData = Map<String, dynamic>.from(event.snapshot.value as Map);
      final newDuration = parseDurationFromString(
          reservationData['remaining_time'] ?? "0:00:00");

      reservation =
          await ApiReservation().getByID(reservationData['reservation']);
      vehicleEntry = await ApiVehicleEntry().getByID(reservation.vehicleEntry.toString());
      vehicle = await ApiVehicle().getVehicleDetailsById(vehicleEntry.vehicle.toString());
      parking = ApiParking().getByID(vehicleEntry.parking.toString())
          as Future<Parking>;
      

      setState(() {
        reservationData =
            Map<String, dynamic>.from(event.snapshot.value as Map);
        _duration = newDuration;
        if (newDuration.inSeconds == 0 &&
            (newDuration.inMinutes > 0 || newDuration.inHours > 0)) {
          _duration = Duration(
            hours: newDuration.inHours,
            minutes: newDuration.inMinutes,
            seconds: 59,
          );
        }
      });
      _timer.cancel();
      startTimer();
    });
  }

  Duration parseDurationFromString(String durationString) {
    final parts = durationString.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final seconds = int.parse(parts[2]);
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return Scaffold(
        body: reservationData.isEmpty || _duration.inSeconds <= 0
            ? Center(child: Text("Aun no tienes reservas en curso"))
            : buildDetailsReservation());
  }

  Widget buildDetailsReservation() {
    return FutureBuilder<Parking>(
      future: parking,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return Text('No se encontró la reservación');
        } else {
          TextStyle detailsTextStyle = TextStyle(
            fontSize: 18,
            color: Colors.black,
          );
          Parking parking = snapshot.data!;
          return Container(
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reserva',
                          style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      Divider(color: lightGray)
                    ],
                  ),
                ),
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
                                    width: 180, // Increased size of the circle
                                    height: 180,
                                    child: CircularProgressIndicator(
                                      value: _progress,
                                      backgroundColor: Colors.grey.shade300,
                                      color: Color(
                                          0xFF1b4ee4), // Color of the progress bar
                                      strokeWidth: 12, // Increased thickness
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        formatDuration(_duration),
                                        style: const TextStyle(
                                          fontSize: 20, // Increased font size
                                          fontWeight: FontWeight.bold,
                                          color: Color(
                                              0xFF1b4ee4), // Matching the progress bar color
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('Hr',
                                              style: TextStyle(
                                                  color: Colors.black)),
                                          SizedBox(width: 12),
                                          Text('Min',
                                              style: TextStyle(
                                                  color: Colors.black)),
                                          SizedBox(width: 12),
                                          Text('Sec',
                                              style: TextStyle(
                                                  color: Colors.black)),
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
                              Text(parking.name!,
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              Divider(color: Colors.grey),
                              ListTile(
                                title:
                                    Text('Direccion', style: detailsTextStyle),
                                trailing: Text('Av. Banzer 2do. Anillo',
                                    style: detailsTextStyle),
                              ),
                              ListTile(
                                title: Text('Mi Vehiculo',
                                    style: detailsTextStyle),
                                trailing: Text(vehicle['brand'],
                                    style: detailsTextStyle),
                              ),
                              ListTile(
                                title: Text('Placa', style: detailsTextStyle),
                                trailing:
                                    Text(vehicle['registration_plate'], style: detailsTextStyle),
                              ),
                              ListTile(
                                title: Text('Hora', style: detailsTextStyle),
                                trailing: Text(
                                    '${reservation.startTime} - ${reservation.endTime}',
                                    style: detailsTextStyle),
                              ),
                              ListTile(
                                title: Text('Horas Totales', style: detailsTextStyle),
                                trailing: Text('${reservation.getTotalHours()} ',
                                    style: detailsTextStyle),
                              ),
                              ListTile(
                                title: Text('Total', style: detailsTextStyle),
                                trailing: Text('${reservation.totalAmount} Bs',
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
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
