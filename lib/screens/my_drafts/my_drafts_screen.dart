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

  static const Color colorNavbarBg = Color(0xFF182420);
  static const Color colorLemonGreen = Color(0xFFDDEF6D);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      await Future.wait([
        propertyProvider.fetchUserManageableProperties(token),
        propertyProvider.fetchUserSoldProperties(token),
        propertyProvider.fetchUserApprovedProperties(token),
      ]);
    } else if (token == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        // ENGLISH TRANSLATION
        const SnackBar(content: Text('Invalid session. Please log in again.')),
      );
    }
  }

  void _navigateToForm({Property? existingProperty, bool isSold = false}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddPropertyFormScreen(
          propertyToEdit: existingProperty,
        ),
      ),
    );

    if (result == true && mounted) {
      _fetchAllUserProperties();
    }
  }

  String _getStatusText(PropertyStatus status) {
    // ENGLISH TRANSLATION
    switch (status) {
      case PropertyStatus.draft:
        return 'Draft';
      case PropertyStatus.pendingVerification:
        return 'Pending Verification';
      case PropertyStatus.approved:
        return 'Approved';
      case PropertyStatus.rejected:
        return 'Rejected';
      case PropertyStatus.sold:
        return 'Sold';
      case PropertyStatus.archived:
        return 'Archived';
      default:
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
        return colorLemonGreen;
      case PropertyStatus.approved:
        return Colors.green[600]!;
      case PropertyStatus.rejected:
        return Colors.red[700]!;
      case PropertyStatus.archived:
        return Colors.grey[700]!;
      case PropertyStatus.sold:
        return colorNavbarBg;
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
        return Icons.hourglass_empty_rounded;
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

  Color _getTrailingIconColor(PropertyStatus status) {
     switch (status) {
      case PropertyStatus.draft:
      case PropertyStatus.rejected:
        return Colors.blueAccent.shade700;
      case PropertyStatus.pendingVerification:
        return colorNavbarBg;
      case PropertyStatus.approved:
        return Colors.green.shade700;
      case PropertyStatus.archived:
        return Colors.grey.shade800;
      case PropertyStatus.sold:
        return colorNavbarBg;
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
              // ENGLISH TRANSLATION
              Text('Failed to load data: $errorMessage', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.red[700])),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                // ENGLISH TRANSLATION
                label: const Text("Try Again"),
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
          final Color chipTextColor;
          if (property.status == PropertyStatus.sold) {
            chipTextColor = colorLemonGreen;
          } else if (property.status == PropertyStatus.pendingVerification) {
            chipTextColor = colorNavbarBg;
          } else {
            chipTextColor = Colors.white;
          }

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
              title: Text(property.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(
                      _getStatusText(property.status),
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: chipTextColor),
                    ),
                    backgroundColor: _getStatusColor(property.status),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              trailing: Icon(_getStatusIcon(property.status), color: _getTrailingIconColor(property.status)),
              onTap: () {
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
    const Color tabColor = Color(0xFF121212);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // ENGLISH TRANSLATION
        title: Text("Manage My Listings"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: tabColor,
          unselectedLabelColor: Colors.grey[500],
          indicatorColor: tabColor,
          indicatorWeight: 2.5,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15),
          // ENGLISH TRANSLATION
          tabs: const [
            Tab(text: "Drafts & Archives"),
            Tab(text: "Sold"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPropertyList(
            propertyProvider.userProperties,
            // ENGLISH TRANSLATION
            "No drafts, submissions, or archived properties found.",
            propertyProvider.isLoadingUserProperties,
            propertyProvider.userPropertiesError
          ),
          _buildPropertyList(
            propertyProvider.userSoldProperties,
            // ENGLISH TRANSLATION
            "No sold properties yet.",
            propertyProvider.isLoadingUserSoldProperties,
            propertyProvider.userSoldPropertiesError
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        backgroundColor: const Color(0xFF1F2937),
        icon: const Icon(Icons.add, color: Colors.white),
        // ENGLISH TRANSLATION
        label: Text("New Listing", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}