// lib/widgets/property_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:real/models/property.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:real/provider/property_provider.dart';
import 'package:real/screens/detail/detailpost.dart';
import 'package:real/widgets/bookmark_button.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final bool isHorizontalVariant;

  const PropertyCard({
    super.key,
    required this.property,
    this.isHorizontalVariant = true,
  });

  @override
  Widget build(BuildContext context) { // 'context' tersedia di sini
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final cardWidth = isHorizontalVariant ? 320.0 : double.infinity;
    final imageHeight = isHorizontalVariant ? 160.0 : 180.0;

    return GestureDetector(
      onTap: () async {
        print("PropertyCard diklik, ID properti: ${property.id}");
        final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        showDialog(
          context: context, // 'context' dari build method digunakan di sini
          barrierDismissible: false,
          builder: (BuildContext dialogContext) { // Ini adalah context baru untuk dialog
            return const Center(child: CircularProgressIndicator());
          },
        );

        Property? freshPropertyData = await propertyProvider.fetchPublicPropertyDetail(
          property.id,
          authProvider.token
        );

        if (context.mounted) {
           Navigator.pop(context); // Gunakan 'context' dari build method
        }

        if (freshPropertyData != null && context.mounted) {
          print("Navigating to PropertyDetailPage with fresh data for ${freshPropertyData.id}. Total Views: ${freshPropertyData.viewsCount}");
          Navigator.push(
            context, // 'context' dari build method
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider.value( // Ini 'context' baru dari builder MaterialPageRoute
                   value: freshPropertyData,
                   child: PropertyDetailPage(
                     key: ValueKey(freshPropertyData.id), // <-- TAMBAHKAN KEY UNIK DI SINI
                     property: freshPropertyData,
                   ),
              ),
            ),
          );
        } else if (context.mounted) {
          print("Failed to fetch fresh property data for ${property.id}");
          ScaffoldMessenger.of(context).showSnackBar( // 'context' dari build method
            const SnackBar(content: Text('Gagal memuat detail properti. Coba lagi nanti.')),
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
              color: Colors.grey.withOpacity(0.12),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
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
                  child: (property.imageUrl.isNotEmpty && Uri.tryParse(property.imageUrl)?.isAbsolute == true)
                      ? Image.network(
                          property.imageUrl,
                          height: imageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (imgContext, error, stackTrace) => // 'imgContext' adalah BuildContext dari errorBuilder
                              _imageErrorPlaceholder(imgContext, imageHeight), // Teruskan context
                          loadingBuilder: (imgContext, child, loadingProgress) { // 'imgContext' adalah BuildContext dari loadingBuilder
                            if (loadingProgress == null) return child;
                            return _imageLoadingPlaceholder(imgContext, imageHeight, loadingProgress); // Teruskan context
                          },
                        )
                      : _imageErrorPlaceholder(context, imageHeight, iconSize: 60), // Teruskan context dari build method
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
                    children: [
                      Expanded(
                        child: Text(
                          currencyFormatter.format(property.price),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      BookmarkButton(
                        isBookmarked: property.isFavorite,
                        onPressed: () {
                          property.toggleFavorite();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.address.isNotEmpty ? property.address : "Alamat tidak tersedia",
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildDetailItem(context, Icons.king_bed_outlined, // Teruskan context
                          '${property.bedrooms} Kamar'),
                      _buildDetailSeparator(),
                      _buildDetailItem(context, Icons.bathtub_outlined, // Teruskan context
                          '${property.bathrooms} WC'),
                      _buildDetailSeparator(),
                      _buildDetailItem(context, Icons.aspect_ratio_outlined, // Teruskan context
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

  // --- PERUBAHAN DI SINI: Tambahkan BuildContext context sebagai parameter ---
  Widget _buildDetailItem(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 9.5,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSeparator() {
    return Container(
      height: 10,
      width: 1,
      color: Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  // --- PERUBAHAN DI SINI: Tambahkan BuildContext context sebagai parameter ---
  Widget _imageLoadingPlaceholder(BuildContext context, double height, ImageChunkEvent? loadingProgress){
    return Container(
        height: height,
        width: double.infinity,
        color: Colors.grey[200],
        child: Center(
        child: CircularProgressIndicator(
            value: loadingProgress != null && loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
            strokeWidth: 2.0,
            color: Theme.of(context).primaryColor.withOpacity(0.6), // Sekarang 'context' tersedia
        ),
        ),
    );
  }

  // --- PERUBAHAN DI SINI: Tambahkan BuildContext context sebagai parameter ---
  Widget _imageErrorPlaceholder(BuildContext context, double height, {double iconSize = 50}){
      return Container(
        height: height,
        width: double.infinity,
        color: Colors.grey[200],
        child: Center(
            child: Icon(Icons.apartment_rounded,
                size: iconSize, color: Theme.of(context).disabledColor.withOpacity(0.5))), // Menggunakan Theme untuk warna ikon
    );
  }
}