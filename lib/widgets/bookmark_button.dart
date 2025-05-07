import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      lowerBound: 0.9,
      upperBound: 1.1,
    );
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _controller.drive(CurveTween(curve: Curves.easeOut)),
        child: Icon(
          widget.isBookmarked ? EvaIcons.bookmark : EvaIcons.bookmarkOutline,
          color: Colors.black,
          size: 26,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
