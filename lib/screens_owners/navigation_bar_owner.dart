import 'package:flutter/material.dart';

import 'account_owner.dart';
import 'home_gerente.dart';
import 'register_car.dart';
import 'reports_screen.dart';
import 'package:map_flutter/screens_owners/home_gerente.dart';

import 'package:map_flutter/services/api_parking.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final String parkingId;

  MainScreen({Key? key, required this.parkingId}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ParkingScreen(parkingId: widget.parkingId),
      SignUpCarPage(),
      ReportsPage(),
      ParkingOwnerScreen(),
    ];
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Color(0xFF1b4ee4),
          primaryColor:
              Colors.white, // Color blanco para el elemento seleccionado
        ),
        child: BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
              label: 'Register',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Informacion parqueo',
            ),
          ],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }
}
