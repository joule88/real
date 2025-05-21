// lib/services/property_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:real/models/property.dart'; // Pastikan path ini benar
import 'api_constants.dart';

class PropertyService {
  Future<Map<String, dynamic>> submitProperty({
    required Property property,
    required List<XFile> newSelectedImages,
    required List<String> existingImageUrls,
    required String token,
  }) async {
    bool isUpdate = property.id.isNotEmpty && !(property.id.contains(RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z?$')));
    String endpoint = isUpdate
        ? '${ApiConstants.propertiesEndpoint}/${property.id}'
        : ApiConstants.propertiesEndpoint;
    // URL untuk submit properti akan menggunakan laravelApiBaseUrl
    var uri = Uri.parse('${ApiConstants.laravelApiBaseUrl}$endpoint'); // Menggunakan laravelApiBaseUrl
    var request = http.MultipartRequest(isUpdate ? 'PUT' : 'POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['title'] = property.title;
    request.fields['description'] = property.description;
    request.fields['uploader'] = property.uploader;
    request.fields['price'] = property.price.toString();
    request.fields['address'] = property.address;
    request.fields['city'] = property.city;
    request.fields['stateZip'] = property.stateZip;
    request.fields['bedrooms'] = property.bedrooms.toString();
    request.fields['bathrooms'] = property.bathrooms.toString();
    request.fields['areaSqft'] = property.areaSqft.toString();
    request.fields['propertyType'] = property.propertyType;
    request.fields['furnishings'] = property.furnishings;
    request.fields['status'] = property.status.toString().split('.').last;

    List<String> retainedImageUrls = [];
    if (isUpdate) {
      retainedImageUrls.addAll(existingImageUrls.where((url) => url.startsWith('http')));
    }
    request.fields['retainedImageUrls'] = jsonEncode(retainedImageUrls);

    for (var image in newSelectedImages) {
      File imageFile = File(image.path);
      request.files.add(
        await http.MultipartFile.fromPath('new_images[]', imageFile.path),
      );
    }

    print('Submitting property to: $uri');
    print('Request fields: ${request.fields}');

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Submit Property API Response Status: ${response.statusCode}');
      print('Submit Property API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        String errorMessage = 'Gagal mengirim properti.';
        try {
          var decodedError = jsonDecode(response.body);
          if (decodedError is Map && decodedError.containsKey('message')) {
            errorMessage = decodedError['message'];
          } else if (decodedError is Map && decodedError.containsKey('errors')) {
            Map<String, dynamic> errors = decodedError['errors'];
            errorMessage = errors.entries.map((e) => '${e.key}: ${e.value.join(", ")}').join("\n");
          } else {
            errorMessage = response.body;
          }
        } catch (e) {
          errorMessage = response.body.isEmpty ? 'Status: ${response.statusCode}' : response.body;
        }
        return {'success': false, 'message': errorMessage};
      }
    } on SocketException catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server. Error: $e'};
    } on TimeoutException catch (e) {
      return {'success': false, 'message': 'Permintaan timeout. Error: $e'};
    } catch (e) {
      print('Error submitting property: $e');
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  // --- FUNGSI PREDIKSI HARGA ---
  Future<Map<String, dynamic>> predictPropertyPrice({
    required int bathrooms,
    required int bedrooms,
    required int furnishing,
    required double sizeMin,      // Ini akan dalam SQFT, sesuai dengan input Flask 'sizeMin'
    required int verified,
    required int listingAgeCategory,
    required int viewType,
    required int titleKeyword,
    // String? token, // Token mungkin tidak dibutuhkan jika Flask API tidak di-secure
  }) async {
    // URL akan menggunakan flaskApiBaseUrl: http://127.0.0.1:5000/prediksi/create
    final String predictUrl = '${ApiConstants.flaskApiBaseUrl}${ApiConstants.predictPriceEndpoint}';

    print('Attempting to predict price with URL: $predictUrl');
    final payload = {
      'bathrooms': bathrooms,
      'bedrooms': bedrooms,
      'furnishing': furnishing,
      'sizeMin': sizeMin, // Mengirimkan nilai dalam SQFT
      'verified': verified,
      'listing_age_category': listingAgeCategory,
      'view_type': viewType,
      'title_keyword': titleKeyword,
    };
    print('Prediction payload for Flask API: $payload');

    try {
      final response = await http.post(
        Uri.parse(predictUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Jika API Flask memerlukan token, tambahkan di sini:
          // 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      print('Flask Prediction API Response Status: ${response.statusCode}');
      print('Flask Prediction API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['prediction_result'] != null) {
          return {'success': true, 'predicted_price': data['prediction_result']};
        } else {
          String errorMessage = data != null && data['error'] != null ? data['error'] : 'Format respons prediksi tidak valid dari Flask API.';
          return {'success': false, 'message': errorMessage};
        }
      } else {
        String errorMessage = 'Gagal memprediksi harga dari Flask API.';
        try {
          var decodedError = jsonDecode(response.body);
          if (decodedError is Map && decodedError.containsKey('error')) {
            errorMessage = decodedError['error'];
          } else {
            errorMessage = response.body;
          }
        } catch (e) {
          errorMessage = response.body.isNotEmpty ? response.body : 'Error tidak diketahui dari server prediksi.';
        }
        return {'success': false, 'message': '$errorMessage (Status: ${response.statusCode})'};
      }
    } on SocketException catch (e) {
      print('Flask Prediction API SocketException: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server prediksi (Flask di port 5000). Periksa koneksi dan URL. Error: $e'};
    } on TimeoutException catch (e) {
      print('Flask Prediction API TimeoutException: $e');
      return {'success': false, 'message': 'Permintaan prediksi (Flask) timeout. Error: $e'};
    } catch (e) {
      print('Error predicting property price (Flask): $e');
      return {'success': false, 'message': 'Terjadi kesalahan saat menghubungi layanan prediksi (Flask). Error: $e'};
    }
  }
}