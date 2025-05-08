// lib/screens/profile/my_property_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal dan mata uang
import 'package:real/models/property.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:real/screens/detail/detailpost.dart'; // Untuk navigasi ke halaman publik
import 'package:real/screens/my_drafts/add_property_form_screen.dart'; // Untuk navigasi ke form edit

class MyPropertyDetailScreen extends StatelessWidget {
  final Property property;

  const MyPropertyDetailScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    // Format mata uang, sesuaikan dengan preferensi Anda (misal 'id_ID' untuk Rupiah)
    final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$ ', decimalDigits: 0);
    // Format tanggal
    final DateFormat dateFormatter = DateFormat('dd MMMM yyyy', 'id_ID'); // Contoh format Indonesia

    return Scaffold(
      backgroundColor: Colors.grey[100], // Warna latar belakang halaman
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          property.title, // Judul properti di AppBar
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18, // Ukuran font disesuaikan
          ),
          overflow: TextOverflow.ellipsis, // Jika judul terlalu panjang
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar Properti
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(
                  property.imageUrl,
                  width: double.infinity,
                  height: 250, // Tinggi gambar bisa disesuaikan
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: const Center(
                        child: Icon(Icons.broken_image,
                            size: 50, color: Colors.grey)),
                  ),
                ),
              ),
            ),

            // 2. Statistik (Bookmark, Dilihat, Pertanyaan) - Rata Kanan
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildStatItem(EvaIcons.bookmark,
                      '${property.bookmarkCount} Dibookmark'),
                  const SizedBox(width: 16),
                  _buildStatItem(
                      EvaIcons.eyeOutline, '${property.viewsCount} Dilihat'),
                  const SizedBox(width: 16),
                  _buildStatItem(EvaIcons.messageCircleOutline,
                      '${property.inquiriesCount} Pertanyaan'),
                ],
              ),
            ),

            // 3. Konten Detail dalam Card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title,
                      style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormatter.format(property.price),
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColorDark), // Gunakan warna tema
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(EvaIcons.pinOutline,
                            color: Colors.grey[700], size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${property.address}, ${property.city}, ${property.stateZip}',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Detail Kamar, Kamar Mandi, Luas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribusi merata
                      children: [
                        _buildFeatureItem(Icons.king_bed_outlined,
                            '${property.bedrooms} Kamar Tidur'),
                        _buildFeatureItem(Icons.bathtub_outlined,
                            '${property.bathrooms} Kamar Mandi'),
                        _buildFeatureItem(Icons.straighten_outlined,
                            '${property.areaSqft.toStringAsFixed(0)} sqft'),
                      ],
                    ),
                    const Divider(height: 32, thickness: 0.7),

                    // Status dan Tanggal
                    _buildInfoRow(
                      "Status Properti:",
                      property.status.toString().split('.').last.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').trim(), // Membuat "pendingVerification" jadi "Pending Verification"
                      chipColor: _getStatusColor(property.status).withOpacity(0.15),
                      textColor: _getStatusColor(property.status),
                      isChip: true,
                    ),
                    if (property.approvalDate != null)
                      _buildInfoRow("Tanggal Tayang:",
                          dateFormatter.format(property.approvalDate!)),
                    if (property.submissionDate != null && property.status == PropertyStatus.pendingVerification)
                       _buildInfoRow("Tanggal Diajukan:",
                          dateFormatter.format(property.submissionDate!)),


                    const SizedBox(height: 16),
                    Text(
                      "Deskripsi",
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      property.description.isEmpty ? "Tidak ada deskripsi." : property.description,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[800],
                          height: 1.5),
                    ),
                    const Divider(height: 32, thickness: 0.7),

                    // Tombol Aksi
                    Text(
                      "Tindakan",
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(EvaIcons.edit2Outline, size: 20),
                        label: Text("Edit Iklan",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddPropertyFormScreen(
                                  propertyToEdit: property),
                            ),
                          ).then((_) {
                            // Anda mungkin ingin refresh data di ProfileScreen jika ada perubahan
                            // Ini bisa dilakukan dengan callback atau state management yang lebih canggih
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary, //Warna Primer
                          foregroundColor: Theme.of(context).colorScheme.onPrimary, // Warna teks di atas primer
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(EvaIcons.externalLinkOutline, size: 20),
                        label: Text("Lihat Halaman Publik",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PropertyDetailPage(property: property),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    // Tambahkan tombol lain jika perlu, misal "Nonaktifkan Iklan"
                    // const SizedBox(height: 12),
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: OutlinedButton.icon(
                    //     icon: const Icon(EvaIcons.powerOutline, size: 20, color: Colors.red),
                    //     label: Text("Nonaktifkan Iklan",
                    //         style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.red)),
                    //     onPressed: () {
                    //       // TODO: Logika untuk menonaktifkan iklan
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //         const SnackBar(content: Text("Fitur Nonaktifkan Iklan belum ada.")),
                    //       );
                    //     },
                    //     style: OutlinedButton.styleFrom(
                    //       side: const BorderSide(color: Colors.red),
                    //       padding: const EdgeInsets.symmetric(vertical: 12),
                    //       shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(10)),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20), // Memberi ruang di bagian bawah
          ],
        ),
      ),
    );
  }

  // Helper widget untuk statistik di atas
  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 16),
        const SizedBox(width: 6), // Jarak antara ikon dan teks
        Text(
          text,
          style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // Helper widget untuk detail fitur (kamar tidur, dll)
  Widget _buildFeatureItem(IconData icon, String text) {
    return Expanded( // Agar setiap item mengambil ruang yang sama
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.grey[800]),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget untuk baris info (status, tanggal)
  Widget _buildInfoRow(String label, String value, {Color? chipColor, Color? textColor, bool isChip = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: isChip && chipColor != null
                  ? Chip(
                      label: Text(value,
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: textColor ?? Colors.black87,
                              fontWeight: FontWeight.w600)),
                      backgroundColor: chipColor,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    )
                  : Text(
                      value,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.approved:
        return Colors.green.shade700;
      case PropertyStatus.pendingVerification:
        return Colors.orange.shade700;
      case PropertyStatus.draft:
        return Colors.blueGrey.shade700;
      case PropertyStatus.rejected:
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}