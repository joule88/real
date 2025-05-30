// lib/screens/login/login.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:real/screens/login/register.dart';
import 'package:real/widgets/textfield_login.dart'; // Pastikan ini sudah diimpor
import 'package:google_fonts/google_fonts.dart';
import 'package:real/screens/login/forgot_password_screen.dart';
// import 'package:real/screens/main_screen.dart'; // Tidak perlu jika navigasi via Consumer

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoginButtonLoading = false; // State loading lokal

  final Color themeColor = const Color.fromARGB(255, 209, 247, 43);
  final Color textOnThemeColor = Colors.black87; // Warna teks di atas themeColor

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isLoginButtonLoading) return;

    if (!(_formKey.currentState?.validate() ?? false)) {
      if (_isLoginButtonLoading && mounted) {
        setState(() { _isLoginButtonLoading = false; });
      }
      return;
    }

    if (mounted) {
      setState(() { _isLoginButtonLoading = true; });
    } else {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    print('Login.dart: Memanggil authProvider.login...');

    Map<String, dynamic>? loginResult;

    try {
      loginResult = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      print('Login.dart: Hasil dari authProvider.login TELAH DITERIMA: $loginResult');
    } catch (e) {
      print('Login.dart: Exception saat memanggil authProvider.login: $e');
      loginResult = {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }

    // PENANGANAN UI SETELAH AWAIT, GUNAKAN addPostFrameCallback
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) { // Menggunakan addPostFrameCallback
        if (!mounted) return;

        if (loginResult != null) {
          if (loginResult['success'] == true) {
            print('Login.dart (postFrame): Login SUKSES. Pesan: ${loginResult['message']}');
            // TIDAK ADA SNACKBAR SUKSES DI SINI.
          } else {
            final String errorMessage = loginResult['message'] ?? 'Login gagal atau hasil tidak diketahui.';
            print('Login.dart (postFrame): Login GAGAL. Pesan: $errorMessage');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else {
          print('Login.dart (postFrame): Hasil login tidak diketahui.');
           if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Proses login gagal karena kesalahan tidak diketahui (postFrame).'),
                backgroundColor: Colors.orange,
              ),
            );
           }
        }

        if (mounted) {
          setState(() {
            _isLoginButtonLoading = false;
          });
        }
      });
    } else {
      _isLoginButtonLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Selamat Datang Kembali!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masuk untuk melanjutkan',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextFieldLogin(
                    label: 'Email',
                    controller: _emailController,
                    hintText: 'user@gmail.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Masukkan email yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFieldLogin(
                    label: 'Password',
                    controller: _passwordController,
                    hintText: 'Password Anda',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  // POSISI LUPA PASSWORD YANG BENAR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isLoginButtonLoading ? null : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                          );
                        },
                        child: Text(
                          'Lupa Password?',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF5C5C5C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // TOMBOL MASUK YANG SUDAH DIPERBAIKI
                  _isLoginButtonLoading
                      ? Center(child: CircularProgressIndicator(color: themeColor))
                      : ElevatedButton(
                          onPressed: _isLoginButtonLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          // Widget Text 'Masuk' dipindahkan ke dalam child
                          child: Text(
                            'Masuk',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textOnThemeColor,
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun?',
                        style: GoogleFonts.poppins(color: Colors.grey[700]),
                      ),
                      TextButton(
                        onPressed: _isLoginButtonLoading ? null : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: Text(
                          'Daftar di sini',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 0, 0)
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}