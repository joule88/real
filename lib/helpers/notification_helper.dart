import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Fungsi helper untuk menampilkan notifikasi dari atas
void showTopNotification(BuildContext context, String message, {bool isError = false}) {
  if (!context.mounted) return;

  final overlay = Overlay.of(context);
  // Membuat OverlayEntry yang unik setiap kali fungsi dipanggil
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      // Menggunakan Positioned untuk menempatkan notifikasi di dalam Overlay
      top: 0,
      left: 0,
      right: 0,
      child: TopNotificationWidget(
        message: message,
        isError: isError,
        onDismiss: () {
          // Fungsi untuk menghapus notifikasi saat disentuh
          if (overlayEntry.mounted) {
            overlayEntry.remove();
          }
        },
      ),
    ),
  );

  // Menambahkan notifikasi ke dalam tree widget
  overlay.insert(overlayEntry);

  // Menghapus notifikasi secara otomatis setelah 4 detik
  Future.delayed(const Duration(seconds: 4), () {
    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  });
}

// Widget untuk UI notifikasi
class TopNotificationWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const TopNotificationWidget({
    super.key,
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  @override
  State<TopNotificationWidget> createState() => _TopNotificationWidgetState();
}

class _TopNotificationWidgetState extends State<TopNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    // Controller untuk animasi masuk
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    // Mendefinisikan animasi slide dari atas ke bawah
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    // Memulai animasi
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: SafeArea( // Memastikan notifikasi tidak tumpang tindih dengan status bar
        child: GestureDetector(
          onTap: widget.onDismiss,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.isError ? const Color(0xFFD32F2F) : const Color(0xFF388E3C), // Warna merah/hijau
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
