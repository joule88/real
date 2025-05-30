// lib/screens/login/register.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:real/widgets/textfield_login.dart'; // Pastikan ini diimpor
import 'package:google_fonts/google_fonts.dart';
// import 'dart:io'; // Untuk File, jika Anda menggunakan image picker
// import 'package:image_picker/image_picker.dart'; // Jika Anda menggunakan image picker

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isRegisterButtonLoading = false; // State loading lokal
  // _isPasswordVisible dan _isConfirmPasswordVisible tidak diperlukan lagi di sini
  // karena TextFieldLogin dengan isPassword:true akan mengelolanya.

  // Definisikan warna tema Anda
  final Color themeColor = const Color(0xFFDAF365);
  final Color textOnThemeColor = Colors.black87; // Atau warna gelap lain yang kontras

  // File? _image; // Untuk menyimpan gambar profil jika ada
  // final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Future<void> _pickImage() async {
  //   final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _image = File(pickedFile.path);
  //     });
  //   }
  // }

  Future<void> _register() async {
    if (_isRegisterButtonLoading) return; // Mencegah klik ganda

    if (_formKey.currentState?.validate() ?? false) {
      if (mounted) {
        setState(() {
          _isRegisterButtonLoading = true;
        });
      } else {
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      print('Register.dart: Memanggil authProvider.register...');

      Map<String, dynamic>? result;
      try {
        result = await authProvider.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          phone: _phoneController.text.trim(),
          // profileImage: _image?.path, // Jika Anda implementasi upload gambar
        );
        print('Register.dart: Hasil dari authProvider.register TELAH DITERIMA: $result');
      } catch (e) {
        print('Register.dart: Exception saat memanggil authProvider.register: $e');
        result = {'success': false, 'message': 'Terjadi kesalahan internal: $e'};
      }

      if (!mounted) return;

      if (result['success'] == true) {
        print('Register.dart: Registrasi SUKSES. Pesan: ${result['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Registrasi berhasil! Silakan login.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Kembali ke halaman login
      } else {
        print('Register.dart: Registrasi GAGAL. Pesan: ${result['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Registrasi gagal. Mohon coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    
      if (mounted) {
        setState(() {
          _isRegisterButtonLoading = false;
        });
      }
    } else {
      if (_isRegisterButtonLoading && mounted) {
         setState(() { _isRegisterButtonLoading = false; });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: const Color.fromARGB(255, 0, 0, 0)), // Warna tema
          onPressed: () {
            if (_isRegisterButtonLoading) return; // Cegah pop saat loading
            Navigator.of(context).pop();
          }
        ),
        title: Text(
          'Buat Akun Baru',
          style: GoogleFonts.poppins(
              color: const Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold), // Warna tema
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Widget untuk pilih gambar (jika diaktifkan)
                  // ... (kode _pickImage dan UI-nya bisa Anda tambahkan kembali jika perlu) ...
                  // const SizedBox(height: 20),

                  TextFieldLogin(
                    label: 'Nama Lengkap', // TAMBAHKAN LABEL
                    controller: _nameController,
                    hintText: 'Masukkan nama lengkap Anda',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      if (value.length < 3) {
                        return 'Nama minimal 3 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFieldLogin(
                    label: 'Email', // TAMBAHKAN LABEL
                    controller: _emailController,
                    hintText: 'Masukkan email Anda',
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
                    label: 'Nomor Telepon', // TAMBAHKAN LABEL
                    controller: _phoneController,
                    hintText: 'Masukkan nomor telepon Anda',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nomor telepon tidak boleh kosong';
                      }
                      if (value.length < 9) { // Validasi panjang nomor telepon
                        return 'Nomor telepon tidak valid (minimal 9 digit)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFieldLogin(
                    label: 'Password', // TAMBAHKAN LABEL
                    controller: _passwordController,
                    hintText: 'Buat password Anda',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true, // TextFieldLogin akan menghandle visibility
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
                  const SizedBox(height: 20),
                  TextFieldLogin(
                    label: 'Konfirmasi Password', // TAMBAHKAN LABEL
                    controller: _confirmPasswordController,
                    hintText: 'Ulangi password Anda',
                    prefixIcon: Icons.lock_reset_outlined,
                    isPassword: true, // TextFieldLogin akan menghandle visibility
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Konfirmasi password tidak boleh kosong';
                      }
                      if (value != _passwordController.text) {
                        return 'Password tidak cocok';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  _isRegisterButtonLoading
                      ? Center(child: CircularProgressIndicator(color: themeColor))
                      : ElevatedButton(
                          onPressed: _isRegisterButtonLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: Text(
                            'Daftar',
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
                        'Sudah punya akun?',
                        style: GoogleFonts.poppins(color: Colors.grey[700]),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_isRegisterButtonLoading) return;
                          Navigator.pop(context); // Kembali ke halaman login
                        },
                        child: Text(
                          'Masuk di sini',
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