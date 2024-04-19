import 'package:flutter/material.dart';

class PriceParkingCard extends StatelessWidget {
  final String vehicleType;
  final double price;
  final String parkingName;
  final bool isReservation;
  final bool isEntryFee;
  final bool isPriceHour;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int totalHours;

  PriceParkingCard({
    required this.vehicleType,
    required this.price,
    required this.parkingName,
    required this.isReservation,
    required this.isEntryFee,
    required this.isPriceHour,
    this.startTime = const TimeOfDay(hour: 0, minute: 0),
    this.endTime = const TimeOfDay(hour: 0, minute: 0),
    this.totalHours = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Card(
      elevation: 4,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Type: $vehicleType',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Price: \$${price.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Parking: $parkingName',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Reservation Required: ${isReservation ? 'Yes' : 'No'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Entry Fee Required: ${isEntryFee ? 'Yes' : 'No'}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Price by Hour: ${isPriceHour ? 'Yes' : 'No'}',
              style: TextStyle(fontSize: 16),
            ),
            if (isPriceHour)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12),
                  Text(
                    'Hourly Price Details:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start Time: ${startTime.format(context)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'End Time: ${endTime.format(context)}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Total Hours: $totalHours',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
          ],
        ),
      ),
    ));
  }
}
