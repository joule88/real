import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import '../services/api_services.dart';
import '../services/api_constants.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token; // Tambahkan ini

  User? get user => _user; // asumsikan setelah login selalu tidak null
  String? get token => _token; // Getter untuk token
  bool get isAuthenticated => _user != null;

  void setUser(User user) {
    _user = user;
    notifyListeners(); // supaya semua widget yang mendengar perubahan ikut update
  }

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.loginEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true && json['data'] != null) {
        _user = User.fromJson(json['data']);
        _token = json['data']['token'];
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

    if (result['success'] == true) {
      // Simpan token atau user data ke state management di sini jika perlu
      _token = result['data']['token'];
      return true;
    } else {
      // Bisa log error message jika perlu: result['message']
      return false;
    }
  }
}
