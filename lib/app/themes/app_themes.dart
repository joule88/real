// lib/app/themes/app_themes.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- PENAMBAHAN WARNA KONSTANTA DI SINI ---
  static const Color nearlyBlack = Color(0xFF020305);

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      primaryColor: const Color(0xFF205295),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF205299)),
      // Anda bisa juga mengatur warna progress indicator default di sini
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: nearlyBlack,
      ),
      useMaterial3: true,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: nearlyBlack,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: nearlyBlack,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: nearlyBlack,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: nearlyBlack,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: nearlyBlack,
        ),
      ),
    );
  }
}

class NestoraButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const NestoraButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF020305),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}