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
    var request = http.MultipartRequest(isUpdate ? 'PUT' : 'POST', uri); // 'PUT' untuk update

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // Menggunakan data dari objek Property yang sudah diperbarui
    request.fields['title'] = property.title;
    request.fields['description'] = property.description;
    request.fields['price'] = property.price.toString();
    request.fields['address'] = property.address; // Ini sudah berisi alamat lengkap
    request.fields['bedrooms'] = property.bedrooms.toString();
    request.fields['bathrooms'] = property.bathrooms.toString();
    // Pastikan key 'sizeMin' atau 'areaSqft' konsisten dengan backend Anda
    request.fields['sizeMin'] = property.areaSqft.toString(); 
    request.fields['furnishing'] = property.furnishings;
    request.fields['propertyType'] = property.propertyType;
    request.fields['status'] = property.status.toString().split('.').last;


    // Field opsional/baru dari model Property
    if (property.mainView != null) {
      request.fields['mainView'] = property.mainView!;
    }
    if (property.listingAgeCategory != null) {
      request.fields['listingAgeCategory'] = property.listingAgeCategory!;
    }
    if (property.propertyLabel != null) {
      request.fields['propertyLabel'] = property.propertyLabel!;
    }
    
    // Tambahkan retained image URLs
    List<String> retainedImageUrls = [];
    if (isUpdate) {
      retainedImageUrls.addAll(existingImageUrls.where((url) => url.startsWith('http')));
    }
    // Backend Anda harus bisa menangani 'retainedImageUrls' jika dikirim sebagai JSON string
    // Atau Anda bisa mengirimnya sebagai array jika backend mendukung (misal, retainedImageUrls[0], retainedImageUrls[1], dst.)
    request.fields['retainedImageUrls'] = jsonEncode(retainedImageUrls); 

    for (var imageFile in newSelectedImages) {
      Uint8List imageBytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'images[]', // Key yang diharapkan Laravel untuk array gambar baru
          imageBytes,
          filename: imageFile.name,
          contentType: MediaType('image', _getExtension(imageFile.name)),
        ),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final errorBody = jsonDecode(response.body);
        // Logika parsing pesan error yang lebih baik
        String message = 'Terjadi kesalahan';
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
      return {'success': false, 'message': 'Error saat mengirim properti: $e'};
    }
  }

  // ... (createNewProperty dan predictPropertyPrice SAMA)
    Future<Map<String, dynamic>> createNewProperty({
    required Property property,
    required List<XFile> selectedImages,
    required String token,
  }) async {
    return await submitProperty(
      property: property,
      newSelectedImages: selectedImages,
      existingImageUrls: [],
      token: token,
    );
  }

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
    final String predictUrl = '${ApiConstants.flaskApiBaseUrl}${ApiConstants.predictPriceEndpoint}';

    final payload = {
      'bathrooms': bathrooms,
      'bedrooms': bedrooms,
      'furnishing': furnishing,
      'sizeMin': sizeMin,
      'verified': verified,
      'listing_age_category': listingAgeCategory,
      'view_type': viewType,
      'title_keyword': titleKeyword,
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
        String message = 'Gagal mendapatkan prediksi harga.';
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
      return {'success': false, 'message': 'Error saat prediksi harga: $e'};
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
      default:
        return 'jpeg'; 
    }
  }
}