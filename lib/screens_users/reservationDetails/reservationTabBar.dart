import 'package:flutter/material.dart';
import 'package:map_flutter/screens_users/reservationDetails/list_reservations.dart';
import 'package:map_flutter/screens_users/reservationDetails/reserva.dart';

class ReservationTabBar extends StatefulWidget {
  const ReservationTabBar({super.key});

  @override
  State<ReservationTabBar> createState() => _ReservationTabBarState();
}

class _ReservationTabBarState extends State<ReservationTabBar> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reserva',
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                Divider(color: Colors.grey),
              ],
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          body: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                    bottom: 20,
                    top: 5), // Ajusta el valor del margen según tus necesidades
                child: Material(
                  color: Color(0xFF4285f4),
                  child: TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,

                    // Color del indicador si deseas agregar

                    tabs: [
                      Tab(text: "Reserva Actual"),
                      Tab(text: "Historial"),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    ReservaScreen(),
                    ListReservation(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
