import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:map_flutter/models/Reservation.dart';

class ReservationCard extends StatelessWidget {
  final Reservation reservation;

  ReservationCard({Key? key, required this.reservation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(reservation.reservationDate))}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Hora de inicio: ${reservation.startTime}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Hora de fin: ${reservation.endTime}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Monto Total: Bs ${reservation.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
            if (reservation.extraTime != null) 
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Tiempo extra: ${reservation.extraTime} mins',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
