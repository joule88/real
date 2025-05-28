// lib/provider/auth_provider.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_services.dart';

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
    // Jangan panggil _setLoading(true) dan notifyListeners() di sini dulu.
    // Kita akan panggil di awal try, dan di finally.
    _isLoading = true;
    notifyListeners(); // Notify bahwa loading dimulai
    _clearError();

    Map<String, dynamic> apiResult;
    bool loginSuccess = false; // Flag untuk status login akhir

    try {
      apiResult = await ApiService.loginUser(email: email, password: password);
      print('AuthProvider: Hasil dari ApiService.loginUser: $apiResult');

      if (apiResult['success'] == true && apiResult['data'] != null) {
        // Ingat, 'apiResult['data']' sekarang adalah seluruh respons body dari API Anda
        // yang berisi 'token' dan 'user' di root-nya.
        final Map<String, dynamic> responseDataFromApi = apiResult['data'] as Map<String, dynamic>;

        if (responseDataFromApi.containsKey('token') && responseDataFromApi.containsKey('user')) {
          _token = responseDataFromApi['token'] as String?;
          print('AuthProvider: Token di-set -> $_token');

          if (responseDataFromApi['user'] is Map<String, dynamic>) {
            _user = User.fromJson(responseDataFromApi['user'] as Map<String, dynamic>);
            print('AuthProvider: User di-parse dari login -> ID: ${_user?.id}, Nama: ${_user?.name}, Email: ${_user?.email}, Bio: "${_user?.bio}"');
            // Bio akan kosong jika tidak ada di JSON, itu sudah ditangani User.fromJson
          } else {
            _user = null;
            _token = null; // Jika data user tidak valid, anggap token juga tidak valid untuk sesi ini
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
      // Panggil _setLoading(false) dan notifyListeners() SEKALI di sini.
      // Ini akan memastikan UI diupdate dengan status loading terakhir DAN
      // status _user/_token yang sudah final.
      _isLoading = false;
      notifyListeners();
    }

    // Tentukan status sukses akhir berdasarkan apakah _user dan _token valid
    loginSuccess = (_user != null && _token != null);

    if (loginSuccess) {
      // Jika API login Anda tidak mengembalikan bio, dan Anda ingin langsung punya bio
      // Anda bisa memanggil fetchUserProfile di sini setelah login berhasil
      // dan sebelum mengembalikan hasil.
      // Contoh: await fetchUserProfile();
      // Lalu cek lagi if (_user != null && _user.bio != null) // atau semacamnya
      // Tapi ini akan membuat proses login lebih lama.
      // Lebih baik biarkan ProfileScreen yang handle fetch jika bio kosong.
      return {'success': true, 'message': _errorMessage ?? 'Login berhasil'};
    } else {
      return {'success': false, 'message': _errorMessage ?? 'Login gagal karena alasan tidak diketahui.'};
    }
  }

  // ... (fungsi register, updateUserProfile, logout, fetchUserProfile Anda yang sudah direvisi sebelumnya)
  // Pastikan pola try-catch-finally dengan setLoading dan notifyListeners di finally juga diterapkan di sana jika perlu.

  Future<void> logout() async {
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
      print('AuthProvider: Hasil dari ApiService.registerUser: $apiResult');

      if (apiResult['success'] == true) {
        // Jika API register Anda mengembalikan token & user untuk auto-login
        if (apiResult['data'] != null) {
            final Map<String, dynamic> responseDataFromApi = apiResult['data'] as Map<String, dynamic>;
            if (responseDataFromApi.containsKey('token') && responseDataFromApi.containsKey('user')) {
                _token = responseDataFromApi['token'] as String?;
                if (responseDataFromApi['user'] is Map<String, dynamic>) {
                    _user = User.fromJson(responseDataFromApi['user'] as Map<String, dynamic>);
                     print('AuthProvider Register: Auto-login -> Token: $_token, User: ${_user?.name}');
                     registrationProcessedSuccessfully = true; // Sukses dan auto-login
                     successMessage = apiResult['message'] ?? 'Registrasi dan login berhasil';
                } else {
                    _errorMessage = 'Data user dari API register tidak valid untuk auto-login.';
                }
            } else {
                 // Mungkin registrasi sukses tapi tidak ada data untuk auto-login
                 registrationProcessedSuccessfully = true; // Anggap sukses registrasinya
                 successMessage = apiResult['message'] ?? 'Registrasi berhasil, silakan login.';
            }
        } else {
             registrationProcessedSuccessfully = true; // Anggap sukses registrasinya
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

    try {
      final result = await ApiService.updateUserProfile(
        token: _token!,
        name: name,
        bio: bio,
      );
      print('AuthProvider: Hasil dari ApiService.updateUserProfile: $result');

      if (result['success'] == true) {
        if (result['data'] != null && result['data'] is Map<String, dynamic>) {
           final Map<String, dynamic> userData = result['data'] as Map<String, dynamic>;
           _user = User.fromJson(userData); // Update user dengan data dari API
        } else {
          // Jika API tidak mengembalikan data, update lokal
          _user = _user?.copyWith(name: name, bio: bio);
        }
        updateSuccess = true; // Tandai sukses
      } else {
        _errorMessage = result['message'] ?? 'Gagal memperbarui profil.';
      }
    } catch (e) {
      _errorMessage = 'Exception di AuthProvider.updateUserProfile: $e';
      print('AuthProvider: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    if (updateSuccess) {
      return {'success': true, 'message': _errorMessage ?? 'Profil berhasil diperbarui'};
    } else {
      return {'success': false, 'message': _errorMessage ?? 'Gagal memperbarui profil.'};
    }
  }

  Future<void> fetchUserProfile() async {
    if (_token == null) {
      print('AuthProvider: Token tidak ada, tidak bisa fetch user profile.');
      // _errorMessage = 'Sesi tidak valid.'; // Jangan set error jika ini dipanggil saat startup misalnya
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
            _user = null;
         }
      } else {
        _errorMessage = result['message'] ?? 'Gagal mengambil data profil pengguna.';
        _user = null; // Jika gagal fetch, pastikan user null
      }
    } catch (e) {
      _errorMessage = 'Exception saat fetchUserProfile: $e';
      _user = null;
      print('AuthProvider: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}