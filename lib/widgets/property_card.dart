import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Untuk format harga
import 'package:provider/provider.dart';
import 'package:real/models/property.dart'; // Import model data
import 'package:real/screens/detail/detailpost.dart';
import 'package:real/widgets/bookmark_button.dart'; // Import widget BookmarkButton

class PropertyCard extends StatelessWidget {
  final Property property;
  final bool isHorizontalVariant; // Untuk membedakan card di list horizontal/vertikal jika perlu

  const PropertyCard({
    super.key,
    required this.property,
    this.isHorizontalVariant = true, // Defaultnya untuk list horizontal (featured)
  });

  @override
  Widget build(BuildContext context) {
    // Format harga agar lebih mudah dibaca (misal: $842,00)
    // Pastikan Anda sudah menambahkan package intl: flutter pub add intl
    final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);

    // Tentukan ukuran berdasarkan varian (opsional, jika ingin card berbeda ukuran)
    final cardWidth = isHorizontalVariant ? 320.0 : double.infinity; // Lebar penuh untuk list vertikal
    final imageHeight = isHorizontalVariant ? 160.0 : 180.0; // Contoh tinggi gambar

    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman detail dengan Provider
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider.value(
              value: property, // Kirim data properti ke halaman detail
              child: PropertyDetailPage(property: property),
            ),
          ),
        );
      },
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.only(
          right: isHorizontalVariant ? 15 : 0, // Margin kanan hanya untuk list horizontal
          bottom: isHorizontalVariant ? 0 : 15, // Margin bawah hanya untuk list vertikal
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [ // Beri sedikit bayangan agar 'pop'
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
            // 1. Gambar Properti dengan Bookmark
            Stack(
              children: [
                ClipRRect( // Agar gambar mengikuti border radius container
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Image.network(
                    property.imageUrl, // Ambil URL gambar dari data property
                    height: imageHeight,
                    width: double.infinity, // Lebar penuh container
                    fit: BoxFit.cover, // Agar gambar menutupi area
                    // Error handling jika gambar gagal load
                    errorBuilder: (context, error, stackTrace) => Container(
                       height: imageHeight,
                       color: Colors.grey[300],
                       child: const Center(child: Icon(Icons.broken_image, color: Colors.grey))
                    ),
                    // Loading indicator
                     loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: imageHeight,
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
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

            // Padding untuk konten teks di bawah gambar
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Harga dan Bookmark
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Harga Properti
                      Text(
                        currencyFormatter.format(property.price), // Format harga
                        style: GoogleFonts.poppins(
                          fontSize: 18, // Sesuaikan ukuran
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Ikon Bookmark menggunakan BookmarkButton
                      BookmarkButton(
                        isBookmarked: property.isFavorite, // Menggunakan properti isFavorite
                        onPressed: () {
                          property.toggleFavorite(); // Mengubah status bookmark
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // 3. Alamat
                  Text(
                    '${property.address}, ${property.city}, ${property.stateZip}', // Gabungkan alamat
                    style: GoogleFonts.poppins(
                      fontSize: 12, // Sesuaikan ukuran
                      color: Colors.grey[700],
                    ),
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // 4. Detail (Kamar, dll.) dalam satu baris
                  Row(
                    mainAxisSize: MainAxisSize.min, // Tambahkan ini untuk lebar minimum
                    children: [
                      _buildDetailItem(Icons.king_bed_outlined, '${property.bedrooms} Kamar Tidur'),
                      const SizedBox(width: 10),
                      _buildDetailItem(Icons.bathtub_outlined, '${property.bathrooms} Kamar Mandi'),
                      const SizedBox(width: 10),
                      _buildDetailItem(Icons.straighten_outlined, '${property.areaSqft.toStringAsFixed(0)} sqft'),
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

  // Helper widget kecil untuk item detail (ikon + teks)
  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 10, // Ukuran kecil untuk detail
            color: Colors.grey[700],
             fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
