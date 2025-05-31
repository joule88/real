// lib/provider/property_provider.dart
import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/property_service.dart';
import '../services/api_services.dart';
import '../services/api_constants.dart'; // Pastikan path ini benar
import 'dart:convert';                 // Untuk jsonDecode
import 'package:http/http.dart' as http; // Untuk http.get

class PropertyProvider extends ChangeNotifier {
  List<Property> _userProperties = [];
  bool _isLoadingUserProperties = false;
  String? _userPropertiesError;

  List<Property> get userProperties => _userProperties;
  bool get isLoadingUserProperties => _isLoadingUserProperties;
  String? get userPropertiesError => _userPropertiesError;

  List<Property> _userApprovedProperties = [];
  bool _isLoadingUserApprovedProperties = false;
  String? _userApprovedPropertiesError;

  List<Property> get userApprovedProperties => _userApprovedProperties;
  bool get isLoadingUserApprovedProperties => _isLoadingUserApprovedProperties;
  String? get userApprovedPropertiesError => _userApprovedPropertiesError;

  List<Property> _userSoldProperties = [];
  bool _isLoadingUserSoldProperties = false;
  String? _userSoldPropertiesError;

  List<Property> get userSoldProperties => _userSoldProperties;
  bool get isLoadingUserSoldProperties => _isLoadingUserSoldProperties;
  String? get userSoldPropertiesError => _userSoldPropertiesError;

  final PropertyService _propertyService = PropertyService();

  List<Property> _publicProperties = [];
  bool _isLoadingPublicProperties = false;
  String? _publicPropertiesError;
  int _publicPropertiesCurrentPage = 1;
  int _publicPropertiesLastPage = 1;
  bool _hasMorePublicProperties = true;

  List<Property> get publicProperties => _publicProperties;
  bool get isLoadingPublicProperties => _isLoadingPublicProperties;
  String? get publicPropertiesError => _publicPropertiesError;
  bool get hasMorePublicProperties => _hasMorePublicProperties;

  List<Property> _searchedProperties = [];
  bool _isLoadingSearch = false;
  String? _searchError;
  int _searchResultCurrentPage = 1;
  int _searchResultLastPage = 1;
  bool _hasMoreSearchResults = true;
  String _currentSearchKeyword = "";

  List<Property> get searchedProperties => _searchedProperties;
  bool get isLoadingSearch => _isLoadingSearch;
  String? get searchError => _searchError;
  bool get hasMoreSearchResults => _hasMoreSearchResults;
  String get currentSearchKeyword => _currentSearchKeyword;

  // --- 👇 METHOD BARU DITAMBAHKAN DI SINI 👇 ---
  Future<Property?> fetchPublicPropertyDetail(String propertyId, String? token) async {
    // Endpoint ini di Laravel (showPublicProperty) akan mencatat view
    final url = Uri.parse('${ApiConstants.laravelApiBaseUrl}/properties/public/$propertyId');
    print('PropertyProvider: Memanggil fetchPublicPropertyDetail untuk ID $propertyId dari $url');

    try {
      final headers = {
        'Accept': 'application/json',
      };
      // Token bisa jadi tidak wajib untuk endpoint publik ini,
      // tapi backend bisa menggunakannya untuk mencatat user_id jika ada (auth('api')->check()).
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(url, headers: headers);

      print('PropertyProvider: Status respons fetchPublicPropertyDetail: ${response.statusCode}');
      // Sebaiknya jangan print body jika responsnya besar, kecuali untuk debugging singkat
      // print('PropertyProvider: Body respons fetchPublicPropertyDetail: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          // Data properti yang diterima dari backend sudah termasuk total viewsCount terbaru
          // (jika backend Anda mengirimkan field viewsCount/total_views_count yang terupdate).
          final property = Property.fromJson(responseData['data'] as Map<String, dynamic>);
          print('PropertyProvider: Properti publik ${property.id} berhasil diambil. Total Views dari backend: ${property.viewsCount}');
          
          // Helper untuk memperbarui properti yang sama di list lokal (jika ada)
          // agar viewsCount-nya konsisten jika ditampilkan di list setelah detail dibuka.
          _updatePropertyInLocalLists(property);

          return property;
        } else {
          print('PropertyProvider: Gagal mengambil detail properti publik - Pesan dari server: ${responseData['message']}');
          return null;
        }
      } else {
        print('PropertyProvider: Error mengambil detail properti publik - Status: ${response.statusCode}, Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('PropertyProvider: Exception saat mengambil detail properti publik - $e');
      return null;
    }
  }

  // Helper method untuk update properti di list lokal (opsional tapi bagus untuk konsistensi UI)
  void _updatePropertyInLocalLists(Property updatedProperty) {
    // Update di _publicProperties
    int indexInPublic = _publicProperties.indexWhere((p) => p.id == updatedProperty.id);
    if (indexInPublic != -1) {
      // Ganti objek lama dengan yang baru yang memiliki viewsCount terupdate
      _publicProperties[indexInPublic] = updatedProperty;
    }
    // Update di _searchedProperties
    int indexInSearch = _searchedProperties.indexWhere((p) => p.id == updatedProperty.id);
    if (indexInSearch != -1) {
      _searchedProperties[indexInSearch] = updatedProperty;
    }
    // Anda mungkin tidak perlu notifyListeners() di sini jika perubahan ini tidak langsung
    // mempengaruhi UI list yang sedang aktif ditampilkan. Jika mempengaruhi, maka panggil.
    // notifyListeners();
  }
  // --- 👆 METHOD BARU SELESAI DI SINI 👆 ---


  Future<void> fetchUserManageableProperties(String token) async {
    _isLoadingUserProperties = true;
    _userPropertiesError = null;
    _userProperties = [];
    notifyListeners();

    try {
      final result = await _propertyService.getUserProperties(
        token,
        statuses: ['draft', 'pendingVerification', 'rejected', 'archived'],
      );

      if (result['success'] == true) {
        List<dynamic> propertiesData = result['properties'] ?? [];
        _userProperties = propertiesData.map((data) => Property.fromJson(data as Map<String, dynamic>)).toList();
      } else {
        _userPropertiesError = result['message'] ?? 'Gagal mengambil properti kelolaan pengguna.';
      }
    } catch (e) {
      _userPropertiesError = 'Terjadi kesalahan: $e';
      print('PropertyProvider fetchUserManageableProperties Error: $e');
    } finally {
      _isLoadingUserProperties = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserApprovedProperties(String token) async {
    _isLoadingUserApprovedProperties = true;
    _userApprovedPropertiesError = null;
    _userApprovedProperties = [];
    notifyListeners();

    try {
      final result = await _propertyService.getUserProperties(
        token,
        statuses: ['approved'],
      );

      if (result['success'] == true) {
        List<dynamic> propertiesData = result['properties'] ?? [];
        _userApprovedProperties = propertiesData
            .map((data) => Property.fromJson(data as Map<String, dynamic>))
            .toList();
      } else {
        _userApprovedPropertiesError =
            result['message'] ?? 'Gagal mengambil properti approved pengguna.';
      }
    } catch (e) {
      _userApprovedPropertiesError =
          'Terjadi kesalahan: $e';
      print('PropertyProvider fetchUserApprovedProperties Error: $e');
    } finally {
      _isLoadingUserApprovedProperties = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserSoldProperties(String token) async {
    _isLoadingUserSoldProperties = true;
    _userSoldPropertiesError = null;
    _userSoldProperties = [];
    notifyListeners();

    try {
      final result = await _propertyService.getUserProperties(
        token,
        statuses: ['sold'],
      );

      if (result['success'] == true) {
        List<dynamic> propertiesData = result['properties'] ?? [];
        _userSoldProperties = propertiesData
            .map((data) => Property.fromJson(data as Map<String, dynamic>))
            .toList();
        if (_userSoldProperties.isEmpty) {
          print('PropertyProvider: Tidak ada properti sold yang ditemukan untuk pengguna ini.');
        }
      } else {
        _userSoldPropertiesError =
            result['message'] ?? 'Gagal mengambil properti sold pengguna.';
      }
    } catch (e) {
      _userSoldPropertiesError =
          'Terjadi kesalahan saat mengambil properti sold pengguna: $e';
      print('PropertyProvider fetchUserSoldProperties Error: $e');
    } finally {
      _isLoadingUserSoldProperties = false;
      notifyListeners();
    }
  }

  Future<void> fetchPublicProperties({bool loadMore = false}) async {
    if (_isLoadingPublicProperties && !loadMore) return;
    if (loadMore && !_hasMorePublicProperties) return;
    if (loadMore && _isLoadingPublicProperties) return;

    _isLoadingPublicProperties = true;
    if (!loadMore) {
      _publicPropertiesError = null;
      _publicPropertiesCurrentPage = 1;
      _publicProperties = [];
      _hasMorePublicProperties = true;
    }
    notifyListeners();

    try {
      final result = await ApiService.getPublicProperties(page: _publicPropertiesCurrentPage);

      if (result['success'] == true) {
        final List<dynamic> propertiesData = result['properties'] ?? [];
        final List<Property> fetchedProperties = propertiesData
            .map((data) => Property.fromJson(data as Map<String, dynamic>))
            .toList();

        if (loadMore) {
          _publicProperties.addAll(fetchedProperties);
        } else {
          _publicProperties = fetchedProperties;
        }

        int apiCurrentPage = result['currentPage'] as int? ?? _publicPropertiesCurrentPage;
        _publicPropertiesLastPage = result['lastPage'] as int? ?? _publicPropertiesLastPage;

        if (fetchedProperties.isNotEmpty) {
            _hasMorePublicProperties = apiCurrentPage < _publicPropertiesLastPage;
            _publicPropertiesCurrentPage = apiCurrentPage + 1;
        } else {
            _hasMorePublicProperties = false;
        }

        if (_publicProperties.isEmpty && !loadMore) {
          print('PropertyProvider: Tidak ada properti publik yang ditemukan (halaman pertama kosong).');
        }
      } else {
        _publicPropertiesError = result['message'] ?? 'Gagal mengambil properti publik.';
        _hasMorePublicProperties = false;
      }
    } catch (e) {
      _publicPropertiesError = 'Terjadi kesalahan jaringan saat mengambil properti publik: $e';
      _hasMorePublicProperties = false;
      print('PropertyProvider fetchPublicProperties Exception: $e');
    } finally {
      _isLoadingPublicProperties = false;
      notifyListeners();
    }
  }

  Future<void> performKeywordSearch(String keyword, {bool loadMore = false}) async {
    if (_isLoadingSearch && !loadMore) return;
    if (loadMore && !_hasMoreSearchResults) return;
    if (loadMore && _isLoadingSearch) return;

    _isLoadingSearch = true;

    if (!loadMore) {
      _searchError = null;
      _searchResultCurrentPage = 1;
      _searchedProperties = [];
      _currentSearchKeyword = keyword;
      _hasMoreSearchResults = true;
    }
    notifyListeners();

    try {
      final result = await ApiService.getPublicProperties(
        page: _searchResultCurrentPage,
        keyword: _currentSearchKeyword,
      );

      if (result['success'] == true) {
        final List<dynamic> propertiesData = result['properties'] ?? [];
        final List<Property> fetchedProperties = propertiesData
            .map((data) => Property.fromJson(data as Map<String, dynamic>))
            .toList();

        if (loadMore) {
          _searchedProperties.addAll(fetchedProperties);
        } else {
          _searchedProperties = fetchedProperties;
        }

        int apiCurrentPage = result['currentPage'] as int? ?? _searchResultCurrentPage;
        _searchResultLastPage = result['lastPage'] as int? ?? _searchResultLastPage;

        if (fetchedProperties.isNotEmpty) {
          _hasMoreSearchResults = apiCurrentPage < _searchResultLastPage;
          _searchResultCurrentPage = apiCurrentPage + 1;
        } else {
          _hasMoreSearchResults = false;
        }

        if (_searchedProperties.isEmpty && !loadMore) {
          print('PropertyProvider: Tidak ada properti ditemukan untuk keyword: "$_currentSearchKeyword"');
        }
      } else {
        _searchError = result['message'] ?? 'Gagal melakukan pencarian properti.';
        _hasMoreSearchResults = false;
      }
    } catch (e) {
      _searchError = 'Terjadi kesalahan jaringan saat pencarian: $e';
      _hasMoreSearchResults = false;
      print('PropertyProvider performKeywordSearch Exception: $e');
    } finally {
      _isLoadingSearch = false;
      notifyListeners();
    }
  }

  void clearSearchResults() {
    _searchedProperties = [];
    _searchError = null;
    _currentSearchKeyword = "";
    _searchResultCurrentPage = 1;
    _searchResultLastPage = 1;
    _hasMoreSearchResults = true;
    _isLoadingSearch = false;
    notifyListeners();
    print('PropertyProvider: Hasil pencarian telah dibersihkan.');
  }

  void updatePropertyListsState(Property updatedProperty) {
    int indexInUserProperties = _userProperties.indexWhere((p) => p.id == updatedProperty.id);
    bool isInManageableGroup = [
      PropertyStatus.draft,
      PropertyStatus.pendingVerification,
      PropertyStatus.rejected,
      PropertyStatus.archived
    ].contains(updatedProperty.status);

    if (isInManageableGroup) {
      if (indexInUserProperties != -1) {
        _userProperties[indexInUserProperties] = updatedProperty;
      } else {
        _userProperties.add(updatedProperty);
      }
    } else {
      if (indexInUserProperties != -1) {
        _userProperties.removeAt(indexInUserProperties);
      }
    }

    int indexInApprovedProperties = _userApprovedProperties.indexWhere((p) => p.id == updatedProperty.id);
    if (updatedProperty.status == PropertyStatus.approved) {
      if (indexInApprovedProperties != -1) {
        _userApprovedProperties[indexInApprovedProperties] = updatedProperty;
      } else {
        _userApprovedProperties.add(updatedProperty);
      }
    } else {
      if (indexInApprovedProperties != -1) {
        _userApprovedProperties.removeAt(indexInApprovedProperties);
      }
    }

    int indexInSoldProperties = _userSoldProperties.indexWhere((p) => p.id == updatedProperty.id);
    if (updatedProperty.status == PropertyStatus.sold) {
      if (indexInSoldProperties != -1) {
        _userSoldProperties[indexInSoldProperties] = updatedProperty;
      } else {
        _userSoldProperties.add(updatedProperty);
      }
    } else {
      if (indexInSoldProperties != -1) {
        _userSoldProperties.removeAt(indexInSoldProperties);
      }
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> updatePropertyStatus(String propertyId, PropertyStatus newStatus, String token) async {
    Property? propertyToUpdate;

    int approvedIdx = _userApprovedProperties.indexWhere((p) => p.id == propertyId);
    if (approvedIdx != -1) {
      propertyToUpdate = _userApprovedProperties[approvedIdx];
    } else {
      int manageableIdx = _userProperties.indexWhere((p) => p.id == propertyId);
      if (manageableIdx != -1) {
        propertyToUpdate = _userProperties[manageableIdx];
      } else {
        int soldIdx = _userSoldProperties.indexWhere((p) => p.id == propertyId);
        if (soldIdx != -1) {
            propertyToUpdate = _userSoldProperties[soldIdx];
        }
      }
    }

    if (propertyToUpdate == null) {
        return {'success': false, 'message': 'Properti tidak ditemukan untuk diupdate statusnya.'};
    }

    // Buat objek baru dengan status yang diperbarui
    Property propertyWithNewStatus = propertyToUpdate.copyWith(
      status: newStatus,
      // Jika status berubah ke pendingVerification, set submissionDate
      submissionDate: () => newStatus == PropertyStatus.pendingVerification ? DateTime.now() : propertyToUpdate!.submissionDate,
      // Jika status berubah ke approved, set approvalDate
      approvalDate: () => newStatus == PropertyStatus.approved ? DateTime.now() : propertyToUpdate!.approvalDate,
    );

    print('Updating status for property ${propertyWithNewStatus.id} from ${propertyToUpdate.status.name} to ${newStatus.name}');

    final result = await _propertyService.submitProperty(
      property: propertyWithNewStatus,
      newSelectedImages: [], // Tidak ada gambar baru saat hanya update status
      existingImageUrls: propertyToUpdate.imageUrl.isNotEmpty ? [propertyToUpdate.imageUrl, ...propertyToUpdate.additionalImageUrls] : [],
      token: token
    );

    if (result['success'] == true) {
      // Ambil data properti terbaru dari respons API jika ada, atau gunakan propertyWithNewStatus
      Property finalUpdatedProperty = result['data'] != null && result['data']['data'] != null
        ? Property.fromJson(result['data']['data'] as Map<String, dynamic>)
        : propertyWithNewStatus;

      updatePropertyListsState(finalUpdatedProperty);
    }
    return result;
  }

  void removePropertyById(String propertyId) {
    _userProperties.removeWhere((p) => p.id == propertyId);
    _userApprovedProperties.removeWhere((p) => p.id == propertyId);
    _userSoldProperties.removeWhere((p) => p.id == propertyId);
    notifyListeners();
  }

  Future<Map<String, dynamic>?> fetchPropertyStatistics(String propertyId, String? token) async {
    if (token == null) {
      print('PropertyProvider: Token is null, cannot fetch statistics.');
      return null;
    }
    // Pastikan ApiConstants.laravelApiBaseUrl sudah benar
    final url = Uri.parse('${ApiConstants.laravelApiBaseUrl}/properties/$propertyId/statistics');
    print('PropertyProvider: Fetching statistics from $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      print('PropertyProvider (fetchPropertyStatistics): Status Respons: ${response.statusCode}');
       print('PropertyProvider (fetchPropertyStatistics): Body Respons: ${response.body}'); // Ini penting!
      // print('PropertyProvider: Statistics response body: ${response.body}'); // Hati-hati jika body besar

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] is Map<String, dynamic>) {
          print('PropertyProvider: Statistics fetched successfully for property $propertyId.');
          return responseData['data'] as Map<String, dynamic>;
        } else {
          print('PropertyProvider: Failed to fetch statistics - ${responseData['message']}');
          return null;
        }
      } else {
        print('PropertyProvider: Error fetching statistics - ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('PropertyProvider: Exception fetching statistics - $e');
      return null;
    }
  }
  
  // Anda sudah memiliki method recordPropertyView di bawah, jadi ini duplikat.
  // Jika Anda ingin ini berbeda, beri nama lain.
  // Future<void> recordPropertyView(String propertyId, String? token) async {
  //   // ...
  // }
}