// lib/widgets/property_action_buttons.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real/models/property.dart';

class PropertyActionButtons extends StatelessWidget {
  final bool isLoading;
  final PropertyStatus currentStatus;
  final Function({required PropertyStatus targetStatus}) onSubmit;
  final VoidCallback onEdit; // For 'rejected' -> 'draft' status

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

    // Logic for DRAFT status
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
            // ENGLISH TRANSLATION
            child: const Text("Save Draft"),
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
            // ENGLISH TRANSLATION
            child: const Text("Submit for Verification"),
          ),
        ),
      );
    }
    // Logic for REJECTED status
    else if (currentStatus == PropertyStatus.rejected) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onEdit, // This will change _currentStatus in the form to draft
            style: baseButtonStyle.copyWith(
              backgroundColor: WidgetStateProperty.all(Colors.orange[700]),
              foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
            // ENGLISH TRANSLATION
            child: const Text("Revise & Resubmit"),
          ),
        ),
      );
    }
    // Logic for ARCHIVED status
    else if (currentStatus == PropertyStatus.archived) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => onSubmit(targetStatus: PropertyStatus.approved), // Directly change to approved
            style: baseButtonStyle.copyWith(
               backgroundColor: WidgetStateProperty.all(Colors.green[600]),
               foregroundColor: WidgetStateProperty.all(Colors.white),
            ),
            // ENGLISH TRANSLATION
            child: const Text("Re-list Property"),
          ),
        ),
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: buttons,
    );
  }
}