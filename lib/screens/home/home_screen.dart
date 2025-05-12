import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real/models/property.dart'; // Import model
import 'package:real/widgets/property_card_profile.dart';
import 'package:real/widgets/property_card.dart'; // Import widget card

class HomeScreen extends StatelessWidget {
  // --- CONTOH DATA PROPERTY (Ganti dengan data asli Anda nanti) ---
  final List<Property> featuredProperties = [
    Property(
      id: '1',
      title: 'Modern Family Home',
      description:
          'Properti ini terletak di lokasi strategis, cocok untuk keluarga modern dengan fasilitas lengkap.',
      uploader: 'Johan Pratama',
      imageUrl:
          'https://images.pexels.com/photos/106399/pexels-photo-106399.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      price: 842000,
      address: '8502 Preston Rd',
      city: 'Inglewood',
      stateZip: 'Maine 98380',
      bedrooms: 5,
      bathrooms: 4,
      areaSqft: 2135,
      propertyType: "Rumah Keluarga", // <--- TAMBAHKAN INI
      furnishings: "Full Furnished", // <--- TAMBAHKAN INI
      additionalImageUrls: [], // <--- TAMBAHKAN INI
      status: PropertyStatus.approved, // <--- TAMBAHKAN INI
      isFavorite: false,
    ),
    Property(
      id: '2',
      title: 'Elegant Urban House',
      description:
          'Hunian elegan dengan desain kontemporer dan lokasi premium di tengah kota.',
      uploader: 'Aldo Santosa',
      imageUrl:
          'https://images.pexels.com/photos/1396122/pexels-photo-1396122.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      price: 720000,
      address: '6391 Elgin St.',
      city: 'Celina',
      stateZip: 'California 98380',
      bedrooms: 4,
      bathrooms: 4,
      areaSqft: 2000,
      propertyType: "Townhouse", // <--- TAMBAHKAN INI
      furnishings: "Semi Furnished", // <--- TAMBAHKAN INI
      additionalImageUrls: [],
      status: PropertyStatus.approved,
      isFavorite: true,
    ),
    Property(
      id: '3',
      title: 'Luxury Classic Estate',
      description:
          'Rumah mewah dengan gaya klasik, taman luas, dan kolam renang pribadi.',
      uploader: 'Siti Rahmawati',
      imageUrl:
          'https://images.pexels.com/photos/259588/pexels-photo-259588.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      price: 1212000,
      address: '123 Main St',
      city: 'Anytown',
      stateZip: 'USA 12345',
      bedrooms: 6,
      bathrooms: 5,
      areaSqft: 3000,
      propertyType: "Estate Klasik", // <--- TAMBAHKAN INI
      furnishings: "Luxury Furnished", // <--- TAMBAHKAN INI
      additionalImageUrls: [],
      status: PropertyStatus.approved,
      isFavorite: false,
    ),
  ];

  final List<Property> forYouProperties = [
    Property(
      id: '4',
      title: 'Comfortable Family Home',
      description:
          'Rumah nyaman dengan lingkungan tenang, cocok untuk keluarga dengan anak-anak.',
      uploader: 'Rina Marlina',
      imageUrl:
          'https://images.pexels.com/photos/209296/pexels-photo-209296.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      price: 842000,
      address: '8502 Redwood Ln',
      city: 'Inglewood',
      stateZip: 'California 98380',
      bedrooms: 5,
      bathrooms: 4,
      areaSqft: 2135,
      propertyType: "Rumah Nyaman", // <--- TAMBAHKAN INI
      furnishings: "Unfurnished", // <--- TAMBAHKAN INI
      additionalImageUrls: [],
      status: PropertyStatus.approved,
      isFavorite: false,
    ),
    Property(
      id: '5',
      title: 'Spacious Modern House',
      description:
          'Hunian luas dengan desain modern dan pencahayaan alami optimal.',
      uploader: 'Bagus Permana',
      imageUrl:
          'https://images.pexels.com/photos/276724/pexels-photo-276724.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      price: 1212000,
      address: '6391 Maple Ave',
      city: 'Celina',
      stateZip: 'California 98380',
      bedrooms: 4,
      bathrooms: 4,
      areaSqft: 2135,
      propertyType: "Rumah Modern Luas", // <--- TAMBAHKAN INI
      furnishings: "Semi Furnished", // <--- TAMBAHKAN INI
      additionalImageUrls: [],
      status: PropertyStatus.approved,
      isFavorite: false,
    ),
  ];

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ... (Sisa build method sama seperti sebelumnya)
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          children: [
            // ... (Header Title, Search Bar, Category Chips) ...
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
              /* ... Search bar ... */
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 5),
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
                  child: const Icon(
                    Icons.filter_list,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              /* ... Category chips ... */
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

            // 4. Featured Properties (Horizontal Scroll)
            SizedBox(
              height: 280, // Sesuaikan tinggi jika perlu agar card tidak terpotong
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: featuredProperties.length,
                itemBuilder: (context, index) {
                  return PropertyCard(
                    property: featuredProperties[index],
                    isHorizontalVariant: true,
                  );
                },
              ),
            ),
            const SizedBox(height: 25),

            // 5. "For You" Section Header
            Row(
              /* ... For You Header ... */
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
                TextButton(
                  onPressed: () {
                    /* Aksi lihat semua */
                  },
                  child: Text(
                    "More",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // 6. "For You" Properties List (Vertical)
            // Perhatikan: Jika isHorizontalVariant: true untuk PropertyCard di sini,
            // ListView.builder ini akan mencoba membuat item dengan lebar tetap
            // di dalam ListView vertikal utama. Ini bisa menyebabkan masalah layout.
            // Sebaiknya PropertyCard untuk daftar vertikal memiliki isHorizontalVariant: false
            // atau Anda menggunakan widget lain seperti PropertyListItem.
            // Untuk sementara, saya biarkan isHorizontalVariant: true sesuai kode Anda,
            // tapi ini perlu diperhatikan.
            ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: forYouProperties.length,
                itemBuilder: (context, index) {
                  // Tambahkan Padding atau Margin jika PropertyCard tidak punya margin sendiri
                  // saat isHorizontalVariant: false (atau saat dipakai dalam list vertikal)
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15.0), // Contoh margin bawah
                    child: PropertyCard(
                      property: forYouProperties[index],
                      isHorizontalVariant: false, // Sebaiknya false untuk list vertikal
                                                 // Ini akan membuat card mengambil lebar penuh
                                                 // dan menggunakan margin bottom dari PropertyCard.
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }

  // Helper widget untuk membuat chip kategori (sama seperti sebelumnya)
  Widget _buildCategoryChip(String label, {bool isActive = false}) {
    // ... (kode _buildCategoryChip sama)
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
}