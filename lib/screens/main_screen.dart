// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real/provider/property_provider.dart';
import 'package:real/screens/home/home_screen.dart';
import 'package:real/screens/search/search_screen.dart';
import 'package:real/screens/bookmark/bookmark_screen.dart';
import 'package:real/screens/profile/profile_screen.dart';
import 'package:real/widgets/navbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  Key _homeScreenKey = UniqueKey();
  Key _searchScreenKey = UniqueKey();

  // Flag untuk memberi tahu SearchScreen agar membuka modal filter
  bool _triggerOpenFilterModalOnSearchScreen = false;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _buildPages();
  }

  void _buildPages() {
    _pages = [
      HomeScreen(key: _homeScreenKey),
      SearchScreen(
        key: _searchScreenKey,
        // Kirim flag ke SearchScreen
        autoOpenFilterModal: _triggerOpenFilterModalOnSearchScreen,
      ),
      const BookmarkScreen(),
      const ProfileScreen(),
    ];
    // Reset flag setelah digunakan untuk membangun _pages
    if (_triggerOpenFilterModalOnSearchScreen) {
       _triggerOpenFilterModalOnSearchScreen = false;
    }
  }

  void changeTabAndPrepareSearch(
    int index, {
    String? keyword,
    Map<String, dynamic>? filters,
    bool autoOpenFilter = false,
  }) {
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);

    if (index == 1) { // Target adalah SearchScreen
      propertyProvider.prepareSearchParameters(keyword: keyword, filters: filters);

      // Selalu berikan key baru untuk memastikan SearchScreen di-rebuild dengan parameter baru
      _searchScreenKey = UniqueKey();
      _triggerOpenFilterModalOnSearchScreen = autoOpenFilter;

      setState(() {
        _selectedIndex = index;
        _buildPages(); // Bangun ulang _pages dengan SearchScreen baru
      });

    } else if (index == 0 && _selectedIndex != 0) {
        setState(() {
            _homeScreenKey = UniqueKey();
            _buildPages(); // Bangun ulang halaman
            _selectedIndex = index;
        });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onItemTapped(int index) {
    // --- PERUBAHAN UTAMA UNTUK MERESET FILTER ---

    // 1. Deteksi jika kita meninggalkan tab Search (indeks 1)
    if (_selectedIndex == 1 && index != 1) {
      Provider.of<PropertyProvider>(context, listen: false).resetSearchState();
      print("MainScreen: Leaving search tab, state has been reset.");
    }

    // 2. Beri key baru ke SearchScreen setiap kali dipilih, agar initState-nya terpanggil kembali
    // Ini memastikan UI-nya juga ikut ter-reset sesuai dengan state provider yang sudah bersih.
    if (index == 1) {
      _searchScreenKey = UniqueKey();
    }

    // Logika untuk merefresh HomeScreen jika dipilih kembali
    if (index == 0 && _selectedIndex != 0) {
      _homeScreenKey = UniqueKey();
    }

    // 3. Set state untuk mengganti halaman dan membangun ulang daftar halaman dengan key yang baru
    setState(() {
      _triggerOpenFilterModalOnSearchScreen = false; // Selalu reset flag ini
      _buildPages(); // Penting untuk membangun ulang _pages dengan key yang baru
      _selectedIndex = index;
    });
    // --- AKHIR PERUBAHAN ---
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}
