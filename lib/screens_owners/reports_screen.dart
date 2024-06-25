import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:map_flutter/models/statistics/popular_price.dart';
import 'package:map_flutter/models/statistics/reports.dart';
import 'package:map_flutter/services/api_reports.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportsPage extends StatefulWidget {
  final String parkingId;

  const ReportsPage({Key? key, required this.parkingId}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late Color myColor;
  late Size mediaSize;
  late Future<List<Report>> reportsFuture;
  late Future<PopularPrices> popularPricesFuture;
  DateTime? selectedDate;
  int? selectedYear;
  @override
  void initState() {
    super.initState();
    reportsFuture = _fetchReports();
    popularPricesFuture = _fetchPopularPrices();
  }

  Future<List<Report>> _fetchReports() {
    int parkingIdInt = int.tryParse(widget.parkingId) ?? -1;
    return ReportRepository().fetchReports(parkingIdInt);
  }

  Future<PopularPrices> _fetchPopularPrices() async {
    int parkingIdInt = int.tryParse(widget.parkingId) ?? -1;
    return ReportRepository().fetchPopularPrices(
      parkingIdInt.toString(),
      date: selectedDate,
      year: selectedYear,
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedYear = null;
        popularPricesFuture = _fetchPopularPrices();
      });
    }
  }

  void _selectYear() async {
    final int? picked = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Seleccionar Año"),
          content: Container(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(DateTime.now().year - 100, 1),
              lastDate: DateTime(DateTime.now().year + 1, 1),
              selectedDate: DateTime(selectedYear ?? DateTime.now().year),
              onChanged: (DateTime dateTime) {
                Navigator.pop(context, dateTime.year);
              },
            ),
          ),
        );
      },
    );
    if (picked != null && picked != selectedYear) {
      setState(() {
        selectedYear = picked;
        selectedDate = null;
        popularPricesFuture = _fetchPopularPrices();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).colorScheme.primary;
    mediaSize = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Reportes',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              child: Material(
                color: Colors.white,
                child: TabBar(
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.blueAccent,
                  indicatorColor: Colors.blue,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.car_repair),
                      text: "Ocupación y Capacidad",
                    ),
                    Tab(
                      icon: Icon(Icons.attach_money_sharp),
                      text: "Ingresos",
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [_reportCapacity(), _reportEarnings()],
              ),
            ),
          ],
        ),
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
          width: mediaSize.width * 0.9,
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

Widget _reportCapacity() {
  return FutureBuilder<List<Report>>(
    future: reportsFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (snapshot.hasData) {
        List<Report> reports = snapshot.data!;
        List<_ReportData> data = reports.map((report) {
          return _ReportData(
            date: report.date,
            reservationVehicleCount: report.reservationVehicleCount,
            entryVehicleCount: report.entryVehicleCount,
            externalVehicleCount: report.externalVehicleCount,
          );
        }).toList();

        return SingleChildScrollView(
          child: Column(
            children: [
              SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                title: ChartTitle(text: 'Ocupación y Capacidad'),
                legend: Legend(isVisible: true, position: LegendPosition.bottom),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  BarSeries<_ReportData, String>(
                    dataSource: data,
                    xValueMapper: (_ReportData report, _) => report.date,
                    yValueMapper: (_ReportData report, _) =>
                        report.reservationVehicleCount.toDouble(),
                    name: 'Vehículos con Reserva',
                    color: Colors.blue,
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  ),
                  BarSeries<_ReportData, String>(
                    dataSource: data,
                    xValueMapper: (_ReportData report, _) => report.date,
                    yValueMapper: (_ReportData report, _) =>
                        report.entryVehicleCount.toDouble(),
                    name: 'Total de Vehículos Ingresados',
                    color: Colors.green,
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  ),
                  BarSeries<_ReportData, String>(
                    dataSource: data,
                    xValueMapper: (_ReportData report, _) => report.date,
                    yValueMapper: (_ReportData report, _) =>
                        report.externalVehicleCount.toDouble(),
                    name: 'Vehículos Externos',
                    color: Colors.red,
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
              ..._reportOccupation(),
            ],
          ),
        );
      } else {
        return Center(child: Text('No se encontraron datos'));
      }
    },
  );
}
  Widget _reportEarnings() {
    return FutureBuilder<List<Report>>(
      future: reportsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          List<Report> reports = snapshot.data!;
          List<_EarningsData> data = reports.map((report) {
            return _EarningsData(
              date: report.date,
              totalEarnings: report.totalEarnings,
            );
          }).toList();

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    title: ChartTitle(text: 'Ingresos Totales'),
                    legend: Legend(
                        isVisible: true, position: LegendPosition.bottom),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries>[
                      BarSeries<_EarningsData, String>(
                        dataSource: data,
                        xValueMapper: (_EarningsData earnings, _) =>
                            earnings.date,
                        yValueMapper: (_EarningsData earnings, _) =>
                            earnings.totalEarnings,
                        name: 'Ingresos Totales',
                        color: Colors.blue,
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        } else {
          return Center(child: Text('No se encontraron datos'));
        }
      },
    );
  }

List<Widget> _reportOccupation() {
  return <Widget>[
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _selectDate,
          child: Text('Seleccionar Fecha'),
        ),
        ElevatedButton(
          onPressed: _selectYear,
          child: Text('Seleccionar Año'),
        ),
      ],
    ),
    FutureBuilder<PopularPrices>(
      future: popularPricesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
           return SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            title: ChartTitle(text: 'Comparación de Precios Populares'),
            legend: Legend(isVisible: true, position: LegendPosition.bottom),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries>[
              ColumnSeries<PriceInfo, String>(
                dataSource: snapshot.data!.popularReservationPrices,
                xValueMapper: (PriceInfo price, _) => price.typeVehicleName,
                yValueMapper: (PriceInfo price, _) => price.count,
                dataLabelSettings: DataLabelSettings(isVisible: true),
                name: 'Reservas',
                color: Colors.blue,
              ),
              ColumnSeries<PriceInfo, String>(
                dataSource: snapshot.data!.popularDetailsPrices,
                xValueMapper: (PriceInfo price, _) => price.typeVehicleName,
                yValueMapper: (PriceInfo price, _) => price.count,
                dataLabelSettings: DataLabelSettings(isVisible: true),
                name: 'Detalles',
                color: Colors.green,
              ),
            ],
          );
        } else {
          return Center(child: Text('No se encontraron datos'));
        }
      },
    ),
  ];
}
}

class _ReportData {
  _ReportData({
    required this.date,
    required this.reservationVehicleCount,
    required this.entryVehicleCount,
    required this.externalVehicleCount,
  });

  final String date;
  final int reservationVehicleCount;
  final int entryVehicleCount;
  final int externalVehicleCount;
}

class _EarningsData {
  _EarningsData({required this.date, required this.totalEarnings});

  final String date;
  final double totalEarnings;
}
