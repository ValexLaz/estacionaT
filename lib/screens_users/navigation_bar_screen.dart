import 'package:flutter/material.dart';
import 'package:map_flutter/screens_users/account_user.dart';
import 'package:map_flutter/screens_users/parkings_screen.dart';
import 'package:map_flutter/screens_users/reservationDetails/reservationTabBar.dart';

import 'map_screen.dart';
import 'reservationDetails/reserva.dart';
class NavigationBarScreen extends StatefulWidget {
  final int initialIndex;

  NavigationBarScreen({this.initialIndex = 0});

  @override
  _NavigationBarScreenState createState() => _NavigationBarScreenState();
}

class _NavigationBarScreenState extends State<NavigationBarScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _children = [
    MapScreen(),
    ParkingsScreen(),
    const ReservationTabBar(),
    CuentaScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Color(0xFF4285f4),
          primaryColor: primaryColor,
          textTheme: Theme.of(context).textTheme.copyWith(
                caption: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: Colors.white.withOpacity(0.7),
          selectedItemColor: Color(0xFFFFFFFF),
          currentIndex: _currentIndex,
          onTap: onTabTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_parking),
              label: 'Parqueos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Reserva',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Cuenta',
            ),
          ],
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          elevation: 20,
          selectedLabelStyle: TextStyle(color: Colors.white),
          unselectedLabelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
      ),
    );
  }
}
