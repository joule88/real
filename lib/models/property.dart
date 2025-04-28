// lib/models/property.dart
class Property {
  final String id;
  final String imageUrl;
  final double price;
  final String address;
  final String city;
  final String stateZip; 
  final int bedrooms;
  final int bathrooms;
  final double areaSqft;
  final bool isFavorite; // status bookmark

  Property({
    required this.id,
    required this.imageUrl,
    required this.price,
    required this.address,
    required this.city,
    required this.stateZip,
    required this.bedrooms,
    required this.bathrooms,
    required this.areaSqft,
    this.isFavorite = false,
  });
}