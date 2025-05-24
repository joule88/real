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
  String address; // city dan stateZip sudah dihapus, address berisi alamat lengkap
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

  String? mainView; // Untuk Pemandangan Utama
  String? listingAgeCategory; // Untuk Kategori Usia Listing
  String? propertyLabel; // Untuk Label Properti

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
    required this.address, // Hanya address
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
    this.mainView,
    this.listingAgeCategory,
    this.propertyLabel,
  }) : _isFavorite = isFavorite;

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      uploader: json['uploader'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      additionalImageUrls: List<String>.from(json['additionalImageUrls'] ?? []),
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : (json['price'] ?? 0.0),
      address: json['address'] ?? '', // Hanya address
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      areaSqft: (json['areaSqft'] is int) ? (json['areaSqft'] as int).toDouble() : (json['areaSqft'] ?? 0.0),
      propertyType: json['propertyType'] ?? '',
      furnishings: json['furnishings'] ?? '',
      status: PropertyStatus.values.firstWhere(
        (e) => e.toString() == 'PropertyStatus.${json['status']}',
        orElse: () => PropertyStatus.draft,
      ),
      submissionDate: json['submissionDate'] != null ? DateTime.parse(json['submissionDate']) : null,
      approvalDate: json['approvalDate'] != null ? DateTime.parse(json['approvalDate']) : null,
      rejectionReason: json['rejectionReason'],
      bookmarkCount: json['bookmarkCount'] ?? 0,
      viewsCount: json['viewsCount'] ?? 0,
      inquiriesCount: json['inquiriesCount'] ?? 0,
      mainView: json['mainView'],
      listingAgeCategory: json['listingAgeCategory'],
      propertyLabel: json['propertyLabel'],
      // isFavorite tidak diambil dari JSON di sini, biasanya dikelola secara lokal atau API terpisah
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'uploader': uploader,
      'imageUrl': imageUrl,
      'additionalImageUrls': additionalImageUrls,
      'price': price,
      'address': address, // Hanya address
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'areaSqft': areaSqft, // Pastikan backend Anda juga menggunakan 'areaSqft' atau 'sizeMin' secara konsisten
      'propertyType': propertyType,
      'furnishings': furnishings,
      'status': status.toString().split('.').last,
      'rejectionReason': rejectionReason,
      'submissionDate': submissionDate?.toIso8601String(),
      'approvalDate': approvalDate?.toIso8601String(),
      'bookmarkCount': bookmarkCount,
      'viewsCount': viewsCount,
      'inquiriesCount': inquiriesCount,
      'mainView': mainView,
      'listingAgeCategory': listingAgeCategory,
      'propertyLabel': propertyLabel,
    };
  }

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
      submissionDate = DateTime.now();
    }
    if (newStatus == PropertyStatus.approved) {
      approvalDate = DateTime.now();
    }
    notifyListeners();
  }

  void updateDetails({
    required String title,
    required String description,
    required String imageUrl,
    required List<String> additionalImageUrls,
    required double price,
    required String address, // Hanya address
    required int bedrooms,
    required int bathrooms,
    required double areaSqft,
    required String propertyType,
    required String furnishings,
    String? mainView,
    String? listingAgeCategory,
    String? propertyLabel,
  }) {
    this.title = title;
    this.description = description;
    this.imageUrl = imageUrl;
    this.additionalImageUrls = additionalImageUrls;
    this.price = price;
    this.address = address; // Hanya address
    this.bedrooms = bedrooms;
    this.bathrooms = bathrooms;
    this.areaSqft = areaSqft;
    this.propertyType = propertyType;
    this.furnishings = furnishings;
    this.mainView = mainView;
    this.listingAgeCategory = listingAgeCategory;
    this.propertyLabel = propertyLabel;
    notifyListeners();
  }
}