import 'package:flutter/foundation.dart';

// Enum status properti
enum PropertyStatus {
  draft, // Baru dibuat atau sedang diedit oleh pengguna
  pendingVerification, // Diajukan oleh pengguna, menunggu review admin
  approved, // Diverifikasi admin, tayang di publik
  rejected, // Ditolak oleh admin
  sold,
  archived // Diarsipkan oleh pengguna (opsional)
}

class Property extends ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String uploader; // User ID atau nama pengunggah
  // Tambahkan List<String> untuk imageUrls jika ingin multiple images
  // Untuk saat ini kita masih pakai satu imageUrl utama
  final String imageUrl; // Atau List<String> imageUrls jika multiple
  final List<String> additionalImageUrls; // Untuk foto-foto tambahan
  final double price;
  final String address;
  final String city;
  final String stateZip; // Bisa juga nama provinsi atau kode pos saja
  final int bedrooms;
  final int bathrooms;
  final double areaSqft;
  final String propertyType; // Cth: Rumah, Apartemen, Villa
  final String furnishings; // Cth: Full Furnished, Semi, Unfurnished
  PropertyStatus status; // Status properti saat ini
  bool _isFavorite;
  String? rejectionReason; // Alasan penolakan oleh admin (jika status rejected)
  DateTime? submissionDate; // Tanggal pengajuan (opsional)
  DateTime? approvalDate; // Tanggal approval (opsional)

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.uploader,
    required this.imageUrl, // Gambar utama
    this.additionalImageUrls = const [], // Defaultnya list kosong
    required this.price,
    required this.address,
    required this.city,
    required this.stateZip,
    required this.bedrooms,
    required this.bathrooms,
    required this.areaSqft,
    required this.propertyType,
    required this.furnishings,
    this.status = PropertyStatus.draft, // Default status adalah draft
    bool isFavorite = false,
    this.rejectionReason,
    this.submissionDate,
    this.approvalDate,
  }) : _isFavorite = isFavorite;

  bool get isFavorite => _isFavorite;

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners();
  }

  // Helper untuk mengubah status (nantinya bisa dipanggil setelah interaksi API)
  void updateStatus(PropertyStatus newStatus, {String? reason}) {
    status = newStatus;
    if (newStatus == PropertyStatus.rejected) {
      rejectionReason = reason;
    }
    if (newStatus == PropertyStatus.pendingVerification) {
      submissionDate = DateTime.now();
    }
    if (newStatus == PropertyStatus.approved) {
      approvalDate = DateTime.now();
    }
    notifyListeners();
  }

  // Tambahkan factory constructor atau method lain jika perlu untuk parsing dari/ke JSON (MongoDB)
}
