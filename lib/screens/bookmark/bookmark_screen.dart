import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:real/models/property.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:real/provider/property_provider.dart';
import 'package:real/screens/detail/detailpost.dart'; // Pastikan import ini ada
import 'package:real/widgets/property_list_item.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        Provider.of<PropertyProvider>(context, listen: false)
            .fetchBookmarkedProperties(authProvider.token);
      }
    });
  }

  Future<void> _refreshBookmarks() async {
    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await Provider.of<PropertyProvider>(context, listen: false)
          .fetchBookmarkedProperties(authProvider.token);
    }
  }

  // Fungsi untuk navigasi ke detail properti
  Future<void> _navigateToDetail(Property property) async {
    // Tampilkan dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    Property? freshPropertyData = await propertyProvider.fetchPublicPropertyDetail(
      property.id,
      authProvider.token,
    );

    if (!mounted) return; // Cek mounted setelah await
    Navigator.pop(context); // Tutup dialog loading

    if (freshPropertyData != null) {
      print("Navigating to PropertyDetailPage from BookmarkScreen with fresh data for ${freshPropertyData.id}.");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: freshPropertyData, // Property model adalah ChangeNotifier
            child: PropertyDetailPage(
              key: ValueKey(freshPropertyData.id), // Gunakan key unik
              property: freshPropertyData,
            ),
          ),
        ),
      );
    } else {
      print("Failed to fetch fresh property data from BookmarkScreen for ${property.id}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat detail properti. Coba lagi nanti.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Bookmark",
          style: GoogleFonts.poppins(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      body: Consumer<PropertyProvider>(
        builder: (context, propertyProvider, child) {
          if (propertyProvider.isLoadingBookmarkedProperties && propertyProvider.bookmarkedProperties.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (propertyProvider.bookmarkedPropertiesError != null && propertyProvider.bookmarkedProperties.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[400], size: 50),
                    const SizedBox(height: 10),
                    Text(
                      'Gagal memuat bookmark: ${propertyProvider.bookmarkedPropertiesError}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text("Coba Lagi"),
                      onPressed: _refreshBookmarks,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    )
                  ],
                ),
              )
            );
          }

          final List<Property> actualBookmarkedProperties = propertyProvider.bookmarkedProperties;

          return RefreshIndicator(
            onRefresh: _refreshBookmarks,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Column(
                children: [
                  Expanded(
                    child: actualBookmarkedProperties.isEmpty
                        ? _buildEmptyState()
                        : _buildBookmarkList(actualBookmarkedProperties),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookmarkList(List<Property> properties) {
    return ListView.builder(
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];
        return GestureDetector( // Membungkus PropertyListItem dengan GestureDetector
          onTap: () {
            _navigateToDetail(property); // Memanggil fungsi navigasi
          },
          child: PropertyListItem(
            property: property,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_outline_rounded,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Halaman Bookmark Anda Kosong",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Klik ikon bookmark pada properti untuk menyimpannya di sini.",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}