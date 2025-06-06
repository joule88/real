// lib/screens/bookmark/bookmark_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:real/app/themes/app_themes.dart';
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
      builder: (BuildContext dialogContext) => const Center(child: CircularProgressIndicator(color: AppTheme.nearlyBlack)),
    );

    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    Property? freshPropertyData = await propertyProvider.fetchPublicPropertyDetail(
      property.id,
      authProvider.token,
    );

    if (!mounted) return;
    Navigator.pop(context);

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
        // ENGLISH
        const SnackBar(content: Text('Failed to load property details.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Bookmarks", // ENGLISH
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
                  return const Center(child: CircularProgressIndicator(color: AppTheme.nearlyBlack));
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
                            // ENGLISH
                            'Failed to load bookmarks: ${propertyProvider.bookmarkedPropertiesError}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text("Try Again"), // ENGLISH
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
            "Please Log In", // ENGLISH
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            "To view and save your favorite properties.", // ENGLISH
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColorDark),
            child: Text("Log In Now", style: GoogleFonts.poppins(color: Colors.white)), // ENGLISH
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
          child: PropertyListItem(
            key: ValueKey(property.id),
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
                  Icon(Icons.bookmark_outline_rounded, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    "Your Bookmarks are Empty", // ENGLISH
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Tap the bookmark icon on a property to save it here.", // ENGLISH
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