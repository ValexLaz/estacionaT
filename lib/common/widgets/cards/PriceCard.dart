import 'package:flutter/material.dart';

import '../../../models/Price.dart';

import 'package:flutter/material.dart';

class PriceCard extends StatelessWidget {
  final Price price;
  final VoidCallback? onTap;

  const PriceCard({Key? key, required this.price, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0, // Sombra para destacar la tarjeta
        margin: const EdgeInsets.all(8.0), // Margen alrededor de la tarjeta
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Espaciado interno de la tarjeta
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tipo de Vehículo: ${price.typeVehicle ?? "No especificado"}',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0), // Espacio entre líneas de texto
              Text(
                'Precio: Bs ${price.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (price.isReservation) ...[
                SizedBox(height: 5.0),
                Chip(
                  label: Text('Requiere Reservación'),
                  backgroundColor: Colors.orangeAccent,
                ),
              ],
              if (price.isPriceHour) ...[
                SizedBox(height: 5.0),
                Chip(
                  label: Text('Precio por Hora'),
                  backgroundColor: Colors.blueAccent,
                ),
              ],
              if (price.isEntryFee) ...[
                SizedBox(height: 5.0),
                Chip(
                  label: Text('Cuota de Entrada'),
                  backgroundColor: Colors.redAccent,
                ),
              ],
              if (price.priceHour != null) ...[
                SizedBox(height: 10.0),
                Text(
                  'Horario de Tarifa: De ${formatTimeOfDay(price.priceHour!.startTime)} a ${formatTimeOfDay(price.priceHour!.endTime)}',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return "No definido";
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
