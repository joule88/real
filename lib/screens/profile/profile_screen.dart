// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:real/models/user_model.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:real/provider/property_provider.dart'; // Pastikan ini diimpor
import 'package:real/screens/profile/edit_profile_screen.dart';
import 'package:real/widgets/property_card_profile.dart';
import 'package:real/screens/my_drafts/my_drafts_screen.dart';
import 'package:real/screens/profile/my_property_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated && authProvider.token != null) {
        // Fetch profil pengguna
        if (authProvider.user?.bio == null || (authProvider.user?.bio != null && authProvider.user!.bio.isEmpty)) {
          print('ProfileScreen: Fetching user profile in initState because bio might be missing/empty.');
          authProvider.fetchUserProfile().catchError((error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal memuat detail profil: $error')),
              );
            }
          });
        }
        // Fetch properti approved pengguna
        print('ProfileScreen: Fetching user approved properties.');
        Provider.of<PropertyProvider>(context, listen: false)
            .fetchUserApprovedProperties(authProvider.token!);
      } else {
        print('ProfileScreen: User not authenticated or token is null. Skipping fetches.');
      }
    });
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.logout();
      print('ProfileScreen: Logout berhasil.');
       if (mounted) {
         // Navigasi ke LoginScreen atau halaman awal setelah logout jika diperlukan
         // Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
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

  Future<void> _refreshProfileData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated && authProvider.token != null) {
      print('ProfileScreen: Refreshing profile data...');
      // Gunakan Future.wait untuk menjalankan keduanya secara paralel
      await Future.wait([
        authProvider.fetchUserProfile(),
        Provider.of<PropertyProvider>(context, listen: false)
            .fetchUserApprovedProperties(authProvider.token!),
      ]);
      print('ProfileScreen: Profile data refreshed.');
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data profil diperbarui.'), duration: Duration(seconds: 2)),
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
    final Color textOnThemeColor = Colors.black87;

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
                             _refreshProfileData(); // Coba muat ulang semua data
                          }
                        },
                        child: const Text('Coba Lagi'),
                      )
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshProfileData,
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
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.edit_outlined, color: textOnThemeColor),
                              label: Text("Edit Profil",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: textOnThemeColor)),
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
                                     // Tidak perlu refresh manual di sini jika AuthProvider sudah notifyListeners
                                     // dan UI profil (nama, bio) sudah di-consume dari AuthProvider.
                                     // Jika ada data lain yang perlu di-refresh, panggil _refreshProfileData()
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: themeColor,
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.article_outlined, color: textOnThemeColor),
                              label: Text("Kelola Iklan",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: textOnThemeColor)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MyDraftsScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: themeColor,
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                        ],
                      ),
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

                      Consumer<PropertyProvider>(
                        builder: (context, propertyProvider, child) {
                          if (propertyProvider.isLoadingUserApprovedProperties) {
                            return const Center(child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ));
                          }
                          if (propertyProvider.userApprovedPropertiesError != null) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column( // Tambah tombol coba lagi
                                  children: [
                                    Text('Error: ${propertyProvider.userApprovedPropertiesError}'),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                         if (authProvider.isAuthenticated && authProvider.token != null) {
                                          Provider.of<PropertyProvider>(context, listen: false)
                                            .fetchUserApprovedProperties(authProvider.token!);
                                         }
                                      },
                                      child: const Text('Coba Lagi'),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                          if (propertyProvider.userApprovedProperties.isEmpty) {
                            return Center(
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
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: propertyProvider.userApprovedProperties.length,
                            itemBuilder: (context, index) {
                              final property =
                                  propertyProvider.userApprovedProperties[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: PropertyCardProfile( // Menggunakan PropertyCardProfile
                                  property: property,
                                  isHorizontalVariant: false,
                                  showEditIcon: false,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MyPropertyDetailScreen(property: property),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}