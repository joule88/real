import 'package:flutter/material.dart';
import 'package:real/screens/main_screen.dart';

class LoginController {
  void login(BuildContext context) {
    // TODO: logika autentikasi
    print("Login button pressed - Navigating...");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
    // Jika gagal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login Gagal! Cek username/password.')),
    );
  }
}