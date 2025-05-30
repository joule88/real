// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:real/models/property.dart';        // Pastikan import model Property benar
import 'package:real/provider/property_provider.dart'; // Import PropertyProvider
import 'package:real/widgets/property_card.dart';     // Import widget card

// Ubah menjadi StatefulWidget
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); // Tambahkan const jika tidak ada parameter

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Panggil fetchPublicProperties saat layar pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PropertyProvider>(context, listen: false)
          .fetchPublicProperties();
    });

    // Listener untuk ScrollController (untuk load more)
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 && // Trigger sebelum akhir banget
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
              // Data properti tersedia
              final List<Property> allProps = propertyProvider.publicProperties;
              // Ambil beberapa properti untuk "Featured" (horizontal scroll)
              // Misalnya 5 properti pertama, atau lebih sedikit jika totalnya kurang dari 5
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
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: 'Search address, city, location',
                              icon: Icon(Icons.search, color: Colors.grey),
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.filter_list, color: Colors.white, size: 24),
                      ),
                    ],
                  ),
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

                  // Featured Properties (Horizontal Scroll)
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

                  // "For You" Section Header (atau "Semua Properti")
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "For You", // atau "Semua Properti"
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      // Tombol "More" bisa dihilangkan jika sudah ada infinite scroll
                      // atau bisa diarahkan ke halaman search dengan filter tertentu.
                      // TextButton(
                      //   onPressed: () { /* Aksi lihat semua */ },
                      //   child: Text(
                      //     "More",
                      //     style: GoogleFonts.poppins(
                      //       fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[600],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // "For You" Properties List (Vertical)
                  // Menampilkan semua properti yang ada di `allProps`
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
                  
                  // Indikator loading untuk "load more"
                  if (propertyProvider.isLoadingPublicProperties && propertyProvider.publicProperties.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  
                  // Pesan jika sudah tidak ada data lagi untuk di-load
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

            // Bungkus bodyContent dengan RefreshIndicator
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