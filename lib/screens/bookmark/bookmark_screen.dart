// lib/screens/bookmark/bookmark_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:real/models/property.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:real/provider/property_provider.dart';
import 'package:real/screens/detail/detailpost.dart';
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
      _loadBookmarks();
    });
  }

  Future<void> _loadBookmarks() async {
    print("BookmarkScreen: _loadBookmarks() CALLED"); // <-- Tambahkan log ini
    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      print("BookmarkScreen: User authenticated: \\${authProvider.isAuthenticated}, Token: \\${authProvider.token != null ? 'Exists' : 'NULL'}"); // <-- Tambahkan log ini
      await Provider.of<PropertyProvider>(context, listen: false)
          .fetchBookmarkedProperties(authProvider.token);
    }
  }

  Future<void> _refreshBookmarks() async {
    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await Provider.of<PropertyProvider>(context, listen: false)
          .fetchBookmarkedProperties(authProvider.token);
    }
  }

  Future<void> _navigateToDetail(Property property) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => const Center(child: CircularProgressIndicator()),
    );

    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    Property? freshPropertyData = await propertyProvider.fetchPublicPropertyDetail(
      property.id,
      authProvider.token,
    );

    if (!mounted) return;
    Navigator.pop(context); // Tutup dialog

    if (freshPropertyData != null) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat detail properti.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context); // Listen to auth changes

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
      ),
      body: !authProvider.isAuthenticated
          ? _buildLoginPrompt()
          : Consumer<PropertyProvider>(
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
                            onPressed: _loadBookmarks,
                          )
                        ],
                      ),
                    )
                  );
                }

                final List<Property> actualBookmarkedProperties = propertyProvider.bookmarkedProperties;

                return RefreshIndicator(
                  onRefresh: _loadBookmarks,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                    child: actualBookmarkedProperties.isEmpty
                        ? _buildEmptyState()
                        : _buildBookmarkList(actualBookmarkedProperties),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.login_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            "Silakan Login",
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            "Untuk melihat dan menyimpan properti favorit Anda.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Arahkan ke halaman login, Anda mungkin perlu menavigasi melalui MainScreen atau langsung.
              // Untuk sederhana, kita anggap ada cara langsung ke LoginScreen atau melalui MainScreen.
              // Jika dari MainScreen, Anda mungkin perlu method untuk mengganti tab.
              Navigator.pushNamed(context, '/login'); // Asumsi '/login' adalah rute ke LoginScreen
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColorDark),
            child: Text("Login Sekarang", style: GoogleFonts.poppins(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildBookmarkList(List<Property> properties) {
    return ListView.builder(
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];
        return GestureDetector(
          onTap: () => _navigateToDetail(property),
          child: PropertyListItem(property: property),
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
                  Icon(Icons.bookmark_outline_rounded, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    "Halaman Bookmark Anda Kosong",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Klik ikon bookmark pada properti untuk menyimpannya di sini.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
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