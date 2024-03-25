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
    TextStyle cardTextStyle = TextStyle(
        fontSize: 18, color: Colors.black); // Estilo de texto mejorado

    return Scaffold(
      appBar: AppBar(
        title: Text('Reserva', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1b4ee4),
      ),
      body: Container(
        color: Colors.white, // Fondo blanco
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey.shade300,
                    color: Color(0xFF1b4ee4),
                    strokeWidth: 10,
                  ),
                ),
                Text(
                  '${_duration.inHours.toString().padLeft(2, '0')}:${(_duration.inMinutes % 60).toString().padLeft(2, '0')}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 30),
            Expanded(
              child: Card(
                color: Color(0xFFf0f0f5),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Detalles',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      SizedBox(height: 10),
                      Divider(color: Colors.grey),
                      ListTile(
                        title: Text('Parqueo', style: cardTextStyle),
                        trailing: Text('Parqueo Central', style: cardTextStyle),
                      ),
                      ListTile(
                        title: Text('Ubicación', style: cardTextStyle),
                        trailing:
                            Text('Calle Principal #123', style: cardTextStyle),
                      ),
                      ListTile(
                        title: Text('Tarifa', style: cardTextStyle),
                        trailing: Text('10 USD/hora', style: cardTextStyle),
                      ),
                      ListTile(
                        title: Text('Tiempo', style: cardTextStyle),
                        trailing: Text('2 horas', style: cardTextStyle),
                      ),
                      ListTile(
                        title: Text('Hora', style: cardTextStyle),
                        trailing: Text('15:00', style: cardTextStyle),
                      ),
                      ListTile(
                        title: Text('Total', style: cardTextStyle),
                        trailing: Text('20 USD', style: cardTextStyle),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
