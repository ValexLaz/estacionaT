import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:map_flutter/screens_users/login_screen.dart';
import 'package:map_flutter/screens_users/token_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Envuelve MaterialApp con ChangeNotifierProvider
      create: (_) => TokenProvider(), // Crea una instancia de TokenProvider
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Login Demo',
        theme: ThemeData(
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: LoginPage(),
      ),
    );
  }
}