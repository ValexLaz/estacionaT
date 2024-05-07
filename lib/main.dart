import 'package:flutter/material.dart';
import 'package:map_flutter/screens_users/navigation_bar_screen.dart';
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
      create: (_) => TokenProvider()..loadUserData(),
      child: Consumer<TokenProvider>(
        builder: (context, tokenProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Login Demo',
            theme: ThemeData(
              useMaterial3: true,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: tokenProvider.token != null && tokenProvider.token!.isNotEmpty
                ? NavigationBarScreen()
                : LoginPage(),
          );
        },
      ),
    );
  }
}
