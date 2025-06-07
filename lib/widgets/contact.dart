// lib/widgets/contact.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real/models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ContactAgentWidget extends StatelessWidget {
  final User? owner;

  const ContactAgentWidget({super.key, required this.owner});

  Future<void> _launchWhatsApp(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Owner\'s WhatsApp number is not available.')),
      );
      return;
    }

    String cleanedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (cleanedPhone.startsWith('0')) {
      cleanedPhone = '62${cleanedPhone.substring(1)}';
    } else if (!cleanedPhone.startsWith('62')) {
      if (cleanedPhone.length >= 9 && cleanedPhone.length <= 13 && !cleanedPhone.startsWith('+')) {
         // This logic is specific to Indonesian numbers
      }
    }
    cleanedPhone = cleanedPhone.replaceAll('+', '');

    final Uri whatsappUri = Uri.parse('https://wa.me/$cleanedPhone');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open WhatsApp. Please ensure it is installed.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening WhatsApp: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (owner == null) {
      // Tampilan jika owner tidak ada, dibuat semi-transparan juga
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            "Owner information is not available.",
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
        ),
      );
    }

    // ==========================================================
    //         PERUBAHAN TAMPILAN DIMULAI DI SINI
    // ==========================================================
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF182420).withOpacity(0.9), // Latar belakang gelap semi-transparan
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[700],
            child: owner!.profileImage.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: owner!.profileImage,
                      placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      errorWidget: (context, url, error) => const Icon(Icons.person_outline, size: 20, color: Colors.white70),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.person_outline, size: 20, color: Colors.white70),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  owner!.name.isNotEmpty ? owner!.name : "Property Owner",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white), // Warna teks diubah
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  owner!.bio.isNotEmpty ? owner!.bio : "Property Agent",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.8)), // Warna teks diubah
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, size: 24, color: Color(0xFFDDEF6D)), // Warna ikon diubah
            onPressed: () => _launchWhatsApp(context, owner!.phone),
            tooltip: 'Contact via WhatsApp',
          ),
        ],
      ),
    );
    // ==========================================================
    //          PERUBAHAN TAMPILAN SELESAI DI SINI
    // ==========================================================
  }
}