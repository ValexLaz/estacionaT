import 'package:flutter/material.dart';

import '../../../models/Price.dart';

import 'package:flutter/material.dart';

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
      child: Container(
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.only(left:16.0,top:16.0,bottom:16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 100,
                  height: 50,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                      child: Text(
                    'Bs ${price.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  )),
                ),
                SizedBox(width: 10), // Espacio entre el precio y el texto
                Expanded(
                  child: Text(
                    'Vehículo: ${price.typeVehicle ?? "No especificado"}',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (price.isReservation)
                        Text(
                          'Requiere Reservación',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.surface),
                        ),
                      if (price.isPriceHour)
                        Text('Precio por Hora',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.surface)),
                      if (price.isEntryFee)
                        Text('Cuota de Entrada',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.surface)),
                      if (price.priceHour != null)
                        Text(
                          'Horario : De ${formatTimeOfDay(price.priceHour!.startTime)} a ${formatTimeOfDay(price.priceHour!.endTime)}',
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Theme.of(context).colorScheme.surface),
                        ),
                    ],
                  ),
                  if (onTap != null)
                    Container(
                      padding:EdgeInsets.only(left: 20,bottom: 15),
                      child: IconButton(
                          onPressed: onTap,
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                          )),
                    ),
                  if (onDelete != null)
                  Container(
                    padding:EdgeInsets.only(left: 20,bottom: 15),
                    child: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red,size: 30,),
                      onPressed: onDelete,
                    ),
                  )
                   
                ],
              )
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
