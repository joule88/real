// lib/services/api_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class ApiService {
  static String get _laravelBaseUrl => ApiConstants.laravelApiBaseUrl;

  static Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
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
    final String url = _laravelBaseUrl + ApiConstants.userProfileEndpoint;
    try {
      final response = await http.put(
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
        final response = await http.post(
          Uri.parse(url),
          headers: _getHeaders(token: token),
        );
        print('ApiService Logout - Status Code: ${response.statusCode}');
        print('ApiService Logout - Body: ${response.body}');
        try {
            final dynamic responseBody = jsonDecode(response.body);
            if (responseBody is Map<String, dynamic>) {
                 return {
                    'success': responseBody['success'] ?? (response.statusCode == 200),
                    'message': responseBody['message'] ?? 'Logout berhasil',
                 };
            } else {
                 return {'success': false, 'message': 'Respons logout tidak valid.'};
            }
        } catch (e) {
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

    // --- FUNGSI BARU UNTUK ALUR LUPA PASSWORD ---

  static Future<Map<String, dynamic>> requestResetCode({required String email}) async {
    final String url = _laravelBaseUrl + ApiConstants.forgotPasswordEndpoint;
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _getHeaders(),
        body: jsonEncode({'email': email}),
      );
      print('ApiService requestResetCode - Status: ${response.statusCode}, Body: ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('ApiService Network error during requestResetCode: $e');
      return {'success': false, 'message': 'Kesalahan jaringan. Silakan coba lagi.'};
    }
  }

  static Future<Map<String, dynamic>> verifyResetCode({
    required String email,
    required String code,
  }) async {
    final String url = _laravelBaseUrl + ApiConstants.verifyCodeEndpoint;
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _getHeaders(),
        body: jsonEncode({'email': email, 'code': code}),
      );
      print('ApiService verifyResetCode - Status: ${response.statusCode}, Body: ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('ApiService Network error during verifyResetCode: $e');
      return {'success': false, 'message': 'Kesalahan Jaringan: $e'};
    }
  }

  static Future<Map<String, dynamic>> resetPasswordWithCode({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
     final String url = _laravelBaseUrl + ApiConstants.resetPasswordWithCodeEndpoint;
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'code': code,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );
      print('ApiService resetPasswordWithCode - Status: ${response.statusCode}, Body: ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('ApiService Network error during resetPasswordWithCode: $e');
      return {'success': false, 'message': 'Kesalahan Jaringan: $e'};
    }
  }
  

  static Future<Map<String, dynamic>> changeUserPassword({
    required String token,
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final String url = _laravelBaseUrl + (ApiConstants.changePasswordEndpoint);

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

      try {
          final dynamic responseBody = jsonDecode(response.body);
          if (responseBody is Map<String, dynamic>) {
            bool success = responseBody['success'] ?? (response.statusCode == 200);
            String message = responseBody['message'] ?? (success ? 'Password berhasil diubah.' : 'Gagal mengubah password.');

            return {
              'success': success,
              'message': message,
              'errors': responseBody['errors'],
            };
          } else {
             return {'success': false, 'message': 'Respons ubah password tidak valid.'};
          }
      } catch (e) {
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

  // --- MODIFIKASI METHOD getPublicProperties ---
  static Future<Map<String, dynamic>> getPublicProperties({
    int page = 1,
    String? keyword, // Tambahkan parameter keyword opsional
  }) async {
    String endpoint = ApiConstants.publicPropertiesEndpoint;
    String queryParams = '?page=$page'; // Selalu ada parameter page

    if (keyword != null && keyword.isNotEmpty) {
      // Pastikan keyword di-encode dengan benar untuk URL
      queryParams += '&keyword=${Uri.encodeQueryComponent(keyword)}'; 
    }

    // Gabungkan base URL, endpoint, dan queryParams
    final String url = '$_laravelBaseUrl$endpoint$queryParams';
    
    print('ApiService: Fetching public properties from $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(), // Tidak memerlukan token untuk API publik ini
      );

      print('ApiService GetPublicProperties - Status Code: ${response.statusCode}');
      print('ApiService GetPublicProperties - Body: ${response.body}');

      final dynamic responseBody = jsonDecode(response.body);

      if (responseBody is Map<String, dynamic>) {
        if (response.statusCode == 200 && responseBody['success'] == true) {
          if (responseBody.containsKey('data') && responseBody['data'] is Map) {
             final Map<String, dynamic> paginatedData = responseBody['data'];
             if (paginatedData.containsKey('data') && paginatedData['data'] is List) {
                return {
                  'success': true,
                  'message': responseBody['message'] ?? 'Properti publik berhasil diambil.',
                  'properties': List<Map<String, dynamic>>.from(paginatedData['data']), // List properti
                  'currentPage': paginatedData['current_page'],
                  'lastPage': paginatedData['last_page'],
                  'total': paginatedData['total'],
                };
             }
          }
          print('ApiService GetPublicProperties - Format data paginasi tidak sesuai, namun success: true.');
          return {
            'success': true,
            'message': responseBody['message'] ?? 'Data diterima namun format tidak standar.',
            'properties': [], 
            'currentPage': 1, 
            'lastPage': 1,
            'total': 0,
          };
        } else {
          return {
            'success': false,
            'message': responseBody['message'] ?? 'Gagal mengambil properti publik. Status: ${response.statusCode}',
          };
        }
      } else {
        return {'success': false, 'message': 'Respons API properti publik tidak valid.'};
      }
    } catch (e) {
      print('ApiService Network error during getPublicProperties: $e');
      return {'success': false, 'message': 'Kesalahan jaringan saat mengambil properti publik: $e'};
    }
  }
  // --- AKHIR MODIFIKASI ---
}