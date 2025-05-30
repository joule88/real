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

class _MyDraftsScreenState extends State<MyDraftsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 2 Tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAllUserProperties();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllUserProperties() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    final token = authProvider.token;

    if (token != null && mounted) {
      // Fetch semua jenis properti pengguna secara bersamaan
      await Future.wait([
        propertyProvider.fetchUserManageableProperties(token),
        propertyProvider.fetchUserSoldProperties(token),
        propertyProvider.fetchUserApprovedProperties(token), // Untuk refresh ProfileScreen jika ada perubahan dari sini
      ]);
    } else if (token == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi tidak valid. Silakan login ulang.')),
      );
    }
  }

  void _navigateToForm({Property? existingProperty, bool isSold = false}) async {
    final result = await Navigator.push<bool>( 
      context,
      MaterialPageRoute(
        builder: (context) => AddPropertyFormScreen(
          propertyToEdit: existingProperty,
          // Anda bisa menambahkan parameter `isReadOnly` atau `targetStatus` ke AddPropertyFormScreen
          // jika ingin mengontrol perilaku form lebih lanjut berdasarkan tab.
          // Untuk properti sold, form akan read-only.
        ),
      ),
    );

    if (result == true && mounted) { 
      _fetchAllUserProperties(); // Refresh semua list
    }
  }

  String _getStatusText(PropertyStatus status) { /* ... (tetap sama seperti sebelumnya, pastikan ada case sold) ... */ 
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
        String name = status.name;
        return name.replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (Match m) => ' ${m[0]}')
                   .replaceFirstMapped(RegExp(r'^[a-z]'), (m) => m[0]!.toUpperCase());
    }
  }

  Color _getStatusColor(PropertyStatus status) { /* ... (tetap sama seperti sebelumnya, pastikan ada case sold) ... */ 
    switch (status) {
      case PropertyStatus.draft:
        return Colors.blueGrey[600]!;
      case PropertyStatus.pendingVerification:
        return Colors.orange[700]!; 
      case PropertyStatus.approved:
        return Colors.green[600]!;
      case PropertyStatus.rejected:
        return Colors.red[700]!;
      case PropertyStatus.archived: 
        return Colors.grey[700]!;
      case PropertyStatus.sold: 
        return Colors.purple[700]!;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(PropertyStatus status) { /* ... (tetap sama seperti sebelumnya, pastikan ada case sold) ... */ 
    switch (status) {
      case PropertyStatus.draft:
      case PropertyStatus.rejected: 
        return Icons.edit_outlined;
      case PropertyStatus.pendingVerification:
        return Icons.hourglass_top_rounded; 
      case PropertyStatus.approved:
        return Icons.check_circle_outline_rounded;
      case PropertyStatus.archived: 
        return Icons.inventory_2_outlined;
      case PropertyStatus.sold: 
        return Icons.paid_outlined;
      default:
        return Icons.info_outline_rounded; 
    }
  }
  
  Color _getTrailingIconColor(PropertyStatus status) { /* ... (tetap sama seperti sebelumnya) ... */ 
     switch (status) {
      case PropertyStatus.draft:
      case PropertyStatus.rejected:
        return Colors.blueAccent;
      case PropertyStatus.pendingVerification:
        return Colors.orange[700]!;
      case PropertyStatus.approved:
        return Colors.green[600]!;
      case PropertyStatus.archived: 
        return Colors.grey[800]!;
      case PropertyStatus.sold: 
        return Colors.purple[800]!;
      default:
        return Colors.grey[700]!;
    }
  }


  Widget _buildPropertyList(List<Property> properties, String noDataMessage, bool isLoading, String? errorMessage) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Gagal memuat data: $errorMessage', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.red[700])),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Coba Lagi"),
                onPressed: _fetchAllUserProperties,
              )
            ],
          ),
        ),
      );
    }
    if (properties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.layers_clear_outlined, size: 70, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(noDataMessage, style: GoogleFonts.poppins(fontSize: 17, color: Colors.grey[700]), textAlign: TextAlign.center),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchAllUserProperties,
      child: ListView.builder(
        padding: const EdgeInsets.all(15.0),
        itemCount: properties.length,
        itemBuilder: (context, index) {
          final property = properties[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: ClipRRect( /* ... (leading image) ... */ 
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
              title: Text(property.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(_getStatusText(property.status), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white)),
                    backgroundColor: _getStatusColor(property.status),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              trailing: Icon(_getStatusIcon(property.status), color: _getTrailingIconColor(property.status)),
              onTap: () {
                // Untuk properti 'sold', form akan read-only.
                _navigateToForm(existingProperty: property, isSold: property.status == PropertyStatus.sold);
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = Provider.of<PropertyProvider>(context);

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
          "Kelola Iklan Saya",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Theme.of(context).primaryColor,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
          tabs: const [
            Tab(text: "Draft & Arsip"), // Menggabungkan draft, pending, rejected, archived
            Tab(text: "Terjual"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab untuk Draft, Pending, Rejected, Archived
          _buildPropertyList(
            propertyProvider.userProperties, 
            "Tidak ada draft, pengajuan, atau arsip properti.",
            propertyProvider.isLoadingUserProperties,
            propertyProvider.userPropertiesError
          ),
          // Tab untuk Sold
          _buildPropertyList(
            propertyProvider.userSoldProperties,
            "Belum ada properti yang terjual.",
            propertyProvider.isLoadingUserSoldProperties,
            propertyProvider.userSoldPropertiesError
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        backgroundColor: const Color(0xFF1F2937),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text("Iklan Baru", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}