import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import '../services/api_services.dart';

class AuthProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://10.10.183.4:8000/api/login'), // Ganti dengan IP server backend
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      if (body != null && body['data'] != null) {
        _user = User.fromJson(body['data']);
        notifyListeners();
        return true;
      } else {
        print('Error: Respons tidak valid');
        return false;
      }
    } else {
      print('Error: ${response.body}');
      return false;
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

    Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final result = await ApiService.registerUser(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );

    if (result['success']) {
      _user = User.fromJson(result['data']['user']);
      notifyListeners();
      return true;
    }

    return false;
  }

}


