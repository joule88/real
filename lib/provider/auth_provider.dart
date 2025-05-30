// lib/provider/auth_provider.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_services.dart'; // Pastikan ApiService memiliki method yang diperlukan

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _user != null && _token != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    print('AuthProvider: login dipanggil dengan email: $email');
    _isLoading = true;
    notifyListeners(); 
    _clearError();

    Map<String, dynamic> apiResult;
    bool loginSuccess = false;

    try {
      apiResult = await ApiService.loginUser(email: email, password: password);
      print('AuthProvider: Hasil dari ApiService.loginUser: $apiResult');

      if (apiResult['success'] == true && apiResult['data'] != null) {
        final Map<String, dynamic> responseDataFromApi = apiResult['data'] as Map<String, dynamic>;

        if (responseDataFromApi.containsKey('token') && responseDataFromApi.containsKey('user')) {
          _token = responseDataFromApi['token'] as String?;
          print('AuthProvider: Token di-set -> $_token');

          if (responseDataFromApi['user'] is Map<String, dynamic>) {
            _user = User.fromJson(responseDataFromApi['user'] as Map<String, dynamic>);
            print('AuthProvider: User di-parse dari login -> ID: ${_user?.id}, Nama: ${_user?.name}, Email: ${_user?.email}, Bio: "${_user?.bio}"');
          } else {
            _user = null;
            _token = null; 
            _errorMessage = 'Data pengguna dari server (login) tidak valid.';
            print('AuthProvider: $_errorMessage');
          }
        } else {
          _user = null;
          _token = null;
          _errorMessage = 'Respons API tidak mengandung token atau data pengguna.';
          print('AuthProvider: $_errorMessage');
        }
      } else {
        _user = null;
        _token = null;
        _errorMessage = apiResult['message'] ?? 'Login gagal dari ApiService.';
        print('AuthProvider: $_errorMessage');
      }
    } catch (e) {
      _user = null;
      _token = null;
      _errorMessage = 'Exception di AuthProvider.login: $e';
      print('AuthProvider: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    loginSuccess = (_user != null && _token != null);

    if (loginSuccess) {
      return {'success': true, 'message': _errorMessage ?? 'Login berhasil'};
    } else {
      return {'success': false, 'message': _errorMessage ?? 'Login gagal karena alasan tidak diketahui.'};
    }
  }

  Future<void> logout() async {
    // Panggil API logout jika ada
    // if (_token != null) {
    //   try {
    //     await ApiService.logoutUser(token: _token!);
    //     print('AuthProvider: Logout API call successful');
    //   } catch (e) {
    //     print('AuthProvider: Error calling logout API: $e');
    //     // Tetap lanjutkan proses logout di sisi client meskipun API gagal
    //   }
    // }

    _user = null;
    _token = null;
    _isLoading = false;
    _clearError();
    notifyListeners();
    print('AuthProvider: User logged out from client-side.');
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
      print('AuthProvider: Hasil dari ApiService.registerUser: $apiResult');

      if (apiResult['success'] == true) {
        if (apiResult['data'] != null) {
            final Map<String, dynamic> responseDataFromApi = apiResult['data'] as Map<String, dynamic>;
            if (responseDataFromApi.containsKey('token') && responseDataFromApi.containsKey('user')) {
                _token = responseDataFromApi['token'] as String?;
                if (responseDataFromApi['user'] is Map<String, dynamic>) {
                    _user = User.fromJson(responseDataFromApi['user'] as Map<String, dynamic>);
                    print('AuthProvider Register: Auto-login -> Token: $_token, User: ${_user?.name}');
                    registrationProcessedSuccessfully = true; 
                    successMessage = apiResult['message'] ?? 'Registrasi dan login berhasil';
                } else {
                    _errorMessage = 'Data user dari API register tidak valid untuk auto-login.';
                }
            } else {
                registrationProcessedSuccessfully = true; 
                successMessage = apiResult['message'] ?? 'Registrasi berhasil, silakan login.';
            }
        } else {
            registrationProcessedSuccessfully = true; 
            successMessage = apiResult['message'] ?? 'Registrasi berhasil.';
        }
      } else {
        _errorMessage = apiResult['message'] ?? 'Registrasi gagal.';
      }
    } catch (e) {
      _errorMessage = 'Exception di AuthProvider.register: $e';
      print('AuthProvider: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    if (registrationProcessedSuccessfully) {
      return {'success': true, 'message': successMessage};
    } else {
      return {'success': false, 'message': _errorMessage ?? 'Registrasi gagal.'};
    }
  }

  Future<Map<String, dynamic>> updateUserProfile({
    required String name,
    required String bio,
  }) async {
    if (!isAuthenticated) {
      return {'success': false, 'message': 'Pengguna belum terautentikasi.'};
    }
    _isLoading = true;
    notifyListeners();
    _clearError();
    bool updateSuccess = false;
    String? messageFromServer;

    try {
      final result = await ApiService.updateUserProfile(
        token: _token!,
        name: name,
        bio: bio,
      );
      print('AuthProvider: Hasil dari ApiService.updateUserProfile: $result');
      messageFromServer = result['message']?.toString();

      if (result['success'] == true) {
        if (result['data'] != null && result['data'] is Map<String, dynamic>) {
            final Map<String, dynamic> userData = result['data'] as Map<String, dynamic>;
            // Pastikan data dari API memiliki semua field yang dibutuhkan User.fromJson
            // atau User.fromJson bisa menangani field yang hilang.
            _user = User.fromJson(userData); 
            print('AuthProvider: User updated from API data -> Name: ${_user?.name}, Bio: "${_user?.bio}"');
        } else {
          // Jika API tidak mengembalikan data user lengkap, update lokal saja
          // Ini asumsi bahwa _user tidak null karena isAuthenticated sudah dicek
          _user = _user?.copyWith(name: name, bio: bio);
           print('AuthProvider: User updated locally -> Name: ${_user?.name}, Bio: "${_user?.bio}"');
        }
        updateSuccess = true;
      } else {
        _errorMessage = messageFromServer ?? 'Gagal memperbarui profil.';
      }
    } catch (e) {
      _errorMessage = 'Exception di AuthProvider.updateUserProfile: $e';
      print('AuthProvider: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    if (updateSuccess) {
      return {'success': true, 'message': messageFromServer ?? 'Profil berhasil diperbarui'};
    } else {
      return {'success': false, 'message': _errorMessage ?? 'Gagal memperbarui profil.'};
    }
  }

  Future<void> fetchUserProfile() async {
    if (_token == null) {
      print('AuthProvider: Token tidak ada, tidak bisa fetch user profile.');
      return;
    }
    _isLoading = true;
    notifyListeners();
    _clearError();
    try {
      final result = await ApiService.getCurrentUserProfile(token: _token!);
      print('AuthProvider: Hasil dari ApiService.getCurrentUserProfile: $result');
      if (result['success'] == true && result['data'] != null) {
          if (result['data'] is Map<String, dynamic>) {
            _user = User.fromJson(result['data'] as Map<String, dynamic>);
            print('AuthProvider: User profile di-fetch -> Nama: ${_user?.name}, Bio: "${_user?.bio}"');
          } else {
            _errorMessage = 'Data pengguna dari server (fetch) tidak valid.';
            _user = null; // Atau jangan ubah _user jika data tidak valid? Tergantung kebutuhan.
          }
      } else {
        _errorMessage = result['message'] ?? 'Gagal mengambil data profil pengguna.';
        // Pertimbangkan apakah _user harus di-null-kan jika fetch gagal.
        // Jika user sudah ada dari login, mungkin lebih baik tidak di-null-kan kecuali ada error auth.
        // _user = null; 
      }
    } catch (e) {
      _errorMessage = 'Exception saat fetchUserProfile: $e';
      // _user = null; // Sama seperti di atas, pertimbangkan dampaknya.
      print('AuthProvider: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- METHOD BARU UNTUK UBAH PASSWORD ---
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    if (!isAuthenticated || _token == null) { // Periksa _token juga untuk kepastian
      return {'success': false, 'message': 'Anda belum login atau sesi tidak valid.'};
    }

    _isLoading = true;
    notifyListeners();
    _clearError();
    
    Map<String, dynamic> apiResult = {'success': false, 'message': 'Terjadi kesalahan yang tidak diketahui.'};

    try {
      // Panggil method yang sesuai di ApiService
      // Kita asumsikan nama methodnya adalah changeUserPassword
      apiResult = await ApiService.changeUserPassword(
        token: _token!,
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );

      print('AuthProvider: Hasil dari ApiService.changeUserPassword: $apiResult');

      if (apiResult['success'] == true) {
        // Password berhasil diubah di backend.
        // Tidak ada state user yang perlu diubah di sini terkait password.
        // Pesan sukses akan diambil dari apiResult.
      } else {
        _errorMessage = apiResult['message'] ?? 'Gagal mengubah password dari ApiService.';
      }
    } catch (e) {
      _errorMessage = 'Exception di AuthProvider.changePassword: $e';
      print('AuthProvider: $_errorMessage');
      apiResult = {'success': false, 'message': _errorMessage}; // Pastikan apiResult mencerminkan error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    
    // Kembalikan hasil dari API apa adanya, atau format ulang jika perlu
    return apiResult; 
  }
}