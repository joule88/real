import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData icon;
  final bool isPassword;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF182420),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 51,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF5C5C5C), width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: const Color(0xFF5C5C5C)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  obscureText: widget.isPassword ? _obscure : false,
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
                  ),
                ),
              ),
              if (widget.isPassword)
                GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF5C5C5C),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
