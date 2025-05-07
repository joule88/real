import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real/models/property.dart'; // Import model
import 'package:real/widgets/property_list_item.dart'; // Import widget list item

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key}); // Hapus const jika stateful

  // --- CONTOH DATA HASIL SEARCH (Ganti dengan logika search asli) ---
  final List<Property> searchResults = [
    Property(
      id: '1',
      title: 'Cozy Family Home',
      description: 'Rumah nyaman untuk keluarga dengan taman depan dan belakang.',
      uploader: 'Rina Anggraini',
      imageUrl:
          'https://images.pexels.com/photos/106399/pexels-photo-106399.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      price: 842000,
      address: '8502 Preston Rd',
      city: 'Inglewood',
      stateZip: 'California 98380',
      bedrooms: 5,
      bathrooms: 4,
      areaSqft: 2135,
      propertyType: "Rumah", // <--- TAMBAHKAN INI
      furnishings: "Semi Furnished", // <--- TAMBAHKAN INI
      isFavorite: false,
      // Anda mungkin juga perlu menambahkan `additionalImageUrls` jika model mengharapkannya,
      // meskipun di sini mungkin tidak terlalu relevan untuk tampilan search list item.
      // additionalImageUrls: [], // Contoh
      status: PropertyStatus.approved, // Asumsikan hasil search adalah properti yang sudah tayang
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
      propertyType: "Rumah Modern", // <--- TAMBAHKAN INI
      furnishings: "Full Furnished", // <--- TAMBAHKAN INI
      isFavorite: false,
      status: PropertyStatus.approved,
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
      furnishings: "Unfurnished", // <--- TAMBAHKAN INI
      isFavorite: true,
      status: PropertyStatus.approved,
    ),
    Property(
      id: '4',
      title: 'Classic Green Villa',
      description:
          'Rumah klasik bergaya vila dengan pemandangan alam yang asri.',
      uploader: 'Dina Rahayu',
      imageUrl:
          'https://images.pexels.com/photos/209296/pexels-photo-209296.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      price: 842000,
      address: '8502 Redwood Ln',
      city: 'Inglewood',
      stateZip: 'California 98380',
      bedrooms: 5,
      bathrooms: 4,
      areaSqft: 2135,
      propertyType: "Villa", // <--- TAMBAHKAN INI
      furnishings: "Full Furnished", // <--- TAMBAHKAN INI
      isFavorite: false,
      status: PropertyStatus.approved,
    ),
    Property(
      id: '3',
      title: 'Luxury Mansion',
      description:
          'Rumah mewah berdesain eksklusif, cocok untuk keluarga besar.',
      uploader: 'Hendri Prasetyo',
      imageUrl:
          'https://images.pexels.com/photos/259588/pexels-photo-259588.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      price: 1212000,
      address: '123 Main St',
      city: 'Anytown',
      stateZip: 'USA 12345',
      bedrooms: 6,
      bathrooms: 5,
      areaSqft: 3000,
      propertyType: "Mansion", // <--- TAMBAHKAN INI
      furnishings: "Luxury Furnished", // <--- TAMBAHKAN INI
      isFavorite: false,
      status: PropertyStatus.approved,
    ),
  ];

  // --- END CONTOH DATA ---

  @override
  Widget build(BuildContext context) {
    int resultCount = searchResults.length; // Ambil jumlah hasil dari data

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Explore",
          style: GoogleFonts.poppins(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Search Bar & Filter Icon (Sama seperti HomeScreen)
            Row(
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
                      // TODO: Tambahkan controller & onChanged untuk logika search
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937), // Warna gelap
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.filter_list, // Ganti dengan ikon filter yg sesuai
                    color: Colors.white,
                    size: 24,
                  ),
                  // TODO: Tambahkan onPressed untuk buka filter
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. Hasil Pencarian Text
            Text(
              "Search results ($resultCount)", // Tampilkan jumlah hasil
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),

            // 3. Daftar Hasil Pencarian
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return PropertyListItem(
                    property: searchResults[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}