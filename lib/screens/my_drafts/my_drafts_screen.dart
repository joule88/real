// lib/screens/my_drafts/my_drafts_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:real/models/property.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:real/provider/property_provider.dart';
import 'package:real/screens/my_drafts/add_property_form_screen.dart';

class MyDraftsScreen extends StatefulWidget {
  const MyDraftsScreen({super.key});

  @override
  State<MyDraftsScreen> createState() => _MyDraftsScreenState();
}

class _MyDraftsScreenState extends State<MyDraftsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMyDrafts();
    });
  }

  Future<void> _fetchMyDrafts() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token != null && mounted) { // Tambahkan cek mounted
      // Panggil metode dari PropertyProvider
      await Provider.of<PropertyProvider>(context, listen: false)
          .fetchUserDraftAndPendingProperties(token);
    } else if (token == null && mounted) { // Tambahkan cek mounted
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi tidak valid. Silakan login ulang.')),
      );
    }
  }

  void _navigateToForm({Property? existingProperty}) async {
    final result = await Navigator.push<bool>( 
      context,
      MaterialPageRoute(
        builder: (context) => AddPropertyFormScreen(propertyToEdit: existingProperty),
      ),
    );

    if (result == true && mounted) { 
      _fetchMyDrafts();
    }
  }

  String _getStatusText(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.draft:
        return 'Draft';
      case PropertyStatus.pendingVerification:
        return 'Menunggu Verifikasi';
      case PropertyStatus.approved:
        return 'Disetujui';
      case PropertyStatus.rejected:
        return 'Ditolak';
      case PropertyStatus.sold:
        return 'Terjual';
      case PropertyStatus.archived:
        return 'Diarsipkan';
      default:
        // Menggunakan e.name untuk mendapatkan nama enum tanpa prefix kelas
        // dan menambahkan spasi sebelum huruf kapital untuk keterbacaan.
        String name = status.name;
        return name.replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (Match m) => ' ${m[0]}')
                   .replaceFirstMapped(RegExp(r'^[a-z]'), (m) => m[0]!.toUpperCase());
    }
  }

  Color _getStatusColor(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.draft:
        return Colors.blueGrey[600]!;
      case PropertyStatus.pendingVerification:
        return Colors.orange[700]!; 
      case PropertyStatus.approved:
        return Colors.green[600]!;
      case PropertyStatus.rejected:
        return Colors.red[700]!;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.draft:
      case PropertyStatus.rejected: 
        return Icons.edit_outlined;
      case PropertyStatus.pendingVerification:
        return Icons.hourglass_top_rounded; 
      case PropertyStatus.approved:
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.info_outline_rounded; 
    }
  }

  Color _getTrailingIconColor(PropertyStatus status) {
     switch (status) {
      case PropertyStatus.draft:
      case PropertyStatus.rejected:
        return Colors.blueAccent;
      case PropertyStatus.pendingVerification:
        return Colors.orange[700]!;
      case PropertyStatus.approved:
        return Colors.green[600]!;
      default:
        return Colors.grey[700]!;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<PropertyProvider>(
      builder: (context, propertyProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              "Draft & Pengajuan Saya",
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
          ),
          body: propertyProvider.isLoadingUserProperties
              ? const Center(child: CircularProgressIndicator())
              : propertyProvider.userPropertiesError != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column( // Bungkus dengan Column untuk tombol refresh
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Gagal memuat data: ${propertyProvider.userPropertiesError}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(color: Colors.red[700]),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text("Coba Lagi"),
                              onPressed: _fetchMyDrafts,
                            )
                          ],
                        ),
                      ),
                    )
                  : propertyProvider.userProperties.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.note_add_outlined, size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 20),
                              Text(
                                "Belum ada draft atau pengajuan.",
                                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Buat properti baru sekarang!",
                                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 30),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add_circle_outline),
                                label: Text("Buat Iklan Baru", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                onPressed: () => _navigateToForm(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDAF365),
                                  foregroundColor: Colors.black87,
                                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                  textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchMyDrafts,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(15.0),
                            itemCount: propertyProvider.userProperties.length,
                            itemBuilder: (context, index) {
                              final property = propertyProvider.userProperties[index];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.only(bottom: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: property.imageUrl.isNotEmpty
                                      ? Image.network(
                                          property.imageUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)),
                                        )
                                      : Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.house_outlined, color: Colors.grey, size: 40)),
                                  ),
                                  title: Text(property.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis,),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(property.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
                                      const SizedBox(height: 4),
                                      Chip(
                                        label: Text(
                                          _getStatusText(property.status),
                                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white)
                                        ),
                                        backgroundColor: _getStatusColor(property.status),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    _getStatusIcon(property.status),
                                    color: _getTrailingIconColor(property.status),
                                  ),
                                  onTap: () {
                                    _navigateToForm(existingProperty: property);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
          floatingActionButton: propertyProvider.isLoadingUserProperties || propertyProvider.userProperties.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _navigateToForm(),
                  backgroundColor: const Color(0xFF1F2937),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text("Iklan Baru", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
        );
      },
    );
  }
}
