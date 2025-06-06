// lib/provider/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_services.dart';
import 'package:image_picker/image_picker.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitializing = true;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitializing => _isInitializing;

  bool get isAuthenticated => _user != null && _token != null;

  AuthProvider() {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    // _isInitializing sudah true, tidak perlu di-set lagi di sini.
    // notifyListeners() akan dipanggil setelah operasi async selesai.
    print("AuthProvider: _tryAutoLogin() dimulai.");

    // Tambahkan sedikit delay di sini HANYA UNTUK DEBUGGING jika prosesnya terlalu cepat
    await Future.delayed(const Duration(milliseconds: 3000)); // HAPUS ATAU KOMENTARI DI PRODUKSI

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('userToken');
      final storedUserId = prefs.getString('userId');
      final storedUserName = prefs.getString('userName');
      final storedUserEmail = prefs.getString('userEmail');
      final storedUserBio = prefs.getString('userBio');
      final storedUserPhone = prefs.getString('userPhone');
      final storedUserProfileImage = prefs.getString('userProfileImage');

      if (storedToken != null && storedUserId != null) {
        _token = storedToken;
        _user = User(
          id: storedUserId,
          name: storedUserName ?? '',
          email: storedUserEmail ?? '',
          bio: storedUserBio ?? '',
          phone: storedUserPhone ?? '',
          profileImage: storedUserProfileImage ?? '',
          token: storedToken,
        );
      }
    } catch (e) {
      print("AuthProvider: Error during _tryAutoLogin: $e");
      _user = null;
      _token = null;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    _clearError();

    // ENGLISH TRANSLATION
    Map<String, dynamic> apiResultOutcome = {'success': false, 'message': 'An unknown error occurred during login.'};
    bool loginSuccess = false;

    try {
      Map<String, dynamic> apiCallResult = await ApiService.loginUser(email: email, password: password);

      if (apiCallResult['success'] == true && apiCallResult['data'] != null) {
        final Map<String, dynamic> responseDataFromApi = apiCallResult['data'] as Map<String, dynamic>;

        if (responseDataFromApi.containsKey('token') && responseDataFromApi.containsKey('user')) {
          _token = responseDataFromApi['token'] as String?;

          if (responseDataFromApi['user'] is Map<String, dynamic>) {
            _user = User.fromJson(responseDataFromApi['user'] as Map<String, dynamic>);

            if (_user != null && _token != null) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('userToken', _token!);
              await prefs.setString('userId', _user!.id);
              await prefs.setString('userName', _user!.name);
              await prefs.setString('userEmail', _user!.email);
              await prefs.setString('userBio', _user!.bio);
              await prefs.setString('userPhone', _user!.phone);
              await prefs.setString('userProfileImage', _user!.profileImage);

              loginSuccess = true;
              _errorMessage = null;
            } else {
              _user = null;
              _token = null;
              // ENGLISH TRANSLATION
              _errorMessage = 'Failed to process user data or token after parsing.';
              loginSuccess = false;
            }
          } else {
            _user = null;
            _token = null;
            // ENGLISH TRANSLATION
            _errorMessage = 'User data from the server (login) is invalid.';
            loginSuccess = false;
          }
        } else {
          _user = null;
          _token = null;
          // ENGLISH TRANSLATION
          _errorMessage = 'API response does not contain a token or user data.';
          loginSuccess = false;
        }
      } else {
        _user = null;
        _token = null;
        // ENGLISH TRANSLATION
        _errorMessage = apiCallResult['message'] ?? 'Login failed from ApiService.';
        loginSuccess = false;
      }
      
      if(_errorMessage == null) {
        apiResultOutcome['message'] = apiCallResult['message'];
      } else {
        apiResultOutcome['message'] = _errorMessage;
      }

    } catch (e) {
      _user = null;
      _token = null;
      // ENGLISH TRANSLATION
      _errorMessage = 'Exception in AuthProvider.login: $e';
      apiResultOutcome['message'] = _errorMessage;
      loginSuccess = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    apiResultOutcome['success'] = loginSuccess;

    if (loginSuccess) {
      // ENGLISH TRANSLATION
      apiResultOutcome['message'] = 'Login successful';
    } else {
      // ENGLISH TRANSLATION
      apiResultOutcome['message'] = _errorMessage ?? apiResultOutcome['message'] ?? 'Login failed for an unknown reason.';
    }
    
    return apiResultOutcome;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // A simpler way to clear all saved data

    _user = null;
    _token = null;
    _isLoading = false;
    _clearError();
    notifyListeners();
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? profileImage,
  }) async {
    _isLoading = true;
    notifyListeners();
    _clearError();
    Map<String, dynamic> apiResult;
    bool registrationProcessedSuccessfully = false;
    String? successMessage;

    try {
      apiResult = await ApiService.registerUser(
        name: name,
        email: email,
        password: password,
        phone: phone,
        profileImage: profileImage,
      );

      if (apiResult['success'] == true) {
        if (apiResult['data'] != null) {
            final Map<String, dynamic> responseDataFromApi = apiResult['data'] as Map<String, dynamic>;
            if (responseDataFromApi.containsKey('token') && responseDataFromApi.containsKey('user')) {
                _token = responseDataFromApi['token'] as String?;
                if (responseDataFromApi['user'] is Map<String, dynamic>) {
                    _user = User.fromJson(responseDataFromApi['user'] as Map<String, dynamic>);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('userToken', _token!);
                    await prefs.setString('userId', _user!.id);
                    await prefs.setString('userName', _user!.name);
                    await prefs.setString('userEmail', _user!.email);
                    await prefs.setString('userBio', _user!.bio);
                    await prefs.setString('userPhone', _user!.phone);
                    await prefs.setString('userProfileImage', _user!.profileImage);

                    registrationProcessedSuccessfully = true;
                    // ENGLISH TRANSLATION
                    successMessage = apiResult['message'] ?? 'Registration and login successful';
                } else {
                    // ENGLISH TRANSLATION
                    _errorMessage = 'User data from registration API is invalid for auto-login.';
                }
            } else {
                registrationProcessedSuccessfully = true;
                // ENGLISH TRANSLATION
                successMessage = apiResult['message'] ?? 'Registration successful, please log in.';
            }
        } else {
            registrationProcessedSuccessfully = true;
            // ENGLISH TRANSLATION
            successMessage = apiResult['message'] ?? 'Registration successful.';
        }
      } else {
        // ENGLISH TRANSLATION
        _errorMessage = apiResult['message'] ?? 'Registration failed.';
      }
    } catch (e) {
      // ENGLISH TRANSLATION
      _errorMessage = 'Exception in AuthProvider.register: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    if (registrationProcessedSuccessfully) {
      return {'success': true, 'message': successMessage};
    } else {
      // ENGLISH TRANSLATION
      return {'success': false, 'message': _errorMessage ?? 'Registration failed.'};
    }
  }

  Future<Map<String, dynamic>> updateUserProfile({
    String? name,
    String? bio,
    String? phone,
    XFile? profileImageFile,
    bool removeProfileImage = false,
  }) async {
    if (!isAuthenticated || _token == null) {
      // ENGLISH TRANSLATION
      return {'success': false, 'message': 'User is not authenticated.'};
    }
    _setLoading(true);
    _clearError();
    bool updateSuccess = false;
    String? messageFromServer;
    Map<String, dynamic>? responseData;

    try {
      final result = await ApiService.updateUserProfile(
        token: _token!,
        name: name,
        bio: bio,
        phone: phone,
        profileImageFile: profileImageFile,
        removeProfileImage: removeProfileImage,
      );
      messageFromServer = result['message']?.toString();
      responseData = result['data'];

      if (result['success'] == true) {
        if (responseData != null) {
            _user = User.fromJson(responseData);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('userName', _user!.name);
            await prefs.setString('userBio', _user!.bio);
            await prefs.setString('userPhone', _user!.phone);
            await prefs.setString('userProfileImage', _user!.profileImage);
        } else {
          _user = _user?.copyWith(name: name, bio: bio, phone: phone);
        }
        updateSuccess = true;
      } else {
        // ENGLISH TRANSLATION
        _errorMessage = messageFromServer ?? 'Failed to update profile.';
      }
    } catch (e) {
      // ENGLISH TRANSLATION
      _errorMessage = 'Exception in AuthProvider.updateUserProfile: $e';
    } finally {
      _setLoading(false);
    }
    if (updateSuccess) {
      // ENGLISH TRANSLATION
      return {'success': true, 'message': messageFromServer ?? 'Profile updated successfully', 'data': responseData};
    } else {
      // ENGLISH TRANSLATION
      return {'success': false, 'message': _errorMessage ?? 'Failed to update profile.'};
    }
  }

  Future<void> fetchUserProfile() async {
    if (_token == null) {
      if (_isLoading) {
        _isLoading = false;
        if (!_isInitializing) notifyListeners();
      }
      return;
    }
    bool shouldShowLoading = !_isInitializing;
    if (shouldShowLoading) {
      _isLoading = true;
      notifyListeners();
    }
    _clearError();

    try {
      final result = await ApiService.getCurrentUserProfile(token: _token!);
      if (result['success'] == true && result['data'] != null) {
          if (result['data'] is Map<String, dynamic>) {
            _user = User.fromJson(result['data'] as Map<String, dynamic>);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('userName', _user!.name);
            await prefs.setString('userEmail', _user!.email);
            await prefs.setString('userBio', _user!.bio);
            await prefs.setString('userPhone', _user!.phone);
            await prefs.setString('userProfileImage', _user!.profileImage);
          } else {
            // ENGLISH TRANSLATION
            _errorMessage = 'User data from server (fetch) is invalid.';
          }
      } else {
        // ENGLISH TRANSLATION
        _errorMessage = result['message'] ?? 'Failed to fetch user profile data.';
        if (result['message'] != null &&
            (result['message'].toString().toLowerCase().contains('unauthenticated') ||
             result['message'].toString().toLowerCase().contains('token has expired'))) {
          await logout();
        }
      }
    } catch (e) {
      // ENGLISH TRANSLATION
      _errorMessage = 'Exception during fetchUserProfile: $e';
    } finally {
      if (shouldShowLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    if (!isAuthenticated || _token == null) {
      // ENGLISH TRANSLATION
      return {'success': false, 'message': 'You are not logged in or your session is invalid.'};
    }
    _isLoading = true;
    notifyListeners();
    _clearError();
    // ENGLISH TRANSLATION
    Map<String, dynamic> apiResult = {'success': false, 'message': 'An unknown error occurred.'};

    try {
      apiResult = await ApiService.changeUserPassword(
        token: _token!,
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      if (apiResult['success'] != true) {
        // ENGLISH TRANSLATION
        _errorMessage = apiResult['message'] ?? 'Failed to change password from ApiService.';
      }
    } catch (e) {
      // ENGLISH TRANSLATION
      _errorMessage = 'Exception in AuthProvider.changePassword: $e';
      apiResult = {'success': false, 'message': _errorMessage};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return apiResult;
  }

  Future<Map<String, dynamic>> requestResetCode(String email) async {
    _setLoading(true);
    _clearError();
    // ENGLISH TRANSLATION
    Map<String, dynamic> result = {'success': false, 'message': 'An unknown error occurred.'};

    try {
      result = await ApiService.requestResetCode(email: email);
      if (result['success'] == false) {
        _errorMessage = result['message'];
      }
    } catch (e) {
      // ENGLISH TRANSLATION
      _errorMessage = 'A network exception occurred: $e';
      result['message'] = _errorMessage;
    } finally {
      _setLoading(false);
    }
    return result;
  }

  Future<Map<String, dynamic>> verifyResetCode({
    required String email,
    required String code,
  }) async {
    _setLoading(true);
    _clearError();
    // ENGLISH TRANSLATION
    Map<String, dynamic> result = {'success': false, 'message': 'An error occurred.'};
    try {
      result = await ApiService.verifyResetCode(email: email, code: code);
      if (result['success'] == false) {
        // ENGLISH TRANSLATION
        _errorMessage = result['message'] ?? 'Failed to verify code.';
      }
    } catch (e) {
      // ENGLISH TRANSLATION
      _errorMessage = 'Exception: $e';
      result['message'] = _errorMessage;
    } finally {
      _setLoading(false);
    }
    return result;
  }

  Future<Map<String, dynamic>> resetPasswordWithVerifiedCode({
    required String email,
    required String code,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    _setLoading(true);
    _clearError();
    // ENGLISH TRANSLATION
    Map<String, dynamic> result = {'success': false, 'message': 'An error occurred.'};
    try {
      result = await ApiService.resetPasswordWithCode(
        email: email,
        code: code,
        password: newPassword,
        passwordConfirmation: passwordConfirmation,
      );
      if (result['success'] == false) {
        // ENGLISH TRANSLATION
        _errorMessage = result['message'] ?? 'Failed to reset password.';
      }
    } catch (e) {
      // ENGLISH TRANSLATION
      _errorMessage = 'Exception: $e';
      result['message'] = _errorMessage;
    } finally {
      _setLoading(false);
    }
    return result;
  }
}