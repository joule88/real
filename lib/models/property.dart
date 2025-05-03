import 'package:flutter/foundation.dart';

class Property extends ChangeNotifier {
  final String id;
  final String title; // ← Tambahkan nama properti
  final String description; // ← Tambahkan deskripsi
  final String uploader; // ← Tambahkan nama pengunggah
  final String imageUrl;
  final double price;
  final String address;
  final String city;
  final String stateZip;
  final int bedrooms;
  final int bathrooms;
  final double areaSqft;
  bool _isFavorite;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.uploader,
    required this.imageUrl,
    required this.price,
    required this.address,
    required this.city,
    required this.stateZip,
    required this.bedrooms,
    required this.bathrooms,
    required this.areaSqft,
    bool isFavorite = false,
  }) : _isFavorite = isFavorite;

  bool get isFavorite => _isFavorite;

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners();
  }
}
