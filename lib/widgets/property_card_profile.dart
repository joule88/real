// lib/widgets/property_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
// Tetap perlukan ini jika BookmarkButton pakai Provider
import 'package:real/models/property.dart';
// import 'package:real/screens/detail/detailpost.dart'; // Hapus import ini
import 'package:real/widgets/bookmark_button.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
// Import halaman edit jika ikon edit ingin langsung navigasi
// import 'package:real/screens/my_drafts/add_property_form_screen.dart';

class PropertyCardProfile extends StatelessWidget {
  final Property property;
  final bool isHorizontalVariant;
  final bool showEditIcon;
  // final VoidCallback? onEditPressed; // Bisa dihapus jika tap ikon edit juga pakai onTap umum
  final VoidCallback? onTap; // <<-- TAMBAHKAN Parameter callback onTap

  const PropertyCardProfile({
    super.key,
    required this.property,
    this.isHorizontalVariant = true,
    this.showEditIcon = false,
    // this.onEditPressed,
    this.onTap, // <<-- Tambahkan di konstruktor
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
        locale: 'en_US',
        symbol: '\$ ',
        decimalDigits: 0); // Sesuaikan locale/simbol jika perlu

    final cardWidth = isHorizontalVariant ? 320.0 : double.infinity;
    final imageHeight = isHorizontalVariant ? 160.0 : 180.0;

    // --- PERUBAHAN DI SINI ---
    return GestureDetector(
      onTap: onTap, // Gunakan callback onTap yang di-pass dari luar
      // --- AKHIR PERUBAHAN ---
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
                  Colors.grey.withOpacity(0.15), // Shadow sedikit lebih halus
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
                        .start, // Agar ikon sejajar atas dengan harga
                    children: [
                      Expanded(
                        // Harga
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
                      // Ikon Bookmark atau Edit (JANGAN pasang onTap di sini jika sudah ada di GestureDetector luar)
                      if (showEditIcon)
                        Padding(
                          // Beri sedikit padding agar tidak terlalu mepet
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(
                            EvaIcons.editOutline,
                            color: Colors.black,
                            size: 24, // Sedikit lebih kecil mungkin?
                          ),
                        )
                      else
                        // BookmarkButton bisa tetap pakai logic internalnya atau diubah juga
                        BookmarkButton(
                          isBookmarked: property.isFavorite,
                          onPressed: () {
                            // Idealnya, aksi bookmark juga dikelola di level state yang lebih tinggi
                            // Tapi untuk sementara, toggle lokal bisa jalan
                            property.toggleFavorite();
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // Alamat
                    '${property.address}, ${property.city}, ${property.stateZip}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    // Detail Kamar, dll.
                    mainAxisAlignment: MainAxisAlignment.start, // Rata kiri
                    children: [
                      _buildDetailItem(Icons.king_bed_outlined,
                          '${property.bedrooms}'), // Lebih singkat
                      const SizedBox(width: 12), // Jarak antar detail
                      _buildDetailItem(Icons.bathtub_outlined,
                          '${property.bathrooms}'), // Lebih singkat
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
