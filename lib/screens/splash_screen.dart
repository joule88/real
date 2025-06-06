// lib/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    print("SplashScreen: initState dijalankan.");
    Timer(const Duration(seconds: 3), () {
      print("SplashScreen: Timer 3 detik selesai.");
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF182420);
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = screenWidth * 0.35;

    print("SplashScreen: build() dijalankan. Mencoba memuat 'assets/images/nestora_logo.png'");
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/nestora_logo.png', // Path standar untuk platform native
              width: logoSize,
              height: logoSize,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Pesan error yang lebih detail di konsol
                print("----------------------------------------------------------------------");
                print("SplashScreen FATAL ERROR: Tidak dapat memuat aset gambar.");
                print("Path yang dicoba: 'assets/images/nestora_logo.png'");
                print("Error object: $error");
                print("StackTrace: $stackTrace");
                print("----------------------------------------------------------------------");
                
                // UI untuk pengguna
                return Container(
                  width: logoSize * 0.9, // Sesuaikan ukuran container error
                  height: logoSize * 0.9,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300, width: 1),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.no_photography_outlined, color: Colors.red.shade700, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          "Logo Gagal Dimuat",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "1. Cek path di kode.\n2. Cek nama file & folder 'assets/images/'.\n3. Pastikan 'pubspec.yaml' benar & sudah 'flutter pub get'.\n4. Lakukan 'flutter clean' & restart aplikasi.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: Colors.red.shade700, fontSize: 9, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Teks "Nestora" dan CircularProgressIndicator sudah dihapus sebelumnya
          ],
        ),
      ),
    );
  }
}