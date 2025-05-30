// lib/provider/property_provider.dart
import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/property_service.dart'; // Digunakan untuk _propertyService instance
import '../services/api_services.dart';   // Digunakan untuk fetchPublicProperties

class PropertyProvider extends ChangeNotifier {
  // State untuk properti pengguna (yang di-draft atau pending)
  List<Property> _userProperties = [];
  bool _isLoadingUserProperties = false;
  String? _userPropertiesError;

  List<Property> get userProperties => _userProperties;
  bool get isLoadingUserProperties => _isLoadingUserProperties;
  String? get userPropertiesError => _userPropertiesError;

  // Instance PropertyService untuk mengambil properti pengguna
  // Pastikan class PropertyService terdefinisi dengan benar dan path import sudah sesuai.
  final PropertyService _propertyService = PropertyService();

  // --- STATE BARU UNTUK PROPERTI PUBLIK (UNTUK BERANDA) ---
  List<Property> _publicProperties = [];
  bool _isLoadingPublicProperties = false;
  String? _publicPropertiesError;
  int _publicPropertiesCurrentPage = 1;
  int _publicPropertiesLastPage = 1;
  bool _hasMorePublicProperties = true; // Flag untuk paginasi

  List<Property> get publicProperties => _publicProperties;
  bool get isLoadingPublicProperties => _isLoadingPublicProperties;
  String? get publicPropertiesError => _publicPropertiesError;
  bool get hasMorePublicProperties => _hasMorePublicProperties;
  // --- AKHIR STATE BARU ---


  // Method untuk mengambil properti pengguna (draft dan pending)
  Future<void> fetchUserDraftAndPendingProperties(String token) async {
    _isLoadingUserProperties = true;
    _userPropertiesError = null;
    _userProperties = []; // Kosongkan list sebelum fetch baru (untuk refresh)
    notifyListeners();

    try {
      // Menggunakan instance _propertyService yang sudah ada di class
      final result = await _propertyService.getUserProperties(
        token,
        statuses: ['draft', 'pendingVerification'], // Filter status yang diinginkan
      );

      if (result['success'] == true) {
        List<dynamic> propertiesData = result['properties'] ?? [];
        _userProperties = propertiesData.map((data) => Property.fromJson(data as Map<String, dynamic>)).toList();
      } else {
        _userPropertiesError = result['message'] ?? 'Gagal mengambil properti pengguna.';
      }
    } catch (e) {
      _userPropertiesError = 'Terjadi kesalahan saat mengambil properti pengguna: $e';
      print('PropertyProvider fetchUserDraftAndPendingProperties Error: $e');
    } finally {
      _isLoadingUserProperties = false;
      notifyListeners();
    }
  }

  // --- METHOD UNTUK MENGAMBIL PROPERTI PUBLIK (BERANDA) ---
  Future<void> fetchPublicProperties({bool loadMore = false}) async {
    // Kondisi untuk mencegah fetch berlebihan
    if (_isLoadingPublicProperties) return;
    if (loadMore && !_hasMorePublicProperties) return;

    _isLoadingPublicProperties = true;
    if (!loadMore) {
      // Jika ini adalah pengambilan data awal (bukan loadMore), reset state
      _publicPropertiesError = null;
      _publicPropertiesCurrentPage = 1;
      _publicProperties = [];
      _hasMorePublicProperties = true; // Asumsikan ada data sampai API mengkonfirmasi
    }
    notifyListeners(); // Update UI untuk menunjukkan loading

    try {
      // Menggunakan ApiService untuk mengambil properti publik
      final result = await ApiService.getPublicProperties(page: _publicPropertiesCurrentPage);

      if (result['success'] == true) {
        final List<dynamic> propertiesData = result['properties'] ?? [];
        final List<Property> fetchedProperties = propertiesData
            .map((data) => Property.fromJson(data as Map<String, dynamic>))
            .toList();

        if (loadMore) {
          _publicProperties.addAll(fetchedProperties); // Tambahkan ke list yang sudah ada
        } else {
          _publicProperties = fetchedProperties; // Ganti list dengan yang baru
        }

        // Update info paginasi dari respons API
        _publicPropertiesCurrentPage = (result['currentPage'] as int? ?? _publicPropertiesCurrentPage) + 1;
        _publicPropertiesLastPage = result['lastPage'] as int? ?? _publicPropertiesLastPage;
        // Cek apakah masih ada halaman berikutnya
        _hasMorePublicProperties = (_publicPropertiesCurrentPage <= _publicPropertiesLastPage) && fetchedProperties.isNotEmpty;
        
        if (fetchedProperties.isEmpty && !loadMore) {
          print('PropertyProvider: Tidak ada properti publik yang ditemukan (halaman pertama kosong).');
          // Anda bisa set _publicPropertiesError di sini jika mau
          // _publicPropertiesError = 'Tidak ada properti yang tersedia saat ini.';
        }
      } else {
        _publicPropertiesError = result['message'] ?? 'Gagal mengambil properti publik.';
        _hasMorePublicProperties = false; // Jika fetch gagal, anggap tidak ada halaman lagi
        print('PropertyProvider fetchPublicProperties Error: $_publicPropertiesError');
      }
    } catch (e) {
      _publicPropertiesError = 'Terjadi kesalahan jaringan: $e';
      _hasMorePublicProperties = false; // Jika exception, anggap tidak ada halaman lagi
      print('PropertyProvider fetchPublicProperties Exception: $e');
    } finally {
      _isLoadingPublicProperties = false;
      notifyListeners();
    }
  }
  // --- AKHIR METHOD BARU ---

  // Method untuk update atau tambah properti di _userProperties (biasanya setelah edit/buat draft)
  void updateOrAddProperty(Property property) {
    final index = _userProperties.indexWhere((p) => p.id == property.id);
    if (index != -1) {
      // Jika properti sudah ada (misalnya diedit)
      _userProperties[index] = property;
    } else {
      // Jika properti baru (misalnya baru dibuat sebagai draft)
      // Cek apakah statusnya relevan untuk ditampilkan di MyDraftsScreen
      if (property.status == PropertyStatus.draft || property.status == PropertyStatus.pendingVerification) {
         _userProperties.add(property);
      }
    }
    notifyListeners();
  }

  // Method untuk menghapus properti dari _userProperties
  void removePropertyById(String propertyId) {
    _userProperties.removeWhere((p) => p.id == propertyId);
    notifyListeners();
  }
}