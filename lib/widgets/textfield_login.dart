// lib/widgets/textfield_login.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextFieldLogin extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Widget? suffixIcon; // Untuk suffix jika isPassword false

  const TextFieldLogin({
    super.key,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.keyboardType,
    this.suffixIcon, // Meskipun isPassword punya tombol internal, ini untuk fleksibilitas jika diperlukan
  });

  @override
  State<TextFieldLogin> createState() => _TextFieldLoginState();
}

class _TextFieldLoginState extends State<TextFieldLogin> {
  bool _obscureTextForPasswordField = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF182420),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52, // Sedikit disesuaikan untuk bayangan
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white, // Latar belakang putih agar bayangan terlihat
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            children: [
              if (widget.prefixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    widget.prefixIcon,
                    color: Colors.grey[600],
                  ),
                ),
              Expanded(
                child: TextFormField( // Menggunakan TextFormField
                  controller: widget.controller,
                  obscureText: widget.isPassword ? _obscureTextForPasswordField : false,
                  keyboardType: widget.keyboardType,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: const Color(0xFF182420),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: GoogleFonts.poppins(
                      color: const Color(0xFF9E9E9E),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  validator: widget.validator, // Menggunakan validator dari parameter
                ),
              ),
              if (widget.isPassword)
                IconButton(
                  icon: Icon(
                    _obscureTextForPasswordField ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureTextForPasswordField = !_obscureTextForPasswordField;
                    });
                  },
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                )
              else if (widget.suffixIcon != null) // Jika bukan password tapi ada suffixIcon
                 widget.suffixIcon!,
            ],
          ),
        ),
      ],
    );
  }
}