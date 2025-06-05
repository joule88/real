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
    // Mendapatkan ukuran layar
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Menentukan ukuran logo berdasarkan persentase lebar layar
    // Anda bisa menyesuaikan persentase ini (misalnya 0.4 untuk 40% lebar layar)
    final logoSize = screenWidth * 0.35; // Contoh: 35% dari lebar layar

    print("SplashScreen: build() dijalankan. ScreenWidth: $screenWidth, LogoSize: $logoSize");
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/nestora_logo.png', // Path yang sudah benar
              width: logoSize, // Menggunakan ukuran logo yang dinamis
              height: logoSize, // Menggunakan ukuran logo yang dinamis
              fit: BoxFit.contain, // Agar gambar tidak terdistorsi
              errorBuilder: (context, error, stackTrace) {
                print("SplashScreen Error dari errorBuilder: Tidak dapat memuat gambar 'images/nestora_logo.png'. Error: $error");
                // Fallback jika path 'images/nestora_logo.png' juga gagal, coba path asli lagi untuk debug
                return Image.asset(
                  'assets/images/nestora_logo.png', // Path asli untuk fallback error message
                  width: logoSize, // Ukuran dinamis juga untuk errorBuilder
                  height: logoSize,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, st) {
                    print("SplashScreen Error dari errorBuilder (fallback): Tidak dapat memuat gambar 'assets/images/nestora_logo.png'. Error: $err");
                    // Konten errorBuilder yang lebih adaptif
                    return Container(
                      width: logoSize * 0.8, // Buat kontainer error sedikit lebih kecil dari logoSize
                      height: logoSize * 0.8,
                      padding: const EdgeInsets.all(8.0), // Tambahkan padding
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8), // Tambahkan border radius
                      ),
                      child: FittedBox( // Agar konten di dalamnya skala menyesuaikan
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 40),
                            const SizedBox(height: 8),
                            Text(
                              "Gagal memuat logo",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(color: Colors.red.shade800, fontSize: 12),
                            ),
                            Text(
                              "(Cek path aset)", // Pesan lebih singkat
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(color: Colors.red.shade700, fontSize: 9),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
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
