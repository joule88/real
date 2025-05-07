import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.10.183.4:8000/api'; // Ganti jika bukan emulator

  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? profileImage, // Tambahkan parameter ini
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'), // Pastikan URL benar
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'profile_image': profileImage ?? '', // Tambahkan ini
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {'success': true, 'data': data};
    } else {
      return {
        'success': false,
        'message': jsonDecode(response.body)['message'] ?? 'Gagal'
      };
    }
  }
}
