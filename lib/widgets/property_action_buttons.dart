// lib/widgets/property_action_buttons.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real/models/property.dart'; // Pastikan import ini ada

class PropertyActionButtons extends StatelessWidget {
  final bool isLoading;
  final PropertyStatus currentStatus;
  final Function({required PropertyStatus targetStatus}) onSubmit;
  final VoidCallback onEdit; // Dipanggil saat tombol "Edit Ulang (Revisi)" ditekan

  const PropertyActionButtons({
    super.key,
    required this.isLoading,
    required this.currentStatus,
    required this.onSubmit,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    // Gaya tombol yang akan digunakan bersama
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFDAF365), // Warna seperti tombol prediksi
      foregroundColor: Colors.black87, // Warna teks
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20), // Padding disesuaikan
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: GoogleFonts.poppins(
        fontSize: 15, // Ukuran font disesuaikan
        fontWeight: FontWeight.w600,
      ),
      minimumSize: const Size(160, 50), // Atur lebar minimal tombol agar sedikit lebih besar
    );

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Hanya tampilkan tombol jika statusnya draft atau ditolak (untuk revisi)
    if (currentStatus == PropertyStatus.draft || currentStatus == PropertyStatus.rejected) {
      return Column(
        mainAxisSize: MainAxisSize.min, // Agar Column tidak mengambil ruang berlebih
        children: [
          if (currentStatus == PropertyStatus.draft) ...[
            SizedBox(
              width: double.infinity, // Tombol mengambil lebar penuh
              child: ElevatedButton(
                onPressed: () => onSubmit(targetStatus: PropertyStatus.draft),
                style: buttonStyle.copyWith( // Gunakan gaya dasar, bisa di-override jika perlu warna beda
                  backgroundColor: MaterialStateProperty.all(Colors.blueGrey[700]), // Warna spesifik untuk Simpan Draft
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                child: const Text("Simpan Draft"),
              ),
            ),
            const SizedBox(height: 12), // Jarak antar tombol
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => onSubmit(targetStatus: PropertyStatus.pendingVerification),
                style: buttonStyle, // Gaya utama
                child: const Text("Ajukan untuk Verifikasi"),
              ),
            ),
          ] else if (currentStatus == PropertyStatus.rejected) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onEdit, // Panggil callback onEdit
                style: buttonStyle.copyWith(
                  backgroundColor: MaterialStateProperty.all(Colors.orange[700]), // Warna untuk revisi
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                child: const Text("Edit Ulang (Revisi)"),
              ),
            ),
          ],
        ],
      );
    }
    // Jika status pendingVerification, approved, dll., tidak ada tombol aksi di sini
    // (kecuali Anda ingin menambahkan tombol "Nonaktifkan", dll.)
    return const SizedBox.shrink(); 
  }
}