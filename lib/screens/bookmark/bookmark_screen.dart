// lib/screens/bookmark/bookmark_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:real/models/property.dart';
import 'package:real/provider/auth_provider.dart'; // Import AuthProvider
import 'package:real/provider/property_provider.dart'; // Import PropertyProvider
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
    // Panggil fetchBookmarkedProperties saat layar pertama kali dibuka
    // Menggunakan addPostFrameCallback memastikan context sudah tersedia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Pastikan widget sudah ter-mount sebelum mengakses context
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        Provider.of<PropertyProvider>(context, listen: false)
            .fetchBookmarkedProperties(authProvider.token);
      }
    });
  }

  // Method untuk pull-to-refresh
  Future<void> _refreshBookmarks() async {
    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await Provider.of<PropertyProvider>(context, listen: false)
          .fetchBookmarkedProperties(authProvider.token);
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
      body: Consumer<PropertyProvider>( // Bungkus dengan Consumer
        builder: (context, propertyProvider, child) {
          if (propertyProvider.isLoadingBookmarkedProperties && propertyProvider.bookmarkedProperties.isEmpty) {
            // Tampilkan loading hanya jika daftar masih kosong dan sedang loading awal
            return const Center(child: CircularProgressIndicator());
          }

          if (propertyProvider.bookmarkedPropertiesError != null && propertyProvider.bookmarkedProperties.isEmpty) {
            // Tampilkan error hanya jika daftar masih kosong dan ada error
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
                  // Jika Anda memiliki search bar atau filter, bisa diletakkan di sini
                  // _buildSearchBarAndFilter(),
                  // const SizedBox(height: 20),
                  Expanded(
                    child: actualBookmarkedProperties.isEmpty
                        ? _buildEmptyState() // Tampilkan empty state jika tidak ada bookmark
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

  // Widget _buildSearchBarAndFilter() {
  //   // Implementasi search bar dan filter jika dibutuhkan
  //   return Container();
  // }

  Widget _buildBookmarkList(List<Property> properties) {
    return ListView.builder(
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];
        // Penting: Pastikan PropertyListItem dapat menangani perubahan state isFavorite
        // dan memanggil togglePropertyBookmark dari PropertyProvider.
        // Kita sudah melakukan ini di langkah sebelumnya.
        return PropertyListItem(
          property: property,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder( // Menggunakan LayoutBuilder agar bisa mengisi ruang yang tersedia
      builder: (context, constraints) {
        return SingleChildScrollView( // Agar konten bisa di-scroll jika layar terlalu kecil
          physics: const AlwaysScrollableScrollPhysics(), // Aktifkan scroll meskipun konten pas
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight), // Memastikan mengisi tinggi
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
                    "Halaman Bookmark Anda Kosong", // Diubah ke Bahasa Indonesia
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Klik ikon bookmark pada properti untuk menyimpannya di sini.", // Diubah ke Bahasa Indonesia
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