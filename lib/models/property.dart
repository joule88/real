// lib/models/property.dart
import 'package:flutter/foundation.dart';

// Enum status properti (pastikan sudah ada)
enum PropertyStatus {
  draft,
  pendingVerification,
  approved,
  rejected,
  sold,
  archived
}

class Property extends ChangeNotifier {
  final String id;
  String title;
  String description;
  final String uploader;
  String imageUrl;
  List<String> additionalImageUrls;
  double price;
  String address;
  String city;
  String stateZip;
  int bedrooms;
  int bathrooms;
  double areaSqft;
  String propertyType;
  String furnishings;
  PropertyStatus status;
  bool _isFavorite;
  String? rejectionReason;
  DateTime? submissionDate;
  DateTime? approvalDate;

  // Field baru untuk statistik
  int bookmarkCount;
  int viewsCount;
  int inquiriesCount;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.uploader,
    required this.imageUrl,
    this.additionalImageUrls = const [],
    required this.price,
    required this.address,
    required this.city,
    required this.stateZip,
    required this.bedrooms,
    required this.bathrooms,
    required this.areaSqft,
    required this.propertyType,
    required this.furnishings,
    this.status = PropertyStatus.draft,
    bool isFavorite = false,
    this.rejectionReason,
    this.submissionDate,
    this.approvalDate,
    this.bookmarkCount = 0,
    this.viewsCount = 0,
    this.inquiriesCount = 0,
  }) : _isFavorite = isFavorite;

  bool get isFavorite => _isFavorite;

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners();
  }

  void updateStatus(PropertyStatus newStatus, {String? reason}) {
    status = newStatus;
    if (newStatus == PropertyStatus.rejected) {
      rejectionReason = reason;
    }
    if (newStatus == PropertyStatus.pendingVerification) {
      submissionDate = DateTime.now(); // Set tanggal saat diajukan
    }
    if (newStatus == PropertyStatus.approved) {
      approvalDate = DateTime.now(); // Set tanggal saat disetujui
    }
    notifyListeners();
  }

  // Jika Anda ingin data properti bisa diupdate dari form edit dan tercermin
  // di seluruh aplikasi (jika menggunakan ChangeNotifier untuk list global),
  // Anda bisa menambahkan method seperti ini:
  void updateDetails({
    required String title,
    required String description,
    required String imageUrl,
    required List<String> additionalImageUrls,
    required double price,
    required String address,
    required String city,
    required String stateZip,
    required int bedrooms,
    required int bathrooms,
    required double areaSqft,
    required String propertyType,
    required String furnishings,
    // jangan update status dari sini, gunakan updateStatus()
  }) {
    this.title = title;
    this.description = description;
    this.imageUrl = imageUrl;
    this.additionalImageUrls = additionalImageUrls;
    this.price = price;
    this.address = address;
    this.city = city;
    this.stateZip = stateZip;
    this.bedrooms = bedrooms;
    this.bathrooms = bathrooms;
    this.areaSqft = areaSqft;
    this.propertyType = propertyType;
    this.furnishings = furnishings;
    notifyListeners();
  }
}
