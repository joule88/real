// lib/services/api_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart'; // Pastikan ApiConstants memiliki changePasswordEndpoint

class ApiService {
  static String get _laravelBaseUrl => ApiConstants.laravelApiBaseUrl;

  static Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8', // Tambahkan charset
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? profileImage,
  }) async {
    final String url = _laravelBaseUrl + ApiConstants.registerEndpoint;
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _getHeaders(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          if (profileImage != null) 'profile_image': profileImage,
        }),
      );
      print('ApiService Register - Status Code: ${response.statusCode}');
      print('ApiService Register - Body: ${response.body}');

      final dynamic responseBody = jsonDecode(response.body);
      if (responseBody is Map<String, dynamic>) {
        if (response.statusCode == 201) {
          return {
            'success': true,
            'message': responseBody['message'] ?? 'Registrasi berhasil',
            'data': responseBody, 
          };
        } else {
          return {
            'success': false,
            'message': responseBody['message'] ?? responseBody['error'] ?? 'Registrasi gagal. Status: ${response.statusCode}',
            'errors': responseBody['errors'],
            'data': null,
          };
        }
      } else {
          return {'success': false, 'message': 'Respons registrasi tidak valid.', 'data': null};
      }
    } catch (e) {
      print('ApiService Network error during registerUser: $e');
      return {'success': false, 'message': 'Kesalahan jaringan saat registrasi: $e', 'data': null};
    }
  }

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final String url = _laravelBaseUrl + ApiConstants.loginEndpoint;
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      print('ApiService Login - Status Code: ${response.statusCode}');
      print('ApiService Login - Body: ${response.body}');

      final dynamic responseBody = jsonDecode(response.body);
      if (responseBody is Map<String, dynamic>) {
          if (response.statusCode == 200) { 
              return {
                'success': true,
                'message': responseBody['message'] ?? 'Login berhasil',
                'data': responseBody, 
              };
          } else { 
              return {
                'success': false,
                'message': responseBody['message'] ?? responseBody['error'] ?? 'Login gagal. Status: ${response.statusCode}',
                'data': null,
              };
          }
      } else {
          return {'success': false, 'message': 'Respons login tidak valid.', 'data': null};
      }
    } catch (e) {
      print('ApiService Network error during loginUser: $e');
      return {'success': false, 'message': 'Kesalahan jaringan saat login: $e', 'data': null};
    }
  }

  // Fungsi helper _handleResponseProfile untuk getCurrentUserProfile dan updateUserProfile
  // karena API profile Anda MENGGUNAKAN pembungkus 'data'
  static Map<String, dynamic> _handleResponseProfile(http.Response response, String operation) {
      print('ApiService $operation - Status Code: ${response.statusCode}');
      print('ApiService $operation - Body: ${response.body}');
      try {
        final dynamic responseBody = jsonDecode(response.body);
        if (responseBody is Map<String, dynamic>) {
          if (response.statusCode >= 200 && response.statusCode < 300) {
            return {
              'success': responseBody['success'] ?? true, 
              'message': responseBody['message'] ?? '$operation berhasil',
              'data': responseBody['data'], 
            };
          } else {
            return {
              'success': false,
              'message': responseBody['message'] ?? responseBody['error'] ?? '$operation gagal. Status: ${response.statusCode}',
              'errors': responseBody['errors'],
              'data': null,
            };
          }
        } else {
          return {'success': false, 'message': '$operation gagal. Respons tidak valid (bukan JSON Map).', 'data': null};
        }
      } catch (e) {
        print('ApiService Error parsing response for $operation: $e');
        return {'success': false, 'message': '$operation gagal. Respons tidak dapat diproses.', 'data': null};
      }
  }


  static Future<Map<String, dynamic>> getCurrentUserProfile({
    required String token,
  }) async {
    final String url = _laravelBaseUrl + ApiConstants.userProfileEndpoint;
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(token: token),
      );
      return _handleResponseProfile(response, 'Ambil Profil Pengguna');
    } catch (e) {
      print('ApiService Network error during getCurrentUserProfile: $e');
      return {'success': false, 'message': 'Kesalahan jaringan saat mengambil profil: $e', 'data': null};
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile({
    required String token,
    required String name,
    required String bio,
  }) async {
    final String url = _laravelBaseUrl + ApiConstants.userProfileEndpoint; // Endpoint update profil sama dengan get profil
    try {
      final response = await http.put( // Menggunakan PUT untuk update
        Uri.parse(url),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'name': name,
          'bio': bio,
        }),
      );
      return _handleResponseProfile(response, 'Update Profil Pengguna'); 
    } catch (e) {
      print('ApiService Network error during updateUserProfile: $e');
      return {'success': false, 'message': 'Kesalahan jaringan saat update profil: $e', 'data': null};
    }
  }

  static Future<Map<String, dynamic>> logoutUser({
      required String token,
  }) async {
      final String url = _laravelBaseUrl + ApiConstants.logoutEndpoint;
      try {
        final response = await http.post( // Logout biasanya POST
          Uri.parse(url),
          headers: _getHeaders(token: token),
        );
        // Logout mungkin tidak mengembalikan 'data', jadi _handleResponseProfile mungkin perlu penyesuaian
        // atau kita handle secara spesifik di sini.
        // Untuk sekarang, kita asumsikan API logout juga mengembalikan struktur 'success' dan 'message'.
        print('ApiService Logout - Status Code: ${response.statusCode}');
        print('ApiService Logout - Body: ${response.body}');
        try {
            final dynamic responseBody = jsonDecode(response.body);
            if (responseBody is Map<String, dynamic>) {
                 return {
                    'success': responseBody['success'] ?? (response.statusCode == 200),
                    'message': responseBody['message'] ?? 'Logout berhasil',
                    // 'data' mungkin tidak ada atau null, biarkan saja
                 };
            } else {
                 return {'success': false, 'message': 'Respons logout tidak valid.'};
            }
        } catch (e) {
            // Jika body kosong atau bukan JSON, tapi status 200, anggap sukses
            if (response.statusCode == 200) {
                return {'success': true, 'message': 'Logout berhasil (respons kosong).'} ;
            }
            return {'success': false, 'message': 'Respons logout tidak dapat diproses.'};
        }
      } catch (e) {
        print('ApiService Network error during logoutUser: $e');
        return {'success': false, 'message': 'Kesalahan jaringan saat logout: $e'};
      }
  }

  // --- METHOD BARU UNTUK UBAH PASSWORD ---
  static Future<Map<String, dynamic>> changeUserPassword({
    required String token,
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    // Pastikan Anda sudah mendefinisikan changePasswordEndpoint di ApiConstants
    // Contoh: static const String changePasswordEndpoint = '/profile/change-password';
    final String url = _laravelBaseUrl + (ApiConstants.changePasswordEndpoint ?? '/profile/change-password'); 
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        }),
      );

      print('ApiService ChangePassword - Status Code: ${response.statusCode}');
      print('ApiService ChangePassword - Body: ${response.body}');

      // Penanganan respons untuk changePassword
      // API Laravel untuk change password biasanya mengembalikan:
      // - 200 OK dengan { "success": true, "message": "..." }
      // - 400 Bad Request dengan { "success": false, "message": "Password lama Anda salah." }
      // - 422 Unprocessable Entity dengan { "success": false, "message": "...", "errors": { ... } }
      // - 401 Unauthorized jika token tidak valid (sudah ditangani oleh middleware auth:api)
      
      try {
          final dynamic responseBody = jsonDecode(response.body);
          if (responseBody is Map<String, dynamic>) {
            // Ambil 'success' flag dari respons jika ada, jika tidak, tentukan berdasarkan statusCode
            bool success = responseBody['success'] ?? (response.statusCode == 200);
            String message = responseBody['message'] ?? (success ? 'Password berhasil diubah.' : 'Gagal mengubah password.');
            
            return {
              'success': success,
              'message': message,
              'errors': responseBody['errors'], // Kirim errors jika ada (untuk validasi)
              // 'data' biasanya tidak ada untuk change password, jadi tidak perlu
            };
          } else {
            // Jika respons bukan JSON Map yang valid
             return {'success': false, 'message': 'Respons ubah password tidak valid.'};
          }
      } catch (e) {
          // Jika gagal parse JSON, tapi status code menandakan sukses (jarang terjadi untuk API yang baik)
          if (response.statusCode == 200) {
              return {'success': true, 'message': 'Password berhasil diubah (respons tidak terstruktur).'} ;
          }
          print('ApiService Error parsing response for ChangePassword: $e');
          return {'success': false, 'message': 'Respons ubah password tidak dapat diproses.'};
      }

    } catch (e) {
      print('ApiService Network error during changeUserPassword: $e');
      return {'success': false, 'message': 'Kesalahan jaringan saat mengubah password: $e'};
    }
  }
}