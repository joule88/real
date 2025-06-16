// lib/services/property_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../services/api_constants.dart';
import '../models/property.dart';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';

class PropertyService {
  // ENGLISH TRANSLATION: All messages are now in English
  Future<Map<String, dynamic>> submitProperty({
    required Property property,
    required List<XFile> newSelectedImages,
    required List<String> existingImageUrls,
    required String token,
  }) async {
    bool isUpdate = property.id.isNotEmpty &&
        !(property.id.contains(RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z?$')));
    
    String endpoint = isUpdate
        ? '${ApiConstants.propertiesEndpoint}/${property.id}'
        : ApiConstants.propertiesEndpoint;

    var uri = Uri.parse('${ApiConstants.laravelApiBaseUrl}$endpoint');
    var request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['title'] = property.title;
    request.fields['description'] = property.description;
    request.fields['price'] = property.price.toString();
    request.fields['address'] = property.address;
    request.fields['bedrooms'] = property.bedrooms.toString();
    request.fields['bathrooms'] = property.bathrooms.toString();
    request.fields['sizeMin'] = property.areaSqft.toString();
    request.fields['furnishing'] = property.furnishings;
    request.fields['propertyType'] = property.propertyType;
    request.fields['status'] = property.status.toString().split('.').last;

    if (property.mainView != null) request.fields['mainView'] = property.mainView!;
    if (property.listingAgeCategory != null) request.fields['listingAgeCategory'] = property.listingAgeCategory!;
    if (property.propertyLabel != null) request.fields['propertyLabel'] = property.propertyLabel!;

    List<String> retainedImageUrls = [];
    if (isUpdate) {
      retainedImageUrls.addAll(existingImageUrls.where((url) => url.startsWith('http')));
    }
    request.fields['retainedImageUrls'] = jsonEncode(retainedImageUrls);

    if (isUpdate) {
      print('DEBUG PropertyService: Sending POST request (for UPDATE) to $uri');
    } else {
      print('DEBUG PropertyService: Sending POST request (for CREATE) to $uri');
    }
    
    int imageIndex = 0;
    for (var imageFile in newSelectedImages) {
      try {
        Uint8List imageBytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'images[$imageIndex]',
            imageBytes,
            filename: imageFile.name,
            contentType: MediaType('image', _getExtension(imageFile.name)),
          ),
        );
        imageIndex++;
      } catch (e) {
        print('ERROR: Failed to read or add image file ${imageFile.name}: $e');
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final errorBody = jsonDecode(response.body);
        String message = 'An error occurred while submitting the property.';
        if (errorBody != null && errorBody is Map) {
          message = errorBody['message'] as String? ??
              (errorBody['errors'] != null && errorBody['errors'] is Map
                  ? (errorBody['errors'] as Map).entries.map((e) => '${e.key}: ${(e.value as List).join(", ")}').join('\n')
                  : response.body);
        } else {
          message = response.body;
        }
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error submitting property: $e'};
    }
  }

  // ENGLISH TRANSLATION: All messages are now in English
  Future<Map<String, dynamic>> getUserProperties(String token, {List<String>? statuses}) async {
    String statusQuery = '';
    if (statuses != null && statuses.isNotEmpty) {
      statusQuery = '?status=${statuses.join(',')}';
    }
    final uri = Uri.parse('${ApiConstants.laravelApiBaseUrl}${ApiConstants.userPropertiesEndpoint}$statusQuery');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('data') && data['data'] is List) {
          return {'success': true, 'properties': List<Map<String, dynamic>>.from(data['data'])};
        } else if (data is List) { 
          return {'success': true, 'properties': List<Map<String, dynamic>>.from(data)};
        }
        return {'success': false, 'message': 'Invalid property data format.'};
      } else {
        return {'success': false, 'message': 'Failed to fetch properties: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // ENGLISH TRANSLATION: All messages are now in English
  Future<Map<String, dynamic>> predictPropertyPrice({
    required int bathrooms,
    required int bedrooms,
    required int furnishing,
    required double sizeMin, 
    required int verified,
    required int listingAgeCategory,
    required int viewType,
    required int titleKeyword,
  }) async {
// BENAR: Memanggil endpoint "predict" di Laravel
const String predictUrl = '${ApiConstants.laravelApiBaseUrl}${ApiConstants.predictPriceEndpoint}';    final payload = {
      'bathrooms': bathrooms, 'bedrooms': bedrooms, 'furnishing': furnishing,
      'sizeMin': sizeMin, 'verified': verified, 'listing_age_category': listingAgeCategory,
      'view_type': viewType, 'title_keyword': titleKeyword,
    };

    try {
      final response = await http.post(
        Uri.parse(predictUrl),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'predicted_price': data['prediction_result'],
        };
      } else {
        final errorBody = jsonDecode(response.body);
        String message = 'Failed to get price prediction.';
        if (errorBody != null && errorBody is Map && errorBody['message'] != null) {
          message = errorBody['message'];
        } else if (errorBody != null && errorBody is Map && errorBody['error'] != null){
          message = errorBody['error'];
        } else {
          message = response.body;
        }
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error during price prediction: $e'};
    }
  }

  // ENGLISH TRANSLATION: All messages are now in English
  Future<Map<String, dynamic>> deletePropertyApi(String propertyId, String token) async {
    final String endpoint = '${ApiConstants.propertiesEndpoint}/$propertyId';
    var uri = Uri.parse('${ApiConstants.laravelApiBaseUrl}$endpoint');

    try {
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final responseBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'success': true,
          'message': responseBody['message'] ?? 'Property deleted successfully.',
          'data': responseBody
        };
      } else {
        final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        String message = errorBody['message'] ?? 'Failed to delete property on the server.';
        if (errorBody['errors'] != null && errorBody['errors'] is Map) {
          message = (errorBody['errors'] as Map).entries.map((e) => '${e.key}: ${(e.value as List).join(", ") }').join('\n');
        }
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error while deleting property: $e'};
    }
  }

  String _getExtension(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'jpeg';
      case 'png':
        return 'png';
      case 'webp':
        return 'webp';
      default:
        return 'jpeg'; 
    }
  }
}