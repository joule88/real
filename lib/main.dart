// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:real/app/themes/app_themes.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:real/provider/property_provider.dart';
import 'package:real/screens/splash_screen.dart'; // Import SplashScreen yang baru
import 'package:real/screens/login/login.dart';
import 'package:real/screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nestora',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Mengarahkan ke SplashScreen sebagai halaman awal
      routes: {
        // Rute ini tetap berguna jika ada navigasi langsung ke login atau main dari bagian lain aplikasi
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}