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
    return Card(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Vehículo: ${price.typeVehicle ?? "No especificado"}',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Texto negro
                      ),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 50,
                    margin: EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Bs ${price.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (price.isReservation)
                          Text(
                            'Requiere Reservación',
                            style: TextStyle(
                              color: Colors.black, // Texto negro
                              fontSize: 16.0,
                            ),
                          ),
                        if (price.isPriceHour)
                          Text(
                            'Precio por Hora',
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
                          Text(
                            'Horario: De ${formatTimeOfDay(price.priceHour!.startTime)} a ${formatTimeOfDay(price.priceHour!.endTime)}',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black, // Texto negro
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Container(
                      alignment: Alignment.center,
                      child: IconButton(
                        onPressed: onTap,
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black, // Color del ícono
                        ),
                      ),
                    ),
                ],
              ),
              if (onDelete != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 30,
                    ),
                    onPressed: onDelete,
                  ),
                ),
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
