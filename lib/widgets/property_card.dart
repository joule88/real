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
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'ar_AE', symbol: 'AED ', decimalDigits: 0);
    final cardWidth = isHorizontalVariant ? 320.0 : double.infinity;
    final imageHeight = isHorizontalVariant ? 160.0 : 180.0;

    return GestureDetector(
      onTap: () async {
        final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        Property? freshPropertyData = await propertyProvider.fetchPublicPropertyDetail(
          property.id,
          authProvider.token
        );

        if (!context.mounted) return;
        Navigator.pop(context);

        if (freshPropertyData != null) {
          if (!context.mounted) return;
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider.value( 
                  value: freshPropertyData,
                  child: PropertyDetailPage(
                    key: ValueKey(freshPropertyData.id), 
                    property: freshPropertyData,
                  ),
              ),
            ),
          );
        } else {
          if (!context.mounted) return;
          // ENGLISH TRANSLATION
          ScaffoldMessenger.of(context).showSnackBar( 
            const SnackBar(content: Text('Failed to load property details. Please try again later.')),
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
                          errorBuilder: (imgContext, error, stackTrace) =>
                              _imageErrorPlaceholder(imgContext, imageHeight),
                          loadingBuilder: (imgContext, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _imageLoadingPlaceholder(imgContext, imageHeight, loadingProgress);
                          },
                        )
                      : _imageErrorPlaceholder(context, imageHeight, iconSize: 60, customText: "Main image unavailable"), // ENGLISH TRANSLATION
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
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          Provider.of<PropertyProvider>(context, listen: false)
                              .togglePropertyBookmark(property.id, authProvider.token);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // ENGLISH TRANSLATION
                    property.address.isNotEmpty ? property.address : "Address not available",
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
                      // ENGLISH TRANSLATION
                      _buildDetailItem(context, Icons.king_bed_outlined,
                          '${property.bedrooms} Beds'),
                          const SizedBox(width: 12),
                      _buildDetailItem(context, Icons.bathtub_outlined,
                          '${property.bathrooms} Baths'),
                          const SizedBox(width: 12),
                      _buildDetailItem(context, Icons.aspect_ratio_outlined,
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
            // ==========================================================
            //         PERUBAHAN DIMULAI DI SINI
            // ==========================================================
            // Properti 'color' dihapus agar widget menggunakan warna dari tema
            // color: Theme.of(context).primaryColor.withOpacity(0.6), 
            // ==========================================================
            //          PERUBAHAN SELESAI DI SINI
            // ==========================================================
        ),
        ),
    );
  }

  Widget _imageErrorPlaceholder(BuildContext context, double height, {double iconSize = 50, String customText = "Image unavailable"}){
      return Container(
        height: height,
        width: double.infinity,
        color: Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.apartment_rounded,
                  size: iconSize, color: Theme.of(context).disabledColor.withOpacity(0.5)),
              const SizedBox(height: 8),
              Text(customText, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]), textAlign: TextAlign.center),
            ],
          )
        ),
    );
  }
}