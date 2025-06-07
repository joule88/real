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
  // Flag baru untuk memberi tahu SearchScreen agar fokus ke text field
  bool _triggerAutoFocusOnSearchScreen = false;

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
        autoOpenFilterModal: _triggerOpenFilterModalOnSearchScreen,
        autoFocusSearch: _triggerAutoFocusOnSearchScreen, // <-- Kirim flag
      ),
      const BookmarkScreen(),
      const ProfileScreen(),
    ];
    // Reset flag setelah digunakan
    if (_triggerOpenFilterModalOnSearchScreen) {
       _triggerOpenFilterModalOnSearchScreen = false;
    }
    if (_triggerAutoFocusOnSearchScreen) {
      _triggerAutoFocusOnSearchScreen = false;
    }
  }

  void changeTabAndPrepareSearch(
    int index, {
    String? keyword,
    Map<String, dynamic>? filters,
    bool autoOpenFilter = false,
    bool autoFocusSearch = false, // <-- Parameter baru
  }) {
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);

    if (index == 1) { // Target adalah SearchScreen
      propertyProvider.prepareSearchParameters(keyword: keyword, filters: filters);

      _searchScreenKey = UniqueKey();
      _triggerOpenFilterModalOnSearchScreen = autoOpenFilter;
      _triggerAutoFocusOnSearchScreen = autoFocusSearch; // <-- Set flag

      setState(() {
        _selectedIndex = index;
        _buildPages(); // Bangun ulang _pages dengan SearchScreen baru
      });

    } else if (index == 0 && _selectedIndex != 0) {
        setState(() {
            _homeScreenKey = UniqueKey();
            _buildPages();
            _selectedIndex = index;
        });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == 1 && index != 1) {
      Provider.of<PropertyProvider>(context, listen: false).resetSearchState();
      print("MainScreen: Leaving search tab, state has been reset.");
    }

    if (index == 1) {
      _searchScreenKey = UniqueKey();
    }

    if (index == 0 && _selectedIndex != 0) {
      _homeScreenKey = UniqueKey();
    }

    setState(() {
      _triggerOpenFilterModalOnSearchScreen = false; 
      _triggerAutoFocusOnSearchScreen = false; // <-- Selalu reset flag
      _buildPages();
      _selectedIndex = index;
    });
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