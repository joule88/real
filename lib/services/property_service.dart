import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../services/api_constants.dart';
import '../models/property.dart';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';

class PropertyService {
  // Metode untuk mengirim properti (Create/Update)
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
    var request = http.MultipartRequest(isUpdate ? 'PUT' : 'POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // Menggunakan data dari objek Property
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

    if (property.mainView != null) {
      request.fields['mainView'] = property.mainView!;
    }
    if (property.listingAgeCategory != null) {
      request.fields['listingAgeCategory'] = property.listingAgeCategory!;
    }
    if (property.propertyLabel != null) {
      request.fields['propertyLabel'] = property.propertyLabel!;
    }

    List<String> retainedImageUrls = [];
    if (isUpdate) {
      retainedImageUrls.addAll(existingImageUrls.where((url) => url.startsWith('http')));
    }
    request.fields['retainedImageUrls'] = jsonEncode(retainedImageUrls);

    print('INFO: Jumlah file gambar baru yang akan dikirim: ${newSelectedImages.length}');
    int imageIndex = 0; // Pindahkan inisialisasi index ke luar loop
    for (var imageFile in newSelectedImages) {
      try {
        Uint8List imageBytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'images[$imageIndex]', // Gunakan index yang diincrement dengan benar
            imageBytes,
            filename: imageFile.name,
            contentType: MediaType('image', _getExtension(imageFile.name)),
          ),
        );
        print('INFO: File gambar ${imageFile.name} (index: $imageIndex) berhasil ditambahkan ke request.');
        imageIndex++; // Increment index untuk gambar berikutnya
      } catch (e) {
        print('ERROR: Gagal membaca atau menambahkan file gambar ${imageFile.name}: $e');
        // Anda mungkin ingin mengembalikan error atau melanjutkan tanpa file ini
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('INFO: Properti berhasil dikirim. Status: ${response.statusCode}');
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final errorBody = jsonDecode(response.body);
        String message = 'Terjadi kesalahan saat mengirim properti.';
        if (errorBody != null && errorBody is Map) {
          message = errorBody['message'] as String? ??
              (errorBody['errors'] != null && errorBody['errors'] is Map
                  ? (errorBody['errors'] as Map).entries.map((e) => '${e.key}: ${(e.value as List).join(", ")}').join('\n')
                  : response.body);
        } else {
          message = response.body;
        }
        print('ERROR: Gagal mengirim properti. Status: ${response.statusCode}, Pesan: $message');
        return {'success': false, 'message': message};
      }
    } catch (e) {
      print('ERROR: Exception saat mengirim properti: $e');
      return {'success': false, 'message': 'Error saat mengirim properti: $e'};
    }
  }

  // Metode untuk mengambil properti pengguna
  Future<Map<String, dynamic>> getUserProperties(String token, {List<String>? statuses}) async {
    String statusQuery = '';
    if (statuses != null && statuses.isNotEmpty) {
      statusQuery = '?status=${statuses.join(',')}';
    }
    final uri = Uri.parse('${ApiConstants.laravelApiBaseUrl}${ApiConstants.userPropertiesEndpoint}$statusQuery');

    print("INFO: Fetching user properties from: $uri");

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
          print("INFO: User properties fetched successfully.");
          return {'success': true, 'properties': List<Map<String, dynamic>>.from(data['data'])};
        } else if (data is List) { // Jika API langsung mengembalikan array properti
          print("INFO: User properties fetched successfully (direct array).");
          return {'success': true, 'properties': List<Map<String, dynamic>>.from(data)};
        }
        print("WARNING: Unexpected response format for user properties: $data");
        return {'success': false, 'message': 'Format data properti tidak sesuai.'};
      } else {
        print("ERROR: Failed to get user properties: ${response.statusCode} - ${response.body}");
        return {'success': false, 'message': 'Gagal mengambil properti: ${response.statusCode}'};
      }
    } catch (e) {
      print("ERROR: Exception getting user properties: $e");
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // Metode untuk prediksi harga properti
  Future<Map<String, dynamic>> predictPropertyPrice({
    required int bathrooms,
    required int bedrooms,
    required int furnishing,
    required double sizeMin, // Ini adalah nilai sqft
    required int verified,
    required int listingAgeCategory,
    required int viewType,
    required int titleKeyword,
  }) async {
    final String predictUrl = '${ApiConstants.flaskApiBaseUrl}${ApiConstants.predictPriceEndpoint}';
    print("INFO: Predicting property price with payload: ${{
      'bathrooms': bathrooms, 'bedrooms': bedrooms, 'furnishing': furnishing,
      'sizeMin': sizeMin, 'verified': verified, 'listing_age_category': listingAgeCategory,
      'view_type': viewType, 'title_keyword': titleKeyword
    }}");

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
        print("INFO: Price prediction successful. Result: $data");
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
        print("ERROR: Failed to predict price: ${response.statusCode} - Message: $message");
        return {'success': false, 'message': message};
      }
    } catch (e) {
      print("ERROR: Exception predicting property price: $e");
      return {'success': false, 'message': 'Error saat prediksi harga: $e'};
    }
  }

  // Helper untuk mendapatkan ekstensi file
  String _getExtension(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'jpeg';
      case 'png':
        return 'png';
      default:
        return 'jpeg'; // default fallback
    }
  }
}