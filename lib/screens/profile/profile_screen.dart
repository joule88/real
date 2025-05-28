// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real/models/property.dart';
import 'package:real/widgets/property_card_profile.dart';
import 'package:real/screens/my_drafts/my_drafts_screen.dart';
import 'package:real/screens/profile/my_property_detail_screen.dart'; // Import halaman detail baru

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Data properti pengguna yang sudah APPROVED dan TAYANG
  // Ditambahkan dummy data untuk statistik
  final List<Property> _myApprovedProperties = [
    Property(
      id: 'approvedProp1',
      title: 'Rumah Keluarga Idaman (TAYANG)',
      description:
          'Deskripsi rumah tayang dengan berbagai fasilitas menarik dan lingkungan yang asri.',
      uploader: 'Anderson',
      imageUrl:
          'https://images.pexels.com/photos/106399/pexels-photo-106399.jpeg',
      price: 1200000,
      address: 'Jl. Merdeka No. 10',
      // city: 'Jakarta Pusat',
      // stateZip: 'DKI Jakarta 10110',
      bedrooms: 3,
      bathrooms: 2,
      areaSqft: 150,
      propertyType: "Rumah",
      furnishings: "Semi Furnished",
      status: PropertyStatus.approved, // Status Approved
      isFavorite:
          false, // isFavorite dari sudut pandang user lain, bukan pemilik
      bookmarkCount: 25, // Dummy data
      viewsCount: 1500, // Dummy data
      inquiriesCount: 12, // Dummy data
      approvalDate: DateTime.now()
          .subtract(const Duration(days: 30)), // Contoh tanggal tayang
    ),
    Property(
      id: 'approvedProp2',
      title: 'Apartemen Modern Pusat Kota (TAYANG)',
      description:
          'Apartemen modern dan strategis di pusat kota, akses mudah ke mana saja.',
      uploader: 'Anderson',
      imageUrl:
          'https://images.pexels.com/photos/276724/pexels-photo-276724.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      price: 850000,
      address: 'Jl. Sudirman Kav. 21',
      // city: 'Jakarta Selatan',
      // stateZip: 'DKI Jakarta 12190',
      bedrooms: 2,
      bathrooms: 1,
      areaSqft: 75,
      propertyType: "Apartemen",
      furnishings: "Full Furnished",
      status: PropertyStatus.approved,
      isFavorite: false,
      bookmarkCount: 42,
      viewsCount: 2150,
      inquiriesCount: 8,
      approvalDate: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Profil Saya",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Info Pengguna
            Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage('boy.jpg'),
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Anderson",
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                    Text("Real Estate Agent",
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 25),

            // 2. Tombol Edit Profile & Kelola Draft Iklan
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Halaman Edit Profile belum diimplementasikan.")),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Text("Edit Profil",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyDraftsScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Text("Kelola Iklan",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            Text(
              "Properti Saya",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),

            Expanded(
              child: _myApprovedProperties.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home_work_outlined,
                              size: 60, color: Colors.grey[400]),
                          const SizedBox(height: 15),
                          Text("Belum ada properti Anda yang tayang.",
                              style: GoogleFonts.poppins(
                                  fontSize: 15, color: Colors.grey[700])),
                          const SizedBox(height: 8),
                          Text(
                            "Buat dan ajukan iklan properti Anda\nmelalui menu 'Kelola Iklan'.",
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _myApprovedProperties.length,
                      itemBuilder: (context, index) {
                        final property = _myApprovedProperties[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: PropertyCardProfile(
                            property: property,
                            isHorizontalVariant: false,
                            showEditIcon: false, // Tetap false di Profile list
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyPropertyDetailScreen(
                                      property: property),
                                ),
                              );
                            },
                          ),
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