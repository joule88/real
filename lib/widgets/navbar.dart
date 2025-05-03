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

class _CustomNavBarState extends State<CustomNavBar>
    with SingleTickerProviderStateMixin {
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

    return GestureDetector(
      onTap: () => widget.onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: AnimatedScale(
          scale: isSelected ? 1.3 : 1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: Icon(
            iconData,
            color: isSelected ? selectedColor : unselectedColor,
            size: 26,
          ),
        ),
      ),
    );
  }
}
