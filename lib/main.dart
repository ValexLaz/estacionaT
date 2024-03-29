import 'package:flutter/material.dart';
import 'package:map_flutter/screens_users/cuenta.dart';
import 'package:map_flutter/screens_users/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Demo',
      theme: ThemeData(
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CuentaScreen(),
    );
  }
}
