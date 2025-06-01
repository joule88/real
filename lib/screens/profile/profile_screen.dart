// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:real/models/user_model.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:real/provider/property_provider.dart';
import 'package:real/screens/profile/edit_profile_screen.dart';
import 'package:real/widgets/property_card_profile.dart';
import 'package:real/screens/my_drafts/my_drafts_screen.dart';
import 'package:real/screens/profile/my_property_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For better image handling

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
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData({bool isRefresh = false}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated && authProvider.token != null) {
      print('ProfileScreen: Loading initial data...');
      try {
        await Future.wait([
          authProvider.fetchUserProfile(), // Always fetch profile
          Provider.of<PropertyProvider>(context, listen: false)
              .fetchUserApprovedProperties(authProvider.token!),
        ]);
        if (isRefresh && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data profil diperbarui.'), duration: Duration(seconds: 2)),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat data: $error')),
          );
        }
      }
    } else {
      print('ProfileScreen: User not authenticated or token is null. Skipping fetches.');
    }
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
                        onPressed: () => _loadInitialData(isRefresh: true),
                        child: const Text('Coba Lagi'),
                      )
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadInitialData(isRefresh: true),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[200],
                            child: user.profileImage.isNotEmpty
                                ? ClipOval(
                                    child: CachedNetworkImage(
                                      key: ValueKey(user.profileImage), // Gunakan URL gambar sebagai key
                                      imageUrl: user.profileImage, // Fallback to profileImage if fullProfileImageUrl is not available
                                      placeholder: (context, url) => const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) {
                                        print("Error loading profile image in ProfileScreen: $error, URL: $url");
                                        return Icon(Icons.person, size: 40, color: Colors.grey[400]);
                                      },
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(Icons.person, size: 40, color: Colors.grey[400]),
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
                                if (user.phone.isNotEmpty) // Display phone
                                  Row(
                                    children: [
                                      Icon(Icons.phone_outlined, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        user.phone,
                                        style: GoogleFonts.poppins(
                                            fontSize: 13, color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                if (user.phone.isNotEmpty) const SizedBox(height: 2),
                                Text(
                                  user.bio.isNotEmpty ? user.bio : 'Belum ada bio.',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14, color: Colors.grey[600]),
                                  maxLines: 2, // Limit bio lines here
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
                              icon: Icon(Icons.edit_outlined, color: textOnThemeColor, size: 20),
                              label: Text("Edit Profil",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: textOnThemeColor)),
                              onPressed: () async {
                                final bool? profileWasUpdated = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditProfileScreen(currentUser: user),
                                  ),
                                );
                                if (profileWasUpdated == true && mounted) {
                                  // AuthProvider would have updated the user object
                                  // and notified listeners, so the UI rebuilds automatically.
                                  // If specific parts didn't update, ensure Consumer is used or call setState.
                                  print('ProfileScreen: Kembali dari Edit Profil dengan update.');
                                  // Optionally, force a specific data refresh if needed:
                                  // await authProvider.fetchUserProfile();
                                }
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
                              icon: Icon(Icons.article_outlined, color: textOnThemeColor, size: 20),
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
                          if (propertyProvider.isLoadingUserApprovedProperties && propertyProvider.userApprovedProperties.isEmpty) {
                            return const Center(child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ));
                          }
                          if (propertyProvider.userApprovedPropertiesError != null && propertyProvider.userApprovedProperties.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
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
                                child: PropertyCardProfile(
                                  property: property,
                                  isHorizontalVariant: false,
                                  showEditIcon: false,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MyPropertyDetailScreen(
                                          key: ValueKey(property.id),
                                          property: property,
                                        ),
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