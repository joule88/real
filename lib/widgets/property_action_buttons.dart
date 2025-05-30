// lib/widgets/property_action_buttons.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real/models/property.dart';

class PropertyActionButtons extends StatelessWidget {
  final bool isLoading;
  final PropertyStatus currentStatus;
  final Function({required PropertyStatus targetStatus}) onSubmit;
  final VoidCallback onEdit; // Untuk status 'rejected' -> 'draft'

  const PropertyActionButtons({
    super.key,
    required this.isLoading,
    required this.currentStatus,
    required this.onSubmit,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle baseButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFDAF365),
      foregroundColor: Colors.black87,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      minimumSize: const Size(160, 50),
    );

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    List<Widget> buttons = [];

    // Logika untuk status DRAFT
    if (currentStatus == PropertyStatus.draft) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => onSubmit(targetStatus: PropertyStatus.draft),
            style: baseButtonStyle.copyWith(
              backgroundColor: WidgetStateProperty.all(Colors.blueGrey[700]),
              foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
            child: const Text("Simpan Draft"),
          ),
        ),
      );
      buttons.add(const SizedBox(height: 12));
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => onSubmit(targetStatus: PropertyStatus.pendingVerification),
            style: baseButtonStyle,
            child: const Text("Ajukan untuk Verifikasi"),
          ),
        ),
      );
    }
    // Logika untuk status REJECTED
    else if (currentStatus == PropertyStatus.rejected) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onEdit, // Ini akan mengubah _currentStatus di form menjadi draft
            style: baseButtonStyle.copyWith(
              backgroundColor: WidgetStateProperty.all(Colors.orange[700]),
              foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
            child: const Text("Revisi & Ajukan Ulang"),
          ),
        ),
      );
    }
    // Logika untuk status ARCHIVED
    else if (currentStatus == PropertyStatus.archived) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => onSubmit(targetStatus: PropertyStatus.approved), // Langsung ubah ke approved
            style: baseButtonStyle.copyWith(
               backgroundColor: WidgetStateProperty.all(Colors.green[600]),
               foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
            child: const Text("Tayangkan Kembali"),
          ),
        ),
      );
    }
    // Tidak ada tombol aksi default untuk status approved, pendingVerification, sold dari widget ini.

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: buttons,
    );
  }
}