import 'dart:math';
import 'package:flutter/material.dart';
import 'package:map_flutter/models/reports.dart';
import 'package:map_flutter/services/api_reports.dart';

import 'package:map_flutter/common/styles/AppTheme.dart'; // Importar el tema

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
    myColor = Theme.of(context).colorScheme.primary;
    mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: FutureBuilder<List<Report>>(
        future: reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<Report> reports = snapshot.data!;
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
                  _buildHeader(),
                  _buildCard("Vehículos con reserva",
                      report.reservationVehicleCount.toString()),
                  _buildCard("Vehículos sin reserva",
                      report.externalVehicleCount.toString()),
                  _buildCard("Total de ingresos",
                      "\$${report.totalEarnings.toStringAsFixed(2)}"),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 10),
      child: Text(
        'Reportes del Parqueo',
        style: TextStyle(
          color: myColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCard(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Container(
          width: mediaSize.width * 0.9, // Ocupa el 90% del ancho de la pantalla
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
