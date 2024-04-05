import 'package:flutter/material.dart';

class TokenProvider extends ChangeNotifier {
  String? _token;
  String? _username; // Añadir el atributo username

  String? get token => _token;
  String? get username => _username; // Getter para el atributo username

  set token(String? value) {
    _token = value;
    notifyListeners();
  }

  // Método para actualizar el atributo username
  void updateUsername(String? username) {
    _username = username;
    notifyListeners();
  }
}
