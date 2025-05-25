import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
// Pastikan semua model dan provider diimpor
import 'package:real/screens/login/login.dart'; //
import 'package:real/screens/main_screen.dart'; //
import 'package:real/app/themes/app_themes.dart'; //
import 'package:real/provider/auth_provider.dart'; //
import 'package:real/provider/property_provider.dart'; // <-- TAMBAHKAN IMPORT INI

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(null, null);
  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()), // <-- DAFTARKAN PROPERTYPROVIDER DI SINI
        // Provider lainnya jika ada
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
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(), //
        '/home': (context) => const MainScreen(), //
        // Tambahkan route lain jika perlu
        // MyDraftsScreen akan diakses melalui navigasi dari dalam MainScreen,
        // jadi provider yang terdaftar di atas MaterialApp akan bisa diakses.
      },
    );
  }
}