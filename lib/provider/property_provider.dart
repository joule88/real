// lib/provider/property_provider.dart
import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/property_service.dart'; // Untuk _propertyService instance
import '../services/api_services.dart';   // Untuk fetchPublicProperties dan searchProperties

class PropertyProvider extends ChangeNotifier {
  // State untuk properti yang dikelola pengguna (draft, pending, rejected, archived)
  List<Property> _userProperties = [];
  bool _isLoadingUserProperties = false;
  String? _userPropertiesError;

  List<Property> get userProperties => _userProperties;
  bool get isLoadingUserProperties => _isLoadingUserProperties;
  String? get userPropertiesError => _userPropertiesError;

  // State untuk properti approved pengguna (yang tayang di profil)
  List<Property> _userApprovedProperties = [];
  bool _isLoadingUserApprovedProperties = false;
  String? _userApprovedPropertiesError;

  List<Property> get userApprovedProperties => _userApprovedProperties;
  bool get isLoadingUserApprovedProperties => _isLoadingUserApprovedProperties;
  String? get userApprovedPropertiesError => _userApprovedPropertiesError;

  // --- STATE UNTUK PROPERTI SOLD PENGGUNA ---
  List<Property> _userSoldProperties = [];
  bool _isLoadingUserSoldProperties = false;
  String? _userSoldPropertiesError;

  List<Property> get userSoldProperties => _userSoldProperties;
  bool get isLoadingUserSoldProperties => _isLoadingUserSoldProperties;
  String? get userSoldPropertiesError => _userSoldPropertiesError;
  // --- AKHIR STATE UNTUK SOLD ---

  final PropertyService _propertyService = PropertyService();

  // State untuk properti publik (Beranda - tanpa keyword)
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

  // --- STATE BARU KHUSUS UNTUK HASIL PENCARIAN PROPERTI ---
  List<Property> _searchedProperties = [];
  bool _isLoadingSearch = false; // Loading state khusus untuk search
  String? _searchError;        // Error message khusus untuk search
  int _searchResultCurrentPage = 1;
  int _searchResultLastPage = 1;
  bool _hasMoreSearchResults = true;
  String _currentSearchKeyword = ""; // Menyimpan keyword pencarian terakhir

  List<Property> get searchedProperties => _searchedProperties;
  bool get isLoadingSearch => _isLoadingSearch;
  String? get searchError => _searchError;
  bool get hasMoreSearchResults => _hasMoreSearchResults;
  String get currentSearchKeyword => _currentSearchKeyword;
  // --- AKHIR STATE BARU UNTUK HASIL PENCARIAN ---

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
    // ... (implementasi Anda yang sudah ada, tetap sama) ...
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
    // ... (implementasi Anda yang sudah ada, tetap sama) ...
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
  
  // Method ini untuk Beranda (tanpa keyword)
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
      // Memanggil ApiService.getPublicProperties TANPA keyword untuk Beranda
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

  // +++ METHOD BARU UNTUK PENCARIAN PROPERTI BERDASARKAN KEYWORD +++
  Future<void> performKeywordSearch(String keyword, {bool loadMore = false}) async {
    // Mencegah pemanggilan berulang jika sedang loading atau sudah tidak ada data lagi
    if (_isLoadingSearch && !loadMore) return;
    if (loadMore && !_hasMoreSearchResults) return;
    if (loadMore && _isLoadingSearch) return;

    _isLoadingSearch = true;

    if (!loadMore) {
      // Jika ini adalah pencarian baru (bukan loadMore)
      _searchError = null;
      _searchResultCurrentPage = 1; // Reset halaman ke 1
      _searchedProperties = [];     // Kosongkan hasil pencarian sebelumnya
      _currentSearchKeyword = keyword; // Simpan keyword yang sedang dicari
      _hasMoreSearchResults = true;   // Asumsikan ada hasil sampai API mengkonfirmasi
    }
    // Jika loadMore, _currentSearchKeyword dan _searchResultCurrentPage sudah berisi nilai dari pencarian sebelumnya.
    notifyListeners(); // Update UI untuk menampilkan loading

    try {
      // Panggil ApiService.getPublicProperties dengan menyertakan keyword
      final result = await ApiService.getPublicProperties(
        page: _searchResultCurrentPage,
        keyword: _currentSearchKeyword, // Gunakan keyword yang tersimpan untuk konsistensi loadMore
      );

      if (result['success'] == true) {
        final List<dynamic> propertiesData = result['properties'] ?? [];
        final List<Property> fetchedProperties = propertiesData
            .map((data) => Property.fromJson(data as Map<String, dynamic>))
            .toList();

        if (loadMore) {
          _searchedProperties.addAll(fetchedProperties); // Tambahkan ke list yang sudah ada
        } else {
          _searchedProperties = fetchedProperties; // Ganti list dengan yang baru
        }

        // Update info paginasi untuk hasil pencarian
        int apiCurrentPage = result['currentPage'] as int? ?? _searchResultCurrentPage;
        _searchResultLastPage = result['lastPage'] as int? ?? _searchResultLastPage;

        if (fetchedProperties.isNotEmpty) {
          _hasMoreSearchResults = apiCurrentPage < _searchResultLastPage;
          _searchResultCurrentPage = apiCurrentPage + 1; // Siapkan untuk halaman berikutnya
        } else {
          _hasMoreSearchResults = false; // Tidak ada data lagi yang di-fetch di halaman ini
        }

        if (_searchedProperties.isEmpty && !loadMore) {
          print('PropertyProvider: Tidak ada properti ditemukan untuk keyword: "$_currentSearchKeyword"');
          // _searchError = 'Tidak ada properti ditemukan untuk "$_currentSearchKeyword".'; // Opsional: set pesan jika tidak ada hasil
        }
      } else {
        _searchError = result['message'] ?? 'Gagal melakukan pencarian properti.';
        _hasMoreSearchResults = false; // Jika API gagal, anggap tidak ada halaman lagi
      }
    } catch (e) {
      _searchError = 'Terjadi kesalahan jaringan saat pencarian: $e';
      _hasMoreSearchResults = false; // Jika exception, anggap tidak ada halaman lagi
      print('PropertyProvider performKeywordSearch Exception: $e');
    } finally {
      _isLoadingSearch = false;
      notifyListeners();
    }
  }

  // Method untuk membersihkan hasil pencarian (dipanggil dari SearchScreen)
  void clearSearchResults() {
    _searchedProperties = [];
    _searchError = null;
    _currentSearchKeyword = "";
    _searchResultCurrentPage = 1;
    _searchResultLastPage = 1;
    _hasMoreSearchResults = true;
    _isLoadingSearch = false; // Pastikan loading juga false
    notifyListeners();
    print('PropertyProvider: Hasil pencarian telah dibersihkan.');
  }
  // +++ AKHIR METHOD BARU UNTUK PENCARIAN +++

  void updatePropertyListsState(Property updatedProperty) {
    // ... (implementasi Anda yang sudah ada, tetap sama) ...
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
    // ... (implementasi Anda yang sudah ada, tetap sama) ...
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

    Property propertyWithNewStatus = propertyToUpdate.copyWith(status: newStatus);
    
    print('Updating status for property ${propertyWithNewStatus.id} from ${propertyToUpdate.status.name} to ${newStatus.name}');

    final result = await _propertyService.submitProperty(
      property: propertyWithNewStatus, 
      newSelectedImages: [],
      existingImageUrls: propertyToUpdate.imageUrl.isNotEmpty ? [propertyToUpdate.imageUrl, ...propertyToUpdate.additionalImageUrls] : [],
      token: token
    );

    if (result['success'] == true) {
      updatePropertyListsState(propertyWithNewStatus); 
    }
    return result;
  }

  void removePropertyById(String propertyId) {
    // ... (implementasi Anda yang sudah ada, tetap sama) ...
    _userProperties.removeWhere((p) => p.id == propertyId);
    _userApprovedProperties.removeWhere((p) => p.id == propertyId);
    _userSoldProperties.removeWhere((p) => p.id == propertyId); 
    notifyListeners();
  }
}