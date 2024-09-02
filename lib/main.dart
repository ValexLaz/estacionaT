import 'package:flutter/material.dart';

import 'screens_users/login_screen.dart'; // Asegúrate de importar la clase LoginScreen desde su archivo correspondiente

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
      home: LoginPage(), // Aquí se llama a tu pantalla de inicio de sesión
    );
  }
}
