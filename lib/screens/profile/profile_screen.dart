// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real/models/property.dart';
import 'package:real/widgets/property_card.dart'; // Atau PropertyListItem jika lebih cocok
// import 'package:real/screens/post_ad/post_ad_screen.dart'; // Ini sekarang jadi MyDraftsScreen
import 'package:real/screens/my_drafts/my_drafts_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Data properti pengguna yang sudah APPROVED dan TAYANG
  final List<Property> _myApprovedProperties = [
    Property(
        id: 'approvedProp1',
        title: 'Rumah Keluarga Idaman (TAYANG)',
        description: 'Deskripsi rumah tayang...',
        uploader: 'Anderson',
        imageUrl: 'https://images.pexels.com/photos/106399/pexels-photo-106399.jpeg',
        price: 1200000,
        address: 'Jl. Merdeka No. 10',
        city: 'Jakarta Pusat',
        stateZip: 'DKI Jakarta 10110',
        bedrooms: 3,
        bathrooms: 2,
        areaSqft: 150,
        propertyType: "Rumah",
        furnishings: "Semi Furnished",
        status: PropertyStatus.approved, // Status Approved
        isFavorite: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Profile Saya",
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
            // 1. Info Pengguna (sama seperti sebelumnya)
            Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage('assets/boy.jpg'),
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Anderson", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                    Text("Real Estate Agent", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
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
                      // TODO: Navigasi ke Halaman Edit Profile Pengguna
                    },
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: Colors.grey[300]!), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: Text("Edit Profile", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyDraftsScreen()), // Navigasi ke MyDraftsScreen
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: Text("Kelola Iklan (Draft)", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            Text(
              "Properti Saya yang Tayang",
              style: GoogleFonts.poppins(
                fontSize: 16,
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
                          Icon(Icons.visibility_off_outlined, size: 60, color: Colors.grey[400]),
                          const SizedBox(height: 10),
                          Text("Belum ada properti Anda yang tayang.", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                          const SizedBox(height: 5),
                           Text("Ajukan draft iklan agar properti Anda bisa dilihat publik.", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]), textAlign: TextAlign.center,),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _myApprovedProperties.length,
                      itemBuilder: (context, index) {
                        final property = _myApprovedProperties[index];
                        // Gunakan PropertyCard atau PropertyListItem
                        // Jika PropertyCard, ikon edit mungkin tidak relevan di sini,
                        // atau bisa diubah menjadi ikon "Kelola" atau "Lihat Statistik"
                        return PropertyCard(
                          property: property,
                          isHorizontalVariant: false,
                          showEditIcon: false, // Jangan tampilkan ikon edit di sini (atau ubah fungsinya)
                          // onEditPressed: () {
                          //   // Aksi jika card properti tayang ditekan (misal lihat detail publik atau kelola)
                          // },
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