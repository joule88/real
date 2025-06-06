// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:real/screens/login/login.dart';
import 'package:real/screens/main_screen.dart';
import 'package:real/app/themes/app_themes.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:real/provider/property_provider.dart';
import 'package:real/screens/splash_screen.dart'; // Ensure SplashScreen is imported

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // INDONESIAN DATE FORMAT RETAINED as requested by the user
  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()), // AuthProvider is created here
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
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (auth.isInitializing) { // Check the isInitializing state
            return const SplashScreen(); // Show SplashScreen if true
          }

          // After initialization is complete, the existing authentication logic runs
          if (auth.isAuthenticated) {
            return const MainScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
        // ...other routes
      },
    );
  }
}