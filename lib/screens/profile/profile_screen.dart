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
import 'package:real/screens/my_drafts/my_drafts_screen.dart';
import 'package:real/screens/profile/my_property_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<Property> _myApprovedProperties = [
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated && (authProvider.user?.bio == null || authProvider.user!.bio.isEmpty)) {
        print('ProfileScreen: Fetching user profile in initState because bio might be missing/empty.');
        authProvider.fetchUserProfile().catchError((error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal memuat detail profil: $error')),
            );
          }
        });
      } else if (authProvider.isAuthenticated) {
        print('ProfileScreen: User is authenticated, bio: "${authProvider.user?.bio}". Fetch skipped if bio exists.');
      }
    });
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.logout();
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
    final authProvider = Provider.of<AuthProvider>(context);
    final User? user = authProvider.user;
    final bool isLoadingUser = authProvider.isLoading;

    final Color themeColor = const Color(0xFFDAF365);
    final Color textOnThemeColor = Colors.black87; // Warna teks untuk kontras dengan themeColor

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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoadingUser && user == null
          ? Center(child: CircularProgressIndicator(color: themeColor))
          : user == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Data pengguna tidak dapat dimuat.'),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (authProvider.isAuthenticated) {
                            authProvider.fetchUserProfile();
                          }
                        },
                        child: const Text('Coba Lagi'),
                      )
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => authProvider.fetchUserProfile(),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: (user.profileImage.isNotEmpty && Uri.tryParse(user.profileImage)?.isAbsolute == true)
                                ? NetworkImage(user.profileImage)
                                : const AssetImage('assets/images/boy.jpg') as ImageProvider,
                            backgroundColor: Colors.grey[200],
                            onBackgroundImageError: (exception, stackTrace) {
                              print('Error loading profile image: $exception');
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
                                  user.name,
                                  style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.bio.isNotEmpty ? user.bio : 'Belum ada bio.',
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

                      // --- MODIFIKASI TOMBOL DI SINI ---
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon( // Diubah menjadi ElevatedButton
                              icon: Icon(Icons.edit_outlined, color: textOnThemeColor), // Warna ikon disesuaikan
                              label: Text("Edit Profil",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: textOnThemeColor)), // Warna teks disesuaikan
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditProfileScreen(currentUser: user),
                                  ),
                                ).then((dataUpdated) {
                                  if (dataUpdated == true) {
                                    print('ProfileScreen: Kembali dari Edit Profil dengan update.');
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: themeColor, // Menggunakan themeColor
                                  elevation: 2, // Tambahkan sedikit elevasi agar menonjol
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.article_outlined, color: textOnThemeColor), // Warna ikon disesuaikan
                              label: Text("Kelola Iklan",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: textOnThemeColor)), // Warna teks disesuaikan
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MyDraftsScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: themeColor, // Diubah menjadi themeColor
                                  elevation: 2, // Tambahkan sedikit elevasi
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                        ],
                      ),
                      // --- AKHIR MODIFIKASI TOMBOL ---
                      const SizedBox(height: 30),

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
                              child: Padding(
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
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
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