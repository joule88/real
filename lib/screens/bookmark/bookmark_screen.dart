import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real/models/property.dart'; // Import model
import 'package:real/widgets/property_list_item.dart'; // Import widget list item

class BookmarkScreen extends StatefulWidget {
  // Hapus const jika stateful
   const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  // --- CONTOH DATA BOOKMARK (Ganti dengan logika data asli Anda) ---
  // Simulasi daftar bookmark. Coba ubah list ini jadi kosong [] untuk melihat empty state
List<Property> bookmarkedProperties = [
  Property(
    id: '2',
    title: 'Elegant Urban House',
    description: 'Hunian elegan dengan desain kontemporer dan lokasi premium di tengah kota.',
    uploader: 'Aldo Santosa',
    imageUrl: 'https://images.pexels.com/photos/1396122/pexels-photo-1396122.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    price: 720000,
    address: '6391 Elgin St.',
    city: 'Celina',
    stateZip: 'California 98380',
    bedrooms: 4,
    bathrooms: 4,
    areaSqft: 2000,
    isFavorite: true,
  ),
  Property(
    id: '5',
    title: 'Spacious Modern House',
    description: 'Hunian luas dengan desain modern dan pencahayaan alami optimal.',
    uploader: 'Bagus Permana',
    imageUrl: 'https://images.pexels.com/photos/276724/pexels-photo-276724.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    price: 1212000,
    address: '6391 Maple Ave',
    city: 'Celina',
    stateZip: 'California 98380',
    bedrooms: 4,
    bathrooms: 4,
    areaSqft: 2135,
    isFavorite: true,
  ),
];


  bool isLoading = false; // Nanti bisa dipakai untuk loading indicator

  @override
  void initState() {
    super.initState();
    // TODO: Tambahkan logika untuk mengambil data bookmark asli dari database/state management
    // Contoh: fetchBookmarkedProperties();
  }

  // --- END CONTOH DATA ---


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1, // Sedikit shadow
        // leading: IconButton( // Tombol kembali, SEMENTARA dihilangkan
        //   icon: Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
        title: Text(
          "Bookmark",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20
          ),
        ),
        centerTitle: true,
         // Garis biru di bawah AppBar (opsional, sesuai prototype)
        bottom: PreferredSize(
           preferredSize: const Size.fromHeight(1.0),
           child: Container(
              color: Colors.blue[300], // Sesuaikan warna
              height: 1.0,
            ),
         ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Tampilkan loading jika isLoading true
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Column( // Gunakan Column agar bisa menempatkan search bar di atas
                children: [
                  // 1. Search Bar & Filter Icon (Sama seperti layar lain)
                  _buildSearchBarAndFilter(),
                  const SizedBox(height: 20),

                  // 2. Tampilkan list atau empty state
                  Expanded(
                    child: bookmarkedProperties.isEmpty
                        ? _buildEmptyState() // Tampilkan pesan jika kosong
                        : _buildBookmarkList(), // Tampilkan list jika ada data
                  ),
                ],
              ),
            ),
    );
  }

  // Widget untuk Search Bar & Filter
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
                hintText: 'Search your bookmarks...', // Hint text beda
                icon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              // TODO: Tambahkan logika filter bookmark
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
            // TODO: Tambahkan onPressed untuk buka filter bookmark
        ),
      ],
    );
  }


  // Widget untuk menampilkan daftar bookmark
  Widget _buildBookmarkList() {
    return ListView.builder(
      itemCount: bookmarkedProperties.length,
      itemBuilder: (context, index) {
        // Pastikan semua properti di list ini isFavorite=true
        final property = bookmarkedProperties[index];
        return PropertyListItem( // Gunakan widget list item yang sudah ada
          property: property,
        );
      },
    );
  }

  // Widget untuk menampilkan pesan saat bookmark kosong
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_outline_rounded, // Ikon bookmark
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
            "Click save button above to start exploring and choose your favorite estates.", // Sesuaikan teks
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