import 'package:flutter/material.dart';
import 'package:map_flutter/screens_users/cuenta.dart';

import 'map_screen.dart';
import 'parqueos_screen.dart';
import 'reserva.dart';

class NavigationBarScreen extends StatefulWidget {
  @override
  _NavigationBarScreenState createState() => _NavigationBarScreenState();
}

class _NavigationBarScreenState extends State<NavigationBarScreen> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    MapScreen(),
    ParqueosScreen(),
    ReservaScreen(),
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
          canvasColor: Color(0xFF1b4ee4),
          primaryColor: primaryColor,
          textTheme: Theme.of(context).textTheme.copyWith(
                caption: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          unselectedItemColor: Colors.white.withOpacity(0.7),
          selectedItemColor: Colors.white,
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
          backgroundColor: Color(0xFF1b4ee4),
          elevation: 20,
          selectedLabelStyle: TextStyle(color: Colors.white),
          unselectedLabelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
      ),
    );
  }
}
