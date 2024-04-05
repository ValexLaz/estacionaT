import 'package:flutter/material.dart';

class TokenProvider extends ChangeNotifier {
  String? _token;
  String? _username; // Añadir el atributo username
  int? _userId;
  String? _lastName;
  String? _email;
  String? _phone;

  String? get token => _token;
  String? get username => _username; // Getter para el atributo username
  int? get userId => _userId;
  String? get lastName => _lastName;
  String? get email => _email;
  String? get phone => _phone;
  set token(String? value) {
    _token = value;
    notifyListeners();
  }

  set userId(int? value) {
    _userId = value;
    notifyListeners();
  }

  // Método para actualizar el atributo username
  void updateUsername(String? username) {
    _username = username;
    notifyListeners();
  }

  set username(String? value) {
    _username = value;
    notifyListeners();
  }

  set lastName(String? value) {
    _lastName = value;
    notifyListeners();
  }

  set email(String? value) {
    _email = value;
    notifyListeners();
  }

  set phone(String? value) {
    _phone = value;
    notifyListeners();
  }
}
