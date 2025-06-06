// lib/services/api_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

  static Map<String, String> _getBaseHeaders({String? token}) {
    final headers = {
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ENGLISH TRANSLATION: All messages are now in English
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

      final dynamic responseBody = jsonDecode(response.body);
      if (responseBody is Map<String, dynamic>) {
        if (response.statusCode == 201) {
          return {
            'success': true,
            'message': responseBody['message'] ?? 'Registration successful',
            'data': responseBody,
          };
        } else {
          return {
            'success': false,
            'message': responseBody['message'] ?? responseBody['error'] ?? 'Registration failed. Status: ${response.statusCode}',
            'errors': responseBody['errors'],
            'data': null,
          };
        }
      } else {
          return {'success': false, 'message': 'Invalid registration response.', 'data': null};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error during registration: $e', 'data': null};
    }
  }

  // ENGLISH TRANSLATION: All messages are now in English
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

      final dynamic responseBody = jsonDecode(response.body);
      if (responseBody is Map<String, dynamic>) {
          if (response.statusCode == 200) {
              return {
                'success': true,
                'message': responseBody['message'] ?? 'Login successful',
                'data': responseBody,
              };
          } else {
              return {
                'success': false,
                'message': responseBody['message'] ?? responseBody['error'] ?? 'Login failed. Status: ${response.statusCode}',
                'data': null,
              };
          }
      } else {
          return {'success': false, 'message': 'Invalid login response.', 'data': null};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error during login: $e', 'data': null};
    }
  }

  // ENGLISH TRANSLATION: All messages are now in English
  static Map<String, dynamic> _handleResponseProfile(http.Response response, String operation) {
      try {
        final dynamic responseBody = jsonDecode(response.body);
        if (responseBody is Map<String, dynamic>) {
          if (response.statusCode >= 200 && response.statusCode < 300) {
            return {
              'success': responseBody['success'] ?? true,
              'message': responseBody['message'] ?? '$operation successful',
              'data': responseBody['data'],
            };
          } else {
            return {
              'success': false,
              'message': responseBody['message'] ?? responseBody['error'] ?? '$operation failed. Status: ${response.statusCode}',
              'errors': responseBody['errors'],
              'data': null,
            };
          }
        } else {
          return {'success': false, 'message': '$operation failed. Invalid response (not a JSON Map).', 'data': null};
        }
      } catch (e) {
        return {'success': false, 'message': '$operation failed. Response could not be processed.', 'data': null};
      }
  }

  // ENGLISH TRANSLATION: All messages are now in English
  static Future<Map<String, dynamic>> getCurrentUserProfile({
    required String token,
  }) async {
    final String url = _laravelBaseUrl + ApiConstants.userProfileEndpoint;
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(token: token),
      );
      return _handleResponseProfile(response, 'Get User Profile');
    } catch (e) {
      return {'success': false, 'message': 'Network error while fetching profile: $e', 'data': null};
    }
  }
  
  // ENGLISH TRANSLATION: All messages are now in English
  static Future<Map<String, dynamic>> updateUserProfile({
    required String token,
    String? name,
    String? bio,
    String? phone,
    XFile? profileImageFile,
    bool removeProfileImage = false,
  }) async {
    final String url = _laravelBaseUrl + ApiConstants.userProfileEndpoint;
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(_getBaseHeaders(token: token));
      request.fields['_method'] = 'PUT';

      if (name != null) request.fields['name'] = name;
      if (bio != null) request.fields['bio'] = bio;
      if (phone != null) request.fields['phone'] = phone;
      
      request.fields['remove_profile_image'] = removeProfileImage ? '1' : '0';

      if (profileImageFile != null) {
        http.MultipartFile multipartFile;
        if (kIsWeb) {
          var bytes = await profileImageFile.readAsBytes();
          multipartFile = http.MultipartFile.fromBytes(
            'profile_image_file',
            bytes,
            filename: profileImageFile.name,
            contentType: MediaType('image', profileImageFile.name.split('.').last),
          );
        } else {
          multipartFile = await http.MultipartFile.fromPath(
            'profile_image_file',
            profileImageFile.path,
            filename: profileImageFile.name,
            contentType: MediaType('image', profileImageFile.name.split('.').last),
          );
        }
        request.files.add(multipartFile);
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponseProfile(response, 'Update User Profile');

    } catch (e) {
      return {'success': false, 'message': 'Network error while updating profile: $e', 'data': null};
    }
  }

  // ENGLISH TRANSLATION: All messages are now in English
  static Future<Map<String, dynamic>> logoutUser({
      required String token,
  }) async {
      final String url = _laravelBaseUrl + ApiConstants.logoutEndpoint;
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: _getHeaders(token: token),
        );
        try {
            final dynamic responseBody = jsonDecode(response.body);
            if (responseBody is Map<String, dynamic>) {
                 return {
                    'success': responseBody['success'] ?? (response.statusCode == 200),
                    'message': responseBody['message'] ?? 'Logout successful',
                 };
            } else {
                 return {'success': false, 'message': 'Invalid logout response.'};
            }
        } catch (e) {
            if (response.statusCode == 200) {
                return {'success': true, 'message': 'Logout successful (empty response).'} ;
            }
            return {'success': false, 'message': 'Could not process logout response.'};
        }
      } catch (e) {
        return {'success': false, 'message': 'Network error during logout: $e'};
      }
  }

  // ENGLISH TRANSLATION: All messages are now in English
  static Future<Map<String, dynamic>> requestResetCode({required String email}) async {
    final String url = _laravelBaseUrl + ApiConstants.forgotPasswordEndpoint;
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _getHeaders(),
        body: jsonEncode({'email': email}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  // ENGLISH TRANSLATION: All messages are now in English
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
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network Error: $e'};
    }
  }

  // ENGLISH TRANSLATION: All messages are now in English
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
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network Error: $e'};
    }
  }
  
  // ENGLISH TRANSLATION: All messages are now in English
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

      try {
          final dynamic responseBody = jsonDecode(response.body);
          if (responseBody is Map<String, dynamic>) {
            bool success = responseBody['success'] ?? (response.statusCode == 200);
            String message = responseBody['message'] ?? (success ? 'Password changed successfully.' : 'Failed to change password.');

            return {
              'success': success,
              'message': message,
              'errors': responseBody['errors'],
            };
          } else {
             return {'success': false, 'message': 'Invalid change password response.'};
          }
      } catch (e) {
          if (response.statusCode == 200) {
              return {'success': true, 'message': 'Password changed successfully (unstructured response).'} ;
          }
          return {'success': false, 'message': 'Could not process change password response.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error while changing password: $e'};
    }
  }

  // ENGLISH TRANSLATION: All messages are now in English
  static Future<Map<String, dynamic>> toggleBookmark({
    required String token,
    required String propertyId,
  }) async {
    final String url = '$_laravelBaseUrl${ApiConstants.toggleBookmarkEndpoint}/$propertyId/toggle-bookmark';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _getHeaders(token: token),
      );
      final dynamic responseBody = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
          return {
              'success': true,
              'message': responseBody['message'] ?? 'Bookmark status updated.',
              'is_favorited_by_user': responseBody['data']?['is_favorited'] ?? false,
          };
      } else {
          return {
              'success': false,
              'message': responseBody['message'] ?? 'Failed to update bookmark. Status: ${response.statusCode}',
          };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ENGLISH TRANSLATION: All messages are now in English
  static Future<Map<String, dynamic>> getBookmarkedProperties({
    required String token,
    int page = 1,
  }) async {
    final String url = '$_laravelBaseUrl${ApiConstants.getBookmarksEndpoint}?page=$page';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(token: token),
      );
      final dynamic responseBody = jsonDecode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == true) {
           final Map<String, dynamic> paginatedData = responseBody['data'] is Map ? responseBody['data'] : {'data': responseBody['data'] ?? []};
             if (paginatedData.containsKey('data') && paginatedData['data'] is List) {
                return {
                  'success': true,
                  'message': responseBody['message'] ?? 'Bookmarked properties fetched successfully.',
                  'properties': List<Map<String, dynamic>>.from(paginatedData['data']),
                  'currentPage': paginatedData['current_page'] ?? 1,
                  'lastPage': paginatedData['last_page'] ?? 1,
                  'total': paginatedData['total'] ?? (paginatedData['data'] as List).length,
                };
             }
             return {
                'success': true,
                'message': responseBody['message'] ?? 'Bookmarked properties fetched successfully (non-standard format).',
                'properties': [],
                'currentPage': 1, 'lastPage': 1, 'total': 0
            };
      } else {
          return {
              'success': false,
              'message': responseBody['message'] ?? 'Failed to fetch bookmarks. Status: ${response.statusCode}',
          };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ENGLISH TRANSLATION: All messages are now in English
  static Future<Map<String, dynamic>> getPublicProperties({
    int page = 1,
    String? keyword,
    String? category,
    Map<String, dynamic>? filters,
    String? authToken,
  }) async {
    String endpoint = ApiConstants.publicPropertiesEndpoint;
    Map<String, String> queryParameters = {'page': page.toString()};

    if (keyword != null && keyword.isNotEmpty) queryParameters['keyword'] = keyword;
    if (category != null && category.isNotEmpty) queryParameters['category'] = category;
    if (filters != null) {
      filters.forEach((key, value) {
        if (value != null) queryParameters[key] = value.toString();
      });
    }
    
    final uri = Uri.parse('$_laravelBaseUrl$endpoint').replace(queryParameters: queryParameters);

    try {
      final response = await http.get(uri, headers: _getHeaders(token: authToken));
      final dynamic responseBody = jsonDecode(response.body);

      if (responseBody is Map<String, dynamic>) {
        if (response.statusCode == 200 && responseBody['success'] == true) {
          if (responseBody.containsKey('data') && responseBody['data'] is Map) {
             final Map<String, dynamic> paginatedData = responseBody['data'];
             if (paginatedData.containsKey('data') && paginatedData['data'] is List) {
                return {
                  'success': true,
                  'message': responseBody['message'] ?? 'Public properties fetched successfully.',
                  'properties': List<Map<String, dynamic>>.from(paginatedData['data']),
                  'currentPage': paginatedData['current_page'],
                  'lastPage': paginatedData['last_page'],
                  'total': paginatedData['total'],
                };
             }
          }
          return {'success': true, 'message': responseBody['message'] ?? 'Non-standard data format.', 'properties': [], 'currentPage': 1, 'lastPage': 1, 'total': 0};
        } else {
          return {'success': false, 'message': responseBody['message'] ?? 'Failed to fetch public properties.'};
        }
      }
      return {'success': false, 'message': 'Invalid API response.'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}