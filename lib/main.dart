import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:map_flutter/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:map_flutter/screens_users/login_screen.dart';
import 'package:map_flutter/screens_users/token_provider.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        ),
        home: LoginPage(),
      ),
    );
  }
}