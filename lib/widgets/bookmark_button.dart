// lib/widgets/bookmark_button.dart
import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

// DIKEMBALIKAN KE STATEFULWIDGET UNTUK MENGAKTIFKAN ANIMASI
class BookmarkButton extends StatefulWidget {
  final bool isBookmarked;
  final VoidCallback onPressed;

  const BookmarkButton({
    super.key,
    required this.isBookmarked,
    required this.onPressed,
  });

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    // Membuat animasi yang membesar lalu kembali ke ukuran normal
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Jalankan animasi maju-mundur
    _controller.forward().then((_) {
      _controller.reverse();
    });
    // Panggil fungsi utamanya
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Icon(
            widget.isBookmarked ? EvaIcons.bookmark : EvaIcons.bookmarkOutline,
            color: Colors.black,
            size: 26,
          ),
        ),
      ),
    );
  }
}