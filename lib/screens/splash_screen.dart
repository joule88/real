import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:real/screens/login/login.dart';
import 'package:real/screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Timer(const Duration(seconds: 3), () { // Durasi splash screen bisa disesuaikan
      if (!mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.isAuthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definisikan warna sesuai permintaanmu
    const Color backgroundColor = Color(0xFF182420);
    // Warna untuk logo dan teks "Nestora" (sesuaikan jika warna dari gambar berbeda)
    // Berdasarkan gambar logo yang kamu berikan, warnanya mirip dengan DDEF6D
    const Color logoAndTextColor = Color(0xFFDDEF6D); 

    return Scaffold(
      backgroundColor: backgroundColor, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'nestora_logo.png', 
              width: 150, // Sesuaikan ukuran logo sesuai keinginan
              // Jika logo PNG-mu sudah memiliki warna yang benar, tidak perlu properti color di Image.asset
              // Jika logo PNG-mu adalah template (misal putih) dan ingin diwarnai di sini,
              // kamu bisa menggunakan properti color, tapi biasanya ini untuk ikon atau SVG.
              // Untuk PNG berwarna, pastikan file gambarnya sudah memiliki warna yang diinginkan.
            ),
            const SizedBox(height: 20), 
            Text(
              'Nestora',
              style: GoogleFonts.poppins(
                fontSize: 40, 
                fontWeight: FontWeight.bold,
                color: logoAndTextColor, // Warna teks sama dengan warna logo
              ),
            ),
            const SizedBox(height: 30), 
            CircularProgressIndicator(
              // Warna progress indicator disesuaikan agar kontras dengan background gelap
              valueColor: AlwaysStoppedAnimation<Color>(logoAndTextColor.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}