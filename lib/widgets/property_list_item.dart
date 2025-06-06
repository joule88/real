// lib/widgets/property_list_item.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:real/models/property.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:real/provider/property_provider.dart';
import 'package:real/widgets/bookmark_button.dart';

// Tetap menggunakan StatefulWidget karena ini adalah kunci keberhasilan reaktivitasnya
class PropertyListItem extends StatefulWidget {
  final Property property;

  const PropertyListItem({
    super.key,
    required this.property,
  });

  @override
  State<PropertyListItem> createState() => _PropertyListItemState();
}

class _PropertyListItemState extends State<PropertyListItem> {
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.property.isFavorite;
  }

  @override
  void didUpdateWidget(covariant PropertyListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.property.isFavorite != _isBookmarked) {
      setState(() {
        _isBookmarked = widget.property.isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'ar_AE', symbol: 'AED ', decimalDigits: 0);
    const double imageSize = 80.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        // ==========================================================
        //         PERUBAHAN TAMPILAN KEMBALI KE SEMULA
        // ==========================================================
        color: Colors.white, // Selalu putih
        borderRadius: BorderRadius.circular(10),
        // Properti border dihapus, hanya menyisakan shadow
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        // ==========================================================
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.property.imageUrl,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                  width: imageSize,
                  height: imageSize,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.broken_image, size: 30, color: Colors.grey))),
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: imageSize,
                  height: imageSize,
                  color: Colors.grey[300],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        currencyFormatter.format(widget.property.price),
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    BookmarkButton(
                      isBookmarked: _isBookmarked,
                      onPressed: () {
                        setState(() {
                          _isBookmarked = !_isBookmarked;
                        });

                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        Provider.of<PropertyProvider>(context, listen: false).togglePropertyBookmark(widget.property.id, authProvider.token);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.property.address.isNotEmpty ? widget.property.address : "Alamat tidak tersedia",
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildDetailItem(Icons.king_bed_outlined, ' ${widget.property.bedrooms} Beds'),
                    const SizedBox(width: 8),
                    _buildDetailItem(Icons.bathtub_outlined, ' ${widget.property.bathrooms} Baths'),
                    const SizedBox(width: 8),
                    _buildDetailItem(Icons.straighten_outlined, '${widget.property.areaSqft.toStringAsFixed(0)} sqft'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey[600]),
        const SizedBox(width: 3),
        Text(
          text,
          style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey[700], fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}