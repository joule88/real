// lib/widgets/property_action_buttons.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real/models/property.dart'; // Pastikan import ini ada

class PropertyActionButtons extends StatelessWidget {
  final bool isLoading;
  final PropertyStatus currentStatus;
  // Callback onSubmit akan dipanggil dengan targetStatus yang sesuai
  // tergantung tombol mana yang ditekan.
  final Function({required PropertyStatus targetStatus}) onSubmit;
  // Callback onEdit dipanggil saat tombol "Edit Ulang (Revisi)" ditekan,
  // biasanya untuk mengubah status di form menjadi draft agar bisa diedit.
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
    // Gaya tombol yang akan digunakan bersama
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFDAF365), // Warna dasar tombol
      foregroundColor: Colors.black87, // Warna teks dasar
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

    // Tombol-tombol hanya akan ditampilkan jika status properti saat ini adalah 'draft' atau 'rejected'.
    // Ini memungkinkan pengguna untuk menyimpan draft lebih lanjut, mengajukan verifikasi, atau memulai revisi.
    if (currentStatus == PropertyStatus.draft || currentStatus == PropertyStatus.rejected) {
      return Column(
        mainAxisSize: MainAxisSize.min, // Agar Column tidak mengambil ruang berlebih
        children: [
          // Bagian ini ditampilkan HANYA JIKA status properti saat ini adalah 'draft'.
          if (currentStatus == PropertyStatus.draft) ...[
            SizedBox(
              width: double.infinity, // Tombol mengambil lebar penuh
              child: ElevatedButton(
                // Saat tombol "Simpan Draft" ditekan:
                // Panggil callback `onSubmit` dengan `targetStatus` diatur ke `PropertyStatus.draft`.
                onPressed: () => onSubmit(targetStatus: PropertyStatus.draft),
                style: buttonStyle.copyWith(
                  backgroundColor: WidgetStateProperty.all(Colors.blueGrey[700]), // Warna spesifik untuk Simpan Draft
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                ),
                child: const Text("Simpan Draft"),
              ),
            ),
            const SizedBox(height: 12), // Jarak antar tombol
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // Saat tombol "Ajukan untuk Verifikasi" ditekan:
                // Panggil callback `onSubmit` dengan `targetStatus` diatur ke `PropertyStatus.pendingVerification`.
                onPressed: () => onSubmit(targetStatus: PropertyStatus.pendingVerification),
                style: buttonStyle, // Menggunakan gaya tombol utama
                child: const Text("Ajukan untuk Verifikasi"),
              ),
            ),
          // Bagian ini ditampilkan HANYA JIKA status properti saat ini adalah 'rejected'.
          ] else if (currentStatus == PropertyStatus.rejected) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // Saat tombol "Edit Ulang (Revisi)" ditekan:
                // Panggil callback `onEdit`. Callback ini biasanya akan mengubah status
                // di form menjadi `PropertyStatus.draft` agar field bisa diedit kembali.
                onPressed: onEdit,
                style: buttonStyle.copyWith(
                  backgroundColor: WidgetStateProperty.all(Colors.orange[700]), // Warna spesifik untuk Revisi
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                ),
                child: const Text("Edit Ulang (Revisi)"),
              ),
            ),
          ],
        ],
      );
    }

    // Jika status properti bukan 'draft' atau 'rejected' (misalnya 'pendingVerification', 'approved', dll.),
    // maka tidak ada tombol aksi yang ditampilkan dari widget ini.
    return const SizedBox.shrink();
  }
}
