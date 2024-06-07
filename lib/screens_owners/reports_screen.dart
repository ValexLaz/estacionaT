import 'dart:math';
import 'package:flutter/material.dart';
import 'package:map_flutter/models/reports.dart';
import 'package:map_flutter/services/api_reports.dart';

class ReportsPage extends StatefulWidget {
  final String parkingId; // Recibir el ID del parqueo como String

  const ReportsPage({Key? key, required this.parkingId}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late Color myColor;
  late Size mediaSize;
  late Future<List<Report>> reportsFuture;

  @override
  void initState() {
    super.initState();
    reportsFuture = ReportRepository().fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Report>>(
        future: reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<Report> reports = snapshot.data!;
            // Convertir el parkingId a int para la comparación
            int parkingIdInt = int.tryParse(widget.parkingId) ?? -1;
            List<Report> filteredReports = reports
                .where((report) => report.parking == parkingIdInt)
                .toList();

            if (filteredReports.isEmpty) {
              return Center(
                  child:
                      Text('No data found for parking ID ${widget.parkingId}'));
            }

            Report report = filteredReports[0];
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildCard(report),
                  const SizedBox(height: 20),
                  _buildDashboard(),
                ],
              ),
            );
          } else {
            return Center(child: Text('No data found'));
          }
        },
      ),
    );
  }

  Widget _buildCard(Report report) {
    return Padding(
      padding: const EdgeInsets.only(top: 30), // Añadir padding superior de 20 píxeles
      child: Card(
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildReportRow(
                "Vehículos con reserva",
                report.reservationVehicleCount.toString(),
              ),
              _buildReportRow(
                "Vehículos sin reserva",
                report.externalVehicleCount.toString(),
              ),
              _buildReportRow(
                "Total de ingresos",
                "\$${report.totalEarnings.toStringAsFixed(2)}",
              ),
            ],
          ),
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
              color: myColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: myColor,
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
      var height =
          random.nextDouble() * size.height * 0.8; 
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
