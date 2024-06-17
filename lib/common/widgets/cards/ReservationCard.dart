import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:map_flutter/models/Reservation.dart';
import 'package:map_flutter/services/ApiRepository.dart';
import 'package:map_flutter/services/api_reservations.dart';

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  OverlayEntry? _cancelReservationToast;

  ReservationCard({Key? key, required this.reservation}) : super(key: key);
  
  Color getBorderColor(ReservationState state) {
    switch (state) {
      case ReservationState.pending:
        return Colors.orange;
      case ReservationState.confirmed:
        return Colors.green;
      case ReservationState.active:
        return Colors.blue;
      case ReservationState.completed:
        return Colors.grey;
      case ReservationState.cancelled:
        return Colors.red;
      case ReservationState.no_Show:
        return Colors.pink;
      case ReservationState.modified:
        return Colors.purple;
      default:
        return Colors.black;
    }
  }
  @override
  void showConfirmationDialog(BuildContext context) {
  
  AlertDialog alert = AlertDialog(
    title: Text('Cancelar reserva'),
    content: Text('¿Estás seguro de que quieres cancelar la reserva?'),
    actions: [
      TextButton(
        child: Text('Aceptar'),
        onPressed: ()async {
          reservation.state = ReservationState.cancelled;
          await ApiReservation().update(reservation.id.toString(), reservation);
          Navigator.of(context).pop(); 
        },
      ),
      TextButton(
        child: Text('Cancelar'),
        onPressed: () {
          Navigator.of(context).pop(); 
        },
      ),
    ],
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
       if (reservation.state == ReservationState.confirmed){
        showConfirmationDialog(context);
       }
      },
      child: Card(
      color: Theme.of(context).colorScheme.secondary,
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: getBorderColor(reservation.state),
          width: 4
      )),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(reservation.reservationDate))}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Hora de inicio: ${reservation.startTime}',
                  style: TextStyle(fontSize: 16,color: Colors.white)
                  ,
                ),
                Text(
                  'Hora de fin: ${reservation.endTime}',
                  style: TextStyle(fontSize: 16,color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Monto Total: Bs ${reservation.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 175, 220, 176)),
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
    ),
    ) ;
  }
}
