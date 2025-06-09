// lib/widgets/property_card_profile.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real/models/property.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

class PropertyCardProfile extends StatelessWidget {
  final Property property;
  final bool isHorizontalVariant;
  final bool showEditIcon;
  final VoidCallback? onTap;

  const PropertyCardProfile({
    super.key,
    required this.property,
    this.isHorizontalVariant = true,
    this.showEditIcon = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'ar_AE', symbol: 'AED ', decimalDigits: 0);

    final cardWidth = isHorizontalVariant ? 320.0 : double.infinity;
    final imageHeight = isHorizontalVariant ? 160.0 : 180.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.only(
          right: isHorizontalVariant ? 15 : 0,
          bottom: isHorizontalVariant ? 0 : 15,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Image.network(
                    property.imageUrl,
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                        height: imageHeight,
                        color: Colors.grey[300],
                        child: const Center(
                            child:
                                Icon(Icons.broken_image, color: Colors.grey))),
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: imageHeight,
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment
                        .start,
                    children: [
                      Expanded(
                        child: Text(
                          currencyFormatter.format(property.price),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // ==========================================================
                      //         PERUBAHAN DIMULAI DI SINI
                      // ==========================================================
                      if (showEditIcon)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(
                            EvaIcons.editOutline,
                            color: Colors.black,
                            size: 24,
                          ),
                        )
                      // Blok "else" yang berisi BookmarkButton telah dihapus
                      // ==========================================================
                      //          PERUBAHAN SELESAI DI SINI
                      // ==========================================================
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.address,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildDetailItem(Icons.king_bed_outlined,
                          '${property.bedrooms} Beds'),
                      const SizedBox(width: 12),
                      _buildDetailItem(Icons.bathtub_outlined,
                          '${property.bathrooms} Baths'),
                      const SizedBox(width: 12),
                      _buildDetailItem(Icons.straighten_outlined,
                          '${property.areaSqft.toStringAsFixed(0)} sqft'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}