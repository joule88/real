// lib/services/property_service.dart
import 'dart:convert';
import 'dart:io'; // Untuk File
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // Untuk XFile
import 'package:real/models/property.dart';
import 'api_constants.dart'; // Import konstanta API

class PropertyService {
  Future<Map<String, dynamic>> submitProperty({
    required Property property,
    required List<XFile> newSelectedImages,
    required List<String> existingImageUrls, // URL gambar yang sudah ada dan tidak dihapus
  }) async {
    // Tentukan apakah ini operasi CREATE atau UPDATE
    bool isUpdate = property.id.isNotEmpty && !(property.id.contains(RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z?$'))); // Asumsi ID dari DB tidak seperti ISO string
    String endpoint = isUpdate
        ? '${ApiConstants.propertiesEndpoint}/${property.id}'
        : ApiConstants.propertiesEndpoint;
    var uri = Uri.parse(ApiConstants.baseUrl + endpoint);
    var request = http.MultipartRequest(isUpdate ? 'PUT' : 'POST', uri);

    // --- Tambahkan Headers jika diperlukan (misalnya, token autentikasi) ---
    // String? token = await SecureStorageService.getToken(); // Contoh
    // if (token != null) {
    //   request.headers['Authorization'] = 'Bearer $token';
    // }
    request.headers['Accept'] = 'application/json';


    // --- Tambahkan Fields Teks dari Properti ---
    request.fields['title'] = property.title;
    request.fields['description'] = property.description;
    request.fields['uploader'] = property.uploader; // Pastikan ini ID pengguna yang valid
    request.fields['price'] = property.price.toString();
    request.fields['address'] = property.address;
    request.fields['city'] = property.city;
    request.fields['stateZip'] = property.stateZip;
    request.fields['bedrooms'] = property.bedrooms.toString();
    request.fields['bathrooms'] = property.bathrooms.toString();
    request.fields['areaSqft'] = property.areaSqft.toString();
    request.fields['propertyType'] = property.propertyType;
    request.fields['furnishings'] = property.furnishings;
    request.fields['status'] = property.status.toString().split('.').last; // e.g., "draft"

    // --- Penanganan Gambar ---
    // Backend perlu tahu mana gambar lama yang dipertahankan dan mana gambar baru yang diupload.
    // Ini adalah contoh, implementasi spesifik tergantung pada bagaimana API Anda dirancang.

    // 1. Kirim daftar URL gambar yang sudah ada dan ingin dipertahankan
    // API Anda mungkin mengharapkan ini sebagai array string JSON.
    List<String> retainedImageUrls = [];
    if(isUpdate) {
        // Jika update, kirimkan URL gambar yang ada di `existingImageUrls`
        // Ini adalah gambar-gambar yang sudah di server dan tidak dihapus oleh user
        retainedImageUrls.addAll(existingImageUrls.where((url) => url.startsWith('http')));
    }
    request.fields['retainedImageUrls'] = jsonEncode(retainedImageUrls);


    // 2. Upload gambar baru yang dipilih pengguna
    for (int i = 0; i < newSelectedImages.length; i++) {
      File imageFile = File(newSelectedImages[i].path);
      request.files.add(
        await http.MultipartFile.fromPath(
          'new_images[]', // Nama field di backend untuk array gambar baru
          imageFile.path,
          // filename: basename(imageFile.path), // Opsional, bisa berguna di backend
          // contentType: MediaType('image', 'jpeg'), // Opsional
        ),
      );
    }
    
    // Jika ada gambar utama yang baru (bukan URL lama), dan API mendukungnya secara terpisah
    // Anda bisa menambahkan logika di sini. Atau backend yang menentukan gambar utama dari `new_images[]`.

    print('Submitting property to: $uri');
    print('Request fields: ${request.fields}');
    print('New images to upload: ${newSelectedImages.length}');
    print('Retained existing image URLs: ${request.fields['retainedImageUrls']}');


    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        String errorMessage = 'Gagal mengirim properti.';
        try {
            var decodedError = jsonDecode(response.body);
            if (decodedError is Map && decodedError.containsKey('message')) {
                errorMessage = decodedError['message'];
            } else if (decodedError is Map && decodedError.containsKey('errors')) {
                // Handle error validasi Laravel
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
    } catch (e) {
      print('Error submitting property: $e');
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }
}