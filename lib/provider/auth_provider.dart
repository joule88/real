// lib/provider/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Pastikan sudah diimpor
import '../models/user_model.dart'; // Sesuaikan path jika perlu
import '../services/api_services.dart'; // Sesuaikan path jika perlu
import 'package:image_picker/image_picker.dart'; // Jika digunakan

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitializing = true; // Default ke true

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitializing => _isInitializing; // Getter untuk UI

  bool get isAuthenticated => _user != null && _token != null;

  AuthProvider() {
    print("AuthProvider: Constructor dipanggil, memulai _tryAutoLogin...");
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    // _isInitializing sudah true, tidak perlu di-set lagi di sini.
    // notifyListeners() akan dipanggil setelah operasi async selesai.
    print("AuthProvider: _tryAutoLogin() dimulai.");

    // Tambahkan sedikit delay di sini HANYA UNTUK DEBUGGING jika prosesnya terlalu cepat
    await Future.delayed(const Duration(milliseconds: 10000)); // HAPUS ATAU KOMENTARI DI PRODUKSI

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
        print('AuthProvider: Auto login berhasil untuk pengguna: ${_user?.name}');
        // Anda bisa memanggil fetchUserProfile() di sini jika perlu data terbaru
        // await fetchUserProfile(); // Pastikan ini tidak mengganggu state _isInitializing atau _isLoading
      } else {
        print('AuthProvider: Tidak ada token tersimpan untuk auto login.');
      }
    } catch (e) {
      print("AuthProvider: Error saat _tryAutoLogin: $e");
      _user = null; // Pastikan user dan token null jika error
      _token = null;
    } finally {
      _isInitializing = false;
      print("AuthProvider: _tryAutoLogin() selesai. isInitializing diatur ke false.");
      notifyListeners(); // PENTING: Beri tahu listener setelah inisialisasi selesai
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
    print('AuthProvider: login dipanggil dengan email: $email'); // PRINT 1
    _isLoading = true;
    notifyListeners();
    _clearError();

    Map<String, dynamic> apiResultOutcome = {'success': false, 'message': 'Terjadi kesalahan tidak diketahui saat login.'}; // Variabel ini akan dikembalikan
    bool loginSuccess = false; // Variabel lokal untuk status keberhasilan aktual dari proses login

    try {
      Map<String, dynamic> apiCallResult = await ApiService.loginUser(email: email, password: password);
      print('AuthProvider: Hasil dari ApiService.loginUser: $apiCallResult'); // PRINT 2 (Output ini SANGAT PENTING)

      if (apiCallResult['success'] == true && apiCallResult['data'] != null) {
        final Map<String, dynamic> responseDataFromApi = apiCallResult['data'] as Map<String, dynamic>;

        if (responseDataFromApi.containsKey('token') && responseDataFromApi.containsKey('user')) {
          _token = responseDataFromApi['token'] as String?;
          print('AuthProvider: Token di-set -> $_token');

          if (responseDataFromApi['user'] is Map<String, dynamic>) {
            _user = User.fromJson(responseDataFromApi['user'] as Map<String, dynamic>);
            print('AuthProvider: User di-parse dari login -> ID: ${_user?.id}, Nama: ${_user?.name}, Email: ${_user?.email}, Bio: "${_user?.bio}"');

            // Penentuan keberhasilan upaya login
            if (_user != null && _token != null) {
              // Simpan token dan data user untuk auto login berikutnya
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('userToken', _token!);
              await prefs.setString('userId', _user!.id);
              await prefs.setString('userName', _user!.name);
              await prefs.setString('userEmail', _user!.email);
              await prefs.setString('userBio', _user!.bio);
              await prefs.setString('userPhone', _user!.phone);
              await prefs.setString('userProfileImage', _user!.profileImage);
              print('AuthProvider: Token dan data pengguna disimpan ke SharedPreferences.');

              loginSuccess = true; // <--- PENTING: Di-set true jika user dan token valid
              _errorMessage = null; // Bersihkan error jika sukses
            } else {
              // Ini seharusnya jarang terjadi jika User.fromJson tidak error dan token ada
              _user = null;
              _token = null;
              _errorMessage = 'Gagal memproses data pengguna atau token setelah parsing.';
              loginSuccess = false;
            }
          } else { // Jika 'user' dari API bukan Map
            _user = null;
            _token = null;
            _errorMessage = 'Data pengguna dari server (login) tidak valid.';
            loginSuccess = false;
          }
        } else { // Jika 'data' dari API tidak mengandung 'token' atau 'user'
          _user = null;
          _token = null;
          _errorMessage = 'Respons API tidak mengandung token atau data pengguna.';
          loginSuccess = false;
        }
      } else { // Jika apiCallResult['success'] == false atau apiCallResult['data'] == null
        _user = null;
        _token = null;
        _errorMessage = apiCallResult['message'] ?? 'Login gagal dari ApiService.';
        loginSuccess = false;
      }
      // Simpan pesan dari hasil panggilan API (apiCallResult) ke hasil akhir (apiResultOutcome)
      // jika _errorMessage masih null (artinya tidak ada error spesifik di parsing AuthProvider).
      if(_errorMessage == null) {
        apiResultOutcome['message'] = apiCallResult['message'];
      } else {
        apiResultOutcome['message'] = _errorMessage;
      }

    } catch (e) { // Jika ada error saat memanggil ApiService.loginUser
      _user = null;
      _token = null;
      _errorMessage = 'Exception di AuthProvider.login: $e';
      print('AuthProvider: $_errorMessage');
      apiResultOutcome['message'] = _errorMessage;
      loginSuccess = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Status sukses akhir untuk Map yang dikembalikan
    apiResultOutcome['success'] = loginSuccess;

    if (loginSuccess) {
      // Jika sukses, pastikan pesan yang dikembalikan adalah pesan sukses
      apiResultOutcome['message'] = 'Login berhasil';
    } else {
      // Jika gagal, pastikan pesan error yang relevan dikembalikan
      apiResultOutcome['message'] = _errorMessage ?? apiResultOutcome['message'] ?? 'Login gagal karena alasan tidak diketahui.';
    }

    print('AuthProvider: Mengembalikan hasil login: $apiResultOutcome'); // PRINT 3 (Output ini juga PENTING)
    return apiResultOutcome;
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

    // Hapus token dan data user dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userToken');
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userBio');
    await prefs.remove('userPhone');
    await prefs.remove('userProfileImage');
    print('AuthProvider: Token dan data pengguna dihapus dari SharedPreferences.');


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

                    // Simpan data untuk auto login jika registrasi langsung login
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('userToken', _token!);
                    await prefs.setString('userId', _user!.id);
                    await prefs.setString('userName', _user!.name);
                    await prefs.setString('userEmail', _user!.email);
                    await prefs.setString('userBio', _user!.bio);
                    await prefs.setString('userPhone', _user!.phone);
                    await prefs.setString('userProfileImage', _user!.profileImage);
                    print('AuthProvider: Token dan data pengguna disimpan ke SharedPreferences setelah registrasi & auto-login.');


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
    String? name, // Made optional, send only if changed
    String? bio,  // Made optional
    String? phone, // Added phone, optional
    XFile? profileImageFile, // For new image file
    bool removeProfileImage = false, // To signal removal
  }) async {
    if (!isAuthenticated || _token == null) {
      return {'success': false, 'message': 'Pengguna belum terautentikasi.'};
    }
    _setLoading(true);
    _clearError();
    bool updateSuccess = false;
    String? messageFromServer;
    Map<String, dynamic>? responseData;

    try {
      // Only pass parameters if they have a value or are explicitly set (like removeProfileImage)
      final result = await ApiService.updateUserProfile(
        token: _token!,
        name: name,
        bio: bio,
        phone: phone,
        profileImageFile: profileImageFile,
        removeProfileImage: removeProfileImage,
      );
      print('AuthProvider: Hasil dari ApiService.updateUserProfile: $result');
      messageFromServer = result['message']?.toString();
      responseData = result['data']; // Store data part of response

      if (result['success'] == true) {
        if (responseData != null) {
            // API now returns the updated user object in 'data' field
            _user = User.fromJson(responseData);
            // Update SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('userName', _user!.name);
            await prefs.setString('userBio', _user!.bio);
            await prefs.setString('userPhone', _user!.phone);
            await prefs.setString('userProfileImage', _user!.profileImage);
            print('AuthProvider: User updated from API data -> Name: ${_user?.name}, Bio: "${_user?.bio}", Phone: ${_user?.phone}, Image: ${_user?.profileImage}');
        } else {
          // Fallback: update locally if API response structure is not as expected but success is true
          _user = _user?.copyWith(
            name: name ?? _user?.name,
            bio: bio ?? _user?.bio,
            phone: phone ?? _user?.phone,
            // profileImage handling needs the URL from server, so rely on server response
          );
           print('AuthProvider: User partially updated locally (awaiting full data from potential fetch).');
        }
        updateSuccess = true;
      } else {
        _errorMessage = messageFromServer ?? 'Gagal memperbarui profil.';
      }
    } catch (e) {
      _errorMessage = 'Exception di AuthProvider.updateUserProfile: $e';
      print('AuthProvider: $_errorMessage');
    } finally {
      _setLoading(false);
    }
     // Return structure should be consistent
    if (updateSuccess) {
      return {'success': true, 'message': messageFromServer ?? 'Profil berhasil diperbarui', 'data': responseData};
    } else {
      return {'success': false, 'message': _errorMessage ?? 'Gagal memperbarui profil.'};
    }
  }

  Future<void> fetchUserProfile() async {
    if (_token == null) {
      print('AuthProvider: Token tidak ada, tidak bisa fetch user profile.');
       // Jika fetchUserProfile dipanggil secara mandiri dan tidak ada token,
       // pastikan isLoading tidak terjebak true.
      if (_isLoading) {
        _isLoading = false;
        if (!_isInitializing) notifyListeners(); // Hanya notify jika bukan bagian dari init awal
      }
      return;
    }

    // Hanya set isLoading jika bukan bagian dari proses inisialisasi awal
    // atau jika memang ingin menunjukkan loading di UI secara eksplisit.
    bool shouldShowLoading = !_isInitializing;
    if (shouldShowLoading) {
      _isLoading = true;
      notifyListeners();
    }
    _clearError();

    try {
      final result = await ApiService.getCurrentUserProfile(token: _token!);
      print('AuthProvider: Hasil dari ApiService.getCurrentUserProfile: $result');
      if (result['success'] == true && result['data'] != null) {
          if (result['data'] is Map<String, dynamic>) {
            _user = User.fromJson(result['data'] as Map<String, dynamic>);
            // Update SharedPreferences juga di sini
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('userName', _user!.name);
            await prefs.setString('userEmail', _user!.email);
            await prefs.setString('userBio', _user!.bio);
            await prefs.setString('userPhone', _user!.phone);
            await prefs.setString('userProfileImage', _user!.profileImage);
            print('AuthProvider: User profile di-fetch -> Nama: ${_user?.name}, Bio: "${_user?.bio}"');
          } else {
            _errorMessage = 'Data pengguna dari server (fetch) tidak valid.';
          }
      } else {
        _errorMessage = result['message'] ?? 'Gagal mengambil data profil pengguna.';
        // Jika fetch gagal karena token tidak valid (misalnya expired atau unauthenticated)
        if (result['message'] != null &&
            (result['message'].toString().toLowerCase().contains('unauthenticated') ||
             result['message'].toString().toLowerCase().contains('token has expired'))) {
          print('AuthProvider: Token tidak valid saat fetchUserProfile. Melakukan logout otomatis.');
          await logout(); // Ini akan membersihkan _user, _token, dan SharedPreferences
        }
      }
    } catch (e) {
      _errorMessage = 'Exception saat fetchUserProfile: $e';
      print('AuthProvider: $_errorMessage');
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
      return {'success': false, 'message': 'Anda belum login atau sesi tidak valid.'};
    }

    _isLoading = true;
    notifyListeners();
    _clearError();

    Map<String, dynamic> apiResult = {'success': false, 'message': 'Terjadi kesalahan yang tidak diketahui.'};

    try {
      apiResult = await ApiService.changeUserPassword(
        token: _token!,
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );

      print('AuthProvider: Hasil dari ApiService.changeUserPassword: $apiResult');

      if (apiResult['success'] == true) {
        // Password berhasil diubah
      } else {
        _errorMessage = apiResult['message'] ?? 'Gagal mengubah password dari ApiService.';
      }
    } catch (e) {
      _errorMessage = 'Exception di AuthProvider.changePassword: $e';
      print('AuthProvider: $_errorMessage');
      apiResult = {'success': false, 'message': _errorMessage};
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return apiResult;
  } // <-- TUTUP KURUNG UNTUK METHOD changePassword YANG BENAR

  Future<Map<String, dynamic>> requestResetCode(String email) async { // Mengganti nama dari forgotPassword
    _setLoading(true);
    _clearError();

    Map<String, dynamic> result = {
      'success': false,
      'message': 'Terjadi kesalahan tidak diketahui.'
    };

    try {
      result = await ApiService.requestResetCode(email: email);
      if (result['success'] == false) {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'Terjadi exception: $e';
      result['message'] = _errorMessage;
    } finally {
      _setLoading(false);
    }
    return result; // Pastikan return ini ada dan di luar finally
  } // <-- TUTUP KURUNG UNTUK METHOD requestResetCode

  Future<Map<String, dynamic>> verifyResetCode({
    required String email,
    required String code,
  }) async {
    _setLoading(true);
    _clearError();
    Map<String, dynamic> result = {'success': false, 'message': 'Terjadi kesalahan.'};
    try {
      result = await ApiService.verifyResetCode(email: email, code: code);
      if (result['success'] == false) {
        _errorMessage = result['message'] ?? 'Gagal memverifikasi kode.';
      }
    } catch (e) {
      _errorMessage = 'Exception: $e';
      result['message'] = _errorMessage;
    } finally {
      _setLoading(false);
    }
    return result;
  } // <-- TUTUP KURUNG UNTUK METHOD verifyResetCode

  Future<Map<String, dynamic>> resetPasswordWithVerifiedCode({
    required String email,
    required String code,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    _setLoading(true);
    _clearError();
    Map<String, dynamic> result = {'success': false, 'message': 'Terjadi kesalahan.'};
    try {
      result = await ApiService.resetPasswordWithCode(
        email: email,
        code: code,
        password: newPassword,
        passwordConfirmation: passwordConfirmation,
      );
      if (result['success'] == false) {
        _errorMessage = result['message'] ?? 'Gagal mereset password.';
      }
    } catch (e) {
      _errorMessage = 'Exception: $e';
      result['message'] = _errorMessage;
    } finally {
      _setLoading(false);
    }
    return result;
  } // <-- TUTUP KURUNG UNTUK METHOD resetPasswordWithVerifiedCode
}