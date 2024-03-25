import 'dart:math';

import 'package:flutter/material.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late Color myColor;
  late Size mediaSize;

  int vehiclesEntered = Random().nextInt(100);
  int vehiclesExited = Random().nextInt(100);
  double totalIncome = Random().nextDouble() * 1000;

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white, // Cambiado a fondo blanco
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCard(),
            const SizedBox(height: 20),
            _buildDashboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildReportRow(
                "Vehículos que ingresaron", vehiclesEntered.toString()),
            _buildReportRow(
                "Vehículos que salieron", vehiclesExited.toString()),
            _buildReportRow(
                "Total de ingresos", "\$${totalIncome.toStringAsFixed(2)}"),
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: myColor, // Ajustado para usar myColor
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: myColor, // Ajustado para usar myColor
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Container(
      width: mediaSize.width,
      height: 200,
      child: CustomPaint(
        painter: _BarChartPainter(myColor),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final Color primaryColor;

  _BarChartPainter(this.primaryColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 10;

    var random = Random();
    for (int i = 0; i < 5; i++) {
      var height = random.nextDouble() * size.height;
      canvas.drawLine(
        Offset(i * size.width / 5 + 25, size.height),
        Offset(i * size.width / 5 + 25, size.height - height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

void main() {
  runApp(MaterialApp(
    home: ReportsPage(),
  ));
}
