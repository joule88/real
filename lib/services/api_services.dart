// lib/services/api_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class ApiService {
  static String get _laravelBaseUrl => ApiConstants.laravelApiBaseUrl;

  static Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Fungsi helper _handleResponse TIDAK AKAN DIGUNAKAN untuk login/register
  // karena struktur responsnya berbeda (tidak ada pembungkus 'data' di root).

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
      print('Register - Status Code: ${response.statusCode}');
      print('Register - Body: ${response.body}');

      final dynamic responseBody = jsonDecode(response.body);
      if (responseBody is Map<String, dynamic>) {
        if (response.statusCode == 201) { // Register sukses (201 Created)
          return {
            'success': true,
            'message': responseBody['message'] ?? 'Registrasi berhasil',
            // API Anda mengembalikan 'user' dan 'token' di root
            'data': responseBody, // Kirim seluruh responseBody sebagai 'data'
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
      print('Network error during registerUser: $e');
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
      print('Login - Status Code: ${response.statusCode}');
      print('Login - Body: ${response.body}');

      final dynamic responseBody = jsonDecode(response.body);
      if (responseBody is Map<String, dynamic>) {
         if (response.statusCode == 200) { // Login sukses
             return {
               'success': true,
               'message': responseBody['message'] ?? 'Login berhasil',
               // API Anda mengembalikan 'token' dan 'user' di root
               'data': responseBody, // Kirim seluruh responseBody sebagai 'data'
             };
         } else { // Gagal login (misal 401 Unauthorized)
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
      print('Network error during loginUser: $e');
      return {'success': false, 'message': 'Kesalahan jaringan saat login: $e', 'data': null};
    }
  }

  // Fungsi helper _handleResponseProfile untuk getCurrentUserProfile dan updateUserProfile
  // karena API profile Anda MENGGUNAKAN pembungkus 'data'
  static Map<String, dynamic> _handleResponseProfile(http.Response response, String operation) {
     print('$operation - Status Code: ${response.statusCode}');
     print('$operation - Body: ${response.body}');
     try {
       final dynamic responseBody = jsonDecode(response.body);
       if (responseBody is Map<String, dynamic>) {
         if (response.statusCode >= 200 && response.statusCode < 300) {
           return {
             'success': responseBody['success'] ?? true, // Ambil 'success' dari API jika ada
             'message': responseBody['message'] ?? '$operation berhasil',
             'data': responseBody['data'], // API profile Anda pakai 'data'
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
       print('Error parsing response for $operation: $e');
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
      return _handleResponseProfile(response, 'Ambil Profil Pengguna'); // Gunakan helper baru
    } catch (e) {
      print('Network error during getCurrentUserProfile: $e');
      return {'success': false, 'message': 'Kesalahan jaringan saat mengambil profil: $e', 'data': null};
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile({
    required String token,
    required String name,
    required String bio,
  }) async {
    final String url = _laravelBaseUrl + ApiConstants.userProfileEndpoint;
    try {
      final response = await http.put( // Asumsi PUT
        Uri.parse(url),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'name': name,
          'bio': bio,
        }),
      );
      // API update profil Anda mungkin juga mengembalikan data user di dalam 'data'
      return _handleResponseProfile(response, 'Update Profil Pengguna'); // Gunakan helper baru
    } catch (e) {
      print('Network error during updateUserProfile: $e');
      return {'success': false, 'message': 'Kesalahan jaringan saat update profil: $e', 'data': null};
    }
  }

 static Future<Map<String, dynamic>> logoutUser({
     required String token,
 }) async {
     final String url = _laravelBaseUrl + ApiConstants.logoutEndpoint;
     try {
     final response = await http.post(
         Uri.parse(url),
         headers: _getHeaders(token: token),
     );
     // Logout mungkin tidak punya 'data' di respons, sesuaikan jika perlu
     // Untuk _handleResponseProfile, jika tidak ada 'data', akan jadi null
     return _handleResponseProfile(response, 'Logout Pengguna');
     } catch (e) {
     print('Network error during logoutUser: $e');
     return {'success': false, 'message': 'Kesalahan jaringan saat logout: $e', 'data': null};
     }
 }
}