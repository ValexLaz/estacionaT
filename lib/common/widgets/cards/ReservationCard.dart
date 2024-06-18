import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
          onPressed: () async {
            reservation.state = ReservationState.cancelled;
            await ApiReservation()
                .update(reservation.id.toString(), reservation);
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
      onTap: () {
        if (reservation.state == ReservationState.confirmed) {
          showConfirmationDialog(context);
        }
      },
      child: Card(
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(width: 0.3)),
          elevation: 5,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Icon(
                            Icons.date_range,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            '${DateFormat('dd/MM/yyyy').format(DateTime.parse(reservation.reservationDate))}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 35, 102, 210),
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.punch_clock_rounded),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Hora de inicio: ${reservation.startTime}',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.punch_clock_rounded),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Hora de fin: ${reservation.endTime}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(),
                      Text(
                        'Monto Total: Bs ${reservation.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(172, 53, 165, 90)),
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
/*     Expanded(
                  flex: 1,
                  child: Container(
                  width: 20,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                ), */
            ],
          )),
    );
  }
}
