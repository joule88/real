import 'package:flutter/material.dart';
import '../models/property.dart';

class PropertyProvider extends ChangeNotifier {
  final List<Property> _properties = [];

  List<Property> get properties => _properties;

  void addProperty(Property property) {
    _properties.add(property);
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final property = _properties.firstWhere((prop) => prop.id == id);
    property.toggleFavorite();
    notifyListeners();
  }

  void loadInitialData(List<Property> initialData) {
    _properties.clear();
    _properties.addAll(initialData);
    notifyListeners();
  }
}
