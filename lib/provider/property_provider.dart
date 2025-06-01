// lib/provider/property_provider.dart
import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/property_service.dart';
import '../services/api_services.dart';
import '../services/api_constants.dart'; // Pastikan path ini benar
import 'dart:convert';                // Untuk jsonDecode
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
          print('PropertyProvider: Properti publik ${property.id} berhasil diambil. Total Views dari backend: ${property.viewsCount}');
          _updatePropertyInLocalLists(property); // Helper dari teman Anda
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

  // Helper method dari teman Anda tetap ada
  void _updatePropertyInLocalLists(Property updatedProperty) {
    int indexInPublic = _publicProperties.indexWhere((p) => p.id == updatedProperty.id);
    if (indexInPublic != -1) {
      _publicProperties[indexInPublic] = updatedProperty;
    }
    int indexInSearch = _searchedProperties.indexWhere((p) => p.id == updatedProperty.id);
    if (indexInSearch != -1) {
      _searchedProperties[indexInSearch] = updatedProperty;
    }
    // Jika perlu, update juga di _bookmarkedProperties jika properti tersebut ada di sana
    // dan field yang diupdate relevan untuk bookmark (misalnya judul, gambar, dll. bukan hanya viewsCount)
    int indexInBookmarks = _bookmarkedProperties.indexWhere((p) => p.id == updatedProperty.id);
    if (indexInBookmarks != -1) {
        // Hanya update jika field yang berubah juga penting untuk tampilan bookmark
        // Contoh: _bookmarkedProperties[indexInBookmarks] = updatedProperty.copyWith(viewsCount: updatedProperty.viewsCount);
        // Untuk saat ini, karena _updatePropertyInLocalLists dipanggil setelah fetch detail,
        // kita bisa asumsikan objek Property yang lengkap (termasuk status isFavorite)
        // sudah benar dari sumbernya.
        _bookmarkedProperties[indexInBookmarks] = updatedProperty;
    }

    // notifyListeners(); // Mungkin tidak perlu jika update ini minor (seperti viewsCount)
                       // dan tidak langsung mengubah tampilan list utama.
                       // Jika dipanggil, pastikan tidak menyebabkan rebuild berlebihan.
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
    if (propertyToUpdate == null) {
      propertyToUpdate = findAndUpdateInList(_searchedProperties, propertyId);
    }
    if (propertyToUpdate == null) {
      propertyToUpdate = findAndUpdateInList(_userApprovedProperties, propertyId);
    }
    if (propertyToUpdate == null) {
      propertyToUpdate = findAndUpdateInList(_userProperties, propertyId);
    }
     if (propertyToUpdate == null) { // Cek juga di list bookmark itu sendiri
      propertyToUpdate = findAndUpdateInList(_bookmarkedProperties, propertyId);
    }


    if (propertyToUpdate != null) {
      propertyToUpdate.toggleFavorite();

      // TODO: Panggil API untuk menyimpan status bookmark di backend (Langkah Berikutnya)
      // if (token != null) {
      //   try {
      //     _isLoadingBookmarkedProperties = true;
      //     notifyListeners();
      //     if (propertyToUpdate.isFavorite) {
      //       // await _propertyService.addBookmarkToApi(propertyId, token);
      //     } else {
      //       // await _propertyService.removeBookmarkFromApi(propertyId, token);
      //     }
      //     // Setelah API call berhasil, refresh daftar bookmark dari API atau update lokal
      //     // Untuk sekarang, kita update lokal saja dulu:
      //     _updateLocalBookmarkedList(propertyToUpdate);
      //   } catch (e) {
      //     print("Error updating bookmark via API: $e");
      //     propertyToUpdate.toggleFavorite(); // Rollback
      //     _updateLocalBookmarkedList(propertyToUpdate);
      //     _bookmarkedPropertiesError = "Gagal memperbarui bookmark: $e";
      //   } finally {
      //     _isLoadingBookmarkedProperties = false; // Mungkin perlu loading state yang lebih spesifik
      //     notifyListeners();
      //   }
      // } else {
      //   _updateLocalBookmarkedList(propertyToUpdate); // Update lokal jika tidak ada token
      // }
      _updateLocalBookmarkedList(propertyToUpdate);
      notifyListeners();
    } else {
      print("PropertyProvider: Property with ID $propertyId not found in managed lists for bookmarking.");
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

    // TODO: Nanti, ini akan mengambil dari API khusus bookmark.
    // Untuk implementasi client-side sementara:
    List<Property> allKnownProperties = [];
    allKnownProperties.addAll(_publicProperties);
    allKnownProperties.addAll(_searchedProperties);
    allKnownProperties.addAll(_userApprovedProperties);
    allKnownProperties.addAll(_userProperties);
    allKnownProperties.addAll(_userSoldProperties);

    final Map<String, Property> uniqueFavoriteProperties = {};
    for (var prop in allKnownProperties) {
      // Penting: Pastikan object `prop` adalah instance yang sama yang status `isFavorite`-nya di-toggle.
      // Jika tidak, `prop.isFavorite` mungkin tidak merefleksikan state terbaru.
      // Cara paling aman adalah selalu mengambil status favorit dari satu sumber terpercaya
      // atau memastikan semua list merujuk ke instance objek Property yang sama.
      if (prop.isFavorite) {
        uniqueFavoriteProperties[prop.id] = prop;
      }
    }
    _bookmarkedProperties = uniqueFavoriteProperties.values.toList();
    print("PropertyProvider: Fetched local bookmarks. Count: ${_bookmarkedProperties.length}");

    _isLoadingBookmarkedProperties = false;
    notifyListeners();
  }
  // --- 👆 METHOD BOOKMARK SELESAI DIKEMBALIKAN 👆 ---


  Future<void> fetchUserManageableProperties(String token) async {
    // ... (kode asli Anda) ...
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
    // ... (kode asli Anda) ...
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
    // ... (kode asli Anda) ...
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
    // ... (kode asli Anda) ...
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
    // ... (kode asli Anda) ...
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
    // ... (kode asli Anda) ...
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
    // ... (kode dari file yang Anda berikan) ...
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

    // Sinkronkan juga dengan _publicProperties dan _searchedProperties jika ada
    int publicIndex = _publicProperties.indexWhere((p) => p.id == updatedProperty.id);
    if (publicIndex != -1) {
      _publicProperties[publicIndex] = updatedProperty;
    }
    int searchedIndex = _searchedProperties.indexWhere((p) => p.id == updatedProperty.id);
    if (searchedIndex != -1) {
      _searchedProperties[searchedIndex] = updatedProperty;
    }

    int bookmarkedIndex = _bookmarkedProperties.indexWhere((p) => p.id == updatedProperty.id);
    if (bookmarkedIndex != -1) {
      // Jika properti ada di bookmark, update atau hapus berdasarkan status isFavorite terbarunya
      if (updatedProperty.isFavorite) {
        _bookmarkedProperties[bookmarkedIndex] = updatedProperty;
      } else {
        _bookmarkedProperties.removeAt(bookmarkedIndex);
      }
    } else if (updatedProperty.isFavorite) {
      // Jika properti tidak ada di bookmark tapi sekarang favorit, tambahkan
      _bookmarkedProperties.add(updatedProperty);
    }

    notifyListeners();
  }

  Future<Map<String, dynamic>> updatePropertyStatus(String propertyId, PropertyStatus newStatus, String token) async {
    // ... (kode dari file yang Anda berikan) ...
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

    Property propertyWithNewStatus = propertyToUpdate.copyWith(
      status: newStatus,
      submissionDate: () => newStatus == PropertyStatus.pendingVerification ? DateTime.now() : propertyToUpdate!.submissionDate,
      approvalDate: () => newStatus == PropertyStatus.approved ? DateTime.now() : propertyToUpdate!.approvalDate,
    );

    print('Updating status for property ${propertyWithNewStatus.id} from ${propertyToUpdate.status.name} to ${newStatus.name}');

    final result = await _propertyService.submitProperty(
      property: propertyWithNewStatus,
      newSelectedImages: [],
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
    // ... (kode dari file yang Anda berikan) ...
    _userProperties.removeWhere((p) => p.id == propertyId);
    _userApprovedProperties.removeWhere((p) => p.id == propertyId);
    _userSoldProperties.removeWhere((p) => p.id == propertyId);
    _publicProperties.removeWhere((p) => p.id == propertyId); // Tambahkan ini jika belum ada
    _searchedProperties.removeWhere((p) => p.id == propertyId); // Tambahkan ini jika belum ada
    _bookmarkedProperties.removeWhere((p) => p.id == propertyId);

    notifyListeners();
  }

  Future<Map<String, dynamic>?> fetchPropertyStatistics(String propertyId, String? token) async {
    // ... (kode dari file yang Anda berikan) ...
    if (token == null) {
      print('PropertyProvider: Token is null, cannot fetch statistics.');
      return null;
    }
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
      print('PropertyProvider (fetchPropertyStatistics): Body Respons: ${response.body}');

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
}