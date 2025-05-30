// lib/models/property.dart
import 'package:flutter/foundation.dart';
import 'dart:convert'; // Diperlukan untuk jsonDecode

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

  factory Property.empty() {
    return Property(
      id: '',
      title: '',
      description: '',
      uploader: '',
      imageUrl: '',
      additionalImageUrls: [],
      price: 0.0,
      address: '',
      bedrooms: 0,
      bathrooms: 0,
      areaSqft: 0.0,
      propertyType: '',
      furnishings: '',
      status: PropertyStatus.draft,
      isFavorite: false,
      rejectionReason: null,
      submissionDate: null,
      approvalDate: null,
      bookmarkCount: 0,
      viewsCount: 0,
      inquiriesCount: 0,
      mainView: null,
      listingAgeCategory: null,
      propertyLabel: null,
    );
  }

  Property copyWith({
    String? id,
    String? title,
    String? description,
    String? uploader,
    String? imageUrl,
    List<String>? additionalImageUrls,
    double? price,
    String? address,
    int? bedrooms,
    int? bathrooms,
    double? areaSqft,
    String? propertyType,
    String? furnishings,
    PropertyStatus? status,
    bool? isFavorite,
    String? rejectionReason,
    ValueGetter<DateTime?>? submissionDate, // Untuk handle null
    ValueGetter<DateTime?>? approvalDate,   // Untuk handle null
    int? bookmarkCount,
    int? viewsCount,
    int? inquiriesCount,
    ValueGetter<String?>? mainView,
    ValueGetter<String?>? listingAgeCategory,
    ValueGetter<String?>? propertyLabel,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      uploader: uploader ?? this.uploader,
      imageUrl: imageUrl ?? this.imageUrl,
      additionalImageUrls: additionalImageUrls ?? this.additionalImageUrls,
      price: price ?? this.price,
      address: address ?? this.address,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      areaSqft: areaSqft ?? this.areaSqft,
      propertyType: propertyType ?? this.propertyType,
      furnishings: furnishings ?? this.furnishings,
      status: status ?? this.status,
      isFavorite: isFavorite ?? _isFavorite,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      submissionDate: submissionDate != null ? submissionDate() : this.submissionDate,
      approvalDate: approvalDate != null ? approvalDate() : this.approvalDate,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      viewsCount: viewsCount ?? this.viewsCount,
      inquiriesCount: inquiriesCount ?? this.inquiriesCount,
      mainView: mainView != null ? mainView() : this.mainView,
      listingAgeCategory: listingAgeCategory != null ? listingAgeCategory() : this.listingAgeCategory,
      propertyLabel: propertyLabel != null ? propertyLabel() : this.propertyLabel,
    );
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    List<String> allImageReferences = [];
    dynamic imageField = json['image'];

    if (imageField is List) {
      allImageReferences = List<String>.from(imageField.map((item) => item.toString()));
    } else if (imageField is String) {
      if (imageField.startsWith("[") && imageField.endsWith("]")) {
        try {
          List<dynamic> decodedList = jsonDecode(imageField);
          allImageReferences = decodedList.map((e) => e.toString()).toList();
        } catch (e) {
          if (kDebugMode) {
            print("Error parsing 'image' field as JSON array string: $e. Raw value: $imageField");
          }
          if (imageField.isNotEmpty) {
            allImageReferences.add(imageField);
          }
        }
      } else if (imageField.isNotEmpty) {
        allImageReferences.add(imageField);
      }
    } else if (imageField != null) {
      if (kDebugMode) {
        print("Warning: 'image' field has an unexpected type: ${imageField.runtimeType}. Value: $imageField");
      }
    }

    const String laravelApiBaseUrl = "http://127.0.0.1:8000/api"; // Sesuaikan jika berbeda
    String parsedMainImageUrl = "";
    List<String> parsedAdditionalImageUrls = [];

    if (allImageReferences.isNotEmpty) {
      String firstRef = allImageReferences.first;
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
    
    PropertyStatus statusValue = PropertyStatus.draft;
    dynamic statusDynamicFromJson = json['status'];
    String? statusStringFromJson;

    if (statusDynamicFromJson is String) {
      statusStringFromJson = statusDynamicFromJson;
    } else if (statusDynamicFromJson is bool) {
      if (kDebugMode) {
        print("Warning: Received boolean for status: $statusDynamicFromJson for property ID ${json['_id'] ?? json['id'] ?? 'N/A'}. Defaulting to draft.");
      }
    } else if (statusDynamicFromJson != null) {
      statusStringFromJson = statusDynamicFromJson.toString();
       if (kDebugMode) {
         print("Warning: Received unexpected type for status: ${statusDynamicFromJson.runtimeType} ('$statusStringFromJson') for property ID ${json['_id'] ?? json['id'] ?? 'N/A'}. Attempting to parse.");
       }
    }

    if (statusStringFromJson != null && statusStringFromJson.isNotEmpty) {
      try {
        statusValue = PropertyStatus.values.firstWhere(
          (e) => e.name.toLowerCase() == statusStringFromJson!.toLowerCase(),
        );
      } catch (e) {
        if (kDebugMode) {
          print("Warning: Unknown status string '$statusStringFromJson' received from backend for property ID ${json['_id'] ?? json['id'] ?? 'N/A'}. Defaulting to draft. Error: $e");
        }
      }
    } else {
        if (statusDynamicFromJson is! bool) { 
             if (kDebugMode) {
               print("Warning: Status string is null, empty, or unhandled non-string type for property ID ${json['_id'] ?? json['id'] ?? 'N/A'}. Defaulting to draft.");
             }
        }
    }

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
      address: json['address'] as String? ?? json['Address'] as String? ?? '',
      bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 0,
      bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 0,
      areaSqft: (json['sizeMin'] != null) // Perhatikan ini, mungkin 'sizeMin' atau 'areaSqft'
                  ? ((json['sizeMin'] as num).toDouble())
                  : ((json['areaSqft'] as num?)?.toDouble() ?? 0.0),
      propertyType: json['propertyType'] ?? '',
      furnishings: json['furnishing'] ?? json['furnishings'] ?? '', // Cek kedua ejaan
      status: statusValue,
      submissionDate: json['submissionDate'] != null ? DateTime.tryParse(json['submissionDate']) : null,
      approvalDate: json['approvalDate'] != null ? DateTime.tryParse(json['approvalDate']) : null,
      rejectionReason: json['rejectionReason'],
      // isFavorite: json['is_favorite'] ?? false, // Sesuaikan dengan nama field di JSON jika ada
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
      'id': id,
      'title': title,
      'description': description,
      'uploader': uploader,
      // 'imageUrl': imageUrl, // Biasanya tidak dikirim balik, backend mengelola path
      // 'additionalImageUrls': additionalImageUrls, // Sama seperti imageUrl
      'price': price,
      'address': address,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'sizeMin': areaSqft, // Cocokkan dengan nama field di backend (sizeMin atau areaSqft)
      'propertyType': propertyType,
      'furnishing': furnishings, // Cocokkan dengan nama field di backend
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