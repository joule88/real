// lib/models/property.dart
import 'package:flutter/foundation.dart';
import 'dart:convert'; // Diperlukan untuk jsonDecode

// Enum status properti
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

  String? mainView;
  String? listingAgeCategory;
  String? propertyLabel;

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
    List<String> allOriginalImageUrls = [];
    dynamic imageField = json['image']; // Field dari backend adalah 'image'

    if (imageField is List) {
      // Jika backend mengirim array URL langsung (ideal)
      allOriginalImageUrls = List<String>.from(imageField.map((item) => item.toString()));
    } else if (imageField is String) {
      // Fallback jika 'image' adalah string berisi JSON array
      try {
        if (imageField.startsWith("[") && imageField.endsWith("]")) {
          List<dynamic> decodedList = jsonDecode(imageField);
          allOriginalImageUrls = decodedList.map((e) => e.toString()).toList();
        } else if (imageField.isNotEmpty) {
           // Jika hanya satu URL string (bukan array JSON string)
           if (Uri.tryParse(imageField)?.hasAbsolutePath ?? false) {
             allOriginalImageUrls.add(imageField);
           }
        }
      } catch (e) {
        print("Error parsing 'image' field string in Property.fromJson: $e. Raw value: $imageField");
      }
    }

    // --- PENTING: Sesuaikan URL Basis Laravel Anda di sini ---
    const String laravelBaseUrl = "http://127.0.0.1:8000/api"; // <<< GANTI INI DENGAN URL SERVER LARAVEL ANDA

    String parsedMainImageUrl = "";
    List<String> parsedAdditionalImageUrls = [];

    if (allOriginalImageUrls.isNotEmpty) {
      try {
        String firstUrl = allOriginalImageUrls.first;
        if (firstUrl.isNotEmpty && (Uri.tryParse(firstUrl)?.hasAbsolutePath ?? false)) {
            Uri originalUri = Uri.parse(firstUrl);
            if (originalUri.pathSegments.isNotEmpty) {
                String filename = originalUri.pathSegments.last;
                parsedMainImageUrl = "$laravelBaseUrl/serve-image/properties/$filename";
            } else {
                 print("Warning: Main image URL has no path segments: $firstUrl. Using original URL.");
                 parsedMainImageUrl = firstUrl; // Fallback ke URL asli jika tidak ada path segment
            }
        } else {
            print("Warning: Invalid or empty main image URL in allOriginalImageUrls: $firstUrl");
        }
      } catch (e) {
        print("Error parsing original main image URL to get filename: ${allOriginalImageUrls.first} - $e");
        if (allOriginalImageUrls.first.isNotEmpty) {
            // parsedMainImageUrl = allOriginalImageUrls.first; // Fallback jika error, tapi bisa kembali ke CORS
        }
      }
    }

    if (allOriginalImageUrls.length > 1) {
      parsedAdditionalImageUrls = allOriginalImageUrls.sublist(1).map((url) {
        try {
          if (url.isNotEmpty && (Uri.tryParse(url)?.hasAbsolutePath ?? false)) {
              Uri originalUri = Uri.parse(url);
              if (originalUri.pathSegments.isNotEmpty) {
                  String filename = originalUri.pathSegments.last;
                  return "$laravelBaseUrl/serve-image/properties/$filename";
              } else {
                  print("Warning: Additional image URL has no path segments: $url. Using original URL.");
                  return url; // Fallback ke URL asli
              }
          } else {
              print("Warning: Invalid or empty additional image URL: $url");
              return "";
          }
        } catch (e) {
          print("Error parsing original additional image URL to get filename: $url - $e");
          // return url; // Fallback jika error
          return "";
        }
      }).where((url) => url.isNotEmpty).toList();
    }

    print('DEBUG Property.fromJson (Using Proxied Route): mainImageUrl = $parsedMainImageUrl, additionalCount: ${parsedAdditionalImageUrls.length}');

    return Property(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      uploader: json['user_id'] ?? json['uploader'] ?? '',
      imageUrl: parsedMainImageUrl,
      additionalImageUrls: parsedAdditionalImageUrls,
      price: (json['price'] is String)
              ? (double.tryParse(json['price']) ?? 0.0)
              : ((json['price'] as num?)?.toDouble() ?? 0.0),
      address: json['address'] ?? '',
      bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 0,
      bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 0,
      areaSqft: (json['sizeMin'] != null)
                  ? ((json['sizeMin'] as num).toDouble())
                  : ((json['areaSqft'] as num?)?.toDouble() ?? 0.0),
      propertyType: json['propertyType'] ?? '',
      furnishings: json['furnishing'] ?? '',
      status: PropertyStatus.values.firstWhere(
        (e) => e.toString() == 'PropertyStatus.${json['status']}',
        orElse: () => PropertyStatus.draft,
      ),
      submissionDate: json['submissionDate'] != null ? DateTime.tryParse(json['submissionDate']) : null,
      approvalDate: json['approvalDate'] != null ? DateTime.tryParse(json['approvalDate']) : null,
      rejectionReason: json['rejectionReason'],
      bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
      viewsCount: (json['viewsCount'] as num?)?.toInt() ?? 0,
      inquiriesCount: (json['inquiriesCount'] as num?)?.toInt() ?? 0,
      mainView: json['mainView'],
      listingAgeCategory: json['listingAgeCategory'],
      propertyLabel: json['propertyLabel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'uploader': uploader,
      'price': price,
      'address': address,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'sizeMin': areaSqft,
      'propertyType': propertyType,
      'furnishing': furnishings,
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
    required String address,
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
    this.address = address;
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