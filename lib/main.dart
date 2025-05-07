import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/property.dart'; // Pastikan model Property diimpor
import 'screens/login/login.dart';
import 'screens/main_screen.dart';
import 'app/themes/app_themes.dart';
import 'provider/auth_provider.dart';
// Import PropertyProvider jika Anda memutuskan untuk menggunakannya untuk list properti global
// import 'provider/property_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Anda mungkin tidak perlu menyediakan satu instance Property global seperti ini lagi
        // jika setiap layar akan mengelola datanya sendiri atau melalui PropertyProvider yang berisi List<Property>.
        // Namun, jika Anda tetap ingin ada satu contoh Property default, perbarui seperti ini:
        ChangeNotifierProvider(
          create: (_) => Property(
            id: 'defaultProp1', // ID unik
            imageUrl:
                'https://images.pexels.com/photos/106399/pexels-photo-106399.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
            price: 842000,
            address: '8502 Preston Rd',
            city: 'Inglewood',
            stateZip: 'Maine 98380',
            bedrooms: 5,
            bathrooms: 4,
            areaSqft: 2135,
            title: 'Contoh Properti Global',
            description:
                'Deskripsi contoh properti yang disediakan secara global.',
            uploader: 'system',
            propertyType: "Rumah Contoh", // <--- TAMBAHKAN INI
            furnishings: "Full Furnished Contoh", // <--- TAMBAHKAN INI
            additionalImageUrls: [], // <--- TAMBAHKAN INI (bisa list kosong)
            status: PropertyStatus.approved, // Contoh status
          ),
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Jika Anda memiliki PropertyProvider untuk mengelola daftar properti:
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
      title: 'Nestora', // Ganti nama aplikasi jika perlu (sebelumnya Livora)
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const MainScreen(),
      },
    );
  }
}