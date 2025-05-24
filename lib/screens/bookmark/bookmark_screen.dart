import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real/models/property.dart'; // Import model
import 'package:real/widgets/property_list_item.dart'; // Import widget list item

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  // --- CONTOH DATA BOOKMARK (Ganti dengan logika data asli Anda) ---
  // Simulasi daftar bookmark.
  List<Property> bookmarkedProperties = [
    Property(
      id: '2',
      title: 'Elegant Urban House (Bookmarked)',
      description:
          'Hunian elegan dengan desain kontemporer dan lokasi premium di tengah kota.',
      uploader: 'Aldo Santosa',
      imageUrl:
          'https://images.pexels.com/photos/1396122/pexels-photo-1396122.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      price: 720000,
      address: '6391 Elgin St.',
      // city: 'Celina',
      // stateZip: 'California 98380',
      bedrooms: 4,
      bathrooms: 4,
      areaSqft: 2000,
      propertyType: "Townhouse", // <--- TAMBAHKAN INI
      furnishings: "Unfurnished", // <--- TAMBAHKAN INI
      additionalImageUrls: [], // <--- TAMBAHKAN INI
      status: PropertyStatus.approved, // <--- TAMBAHKAN INI (asumsi bookmark untuk properti yang tayang)
      isFavorite: true, // Pastikan ini true untuk item di bookmark
    ),
    Property(
      id: '5',
      title: 'Spacious Modern House (Bookmarked)',
      description:
          'Hunian luas dengan desain modern dan pencahayaan alami optimal.',
      uploader: 'Bagus Permana',
      imageUrl:
          'https://images.pexels.com/photos/276724/pexels-photo-276724.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      price: 1212000,
      address: '6391 Maple Ave',
      // city: 'Celina',
      // stateZip: 'California 98380',
      bedrooms: 4,
      bathrooms: 4,
      areaSqft: 2135,
      propertyType: "Rumah Modern", // <--- TAMBAHKAN INI
      furnishings: "Full Furnished", // <--- TAMBAHKAN INI
      additionalImageUrls: [],
      status: PropertyStatus.approved,
      isFavorite: true, // Pastikan ini true
    ),
  ];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // TODO: Tambahkan logika untuk mengambil data bookmark asli dari database/state management
    // Contoh: fetchBookmarkedProperties();
    // Anda mungkin perlu memfilter daftar properti global berdasarkan ID yang disimpan sebagai bookmark
    // atau mengambil daftar ID bookmark dan kemudian mengambil detail properti tersebut.
  }

  @override
  Widget build(BuildContext context) {
    // Jika Anda menggunakan Provider untuk daftar properti global, Anda bisa memfilternya di sini:
    // final propertyProvider = Provider.of<PropertyProvider>(context);
    // final actualBookmarkedProperties = propertyProvider.allProperties.where((p) => p.isFavorite).toList();
    // Untuk saat ini, kita tetap pakai list dummy `bookmarkedProperties`

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
            color: Colors.blue[300],
            height: 1.0,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Column(
                children: [
                  _buildSearchBarAndFilter(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: bookmarkedProperties.isEmpty // Gunakan list dummy yang sudah diperbarui
                        ? _buildEmptyState()
                        : _buildBookmarkList(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSearchBarAndFilter() {
    return Row(
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
                hintText: 'Search your bookmarks...',
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
    );
  }

  Widget _buildBookmarkList() {
    // Jika Anda menggunakan Provider, gunakan `actualBookmarkedProperties` di sini
    return ListView.builder(
      itemCount: bookmarkedProperties.length, // Gunakan list dummy yang sudah diperbarui
      itemBuilder: (context, index) {
        final property = bookmarkedProperties[index]; // Gunakan list dummy yang sudah diperbarui
        return PropertyListItem(
          property: property,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
            "Your Bookmark page is empty",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            "Click the bookmark icon on a property to save it here.", // Teks disesuaikan
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}