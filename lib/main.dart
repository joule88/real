// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// Sesuaikan path import ini jika berbeda di proyek Anda
import 'package:real/screens/login/login.dart';
import 'package:real/screens/main_screen.dart';
import 'package:real/app/themes/app_themes.dart'; // Pastikan ini adalah path yang benar
import 'package:real/provider/auth_provider.dart';
import 'package:real/provider/property_provider.dart';
// import 'package:real/screens/splash_screen.dart'; // Jika Anda punya splash screen

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Cukup panggil sekali untuk 'id_ID' jika itu target utama Anda
  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        // Tambahkan provider lain di sini jika ada
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
      title: 'Nestora', // Ganti dengan nama aplikasi Anda jika berbeda
      theme: AppTheme.lightTheme, // Menggunakan AppTheme.lightTheme
      // darkTheme: AppTheme.darkTheme, // Jika Anda punya dark theme
      // themeMode: ThemeMode.light, // Atau ThemeMode.system
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          // Opsional: Tambahkan logic untuk state loading awal jika AuthProvider
          // melakukan operasi async saat inisialisasi (misalnya, cek token dari storage).
          // if (auth.isInitializing) { // Asumsi ada getter 'isInitializing' di AuthProvider
          //   return const SplashScreen(); // Atau widget loading lainnya
          // }

          if (auth.isAuthenticated) {
            return const MainScreen(); // Jika terotentikasi, tampilkan MainScreen
          } else {
            return const LoginScreen(); // Jika tidak, tampilkan LoginScreen
          }
        },
      ),
      // Anda tetap bisa mendefinisikan named routes untuk navigasi spesifik lainnya
      // meskipun 'home' sudah menangani halaman awal.
      routes: {
        // Jika Anda menggunakan file app_routes.dart, Anda bisa menggabungkannya di sini
        // atau memastikan rute yang paling penting (seperti login dan main) ada.
        // Pastikan tidak ada konflik antara initialRoute (jika diset) dan logika 'home'.
        // Dengan 'home' di atas, initialRoute tidak begitu relevan lagi untuk halaman pertama.
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
        // '/register': (context) => const RegisterScreen(), // Jika perlu diakses via named route
        // ...Tambahkan rute lain dari AppRoutes.routes Anda jika perlu
      },
    );
  }
}
