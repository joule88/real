import 'package:flutter/material.dart';
import 'screens/login/login.dart';
import 'app/themes/app_themes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nestora',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: LoginScreen(), // tampilkan halaman login sebagai halaman awal
    );
  }
}
