import 'package:flutter/material.dart';
import 'package:map_flutter/models/Reservation.dart';
import 'package:map_flutter/screens_users/token_provider.dart';
import 'package:map_flutter/services/api_reservations.dart';
import 'package:provider/provider.dart';

class ListReservation extends StatefulWidget {
  const ListReservation({super.key});

  @override
  State<ListReservation> createState() => _ListReservationState();
}

class _ListReservationState extends State<ListReservation> {
  Future<List<Reservation>>? reservations ;

  Future<void> loadReservaions() async {
      reservations =  ApiReservation().getAllByParam("/user/${
              Provider.of<TokenProvider>(context, listen: false).userId}");
  }

  @override
  Widget build(BuildContext context) {
   return FutureBuilder<List<Reservation>>(
      future: reservations,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Text("data");
            },
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  
  }
}
