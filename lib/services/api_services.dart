// lib/services/api_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart'; // Pastikan file ini ada dan benar

class ApiService {
  static const String baseUrl = ApiConstants.laravelApiBaseUrl;

  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? profileImage,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'), // Endpoint registrasi
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'profile_image': profileImage ?? '',
      }),
    );
    print('Register - Status Code: ${response.statusCode}');
    print('Register - Body: ${response.body}');
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'message': data['message'] ?? 'Registrasi berhasil',
        'data': data['data'], // ini data user/token
      };
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Registrasi gagal. Status: ${response.statusCode}',
          'data': null,
        };
      } catch (e) {
         return {
          'success': false,
          'message': 'Registrasi gagal. Respons tidak valid. Status: ${response.statusCode}',
          'data': null,
        };
      }
    }
  }

  // --- FUNGSI BARU UNTUK UPDATE PROFIL ---
  static Future<Map<String, dynamic>> updateUserProfile({
    required String token, // Token otentikasi pengguna
    required String name,
    required String bio,
    // Anda bisa menambahkan field lain jika API mengizinkan (misal: phone, profile_image)
  }) async {
    // Asumsi endpoint update profil adalah '/user/profile' dan menggunakan method PUT
    // Sesuaikan endpoint dan method (PUT/POST) jika berbeda di API Laravel Anda
    final String updateProfileEndpoint = '$baseUrl/user/profile';

    try {
      final response = await http.put( // Atau http.post jika API Anda menggunakan POST
        Uri.parse(updateProfileEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Kirim token untuk otentikasi
        },
        body: jsonEncode({
          'name': name,
          'bio': bio,
          // 'phone': newPhone, // Jika Anda juga mengizinkan update nomor telepon
        }),
      );

      print('Update Profile - Status Code: ${response.statusCode}');
      print('Update Profile - Body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) { // Sukses
        return {
          'success': true,
          'message': responseBody['message'] ?? 'Profil berhasil diperbarui',
          'data': responseBody['data'], // API mungkin mengembalikan data user yang sudah diupdate
        };
      } else {
        // Gagal, coba parse pesan error dari API
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Gagal memperbarui profil. Status: ${response.statusCode}',
          'errors': responseBody['errors'], // Jika API mengirimkan detail error validasi
          'data': null,
        };
      }
    } catch (e) {
      // Error koneksi atau parsing JSON
      print('Error in updateUserProfile: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
        'data': null,
      };
    }
  }

  // --- Tambahkan fungsi API lainnya di sini (misalnya login, fetch properties, dll) ---
  // Contoh fungsi login (jika belum ada)
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'), // Endpoint login
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    print('Login - Status Code: ${response.statusCode}');
    print('Login - Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'message': data['message'] ?? 'Login berhasil',
        'data': data['data'], // ini biasanya berisi token dan data user
      };
    } else {
       try {
        final errorBody = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorBody['message'] ?? 'Login gagal. Status: ${response.statusCode}',
          'data': null,
        };
      } catch (e) {
         return {
          'success': false,
          'message': 'Login gagal. Respons tidak valid. Status: ${response.statusCode}',
          'data': null,
        };
      }
    }
  }

  // Contoh fungsi untuk mengambil data profil pengguna saat ini (jika diperlukan terpisah)
  static Future<Map<String, dynamic>> getCurrentUserProfile({
    required String token,
  }) async {
    // Asumsi endpoint untuk mendapatkan profil adalah GET /api/user/profile
    final String profileEndpoint = '$baseUrl/user/profile';

    try {
      final response = await http.get(
        Uri.parse(profileEndpoint),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get Profile - Status Code: ${response.statusCode}');
      print('Get Profile - Body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseBody['message'] ?? 'Data profil berhasil diambil',
          'data': responseBody['data'], // Data pengguna
        };
      } else {
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Gagal mengambil data profil. Status: ${response.statusCode}',
          'data': null,
        };
      }
    } catch (e) {
      print('Error in getCurrentUserProfile: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat mengambil profil: $e',
        'data': null,
      };
    }
  }

}