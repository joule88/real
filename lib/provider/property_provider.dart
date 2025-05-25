// lib/provider/property_provider.dart
import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/property_service.dart'; // Import service

class PropertyProvider extends ChangeNotifier {
  // List _properties sebelumnya mungkin untuk semua properti,
  // Anda bisa memisahkannya atau menambahkan list baru untuk properti pengguna.
  // Untuk contoh ini, kita akan fokus pada properti pengguna yang ditampilkan di MyDraftsScreen.
  List<Property> _userProperties = [];
  bool _isLoadingUserProperties = false;
  String? _userPropertiesError;

  List<Property> get userProperties => _userProperties;
  bool get isLoadingUserProperties => _isLoadingUserProperties;
  String? get userPropertiesError => _userPropertiesError;

  final PropertyService _propertyService = PropertyService();

  // Metode addProperty dan toggleFavorite yang sudah ada mungkin perlu disesuaikan
  // jika _properties utama juga dikelola di sini.

  // Metode baru untuk mengambil properti pengguna (draft dan pending)
  Future<void> fetchUserDraftAndPendingProperties(String token) async {
    _isLoadingUserProperties = true;
    _userPropertiesError = null;
    // Hapus daftar lama agar tidak ada duplikasi saat refresh
    // Atau, Anda bisa implementasikan logika update/merge yang lebih canggih
    _userProperties = []; 
    notifyListeners();

    final result = await _propertyService.getUserProperties(
      token,
      statuses: ['draft', 'pendingVerification'], // Filter status
    );

    if (result['success'] == true) {
      List<dynamic> propertiesData = result['properties'];
      _userProperties = propertiesData.map((data) => Property.fromJson(data as Map<String, dynamic>)).toList();
    } else {
      _userPropertiesError = result['message'];
    }
    _isLoadingUserProperties = false;
    notifyListeners();
  }

  // Jika Anda ingin memperbarui properti di list setelah edit/submit dari AddPropertyFormScreen
  // Anda bisa menambahkan metode seperti ini:
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
    // Anda mungkin ingin mengurutkan ulang daftar, misalnya berdasarkan tanggal
    // _userProperties.sort((a, b) => b.submissionDate?.compareTo(a.submissionDate ?? DateTime(0)) ?? 0);
    notifyListeners();
  }

  // Metode untuk menghapus properti dari list (misalnya jika dibatalkan atau dihapus)
  void removePropertyById(String propertyId) {
    _userProperties.removeWhere((p) => p.id == propertyId);
    notifyListeners();
  }

  // Metode loadInitialData yang lama mungkin tidak lagi relevan jika data diambil dari API
  // void loadInitialData(List<Property> initialData) {
  //   _properties.clear();
  //   _properties.addAll(initialData);
  //   notifyListeners();
  // }
}