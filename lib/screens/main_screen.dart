import 'package:flutter/material.dart';
import 'package:real/screens/home/home_screen.dart';
import 'package:real/screens/search/search_screen.dart';
import 'package:real/screens/bookmark/bookmark_screen.dart';
import 'package:real/screens/profile/profile_screen.dart';
import 'package:real/widgets/navbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    SearchScreen(),
    BookmarkScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    // Ganti nama method agar konsisten dengan parameter di CustomNavBar
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors
          .transparent, // Seringkali lebih baik Colors.white atau tema default
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
              onItemTapped: _onItemTapped, // Gunakan nama method yang konsisten
              // Pastikan jumlah item di CustomNavBar sesuai dengan jumlah _pages
            ),
          ),
        ],
      ),
    );
  }
}
