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

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          // Navbar mengambang
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onTap,
            ),
          ),
        ],
      ),
    );
  }
}
