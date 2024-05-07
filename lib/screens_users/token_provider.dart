import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenProvider extends ChangeNotifier {
  String? _token;
  String? _username;
  int? _userId;
  String? _lastName;
  String? _email;
  String? _phone;

  String? get token => _token;
  String? get username => _username;
  int? get userId => _userId;
  String? get lastName => _lastName;
  String? get email => _email;
  String? get phone => _phone;

  set token(String? value) {
    _token = value;
    notifyListeners();
    saveTokenToPreferences();
  }

  set username(String? value) {
    _username = value;
    notifyListeners();
    saveUsernameToPreferences();
  }

  set userId(int? value) {
    _userId = value;
    notifyListeners();
    saveUserIdToPreferences();
  }

  Future<void> saveTokenToPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', _token ?? '');
  }

  Future<void> saveUsernameToPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _username ?? '');
  }

  Future<void> saveUserIdToPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', _userId ?? -1);
  }

  Future<void> loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _username = prefs.getString('username');
    _userId = prefs.getInt('userId');
    notifyListeners();
  }

  Future<void> clearUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('username');
    await prefs.remove('userId');
    _token = null;
    _username = null;
    _userId = null;
    notifyListeners();
  }
}
