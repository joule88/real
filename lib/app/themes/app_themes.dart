import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: Colors.white,
      primaryColor: const Color(0xFF205295),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF205295)),
      useMaterial3: true,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF020305),
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF020305),
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: const Color(0xFF020305),
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(0xFF020305),
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF020305),
        ),
      ),
    );
  }
}

class NestoraButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const NestoraButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF205295),
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
          color: const Color(0xFF182420),
        ),
      ),
    );
  }
}
