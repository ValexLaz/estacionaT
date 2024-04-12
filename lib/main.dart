import 'dart:html';

import 'package:flutter/material.dart';
import 'package:map_flutter/screens_owners/price_screen.dart';
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
      create: (_) => TokenProvider(), 
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Login Demo',
        theme: ThemeData(
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          primaryColor:  const Color(0xFF1b4ee4)
        ),
        //loginPage
        home: LoginPage(),
      ),
    );
  }
}
