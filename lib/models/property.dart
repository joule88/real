// lib/models/property.dart
import 'package:flutter/foundation.dart';
import 'dart:convert'; // Diperlukan untuk jsonDecode
import 'user_model.dart'; // Pastikan User model diimpor
import 'package:real/services/api_constants.dart';

enum PropertyStatus {
  draft,
  pendingVerification,
  approved,
  rejected,
  sold,
  archived
}

class Property extends ChangeNotifier { // Pastikan extends ChangeNotifier
  final String id;
  String title;
  String description;
  final String uploader;
  User? uploaderInfo;
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
  bool _isFavorite; // Private field
  String? rejectionReason;
  DateTime? submissionDate;
  DateTime? approvalDate;

  String? mainView;
  String? listingAgeCategory;
  String? propertyLabel;

  int bookmarkCount;
  int viewsCount;
  int inquiriesCount;
  Map<String, dynamic> viewStatistics;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.uploader,
    this.uploaderInfo,
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
    bool isFavorite = false, // Terima dari constructor
    this.rejectionReason,
    this.submissionDate,
    this.approvalDate,
    this.bookmarkCount = 0,
    this.viewsCount = 0,
    this.inquiriesCount = 0,
    this.mainView,
    this.listingAgeCategory,
    this.propertyLabel,
    this.viewStatistics = const {},
  }) : _isFavorite = isFavorite; // Inisialisasi private field

  // Getter untuk isFavorite
  bool get isFavorite => _isFavorite;

  // Setter atau method untuk mengubah isFavorite dan notify
  set isFavorite(bool value) {
    if (_isFavorite != value) {
      _isFavorite = value;
      notifyListeners();
    }
  }

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners(); // PENTING: Ini akan memberitahu widget yang mendengarkan Property ini
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

    const String laravelApiBaseUrl = ApiConstants.laravelApiBaseUrl;
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
      uploader: json['user_id'] ?? (json['owner'] is Map ? (json['owner']['_id'] ?? json['owner']['id'] ?? '') : json['owner_id'] ?? ''),
      uploaderInfo: json['owner'] != null && json['owner'] is Map<String, dynamic>
          ? User.fromJson(json['owner'] as Map<String, dynamic>)
          : (json['uploader'] != null && json['uploader'] is Map<String, dynamic>
              ? User.fromJson(json['uploader'] as Map<String, dynamic>)
              : null),
      imageUrl: parsedMainImageUrl,
      additionalImageUrls: parsedAdditionalImageUrls,
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
      furnishings: json['furnishing'] ?? json['furnishings'] ?? '',
      status: statusValue,
      // Terima status favorit dari API
      isFavorite: json['is_favorited_by_user'] ?? json['isFavorite'] ?? false,
      submissionDate: json['submissionDate'] != null ? DateTime.tryParse(json['submissionDate']) : null,
      approvalDate: json['approvalDate'] != null ? DateTime.tryParse(json['approvalDate']) : null,
      rejectionReason: json['rejectionReason'],
      bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
      viewsCount: (json['total_views_count'] as num?)?.toInt() ?? (json['views_count'] as num?)?.toInt() ?? 0,
      inquiriesCount: (json['inquiriesCount'] as num?)?.toInt() ?? 0,
      mainView: json['mainView'],
      listingAgeCategory: json['listingAgeCategory'] as String?,
      propertyLabel: json['propertyLabel'] as String?,
      viewStatistics: json['view_statistics'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['view_statistics'])
        : (json['viewStatistics'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['viewStatistics'])
            : const {}),
    );
  }

  // ... (copyWith dan toJson bisa tetap sama atau disesuaikan jika perlu) ...
   Property copyWith({
    String? id,
    String? title,
    String? description,
    String? uploader,
    User? uploaderInfo,
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
    ValueGetter<DateTime?>? submissionDate,
    ValueGetter<DateTime?>? approvalDate,
    int? bookmarkCount,
    int? viewsCount,
    int? inquiriesCount,
    ValueGetter<String?>? mainView,
    ValueGetter<String?>? listingAgeCategory,
    ValueGetter<String?>? propertyLabel,
    Map<String, dynamic>? viewStatistics,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      uploader: uploader ?? this.uploader,
      uploaderInfo: uploaderInfo ?? this.uploaderInfo,
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
      viewStatistics: viewStatistics ?? this.viewStatistics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
    };
  }
}