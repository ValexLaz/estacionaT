import 'package:flutter/material.dart';
import '../../../models/Price.dart';

class PriceCard extends StatelessWidget {
  final Price price;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const PriceCard({
    Key? key,
    required this.price,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        margin: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Bordes redondeados
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // Fondo blanco
            border: Border.all(color: Colors.blue, width: 2.0), // Bordes azules
            borderRadius: BorderRadius.circular(12), // Bordes redondeados
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${capitalizeFirstLetter(price.typeVehicle ?? "No especificado")}',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Texto negro
                        ),
                      ),
                      SizedBox(height: 8),
                      if (price.isReservation)
                        Text(
                          'Requiere Reservación',
                          style: TextStyle(
                            color: Colors.black, // Texto negro
                            fontSize: 16.0,
                          ),
                        ),
                      if (price.isEntryFee)
                        Text(
                          'Cuota de Entrada',
                          style: TextStyle(
                            color: Colors.black, // Texto negro
                            fontSize: 16.0,
                          ),
                        ),
                      if (price.priceHour != null)
                        RichText(
                          text: TextSpan(
                            text: 'Horario: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: Colors.black, // Texto negro
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text:
                                    'De ${formatTimeOfDay(price.priceHour!.startTime)} a ${formatTimeOfDay(price.priceHour!.endTime)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${price.price.toStringAsFixed(0)} Bs',
                        style: TextStyle(
                          fontSize: 24.0, // Tamaño del texto aumentado
                          color: Colors.blue, // Color azul
                          fontWeight: FontWeight.bold, // Texto en negrita
                        ),
                      ),
                      Text(
                        _getPriceTypeText(price),
                        style: TextStyle(
                          fontSize: 16.0, // Tamaño del texto
                          color: Colors.black, // Texto negro
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getPriceTypeText(Price price) {
    if (price.isPriceHour) {
      return 'Por Hora';
    } else if (price.isEntryFee) {
      return 'Cuota de Entrada';
    } else if (price.isReservation) {
      return 'Requiere Reservación';
    } else {
      return 'Por Día';
    }
  }

  String formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return "No definido";
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String capitalizeFirstLetter(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
