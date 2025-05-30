// lib/provider/property_provider.dart
import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/property_service.dart';
import '../services/api_services.dart';

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

  // --- STATE BARU UNTUK PROPERTI SOLD PENGGUNA ---
  List<Property> _userSoldProperties = [];
  bool _isLoadingUserSoldProperties = false;
  String? _userSoldPropertiesError;

  List<Property> get userSoldProperties => _userSoldProperties;
  bool get isLoadingUserSoldProperties => _isLoadingUserSoldProperties;
  String? get userSoldPropertiesError => _userSoldPropertiesError;
  // --- AKHIR STATE BARU UNTUK SOLD ---

  final PropertyService _propertyService = PropertyService();

  // State untuk properti publik (Beranda)
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

  // --- METHOD BARU UNTUK MENGAMBIL PROPERTI SOLD PENGGUNA ---
  Future<void> fetchUserSoldProperties(String token) async {
    _isLoadingUserSoldProperties = true;
    _userSoldPropertiesError = null;
    _userSoldProperties = [];
    notifyListeners();

    try {
      final result = await _propertyService.getUserProperties(
        token,
        statuses: ['sold'], // Hanya ambil properti dengan status 'sold'
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
  // --- AKHIR METHOD BARU UNTUK SOLD ---
  
  Future<void> fetchPublicProperties({bool loadMore = false}) async {
    // ... (Implementasi fetchPublicProperties tetap sama) ...
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

        _publicPropertiesCurrentPage = (result['currentPage'] as int? ?? _publicPropertiesCurrentPage);
        _publicPropertiesLastPage = result['lastPage'] as int? ?? _publicPropertiesLastPage;
        
        if (fetchedProperties.isNotEmpty && _publicPropertiesCurrentPage > 0) {
             _hasMorePublicProperties = _publicPropertiesCurrentPage < _publicPropertiesLastPage;
             _publicPropertiesCurrentPage++; 
        } else if (fetchedProperties.isEmpty) {
             _hasMorePublicProperties = false; 
        }
        
        if (fetchedProperties.isEmpty && !loadMore) {
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


  void updatePropertyListsState(Property updatedProperty) {
    // Update _userProperties (draft, pending, rejected, archived)
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
    } else { // Jika statusnya bukan salah satu dari grup kelolaan (misal jadi approved, sold)
      if (indexInUserProperties != -1) {
        _userProperties.removeAt(indexInUserProperties);
      }
    }

    // Update _userApprovedProperties
    int indexInApprovedProperties = _userApprovedProperties.indexWhere((p) => p.id == updatedProperty.id);
    if (updatedProperty.status == PropertyStatus.approved) {
      if (indexInApprovedProperties != -1) {
        _userApprovedProperties[indexInApprovedProperties] = updatedProperty;
      } else {
        _userApprovedProperties.add(updatedProperty);
      }
    } else { // Jika statusnya bukan approved
      if (indexInApprovedProperties != -1) {
        _userApprovedProperties.removeAt(indexInApprovedProperties);
      }
    }

    // --- UPDATE UNTUK _userSoldProperties ---
    int indexInSoldProperties = _userSoldProperties.indexWhere((p) => p.id == updatedProperty.id);
    if (updatedProperty.status == PropertyStatus.sold) {
      if (indexInSoldProperties != -1) {
        _userSoldProperties[indexInSoldProperties] = updatedProperty;
      } else {
        _userSoldProperties.add(updatedProperty);
      }
    } else { // Jika statusnya bukan sold
      if (indexInSoldProperties != -1) {
        _userSoldProperties.removeAt(indexInSoldProperties);
      }
    }
    // --- AKHIR UPDATE UNTUK SOLD ---

    notifyListeners();
  }

  Future<Map<String, dynamic>> updatePropertyStatus(String propertyId, PropertyStatus newStatus, String token) async {
    Property? propertyToUpdate;
    
    // Cari di approved list dulu
    int approvedIdx = _userApprovedProperties.indexWhere((p) => p.id == propertyId);
    if (approvedIdx != -1) {
      propertyToUpdate = _userApprovedProperties[approvedIdx];
    } else {
      // Cari di manageable list
      int manageableIdx = _userProperties.indexWhere((p) => p.id == propertyId);
      if (manageableIdx != -1) {
        propertyToUpdate = _userProperties[manageableIdx];
      } else {
        // Cari di sold list (jika suatu saat sold bisa diubah statusnya, misal ke archived)
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
    _userProperties.removeWhere((p) => p.id == propertyId);
    _userApprovedProperties.removeWhere((p) => p.id == propertyId);
    _userSoldProperties.removeWhere((p) => p.id == propertyId); // Hapus juga dari sold
    notifyListeners();
  }
}