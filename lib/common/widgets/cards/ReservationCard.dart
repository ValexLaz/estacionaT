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
      title: IntrinsicWidth(
        child: Container(
          margin: EdgeInsets.all(0),
          padding: EdgeInsets.all(8),
          child: Text(
            'Estado: ${reservation.state.name}',
            style: TextStyle(color: getBorderColor(reservation.state)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height *
              0.4, // Limitar la altura máxima del contenido
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Text("Desea cancelar la reserva?")],
        ),
      ),
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
          child: Expanded(
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
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${reservation.state.spanish}',
                            style: TextStyle(
                              color: getBorderColor(reservation.state),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Color.fromARGB(143, 73, 57, 57),),
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
                      const Icon(Icons.punch_clock_rounded),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Hora de fin: ${reservation.endTime}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                
                  Text(
                    'Monto Total: Bs ${reservation.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 16, color: Color.fromARGB(172, 53, 165, 90),
                        fontWeight: FontWeight.bold),
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
        ));
  }
}
