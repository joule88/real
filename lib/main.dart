import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- TAMBAHKAN IMPORT INI
import 'models/property.dart'; // Pastikan semua model dan provider diimpor
import 'screens/login/login.dart';
import 'screens/main_screen.dart';
import 'app/themes/app_themes.dart';
import 'provider/auth_provider.dart';
// Import provider lain jika ada

Future<void> main() async {
  // Tambahkan async dan Future<void>
  // Baris ini penting jika main() jadi async sebelum runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi data format tanggal untuk locale yang akan digunakan
  // Sebaiknya inisialisasi default locale (null) dan locale spesifik ('id_ID')
  await initializeDateFormatting(null, null); // Untuk default locale
  await initializeDateFormatting('id_ID', null); // Untuk locale Indonesia

  runApp(
    MultiProvider(
      providers: [
        // Pastikan semua provider Anda terdaftar di sini
        ChangeNotifierProvider(
          create: (_) => Property(
            // Isi data default Property jika masih diperlukan
            id: 'defaultProp1',
            imageUrl: 'https://via.placeholder.com/150',
            price: 0,
            address: 'Default Address',
            city: 'Default City',
            stateZip: 'Default State',
            bedrooms: 0,
            bathrooms: 0,
            areaSqft: 0,
            title: 'Default Property',
            description: 'Default Description',
            uploader: 'system',
            propertyType: "Default Type",
            furnishings: "Default Furnishings",
          ),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Tambahkan provider lain jika ada (misal PropertyProvider untuk list)
        // ChangeNotifierProvider(create: (_) => PropertyProvider()),
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
      title: 'Nestora', // Ganti nama aplikasi jika perlu
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const MainScreen(),
        // Tambahkan route lain jika perlu
      },
      // Jika Anda ingin mengatur locale default untuk seluruh aplikasi:
      // locale: Locale('id', 'ID'),
      // supportedLocales: [
      //    Locale('en', ''), // English, no country code
      //    Locale('id', 'ID'), // Indonesian, Indonesia
      // ],
      // localizationsDelegates: [ // Ini diperlukan jika Anda pakai localization Flutter
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
    );
  }
}
