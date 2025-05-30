// lib/screens/profile/my_property_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:real/models/property.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:real/provider/auth_provider.dart'; // Import AuthProvider
import 'package:real/provider/property_provider.dart'; // Import PropertyProvider
import 'package:real/screens/detail/detailpost.dart';
import 'package:real/screens/my_drafts/add_property_form_screen.dart';
// lib/screens/profile/my_property_detail_screen.dart


class MyPropertyDetailScreen extends StatelessWidget {
  final Property property;

  const MyPropertyDetailScreen({super.key, required this.property});

  Future<void> _showConfirmationDialog( 
    // ... (method _showConfirmationDialog tetap sama) ...
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(content, style: GoogleFonts.poppins()),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal', style: GoogleFonts.poppins(color: Colors.grey[700])),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              child: Text('Konfirmasi', style: GoogleFonts.poppins(color: Colors.white)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // ... (formatter dan provider tetap sama) ...
    final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$ ', decimalDigits: 0);
    final DateFormat dateFormatter = DateFormat('dd MMMM yyyy', 'id_ID');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);

    return Scaffold(
      // ... (AppBar dan bagian atas body tetap sama) ...
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          property.title,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (Gambar, Statistik, Detail Konten Card tetap sama) ...
             Padding( 
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(
                  property.imageUrl,
                  width: double.infinity,
                  height: 250,
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
                    // ... (Detail judul, harga, alamat, fitur, status, deskripsi tetap sama) ...
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
                          color: Theme.of(context).primaryColorDark),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(EvaIcons.pinOutline, color: Colors.grey[700], size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            property.address,
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                    _buildInfoRow(
                      "Status Properti:",
                      property.status.toString().split('.').last.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}').trim(),
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

                    Text(
                      "Tindakan",
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    // Tombol Edit Iklan
                    if (property.status == PropertyStatus.approved || property.status == PropertyStatus.draft || property.status == PropertyStatus.rejected)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(EvaIcons.edit2Outline, size: 20),
                          label: Text("Edit Iklan", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddPropertyFormScreen(propertyToEdit: property),
                              ),
                            ).then((updated) async { // Tambah async
                               if (updated == true && context.mounted) {
                                  if (authProvider.token != null) {
                                    // Refresh semua list yang mungkin terdampak
                                    await propertyProvider.fetchUserApprovedProperties(authProvider.token!);
                                    await propertyProvider.fetchUserManageableProperties(authProvider.token!);
                                    await propertyProvider.fetchUserSoldProperties(authProvider.token!);
                                  }
                                  Navigator.pop(context); 
                                }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    if (property.status == PropertyStatus.approved || property.status == PropertyStatus.draft || property.status == PropertyStatus.rejected)
                        const SizedBox(height: 12),
                    
                    // Tombol Lihat Halaman Publik
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(EvaIcons.externalLinkOutline, size: 20),
                        label: Text("Lihat Halaman Publik", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PropertyDetailPage(property: property)),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tombol Arsipkan Iklan (Hanya muncul jika status 'approved')
                    if (property.status == PropertyStatus.approved)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.archive_outlined, size: 20, color: Colors.orange.shade800),
                          label: Text("Arsipkan Iklan", style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.orange.shade800)),
                          onPressed: () {
                            _showConfirmationDialog(
                              context,
                              title: "Arsipkan Properti?",
                              content: "Properti ini akan dipindahkan ke arsip dan tidak akan tampil di publik. Anda bisa mengaktifkannya kembali nanti.",
                              onConfirm: () async {
                                if (authProvider.token != null) {
                                  final result = await propertyProvider.updatePropertyStatus(
                                    property.id, 
                                    PropertyStatus.archived, 
                                    authProvider.token!
                                  );
                                  if (context.mounted) {
                                    if (result['success'] == true) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Properti berhasil diarsipkan.'), backgroundColor: Colors.green),
                                      );
                                      // Refresh list yang relevan
                                      await propertyProvider.fetchUserApprovedProperties(authProvider.token!);
                                      await propertyProvider.fetchUserManageableProperties(authProvider.token!);
                                      Navigator.pop(context); // Kembali 
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Gagal mengarsipkan properti: ${result['message']}')),
                                      );
                                    }
                                  }
                                }
                              }
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.orange.shade700),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    if (property.status == PropertyStatus.approved) const SizedBox(height: 12),

                    // --- TOMBOL BARU: Tandai sebagai Terjual ---
                    // Hanya muncul jika status 'approved'
                    if (property.status == PropertyStatus.approved)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.paid_outlined, size: 20, color: Theme.of(context).colorScheme.onPrimary),
                          label: Text("Tandai sebagai Terjual", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          onPressed: () {
                            _showConfirmationDialog(
                              context,
                              title: "Tandai Properti Terjual?",
                              content: "Status properti akan diubah menjadi 'Terjual'. Properti ini tidak akan tampil di publik lagi. Anda yakin?",
                              onConfirm: () async {
                                if (authProvider.token != null) {
                                  final result = await propertyProvider.updatePropertyStatus(
                                    property.id,
                                    PropertyStatus.sold, // Status baru adalah 'sold'
                                    authProvider.token!
                                  );
                                  if (context.mounted) {
                                    if (result['success'] == true) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Properti berhasil ditandai terjual.'), backgroundColor: Colors.green),
                                      );
                                      // Refresh list yang relevan
                                      await propertyProvider.fetchUserApprovedProperties(authProvider.token!);
                                      await propertyProvider.fetchUserSoldProperties(authProvider.token!); // Fetch list sold
                                      Navigator.pop(context); // Kembali 
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Gagal menandai properti terjual: ${result['message']}')),
                                      );
                                    }
                                  }
                                }
                              }
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade600, // Warna untuk tombol "Sold"
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    // --- AKHIR TOMBOL BARU ---
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) { /* ... (tetap sama) ... */ 
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 16),
        const SizedBox(width: 6),
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

  Widget _buildFeatureItem(IconData icon, String text) { /* ... (tetap sama) ... */ 
    return Expanded( 
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

  Widget _buildInfoRow(String label, String value, {Color? chipColor, Color? textColor, bool isChip = false}) { /* ... (tetap sama) ... */ 
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

  Color _getStatusColor(PropertyStatus status) { /* ... (sudah diupdate sebelumnya) ... */ 
    switch (status) {
      case PropertyStatus.approved:
        return Colors.green.shade700;
      case PropertyStatus.pendingVerification:
        return Colors.orange.shade700;
      case PropertyStatus.draft:
        return Colors.blueGrey.shade700;
      case PropertyStatus.rejected:
        return Colors.red.shade700;
      case PropertyStatus.archived: 
        return Colors.grey.shade700;
      case PropertyStatus.sold: 
        return Colors.purple.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}