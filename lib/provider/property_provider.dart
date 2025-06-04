// lib/provider/property_provider.dart
import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/property_service.dart';
import '../services/api_services.dart';
import '../services/api_constants.dart'; 
import 'dart:convert';                
import 'package:http/http.dart' as http; 

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

  // --- State untuk Pencarian ---
  List<Property> _searchedProperties = [];
  bool _isLoadingSearch = false;
  String? _searchError;
  int _searchResultCurrentPage = 1;
  int _searchResultLastPage = 1;
  bool _hasMoreSearchResults = true;

  // Menyimpan keyword dan filter yang akan digunakan oleh SearchScreen
  String _pendingSearchKeyword = "";
  Map<String, dynamic> _pendingSearchFilters = {};
  bool _needsSearchExecution = false; // Flag untuk menandakan SearchScreen perlu eksekusi

  List<Property> get searchedProperties => _searchedProperties;
  bool get isLoadingSearch => _isLoadingSearch;
  String? get searchError => _searchError;
  bool get hasMoreSearchResults => _hasMoreSearchResults;
  String get pendingSearchKeyword => _pendingSearchKeyword; // Getter
  Map<String, dynamic> get pendingSearchFilters => _pendingSearchFilters; // Getter
  bool get needsSearchExecution => _needsSearchExecution; // Getter


  List<Property> _bookmarkedProperties = [];
  bool _isLoadingBookmarkedProperties = false;
  String? _bookmarkedPropertiesError;

  List<Property> get bookmarkedProperties => _bookmarkedProperties;
  bool get isLoadingBookmarkedProperties => _isLoadingBookmarkedProperties;
  String? get bookmarkedPropertiesError => _bookmarkedPropertiesError;

  Future<Property?> fetchPublicPropertyDetail(String propertyId, String? token) async {
    final url = Uri.parse('${ApiConstants.laravelApiBaseUrl}/properties/public/$propertyId');
    print('PropertyProvider: Memanggil fetchPublicPropertyDetail untuk ID $propertyId dari $url');

    try {
      final headers = {
        'Accept': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(url, headers: headers);
      print('PropertyProvider: Status respons fetchPublicPropertyDetail: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final property = Property.fromJson(responseData['data'] as Map<String, dynamic>);
          print('PropertyProvider: Properti publik ${property.id} berhasil diambil. Pengunggah: ${property.uploaderInfo?.name}, Views: ${property.viewsCount}');
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

  void _updatePropertyInLocalLists(Property updatedProperty) {
    int indexInPublic = _publicProperties.indexWhere((p) => p.id == updatedProperty.id);
    if (indexInPublic != -1) {
      _publicProperties[indexInPublic] = updatedProperty;
    }
    int indexInSearch = _searchedProperties.indexWhere((p) => p.id == updatedProperty.id);
    if (indexInSearch != -1) {
      _searchedProperties[indexInSearch] = updatedProperty;
    }
    int indexInBookmarks = _bookmarkedProperties.indexWhere((p) => p.id == updatedProperty.id);
    if (indexInBookmarks != -1) {
        _bookmarkedProperties[indexInBookmarks] = updatedProperty;
    }
    // notifyListeners(); // Tidak selalu perlu, tergantung kebutuhan UI
  }

  Future<void> togglePropertyBookmark(String propertyId, String? token) async {
    Property? propertyToUpdate;

    Property? findAndUpdateInList(List<Property> list, String id) {
      int index = list.indexWhere((p) => p.id == id);
      if (index != -1) {
        return list[index];
      }
      return null;
    }

    propertyToUpdate = findAndUpdateInList(_publicProperties, propertyId);
    propertyToUpdate ??= findAndUpdateInList(_searchedProperties, propertyId);
    propertyToUpdate ??= findAndUpdateInList(_userApprovedProperties, propertyId);
    propertyToUpdate ??= findAndUpdateInList(_userProperties, propertyId);
    propertyToUpdate ??= findAndUpdateInList(_bookmarkedProperties, propertyId);

    if (propertyToUpdate != null) {
      propertyToUpdate.toggleFavorite();
      // TODO: Panggil API untuk menyimpan status bookmark di backend
      _updateLocalBookmarkedList(propertyToUpdate);
      notifyListeners();
    } else {
      print("PropertyProvider: Property with ID $propertyId not found for bookmarking.");
    }
  }

  void _updateLocalBookmarkedList(Property property) {
    if (property.isFavorite) {
      if (!_bookmarkedProperties.any((p) => p.id == property.id)) {
        _bookmarkedProperties.add(property);
      }
    } else {
      _bookmarkedProperties.removeWhere((p) => p.id == property.id);
    }
  }

  Future<void> fetchBookmarkedProperties(String? token) async {
    _isLoadingBookmarkedProperties = true;
    _bookmarkedPropertiesError = null;
    notifyListeners();

    // TODO: Implementasi pengambilan bookmark dari API
    // Untuk sementara, gunakan data lokal
    List<Property> allKnownProperties = [
      ..._publicProperties, ..._searchedProperties, ..._userApprovedProperties,
      ..._userProperties, ..._userSoldProperties
    ];
    final Map<String, Property> uniqueFavoriteProperties = {};
    for (var prop in allKnownProperties) {
      if (prop.isFavorite) {
        uniqueFavoriteProperties[prop.id] = prop;
      }
    }
    _bookmarkedProperties = uniqueFavoriteProperties.values.toList();
    print("PropertyProvider: Fetched local bookmarks. Count: ${_bookmarkedProperties.length}");

    _isLoadingBookmarkedProperties = false;
    notifyListeners();
  }

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
      final result = await _propertyService.getUserProperties(token, statuses: ['approved']);
      if (result['success'] == true) {
        List<dynamic> propertiesData = result['properties'] ?? [];
        _userApprovedProperties = propertiesData.map((data) => Property.fromJson(data as Map<String, dynamic>)).toList();
      } else {
        _userApprovedPropertiesError = result['message'] ?? 'Gagal mengambil properti approved.';
      }
    } catch (e) {
      _userApprovedPropertiesError = 'Terjadi kesalahan: $e';
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
      final result = await _propertyService.getUserProperties(token, statuses: ['sold']);
      if (result['success'] == true) {
        List<dynamic> propertiesData = result['properties'] ?? [];
        _userSoldProperties = propertiesData.map((data) => Property.fromJson(data as Map<String, dynamic>)).toList();
      } else {
        _userSoldPropertiesError = result['message'] ?? 'Gagal mengambil properti sold.';
      }
    } catch (e) {
      _userSoldPropertiesError = 'Terjadi kesalahan: $e';
    } finally {
      _isLoadingUserSoldProperties = false;
      notifyListeners();
    }
  }

  String? _currentPublicCategory; // Menyimpan kategori terakhir yang di-fetch untuk public
  Map<String, dynamic> _currentPublicFilters = {}; // Menyimpan filter terakhir

  // MODIFIKASI DI SINI: Tambahkan parameter category dan filters
  Future<void> fetchPublicProperties({
    bool loadMore = false, 
    String? category,
    Map<String, dynamic>? filters, // <-- Tambahkan parameter filter
  }) async {
    if (_isLoadingPublicProperties && !loadMore) return;
    if (loadMore && !_hasMorePublicProperties) return;
    if (loadMore && _isLoadingPublicProperties) return;

    _isLoadingPublicProperties = true;
    if (!loadMore) {
      _publicPropertiesError = null;
      _publicPropertiesCurrentPage = 1;
      _publicProperties = []; 
      _hasMorePublicProperties = true;
      _currentPublicCategory = category; // Simpan kategori
      _currentPublicFilters = filters ?? {}; // Simpan filter
    } else {
      // Jika loadMore, pastikan category dan filters konsisten dengan fetch awal
      category = _currentPublicCategory;
      filters = _currentPublicFilters;
    }
    notifyListeners();

    try {
      final result = await ApiService.getPublicProperties(
        page: _publicPropertiesCurrentPage,
        category: category, 
        filters: filters, // <-- Kirim filter ke ApiService
      );

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
          print('PropertyProvider: Tidak ada properti publik yang ditemukan untuk kategori: $category, filters: $filters.');
        }
      } else {
        _publicPropertiesError = result['message'] ?? 'Gagal mengambil properti publik.';
        _hasMorePublicProperties = false;
      }
    } catch (e) {
      _publicPropertiesError = 'Terjadi kesalahan jaringan: $e';
      _hasMorePublicProperties = false;
      print('PropertyProvider fetchPublicProperties Exception: $e');
    } finally {
      _isLoadingPublicProperties = false;
      notifyListeners();
    }
  }

  // MODIFIKASI DI SINI: Tambahkan parameter category opsional
  Future<void> performKeywordSearch({bool loadMore = false}) async {
    // Gunakan _pendingSearchKeyword dan _pendingSearchFilters
    final String keywordToSearch = _pendingSearchKeyword;
    final Map<String, dynamic> filtersToApply = Map.from(_pendingSearchFilters);

    if (_isLoadingSearch && !loadMore) return;
    if (loadMore && !_hasMoreSearchResults && _searchedProperties.isNotEmpty) return; // Jangan load more jika sudah tidak ada & ada hasil
    if (loadMore && _isLoadingSearch) return;

    _isLoadingSearch = true;
    _needsSearchExecution = false; // Setelah dimulai, flag dimatikan

    if (!loadMore) {
      _searchError = null;
      _searchResultCurrentPage = 1;
      _searchedProperties = []; // Dikosongkan di prepareSearchParameters atau di sini jika new search
      _hasMoreSearchResults = true;
    }
    notifyListeners();

    try {
      final result = await ApiService.getPublicProperties(
        page: _searchResultCurrentPage,
        keyword: keywordToSearch,
        filters: filtersToApply,
        // category: null, // Kategori tidak digunakan bersamaan dengan keyword search di sini, atau bisa ditambahkan
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
          print('PropertyProvider: Tidak ada properti ditemukan untuk keyword: "${keywordToSearch}", filters: $filtersToApply');
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

  // Method untuk mempersiapkan parameter pencarian/filter
  void prepareSearchParameters({String? keyword, Map<String, dynamic>? filters}) {
    _pendingSearchKeyword = keyword ?? "";
    _pendingSearchFilters = filters ?? {};
    _needsSearchExecution = true; // Tandai bahwa pencarian perlu dieksekusi
    
    // Reset hasil pencarian sebelumnya
    _searchedProperties = [];
    _searchError = null;
    _searchResultCurrentPage = 1;
    _searchResultLastPage = 1;
    _hasMoreSearchResults = true;
    _isLoadingSearch = false; // Akan di-set true saat performKeywordSearch dipanggil
    
    print("PropertyProvider: PrepareSearch. Keyword: $_pendingSearchKeyword, Filters: $_pendingSearchFilters");
    notifyListeners(); // Beritahu listener (misal SearchScreen jika sudah aktif)
  }

  // Method clearSearchResults bisa disederhanakan atau digabung ke prepareSearchParameters
  void clearSearchResults() {
    prepareSearchParameters(keyword: null, filters: null); // Ini akan me-reset semua parameter pencarian
  }

  void updatePropertyListsState(Property updatedProperty) {
    int indexInUserProperties = _userProperties.indexWhere((p) => p.id == updatedProperty.id);
    bool isInManageableGroup = [
      PropertyStatus.draft, PropertyStatus.pendingVerification,
      PropertyStatus.rejected, PropertyStatus.archived
    ].contains(updatedProperty.status);

    if (isInManageableGroup) {
      if (indexInUserProperties != -1) _userProperties[indexInUserProperties] = updatedProperty;
      else _userProperties.add(updatedProperty);
    } else {
      if (indexInUserProperties != -1) _userProperties.removeAt(indexInUserProperties);
    }

    int indexInApprovedProperties = _userApprovedProperties.indexWhere((p) => p.id == updatedProperty.id);
    if (updatedProperty.status == PropertyStatus.approved) {
      if (indexInApprovedProperties != -1) _userApprovedProperties[indexInApprovedProperties] = updatedProperty;
      else _userApprovedProperties.add(updatedProperty);
    } else {
      if (indexInApprovedProperties != -1) _userApprovedProperties.removeAt(indexInApprovedProperties);
    }

    int indexInSoldProperties = _userSoldProperties.indexWhere((p) => p.id == updatedProperty.id);
    if (updatedProperty.status == PropertyStatus.sold) {
      if (indexInSoldProperties != -1) _userSoldProperties[indexInSoldProperties] = updatedProperty;
      else _userSoldProperties.add(updatedProperty);
    } else {
      if (indexInSoldProperties != -1) _userSoldProperties.removeAt(indexInSoldProperties);
    }

    int publicIndex = _publicProperties.indexWhere((p) => p.id == updatedProperty.id);
    if (publicIndex != -1) _publicProperties[publicIndex] = updatedProperty;
    
    int searchedIndex = _searchedProperties.indexWhere((p) => p.id == updatedProperty.id);
    if (searchedIndex != -1) _searchedProperties[searchedIndex] = updatedProperty;

    int bookmarkedIndex = _bookmarkedProperties.indexWhere((p) => p.id == updatedProperty.id);
    if (bookmarkedIndex != -1) {
      if (updatedProperty.isFavorite) _bookmarkedProperties[bookmarkedIndex] = updatedProperty;
      else _bookmarkedProperties.removeAt(bookmarkedIndex);
    } else if (updatedProperty.isFavorite) {
      _bookmarkedProperties.add(updatedProperty);
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> updatePropertyStatus(String propertyId, PropertyStatus newStatus, String token) async {
    Property? propertyToUpdate;
    int approvedIdx = _userApprovedProperties.indexWhere((p) => p.id == propertyId);
    if (approvedIdx != -1) propertyToUpdate = _userApprovedProperties[approvedIdx];
    else {
      int manageableIdx = _userProperties.indexWhere((p) => p.id == propertyId);
      if (manageableIdx != -1) propertyToUpdate = _userProperties[manageableIdx];
      else {
        int soldIdx = _userSoldProperties.indexWhere((p) => p.id == propertyId);
        if (soldIdx != -1) propertyToUpdate = _userSoldProperties[soldIdx];
      }
    }

    if (propertyToUpdate == null) return {'success': false, 'message': 'Properti tidak ditemukan.'};

    Property propertyWithNewStatus = propertyToUpdate.copyWith(
      status: newStatus,
      submissionDate: () => newStatus == PropertyStatus.pendingVerification ? DateTime.now() : propertyToUpdate!.submissionDate,
      approvalDate: () => newStatus == PropertyStatus.approved ? DateTime.now() : propertyToUpdate!.approvalDate,
    );

    final result = await _propertyService.submitProperty(
      property: propertyWithNewStatus, newSelectedImages: [],
      existingImageUrls: propertyToUpdate.imageUrl.isNotEmpty ? [propertyToUpdate.imageUrl, ...propertyToUpdate.additionalImageUrls] : [],
      token: token
    );

    if (result['success'] == true) {
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
    _publicProperties.removeWhere((p) => p.id == propertyId);
    _searchedProperties.removeWhere((p) => p.id == propertyId);
    _bookmarkedProperties.removeWhere((p) => p.id == propertyId);
    notifyListeners();
  }

  Future<Map<String, dynamic>?> fetchPropertyStatistics(String propertyId, String? token) async {
    if (token == null) return null;
    final url = Uri.parse('${ApiConstants.laravelApiBaseUrl}/properties/$propertyId/statistics');
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] is Map<String, dynamic>) {
          return responseData['data'] as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print('Exception fetching statistics: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>> deleteProperty(String propertyId, String token) async {
    final result = await _propertyService.deletePropertyApi(propertyId, token);
    if (result['success'] == true) {
      removePropertyById(propertyId); // Memanggil method lokal untuk update UI
      return {'success': true, 'message': result['message'] ?? 'Properti berhasil dihapus.'};
    } else {
      _userPropertiesError = result['message'];
      notifyListeners();
      return {'success': false, 'message': result['message'] ?? 'Gagal menghapus properti.'};
    }
  }
}