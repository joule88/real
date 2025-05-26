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
    List<String> allImageReferences = []; // Akan berisi nama file atau referensi gambar lainnya
    dynamic imageField = json['image'];

    // Logika untuk parsing field 'image' yang mungkin berupa:
    // 1. String JSON dari array nama file (misalnya, "[\"file1.jpg\", \"file2.png\"]")
    // 2. Array nama file langsung (jika backend mengirimnya sebagai array)
    // 3. String nama file tunggal
    if (imageField is List) {
      allImageReferences = List<String>.from(imageField.map((item) => item.toString()));
    } else if (imageField is String) {
      if (imageField.startsWith("[") && imageField.endsWith("]")) {
        try {
          List<dynamic> decodedList = jsonDecode(imageField);
          allImageReferences = decodedList.map((e) => e.toString()).toList();
        } catch (e) {
          print("Error parsing 'image' field as JSON array string: $e. Raw value: $imageField");
          // Jika gagal parse sebagai array JSON dan stringnya tidak kosong, anggap sebagai nama file tunggal
          if (imageField.isNotEmpty) {
            allImageReferences.add(imageField);
          }
        }
      } else if (imageField.isNotEmpty) {
        // Jika bukan array JSON string tapi string tidak kosong, anggap nama file tunggal
        allImageReferences.add(imageField);
      }
    } else if (imageField != null) {
      print("Warning: 'image' field has an unexpected type: ${imageField.runtimeType}. Value: $imageField");
    }

    // Base URL API Laravel Anda (tempat rute /serve-image berada)
    const String laravelApiBaseUrl = "http://127.0.0.1:8000/api";

    String parsedMainImageUrl = "";
    List<String> parsedAdditionalImageUrls = [];

    if (allImageReferences.isNotEmpty) {
      String firstRef = allImageReferences.first;
      // Ekstrak nama file jika firstRef adalah URL lengkap (sebagai fallback jika data lama masih ada)
      // Namun, dengan backend yang menyimpan nama file, ini seharusnya hanya nama file.
      String mainFilename = firstRef.contains('/') ? firstRef.split('/').last : firstRef;
      if (mainFilename.isNotEmpty) {
        parsedMainImageUrl = "$laravelApiBaseUrl/serve-image/properties/$mainFilename";
      }
    }

    if (allImageReferences.length > 1) {
      parsedAdditionalImageUrls = allImageReferences.sublist(1).map((ref) {
        String additionalFilename = ref.contains('/') ? ref.split('/').last : ref;
        if (additionalFilename.isNotEmpty) {
          return "$laravelApiBaseUrl/serve-image/properties/$additionalFilename";
        }
        return "";
      }).where((url) => url.isNotEmpty).toList();
    }
    // print('DEBUG Property.fromJson: mainImageUrl = $parsedMainImageUrl, additionalCount: ${parsedAdditionalImageUrls.length}');


    // Logika Parsing Status (tetap sama seperti versi perbaikan sebelumnya)
    PropertyStatus statusValue = PropertyStatus.draft;
    dynamic statusDynamicFromJson = json['status'];
    String? statusStringFromJson;

    if (statusDynamicFromJson is String) {
      statusStringFromJson = statusDynamicFromJson;
    } else if (statusDynamicFromJson is bool) {
      print("Warning: Received boolean for status: $statusDynamicFromJson for property ID ${json['_id'] ?? json['id'] ?? 'N/A'}. Defaulting to draft.");
    } else if (statusDynamicFromJson != null) {
      statusStringFromJson = statusDynamicFromJson.toString();
       print("Warning: Received unexpected type for status: ${statusDynamicFromJson.runtimeType} ('$statusStringFromJson') for property ID ${json['_id'] ?? json['id'] ?? 'N/A'}. Attempting to parse.");
    }

    if (statusStringFromJson != null && statusStringFromJson.isNotEmpty) {
      try {
        statusValue = PropertyStatus.values.firstWhere(
          (e) => e.name.toLowerCase() == statusStringFromJson!.toLowerCase(),
        );
      } catch (e) {
        print("Warning: Unknown status string '$statusStringFromJson' received from backend for property ID ${json['_id'] ?? json['id'] ?? 'N/A'}. Defaulting to draft. Error: $e");
      }
    } else {
        if (!(statusDynamicFromJson is bool)) { // Jangan cetak lagi jika sudah dicetak sebagai boolean
             print("Warning: Status string is null, empty, or unhandled non-string type for property ID ${json['_id'] ?? json['id'] ?? 'N/A'}. Defaulting to draft.");
        }
    }

    return Property(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      uploader: json['user_id'] ?? json['uploader'] ?? '',
      imageUrl: parsedMainImageUrl, // Menggunakan URL yang sudah dibangun
      additionalImageUrls: parsedAdditionalImageUrls, // Menggunakan URL yang sudah dibangun
      price: (json['price'] is String)
              ? (double.tryParse(json['price']) ?? 0.0)
              : ((json['price'] as num?)?.toDouble() ?? 0.0),
      address: json['address'] as String? ?? json['Address'] as String? ?? '',
      bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 0,
      bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 0,
      areaSqft: (json['sizeMin'] != null)
                  ? ((json['sizeMin'] as num).toDouble())
                  : ((json['areaSqft'] as num?)?.toDouble() ?? 0.0),
      propertyType: json['propertyType'] ?? '',
      furnishings: json['furnishing'] ?? '',
      status: statusValue,
      submissionDate: json['submissionDate'] != null ? DateTime.tryParse(json['submissionDate']) : null,
      approvalDate: json['approvalDate'] != null ? DateTime.tryParse(json['approvalDate']) : null,
      rejectionReason: json['rejectionReason'],
      bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
      viewsCount: (json['viewsCount'] as num?)?.toInt() ?? 0,
      inquiriesCount: (json['inquiriesCount'] as num?)?.toInt() ?? 0,
      mainView: json['mainView'],
      listingAgeCategory: json['listingAgeCategory'] as String?,
      propertyLabel: json['propertyLabel'] as String?,
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
      'status': status.name,
      'rejectionReason': rejectionReason,
      'submissionDate': submissionDate?.toIso8601String(),
      'approvalDate': approvalDate?.toIso8601String(),
      'bookmarkCount': bookmarkCount,
      'viewsCount': viewsCount,
      'inquiriesCount': inquiriesCount,
      'mainView': mainView,
      'listingAgeCategory': listingAgeCategory,
      'propertyLabel': propertyLabel,
      // 'image' tidak perlu dikirim dari sini jika PropertyService yang mengelola file
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
