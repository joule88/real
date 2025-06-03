import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:real/models/property.dart';
import 'package:real/provider/property_provider.dart';
import 'package:real/screens/search/search_screen.dart'; // Import SearchScreen
import 'package:real/widgets/property_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PropertyProvider>(context, listen: false)
          .fetchPublicProperties();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !Provider.of<PropertyProvider>(context, listen: false)
              .isLoadingPublicProperties &&
          Provider.of<PropertyProvider>(context, listen: false)
              .hasMorePublicProperties) {
        print("HomeScreen: Mencapai akhir scroll, memanggil loadMore...");
        Provider.of<PropertyProvider>(context, listen: false)
            .fetchPublicProperties(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshProperties() async {
    await Provider.of<PropertyProvider>(context, listen: false)
        .fetchPublicProperties();
  }

  Widget _buildCategoryChip(String label, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: Chip(
        label: Text(label),
        labelStyle: GoogleFonts.poppins(
          color: isActive ? Colors.black : Colors.grey[700],
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: isActive ? const Color(0xFFDAF365) : Colors.grey[200],
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), side: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<PropertyProvider>(
          builder: (context, propertyProvider, child) {
            Widget bodyContent;

            if (propertyProvider.isLoadingPublicProperties &&
                propertyProvider.publicProperties.isEmpty) {
              bodyContent = const Center(child: CircularProgressIndicator());
            } else if (propertyProvider.publicPropertiesError != null &&
                propertyProvider.publicProperties.isEmpty) {
              bodyContent = Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[400], size: 50),
                      const SizedBox(height: 10),
                      Text(
                        'Gagal memuat properti: ${propertyProvider.publicPropertiesError}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text("Coba Lagi"),
                        onPressed: _refreshProperties,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              );
            } else if (propertyProvider.publicProperties.isEmpty) {
              bodyContent = Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_work_outlined, color: Colors.grey[400], size: 60),
                      const SizedBox(height: 15),
                      Text(
                        "Belum ada properti yang tersedia.",
                        style: GoogleFonts.poppins(fontSize: 17, color: Colors.grey[800]),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Silakan cek kembali nanti.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                      ),
                       const SizedBox(height: 20),
                       ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text("Refresh"),
                        onPressed: _refreshProperties,
                       )
                    ],
                  ),
                ),
              );
            } else {
              final List<Property> allProps = propertyProvider.publicProperties;
              final List<Property> featuredProps = allProps.take(5).toList();

              bodyContent = ListView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                children: [
                  Text(
                    "Let's Find your",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "Favorite Home",
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // --- PERUBAHAN BAGIAN SEARCH BAR ---
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SearchScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12), // Disesuaikan paddingnya
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey[600]),
                          const SizedBox(width: 10),
                          Text(
                            'Search address, city, location',
                            style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // --- AKHIR PERUBAHAN BAGIAN SEARCH BAR ---
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCategoryChip("Recomended", isActive: true),
                        _buildCategoryChip("Top Rates"),
                        _buildCategoryChip("Best Offers"),
                        _buildCategoryChip("Most Viewed"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  if (featuredProps.isNotEmpty)
                    SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: featuredProps.length,
                        itemBuilder: (context, index) {
                          return PropertyCard(
                            property: featuredProps[index],
                            isHorizontalVariant: true,
                          );
                        },
                      ),
                    ),
                  if (featuredProps.isNotEmpty) const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "For You",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: allProps.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: PropertyCard(
                            property: allProps[index],
                            isHorizontalVariant: false,
                          ),
                        );
                      }),
                  
                  if (propertyProvider.isLoadingPublicProperties && propertyProvider.publicProperties.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  
                  if (!propertyProvider.hasMorePublicProperties && propertyProvider.publicProperties.isNotEmpty)
                     Padding(
                       padding: const EdgeInsets.symmetric(vertical: 20.0),
                       child: Center(
                         child: Text(
                           "Anda sudah melihat semua properti.",
                           style: GoogleFonts.poppins(color: Colors.grey[600]),
                         ),
                       ),
                     ),
                ],
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshProperties,
              child: bodyContent,
            );
          },
        ),
      ),
    );
  }
}