import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real/models/property.dart';

class PropertyActionButtons extends StatelessWidget {
  final bool isLoading;
  final PropertyStatus currentStatus;
  final Function({required PropertyStatus targetStatus}) onSubmit;
  final VoidCallback onEdit;

  const PropertyActionButtons({
    super.key,
    required this.isLoading,
    required this.currentStatus,
    required this.onSubmit,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (currentStatus == PropertyStatus.draft) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => onSubmit(targetStatus: PropertyStatus.draft),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[700]),
              child: Text("Simpan Draft", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => onSubmit(targetStatus: PropertyStatus.pendingVerification),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1F2937)),
              child: Text("Ajukan untuk Verifikasi", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      );
    } else if (currentStatus == PropertyStatus.rejected) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onEdit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800]),
          child: Text("Edit Ulang (Revisi)", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}