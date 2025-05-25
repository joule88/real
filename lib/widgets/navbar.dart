import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

class CustomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

// Menghapus 'with SingleTickerProviderStateMixin' karena tidak ada AnimationController
class _CustomNavBarState extends State<CustomNavBar> {
  final Color navBgColor = const Color(0xFF182420);
  final Color selectedColor = const Color(0xFFDDEF6D);
  final Color unselectedColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 24, right: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 70,
          color: navBgColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, EvaIcons.home),
              _buildNavItem(1, EvaIcons.search),
              _buildNavItem(2, EvaIcons.bookmark),
              _buildNavItem(3, EvaIcons.person),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData iconData) {
    final bool isSelected = widget.selectedIndex == index;

    // Menghapus AnimatedContainer dan AnimatedScale
    return GestureDetector(
      onTap: () => widget.onItemTapped(index),
      behavior: HitTestBehavior.opaque, // Memastikan area tap mencakup padding
      child: Container(
        // Menggunakan Container biasa sebagai pengganti AnimatedContainer
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Icon(
          iconData,
          color: isSelected ? selectedColor : unselectedColor,
          size: isSelected ? 28 : 28, // Sedikit perbedaan ukuran jika item terpilih (opsional)
                                     // Jika ingin ukuran sama persis, gunakan 'size: 26' untuk keduanya.
        ),
      ),
    );
  }
}
