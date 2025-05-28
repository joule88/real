// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Sesuaikan path import ini jika berbeda di proyek Anda
import 'package:real/models/user_model.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:real/screens/profile/edit_profile_screen.dart'; // Untuk navigasi
import 'package:real/models/property.dart'; // Jika masih menggunakan dummy property
import 'package:real/widgets/property_card_profile.dart'; // Jika masih menggunakan dummy property
import 'package:real/screens/my_drafts/my_drafts_screen.dart'; // Jika masih menggunakan dummy property
import 'package:real/screens/profile/my_property_detail_screen.dart'; // Jika masih menggunakan dummy property

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Data properti dummy (bisa dihapus atau diganti dengan data dinamis nanti)
  final List<Property> _myApprovedProperties = [
    // ... (data dummy properti Anda bisa tetap di sini untuk sementara)
    // Contoh:
    Property(
      id: 'approvedProp1',
      title: 'Rumah Keluarga Idaman (TAYANG)',
      description: 'Deskripsi rumah tayang...',
      uploader: 'Anderson',
      imageUrl: 'https://images.pexels.com/photos/106399/pexels-photo-106399.jpeg',
      price: 1200000,
      address: 'Jl. Merdeka No. 10',
      bedrooms: 3, bathrooms: 2, areaSqft: 150, propertyType: "Rumah",
      furnishings: "Semi Furnished", status: PropertyStatus.approved,
      isFavorite: false, bookmarkCount: 25, viewsCount: 1500, inquiriesCount: 12,
      approvalDate: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Panggil fetchUserProfile saat layar ini pertama kali dibuka
    // untuk memastikan data user (terutama bio) adalah yang terbaru.
    // Kita gunakan addPostFrameCallback agar dipanggil setelah build pertama selesai.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Hanya fetch jika user sudah ada (misalnya dari login)
      // atau jika Anda ingin memastikan data selalu fresh.
      // Jika API login Anda tidak mengembalikan bio, fetch di sini jadi penting.
      if (authProvider.isAuthenticated && (authProvider.user?.bio == null || authProvider.user!.bio.isEmpty)) {
        print('ProfileScreen: Fetching user profile in initState because bio might be missing/empty.');
        authProvider.fetchUserProfile().catchError((error) {
          // Handle error jika gagal fetch user, misalnya tampilkan snackbar
          if (mounted) { // Selalu cek mounted dalam callback async
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal memuat detail profil: $error')),
            );
          }
        });
      } else if (authProvider.isAuthenticated) {
        // Jika bio sudah ada, mungkin tidak perlu fetch ulang setiap saat,
        // kecuali Anda ingin data selalu paling update.
        // Untuk sekarang, kita bisa fetch jika bio kosong.
        print('ProfileScreen: User is authenticated, bio: "${authProvider.user?.bio}". Fetch skipped if bio exists.');
      }
    });
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.logout();
      // Navigasi ke halaman login setelah logout (Consumer di main.dart akan handle ini)
      // Jadi tidak perlu navigasi manual di sini.
      print('ProfileScreen: Logout berhasil.');
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda telah logout.')),
        );
       }
    } catch (e) {
      print('ProfileScreen: Error saat logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal logout: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil user dan status loading dari AuthProvider
    // Kita listen: true di sini agar UI rebuild saat user atau isLoading berubah
    final authProvider = Provider.of<AuthProvider>(context);
    final User? user = authProvider.user;
    final bool isLoadingUser = authProvider.isLoading; // Untuk loading data user

    // Definisikan warna tema Anda di sini atau ambil dari Theme.of(context) jika sudah ada
    final Color themeColor = const Color(0xFFDAF365); // Warna tema Anda

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Profil Saya",
          style: GoogleFonts.poppins(
            color: Colors.black, // Bisa juga themeColor atau Colors.black87
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoadingUser && user == null // Tampilkan loading jika sedang fetch user dan user belum ada
          ? Center(child: CircularProgressIndicator(color: themeColor))
          : user == null // Jika tidak loading tapi user tetap null (misalnya belum login atau error fetch parah)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Data pengguna tidak dapat dimuat.'),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Coba fetch lagi atau arahkan ke login jika perlu
                          if (authProvider.isAuthenticated) {
                            authProvider.fetchUserProfile();
                          } else {
                            // Arahkan ke login jika belum authenticated (seharusnya tidak sampai sini jika main.dart benar)
                          }
                        },
                        child: const Text('Coba Lagi'),
                      )
                    ],
                  ),
                )
              // Jika user ada, tampilkan data profil
              : RefreshIndicator( // Untuk pull-to-refresh data profil
                  onRefresh: () => authProvider.fetchUserProfile(),
                  child: ListView( // Ganti Padding dengan ListView agar bisa di-scroll jika konten panjang
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                    children: [
                      // 1. Info Pengguna
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40, // Sedikit lebih besar
                            backgroundImage: (user.profileImage.isNotEmpty && Uri.tryParse(user.profileImage)?.isAbsolute == true)
                                ? NetworkImage(user.profileImage)
                                : const AssetImage('assets/images/boy.jpg') as ImageProvider, // Fallback
                            backgroundColor: Colors.grey[200],
                            onBackgroundImageError: (exception, stackTrace) {
                              print('Error loading profile image: $exception');
                              // Tidak perlu setState di sini, CircleAvatar akan fallback ke child
                            },
                            child: (user.profileImage.isEmpty || Uri.tryParse(user.profileImage)?.isAbsolute != true)
                                ? Icon(Icons.person, size: 40, color: Colors.grey[400])
                                : null,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name, // Ambil dari user.name
                                  style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.bio.isNotEmpty ? user.bio : 'Belum ada bio.', // Ambil dari user.bio
                                  style: GoogleFonts.poppins(
                                      fontSize: 14, color: Colors.grey[600]),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // 2. Tombol Edit Profile & Kelola Iklan
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: Icon(Icons.edit_outlined, color: Colors.black),
                              label: Text("Edit Profil",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: const Color.fromARGB(255, 0, 0, 0))), // Warna tema
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditProfileScreen(currentUser: user), // Kirim data user saat ini
                                  ),
                                ).then((dataUpdated) {
                                  if (dataUpdated == true) {
                                    // Data di AuthProvider seharusnya sudah terupdate dan notifyListeners sudah dipanggil.
                                    // Consumer di sini akan otomatis rebuild.
                                    // Jika Anda ingin memastikan data terbaru dari server, bisa panggil fetch lagi.
                                    // authProvider.fetchUserProfile();
                                    // Atau cukup setState jika hanya mengandalkan data dari AuthProvider yang sudah diupdate:
                                    // setState(() {}); // Tidak selalu perlu jika Provider listen:true
                                    print('ProfileScreen: Kembali dari Edit Profil dengan update.');
                                  }
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(color: themeColor.withOpacity(0.5)), // Border dengan warna tema
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.article_outlined, color: Colors.black87),
                              label: Text("Kelola Iklan",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87)),
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
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Bagian Properti Saya (masih menggunakan data dummy)
                      Text(
                        "Properti Saya (Tayang)",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 15),

                      _myApprovedProperties.isEmpty
                          ? Center(
                              child: Padding( // Beri padding agar tidak terlalu mepet
                                padding: const EdgeInsets.symmetric(vertical: 30.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.home_work_outlined,
                                        size: 60, color: Colors.grey[400]),
                                    const SizedBox(height: 15),
                                    Text("Belum ada properti Anda yang tayang.",
                                        style: GoogleFonts.poppins(
                                            fontSize: 15, color: Colors.grey[700])),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true, // Penting jika ListView di dalam Column/ListView lain
                              physics: const NeverScrollableScrollPhysics(), // Agar scroll utama dari ListView luar
                              itemCount: _myApprovedProperties.length,
                              itemBuilder: (context, index) {
                                final property = _myApprovedProperties[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 15.0),
                                  child: PropertyCardProfile(
                                    property: property,
                                    isHorizontalVariant: false,
                                    showEditIcon: false,
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
                    ],
                  ),
                ),
    );
  }
}