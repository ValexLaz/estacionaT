import 'dart:async';

import 'package:flutter/material.dart';

class ReservaScreen extends StatefulWidget {
  @override
  _ReservaScreenState createState() => _ReservaScreenState();
}

class _ReservaScreenState extends State<ReservaScreen> {
  late Timer _timer;
  Duration _duration = Duration(hours: 2);
  double _progress = 1.0;
  Color textColor = Colors.black;
  Color lightGray = Colors.grey.shade300;

  void startTimer() {
    final totalSeconds = _duration.inSeconds;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        final seconds = _duration.inSeconds - 1;
        _progress = seconds / totalSeconds;
        if (seconds < 0) {
          timer.cancel();
          _progress = 0;
        } else {
          _duration = Duration(seconds: seconds);
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle detailsTextStyle = TextStyle(
      fontSize: 18,
      color: Colors.black,
    );

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hoursStr = twoDigits(_duration.inHours);
    final minutesStr = twoDigits(_duration.inMinutes.remainder(60));
    final secondsStr = twoDigits(_duration.inSeconds.remainder(60));

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
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
                                    '$hoursStr:$minutesStr:$secondsStr',
                                    style: TextStyle(
                                      fontSize: 20, // Increased font size
                                      fontWeight: FontWeight.bold,
                                      color: Color(
                                          0xFF1b4ee4), // Matching the progress bar color
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Hr',
                                          style:
                                              TextStyle(color: Colors.black)),
                                      SizedBox(width: 12),
                                      Text('Min',
                                          style:
                                              TextStyle(color: Colors.black)),
                                      SizedBox(width: 12),
                                      Text('Sec',
                                          style:
                                              TextStyle(color: Colors.black)),
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
                          Text('Parqueo Zona Norte',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          Divider(color: Colors.grey),
                          ListTile(
                            title: Text('Direccion', style: detailsTextStyle),
                            trailing: Text('Av. Banzer 2do. Anillo',
                                style: detailsTextStyle),
                          ),
                          ListTile(
                            title: Text('Mi Vehiculo', style: detailsTextStyle),
                            trailing:
                                Text('Suzuki Ertiga', style: detailsTextStyle),
                          ),
                          ListTile(
                            title: Text('Placa', style: detailsTextStyle),
                            trailing: Text('1234-ABC', style: detailsTextStyle),
                          ),
                          ListTile(
                            title: Text('Hora', style: detailsTextStyle),
                            trailing: Text('15:00 PM - 17:00 PM',
                                style: detailsTextStyle),
                          ),
                          ListTile(
                            title: Text('Duracion', style: detailsTextStyle),
                            trailing: Text('2 horas', style: detailsTextStyle),
                          ),
                          ListTile(
                            title: Text('Total', style: detailsTextStyle),
                            trailing: Text('20 Bs', style: detailsTextStyle),
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
      ),
    );
  }
}
