import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/property.dart';
import 'screens/login/login.dart';
import 'app/themes/app_themes.dart';

void main() {
  runApp(
    ChangeNotifierProvider<Property>(
      create: (_) => Property(
        id: '1',
        imageUrl: 'https://images.pexels.com/photos/106399/pexels-photo-106399.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
        price: 842000,
        address: '8502 Preston Rd',
        city: 'Inglewood',
        stateZip: 'Maine 98380',
        bedrooms: 5,
        bathrooms: 4,
        areaSqft: 2135,
        title: 'Modern Family Home',
        description: 'A spacious and modern family home in a quiet neighborhood.',
        uploader: 'admin@nestora.com',
      ),
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Livora',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}