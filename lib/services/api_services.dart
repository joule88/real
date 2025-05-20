import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class ApiService {
  static const String baseUrl = ApiConstants.baseUrl;

  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? profileImage, // Tambahkan parameter ini
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json', // PENTING agar Laravel tahu ini API request
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'profile_image': profileImage ?? '',
      }),
    );
    print('Status Code: ${response.statusCode}');
    print('Body: ${response.body}');
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {
        'success': true,
        'message': data['message'] ?? 'Registrasi berhasil',
        'data': data['data'], // ini data user/token
      };
    } else {
      final errorBody = jsonDecode(response.body);
      return {
        'success': false,
        'message': errorBody['message'] ?? 'Registrasi gagal',
        'data': null,
      };
    }
  }
}
