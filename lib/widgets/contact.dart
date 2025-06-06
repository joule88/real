// lib/widgets/contact.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real/models/user_model.dart'; // Import User model
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'package:cached_network_image/cached_network_image.dart'; // Import cached_network_image

class ContactAgentWidget extends StatelessWidget {
  final User? owner; // Changed to User?

  const ContactAgentWidget({super.key, required this.owner});

  Future<void> _launchWhatsApp(BuildContext context, String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        // ENGLISH TRANSLATION
        const SnackBar(content: Text('Owner\'s WhatsApp number is not available.')),
      );
      return;
    }

    // Basic phone number cleaning:
    String cleanedPhone = phoneNumber.replaceAll(RegExp(r'\D'), ''); // Remove all non-digits
    if (cleanedPhone.startsWith('0')) {
      cleanedPhone = '62${cleanedPhone.substring(1)}'; // Replace leading 0 with 62 (for Indonesia)
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
            // ENGLISH TRANSLATION
            const SnackBar(content: Text('Could not open WhatsApp. Please ensure it is installed.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            // ENGLISH TRANSLATION
            SnackBar(content: Text('Error opening WhatsApp: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (owner == null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFFDDEF6D),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            // ENGLISH TRANSLATION
            "Owner information is not available.",
            style: GoogleFonts.poppins(color: Colors.black54),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFDDEF6D),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // ENGLISH TRANSLATION
                  owner!.name.isNotEmpty ? owner!.name : "Property Owner",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (owner!.bio.isNotEmpty) ...[
                  Text(
                    owner!.bio,
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else ...[
                  Text(
                    // ENGLISH TRANSLATION
                    "Property Agent",
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.chat_bubble_outline, size: 22, color: Colors.black54),
            onPressed: () => _launchWhatsApp(context, owner!.phone),
            // ENGLISH TRANSLATION
            tooltip: 'Contact via WhatsApp',
          ),
        ],
      ),
    );
  }
}