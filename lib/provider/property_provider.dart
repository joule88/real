// lib/provider/property_provider.dart
import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/property_service.dart';
import '../services/api_services.dart';
import '../services/api_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PropertyProvider extends ChangeNotifier {
  final ValueNotifier<int> listUpdateNotifier = ValueNotifier(0);

  void _forceListUpdate() {
    listUpdateNotifier.value++;
  }

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

  String _pendingSearchKeyword = "";
  Map<String, dynamic> _pendingSearchFilters = {};
  bool _needsSearchExecution = false;

  List<Property> get searchedProperties => _searchedProperties;
  bool get isLoadingSearch => _isLoadingSearch;
  String? get searchError => _searchError;
  bool get hasMoreSearchResults => _hasMoreSearchResults;
  String get pendingSearchKeyword => _pendingSearchKeyword;
  Map<String, dynamic> get pendingSearchFilters => _pendingSearchFilters;
  bool get needsSearchExecution => _needsSearchExecution;


  List<Property> _bookmarkedProperties = [];
  bool _isLoadingBookmarkedProperties = false;
  String? _bookmarkedPropertiesError;

  List<Property> get bookmarkedProperties => _bookmarkedProperties;
  bool get isLoadingBookmarkedProperties => _isLoadingBookmarkedProperties;
  String? get bookmarkedPropertiesError => _bookmarkedPropertiesError;

  Property? _findPropertyAcrossLists(String propertyId) {
    Property? findInList(List<Property> list) {
      final index = list.indexWhere((p) => p.id == propertyId);
      return index != -1 ? list[index] : null;
    }
    return findInList(_publicProperties) ??
           findInList(_searchedProperties) ??
           findInList(_bookmarkedProperties) ??
           findInList(_userProperties) ??
           findInList(_userApprovedProperties) ??
           findInList(_userSoldProperties);
  }

  void _updateLocalBookmarkedList(Property property, {required bool isBookmarked}) {
    final index = _bookmarkedProperties.indexWhere((p) => p.id == property.id);
    if (isBookmarked) {
      if (index == -1) {
        _bookmarkedProperties.add(property.copyWith(isFavorite: true));
      } else {
        _bookmarkedProperties[index].isFavorite = true;
      }
    } else {
      if (index != -1) {
        _bookmarkedProperties.removeAt(index);
      }
    }
  }

  void _updatePropertyInAllLists(Property updatedProperty) {
    int updateList(List<Property> list) {
      int index = list.indexWhere((p) => p.id == updatedProperty.id);
      if (index != -1) {
        list[index] = updatedProperty;
      }
      return index;
    }
    updateList(_publicProperties);
    updateList(_searchedProperties);
    updateList(_bookmarkedProperties);
    updateList(_userProperties);
    updateList(_userApprovedProperties);
    updateList(_userSoldProperties);
  }

  Future<void> togglePropertyBookmark(String propertyId, String? token) async {
    if (token == null) return;
    Property? propertyToUpdate = _findPropertyAcrossLists(propertyId);
    if (propertyToUpdate == null) return;
    
    final originalStatus = propertyToUpdate.isFavorite;
    final newStatus = !originalStatus;

    Property newPropertyInstance = propertyToUpdate.copyWith(isFavorite: newStatus);
    _updatePropertyInAllLists(newPropertyInstance);
    _updateLocalBookmarkedList(newPropertyInstance, isBookmarked: newStatus);
    notifyListeners();
    _forceListUpdate();
    
    try {
      final result = await ApiService.toggleBookmark(token: token, propertyId: propertyId);
      if (result['success'] != true) {
        Property revertedProperty = newPropertyInstance.copyWith(isFavorite: originalStatus);
        _updatePropertyInAllLists(revertedProperty);
        _updateLocalBookmarkedList(revertedProperty, isBookmarked: originalStatus);
        notifyListeners();
        _forceListUpdate();
      }
    } catch (e) {
      Property revertedProperty = newPropertyInstance.copyWith(isFavorite: originalStatus);
      _updatePropertyInAllLists(revertedProperty);
      _updateLocalBookmarkedList(revertedProperty, isBookmarked: originalStatus);
      notifyListeners();
      _forceListUpdate();
    }
  }

  Future<void> fetchBookmarkedProperties(String? token) async {
    if (token == null) {
      // ENGLISH TRANSLATION
      _bookmarkedPropertiesError = "User is not authenticated.";
      _isLoadingBookmarkedProperties = false;
      _bookmarkedProperties = [];
      notifyListeners();
      return;
    }
    _isLoadingBookmarkedProperties = true;
    _bookmarkedPropertiesError = null;
    notifyListeners();
    try {
      final result = await ApiService.getBookmarkedProperties(token: token);
      if (result['success'] == true) {
        final List<dynamic> propertiesData = result['properties'] ?? [];
        _bookmarkedProperties = propertiesData.map((data) {
          final prop = Property.fromJson(data as Map<String, dynamic>);
          prop.isFavorite = true;
          return prop;
        }).toList();
      } else {
        // ENGLISH TRANSLATION
        _bookmarkedPropertiesError = result['message'] ?? 'Failed to load bookmarks.';
        _bookmarkedProperties = [];
      }
    } catch (e) {
      // ENGLISH TRANSLATION
      _bookmarkedPropertiesError = 'A network error occurred while fetching bookmarks: ' + e.toString();
      _bookmarkedProperties = [];
    } finally {
      _isLoadingBookmarkedProperties = false;
      notifyListeners();
      _forceListUpdate();
    }
  }

  Future<Property?> fetchPublicPropertyDetail(String propertyId, String? token) async {
    final url = Uri.parse('${ApiConstants.laravelApiBaseUrl}/properties/public/$propertyId');
    try {
      final headers = {'Accept': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final property = Property.fromJson(responseData['data'] as Map<String, dynamic>);
          _updatePropertyInAllLists(property);
          return property;
        }
      }
    } catch (e) {
      print('PropertyProvider: Exception while fetching public property detail - $e');
    }
    return null;
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
        // ENGLISH TRANSLATION
        _userPropertiesError = result['message'] ?? 'Failed to fetch manageable properties.';
      }
    } catch (e) {
      // ENGLISH TRANSLATION
      _userPropertiesError = 'An error occurred: $e';
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
        // ENGLISH TRANSLATION
        _userApprovedPropertiesError = result['message'] ?? 'Failed to fetch approved properties.';
      }
    } catch (e) {
      // ENGLISH TRANSLATION
      _userApprovedPropertiesError = 'An error occurred: $e';
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
        // ENGLISH TRANSLATION
        _userSoldPropertiesError = result['message'] ?? 'Failed to fetch sold properties.';
      }
    } catch (e) {
      // ENGLISH TRANSLATION
      _userSoldPropertiesError = 'An error occurred: $e';
    } finally {
      _isLoadingUserSoldProperties = false;
      notifyListeners();
    }
  }

  String? _currentPublicCategory;
  Map<String, dynamic> _currentPublicFilters = {};
  String? _currentAuthTokenForPublic;

  Future<void> fetchPublicProperties({
    bool loadMore = false,
    String? category,
    Map<String, dynamic>? filters,
    String? authToken,
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
      _currentPublicCategory = category;
      _currentPublicFilters = filters ?? {};
      _currentAuthTokenForPublic = authToken;
    } else {
      category = _currentPublicCategory;
      filters = _currentPublicFilters;
      authToken = _currentAuthTokenForPublic;
    }
    notifyListeners();

    try {
      final result = await ApiService.getPublicProperties(
        page: _publicPropertiesCurrentPage,
        category: category,
        filters: filters,
        authToken: authToken,
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
      } else {
        // ENGLISH TRANSLATION
        _publicPropertiesError = result['message'] ?? 'Failed to fetch public properties.';
        _hasMorePublicProperties = false;
      }
    } catch (e) {
      // ENGLISH TRANSLATION
      _publicPropertiesError = 'A network error occurred: $e';
      _hasMorePublicProperties = false;
    } finally {
      _isLoadingPublicProperties = false;
      notifyListeners();
    }
  }

  Future<void> performKeywordSearch({bool loadMore = false, String? authToken}) async {
    final String keywordToSearch = _pendingSearchKeyword;
    final Map<String, dynamic> filtersToApply = Map.from(_pendingSearchFilters);

    if (_isLoadingSearch && !loadMore) return;
    if (loadMore && !_hasMoreSearchResults && _searchedProperties.isNotEmpty) return;
    if (loadMore && _isLoadingSearch) return;

    _isLoadingSearch = true;
    _needsSearchExecution = false;

    if (!loadMore) {
      _searchError = null;
      _searchResultCurrentPage = 1;
      _searchedProperties = [];
      _hasMoreSearchResults = true;
    }
    notifyListeners();

    try {
      final result = await ApiService.getPublicProperties(
        page: _searchResultCurrentPage,
        keyword: keywordToSearch,
        filters: filtersToApply,
        authToken: authToken,
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
      } else {
        // ENGLISH TRANSLATION
        _searchError = result['message'] ?? 'Failed to perform property search.';
        _hasMoreSearchResults = false;
      }
    } catch (e) {
      // ENGLISH TRANSLATION
      _searchError = 'A network error occurred during search: ' + e.toString();
      _hasMoreSearchResults = false;
    } finally {
      _isLoadingSearch = false;
      notifyListeners();
      _forceListUpdate();
    }
  }

  void prepareSearchParameters({String? keyword, Map<String, dynamic>? filters}) {
    _pendingSearchKeyword = keyword ?? "";
    _pendingSearchFilters = filters ?? {};
    _needsSearchExecution = true;
    _searchedProperties = [];
    _searchError = null;
    _searchResultCurrentPage = 1;
    _searchResultLastPage = 1;
    _hasMoreSearchResults = true;
    _isLoadingSearch = false;
    notifyListeners();
  }

  void clearSearchResults() {
    prepareSearchParameters(keyword: null, filters: null);
  }

  void resetSearchState() {
    _searchedProperties = [];
    _isLoadingSearch = false;
    _searchError = null;
    _searchResultCurrentPage = 1;
    _searchResultLastPage = 1;
    _hasMoreSearchResults = true;
    _pendingSearchKeyword = "";
    _pendingSearchFilters = {};
    _needsSearchExecution = false;
    notifyListeners();
    _forceListUpdate();
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
    _updateLocalBookmarkedList(updatedProperty, isBookmarked: updatedProperty.isFavorite);
    notifyListeners();
    _forceListUpdate();
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
    // ENGLISH TRANSLATION
    if (propertyToUpdate == null) return {'success': false, 'message': 'Property not found.'};

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
    _forceListUpdate();
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
      removePropertyById(propertyId);
      // ENGLISH TRANSLATION
      return {'success': true, 'message': result['message'] ?? 'Property successfully deleted.'};
    } else {
      _userPropertiesError = result['message'];
      notifyListeners();
      // ENGLISH TRANSLATION
      return {'success': false, 'message': result['message'] ?? 'Failed to delete property.'};
    }
  }
}