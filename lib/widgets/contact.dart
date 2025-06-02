// lib/widgets/contact_agent_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real/models/user_model.dart'; // Impor User model
import 'package:url_launcher/url_launcher.dart'; // Impor url_launcher
import 'package:cached_network_image/cached_network_image.dart'; // Impor cached_network_image

class ContactAgentWidget extends StatelessWidget {
  final User? owner; // Ubah menjadi User?

  const ContactAgentWidget({super.key, required this.owner});

  Future<void> _launchWhatsApp(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor WhatsApp pemilik tidak tersedia.')),
      );
      return;
    }

    // Pembersihan dasar nomor telepon:
    String cleanedPhone = phoneNumber.replaceAll(RegExp(r'\D'), ''); // Hapus semua selain digit
    if (cleanedPhone.startsWith('0')) {
      cleanedPhone = '62${cleanedPhone.substring(1)}'; // Ganti 0 di depan dengan 62 (untuk Indonesia)
    } else if (!cleanedPhone.startsWith('62')) {
      // Jika nomor tidak diawali 0 atau 62, mungkin sudah format internasional atau butuh kode negara.
      // Untuk Indonesia, jika nomornya adalah 8xxxxxxxx, tambahkan 62.
      if (cleanedPhone.length >= 9 && cleanedPhone.length <= 13 && !cleanedPhone.startsWith('+')) {
         // Cukup berisiko jika tidak ada standar, tapi ini salah satu pendekatan
         // cleanedPhone = '62$cleanedPhone';
      }
    }
    // Pastikan tidak ada '+' atau spasi
    cleanedPhone = cleanedPhone.replaceAll('+', '');

    final Uri whatsappUri = Uri.parse('https://wa.me/$cleanedPhone');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka WhatsApp. Pastikan aplikasi terinstal.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error membuka WhatsApp: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fallback UI jika data pemilik tidak ada
    if (owner == null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 60, // Kembalikan tinggi semula
        decoration: BoxDecoration(
          color: const Color(0xFFDDEF6D), // Warna asli
          borderRadius: BorderRadius.circular(10), // Radius asli
        ),
        child: Center(
          child: Text(
            "Informasi pemilik tidak tersedia.",
            style: GoogleFonts.poppins(color: Colors.black54), // Pastikan teks terbaca
          ),
        ),
      );
    }

    // UI utama jika data pemilik ada
    return Container(
      margin: const EdgeInsets.all(16), // Margin asli dari file Anda
      padding: const EdgeInsets.symmetric(horizontal: 16), // Padding asli
      height: 60, // Tinggi asli dari file Anda (bisa disesuaikan jika bio panjang)
      decoration: BoxDecoration(
        color: const Color(0xFFDDEF6D), // Warna utama dikembalikan
        borderRadius: BorderRadius.circular(10), // Radius asli
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20, // Radius asli
            backgroundColor: Colors.grey[300],
            child: owner!.profileImage.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: owner!.profileImage,
                      placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                      errorWidget: (context, url, error) => const Icon(Icons.person_outline, size: 20, color: Colors.black54),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.person_outline, size: 20, color: Colors.black54),
          ),
          const SizedBox(width: 12), // Jarak asli
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  owner!.name.isNotEmpty ? owner!.name : "Pemilik Properti",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87), // Warna teks disesuaikan
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (owner!.bio.isNotEmpty) ...[
                  Text(
                    owner!.bio,
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54), // Warna teks disesuaikan
                    maxLines: 1, // Batasi bio agar pas di height 60
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else ...[
                  Text(
                    "Agen Properti",
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54), // Warna teks disesuaikan
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.chat_bubble_outline, size: 22, color: Colors.black54), // Warna ikon disesuaikan
            onPressed: () => _launchWhatsApp(context, owner!.phone),
            tooltip: 'Hubungi via WhatsApp',
          ),
        ],
      ),
    );
  }
}
