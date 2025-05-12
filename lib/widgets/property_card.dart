import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:real/models/property.dart';
import 'package:real/screens/detail/detailpost.dart';
import 'package:real/widgets/bookmark_button.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final bool
      isHorizontalVariant;
  final bool showEditIcon;
  final VoidCallback? onEditPressed;

  const PropertyCard({
    super.key,
    required this.property,
    this.isHorizontalVariant = true,
    this.showEditIcon = false, // Defaultnya false, jadi tetap ikon bookmark
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);

    final cardWidth = isHorizontalVariant ? 320.0 : double.infinity;
    final imageHeight = isHorizontalVariant ? 160.0 : 180.0;

    return GestureDetector(
      onTap: () {
        if (showEditIcon && onEditPressed != null) {
          // Jika ini adalah mode edit dan ada callback, panggil callback edit
          onEditPressed!();
        } else {
          // Perilaku default: navigasi ke halaman detail
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider.value(
                value: property,
                child: PropertyDetailPage(property: property),
              ),
            ),
          );
        }
      },
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
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
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
                            child: Icon(Icons.broken_image,
                                color: Colors.grey))),
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
                // Bagian ini tidak lagi diperlukan jika ikon bookmark/edit ada di bawah
                // Positioned(
                //   top: 8,
                //   right: 8,
                //   child: showEditIcon
                //       ? IconButton(
                //           icon: Icon(EvaIcons.editOutline, color: Colors.white, size: 28),
                //           onPressed: onEditPressed ?? () {
                //             // TODO: Implementasi aksi edit
                //             print("Edit property: ${property.title}");
                //           },
                //         )
                //       : BookmarkButton(
                //           isBookmarked: property.isFavorite,
                //           onPressed: () {
                //             property.toggleFavorite();
                //           },
                //         ),
                // ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded( // Agar harga tidak overflow jika terlalu panjang
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
                      // Tampilkan ikon Edit atau Bookmark berdasarkan showEditIcon
                      if (showEditIcon)
                        GestureDetector(
                          onTap: onEditPressed ??
                              () {
                                // TODO: Implementasi aksi default jika onEditPressed null
                                // Misalnya navigasi ke halaman edit properti
                                print("Edit property: ${property.title}");
                                // Contoh navigasi (buat halaman EditPropertyScreen nanti)
                                // Navigator.push(context, MaterialPageRoute(builder: (context) => EditPropertyScreen(property: property)));
                              },
                          child: const Icon(
                            EvaIcons.editOutline, // Atau Icons.edit
                            color: Colors.black,
                            size: 26,
                          ),
                        )
                      else
                        BookmarkButton(
                          isBookmarked: property.isFavorite,
                          onPressed: () {
                            // Akses Provider untuk toggle favorite jika menggunakan Provider
                            // Provider.of<PropertyProvider>(context, listen: false).toggleFavorite(property.id);
                            // Jika tidak, panggil langsung method di model (seperti yang sudah ada)
                            property.toggleFavorite();
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDetailItem(Icons.king_bed_outlined,
                          '${property.bedrooms} Kamar Tidur'),
                      const SizedBox(width: 10),
                      _buildDetailItem(Icons.bathtub_outlined,
                          '${property.bathrooms} Kamar Mandi'),
                      const SizedBox(width: 10),
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