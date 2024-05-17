import 'package:flutter/material.dart';
import 'package:map_flutter/services/api_openinghours.dart';
import 'package:map_flutter/models/OpeningHours.dart';

class OpeningHoursScreen extends StatefulWidget {
  final int parkingId;

  OpeningHoursScreen({required this.parkingId});

  @override
  _OpeningHoursScreenState createState() => _OpeningHoursScreenState();
}

class _OpeningHoursScreenState extends State<OpeningHoursScreen> {
  late Future<List<OpeningHours>> _futureOpeningHours;

  @override
  void initState() {
    super.initState();
    _futureOpeningHours =
        ApiOpeningHours().getOpeningHoursByParkingId(widget.parkingId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Horarios de Atención'),
      ),
      body: FutureBuilder<List<OpeningHours>>(
        future: _futureOpeningHours,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No se encontraron horarios.'));
          } else {
            List<OpeningHours> openingHours = snapshot.data!;
            return ListView.builder(
              itemCount: openingHours.length,
              itemBuilder: (context, index) {
                OpeningHours hour = openingHours[index];
                return ListTile(
                  title: Text(hour.day ?? ''),
                  subtitle: Text('${hour.open_time} - ${hour.close_time}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
