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
    // agar tidak selalu terbuka saat SearchScreen di-rebuild karena alasan lain
    if (_triggerOpenFilterModalOnSearchScreen) {
       _triggerOpenFilterModalOnSearchScreen = false;
    }
  }

  // Modifikasi method ini untuk menerima flag autoOpenFilter
  void changeTabAndPrepareSearch(
    int index, {
    String? keyword,
    Map<String, dynamic>? filters,
    bool autoOpenFilter = false, // Parameter baru
  }) {
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    
    if (index == 1) { // Target adalah SearchScreen
      propertyProvider.prepareSearchParameters(keyword: keyword, filters: filters);
      
      bool needsRebuild = false;
      if (_selectedIndex == index || autoOpenFilter) { // Jika sudah di SearchScreen atau diminta buka filter
        _searchScreenKey = UniqueKey(); // Ganti key untuk memaksa rebuild SearchScreen
        needsRebuild = true;
      }
      // Set flag untuk membuka modal jika diminta
      _triggerOpenFilterModalOnSearchScreen = autoOpenFilter;

      if (needsRebuild) {
        // Panggil _buildPages di dalam setState agar SearchScreen baru dibuat dengan flag yang benar
        setState(() {
          _selectedIndex = index;
          _buildPages(); // Ini akan membangun ulang _pages dengan SearchScreen baru
        });
      } else {
        setState(() {
          _selectedIndex = index;
          // Tidak perlu _buildPages() jika tidak ada key change atau flag autoOpen
        });
      }

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
    if (index == 0 && _selectedIndex != 0) {
      setState(() {
        _homeScreenKey = UniqueKey();
        _triggerOpenFilterModalOnSearchScreen = false; // Pastikan reset flag jika ke home
        _buildPages();
        _selectedIndex = index;
      });
    } else if (index == 1) { // Jika tab Search diklik dari navbar
      // Tidak auto open filter, reset parameter pencarian
      Provider.of<PropertyProvider>(context, listen: false).prepareSearchParameters(keyword: null, filters: null);
      bool needsRebuild = false;
      if (_selectedIndex == index) { // Jika sudah di search screen, refresh dengan key baru
         _searchScreenKey = UniqueKey();
         needsRebuild = true;
      }
      setState(() {
        _triggerOpenFilterModalOnSearchScreen = false; // Tidak auto open dari navbar tap
        if(needsRebuild) _buildPages();
        _selectedIndex = index;
      });
    }
    else {
      setState(() {
        _triggerOpenFilterModalOnSearchScreen = false; // Pastikan reset flag jika ke tab lain
        _selectedIndex = index;
      });
    }
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