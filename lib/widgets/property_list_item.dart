import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real/models/property.dart'; // Import model
import 'bookmark_button.dart'; // Import BookmarkButton

class PropertyListItem extends StatelessWidget {
  final Property property;

  const PropertyListItem({
    super.key,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);
    const double imageSize = 80.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Rata atas
        children: [
          // 1. Gambar Kecil
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              property.imageUrl,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                  width: imageSize,
                  height: imageSize,
                  color: Colors.grey[300],
                  child: const Center(
                      child: Icon(Icons.broken_image,
                          size: 30, color: Colors.grey))),
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: imageSize,
                  height: imageSize,
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
          const SizedBox(width: 12),

          // 2. Detail Teks (Kolom Kanan)
          Expanded(
            // Agar teks mengisi sisa ruang
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Harga
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currencyFormatter.format(property.price),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Ikon Bookmark dengan animasi
                    BookmarkButton(
                      isBookmarked: property.isFavorite,
                      onPressed: () {
                        property.toggleFavorite(); // Mengubah status bookmark
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Alamat
                Text(
                  '${property.address}, ${property.city}, ${property.stateZip}',
                  style: GoogleFonts.poppins(
                    fontSize: 11, // Lebih kecil
                    color: Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Detail Kamar/Luas (Mirip PropertyCard tapi mungkin lebih kecil)
                Row(
                  children: [
                    _buildDetailItem(Icons.king_bed_outlined,
                        ' ${property.bedrooms}'), // Singkat
                    const SizedBox(width: 8), // Jarak antar detail
                    _buildDetailItem(Icons.bathtub_outlined,
                        ' ${property.bathrooms}'), // Singkat
                    const SizedBox(width: 8),
                    _buildDetailItem(Icons.straighten_outlined,
                        '${property.areaSqft.toStringAsFixed(0)} sqft'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget kecil untuk item detail (ikon + teks) - bisa disamakan/diambil dari property_card
  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey[600]), // Icon lebih kecil
        const SizedBox(width: 3),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 9, // Font lebih kecil
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
