// lib/screens/profile/edit_profile_screen.dart
import 'dart:convert'; // Diperlukan untuk json.encode di AuthProvider (jika dipindah ke sini)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:real/models/user_model.dart';
import 'package:real/provider/auth_provider.dart';
// import 'package:real/services/api_constants.dart'; // Jika AuthProvider tidak punya baseUrl
// import 'package:http/http.dart' as http; // Jika AuthProvider tidak menangani http call

class EditProfileScreen extends StatefulWidget {
  final User currentUser;

  const EditProfileScreen({super.key, required this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;

  bool _isSaving = false;

  // Controller dan state untuk dialog ubah password
  final _passwordFormKey = GlobalKey<FormState>();
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  bool _isChangingPassword = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;


  final Color themeColor = const Color(0xFFDAF365);
  final Color textOnThemeColor = Colors.black87;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUser.name);
    _bioController = TextEditingController(text: widget.currentUser.bio ?? '');

    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_isSaving) return;

    if (_formKey.currentState?.validate() ?? false) {
      if (mounted) {
        setState(() {
          _isSaving = true;
        });
      } else {
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final newName = _nameController.text.trim();
      final newBio = _bioController.text.trim();

      print('EditProfileScreen: Menyimpan profil -> Nama: $newName, Bio: $newBio');

      Map<String, dynamic>? result;
      try {
        result = await authProvider.updateUserProfile(
          name: newName,
          bio: newBio,
        );
        print('EditProfileScreen: Hasil dari authProvider.updateUserProfile: $result');
      } catch (e) {
        print('EditProfileScreen: Exception saat memanggil authProvider.updateUserProfile: $e');
        result = {'success': false, 'message': 'Terjadi kesalahan: $e'};
      }

      if (!mounted) return;

      if (result['success'] == true) {
        print('EditProfileScreen: Update SUKSES. Pesan: ${result['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        final String errorMessage = result['message'] ?? 'Gagal memperbarui profil.';
        print('EditProfileScreen: Update GAGAL. Pesan: $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    } else {
      if (_isSaving && mounted) {
         setState(() { _isSaving = false; });
      }
    }
  }

  Future<void> _submitChangePasswordForm() async {
    if (_isChangingPassword) return;
    if (!(_passwordFormKey.currentState?.validate() ?? false)) {
      return;
    }

    // Tutup keyboard jika terbuka
    FocusScope.of(context).unfocus();

    setState(() { // Ini untuk loading di tombol dialog
      _isChangingPassword = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      newPasswordConfirmation: _confirmPasswordController.text,
    );

    if (!mounted) return;

    // Tutup dialog setelah proses selesai, baik sukses maupun gagal
    // Pindahkan ini ke dalam blok if/else jika Anda ingin dialog tetap terbuka pada kasus tertentu
    Navigator.of(context).pop(); 

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Password berhasil diubah!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal mengubah password.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    // Pastikan _isChangingPassword di-reset di sini, bukan di dalam dialog setState,
    // karena dialog mungkin sudah di-pop.
    // Namun, karena kita menggunakan StatefulBuilder untuk dialog,
    // setState untuk _isChangingPassword akan dihandle oleh builder dialog.
    // Kita hanya perlu memastikan state global screen juga terupdate jika perlu.
    // Dalam kasus ini, _isChangingPassword hanya relevan untuk tombol di dialog.
    // Jadi, kita bisa hapus setState di sini jika _isChangingPassword hanya untuk dialog.
    // Tapi untuk kejelasan, kita set di sini juga.
    if(mounted){
        setState(() {
            _isChangingPassword = false;
        });
    }
  }

  void _showChangePasswordDialog() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    _obscureCurrentPassword = true;
    _obscureNewPassword = true;
    _obscureConfirmPassword = true;
    _isChangingPassword = false; // Reset state loading dialog

    showDialog(
      context: context,
      barrierDismissible: !_isChangingPassword,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder( // Penting untuk update UI di dalam dialog (obscureText, loading)
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Ubah Password', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0), // Atur padding
              content: SingleChildScrollView(
                child: Form(
                  key: _passwordFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: _currentPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Password Lama',
                          hintText: 'Masukkan password lama',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureCurrentPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            onPressed: () {
                              setDialogState(() {
                                _obscureCurrentPassword = !_obscureCurrentPassword;
                              });
                            },
                          ),
                        ),
                        style: GoogleFonts.poppins(),
                        obscureText: _obscureCurrentPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password lama tidak boleh kosong';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _newPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Password Baru',
                          hintText: 'Minimal 6 karakter',
                          prefixIcon: const Icon(Icons.lock_person_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            onPressed: () {
                              setDialogState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                        ),
                        style: GoogleFonts.poppins(),
                        obscureText: _obscureNewPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password baru tidak boleh kosong';
                          }
                          if (value.length < 6) {
                            return 'Password baru minimal 6 karakter';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi Password Baru',
                          hintText: 'Ulangi password baru',
                          prefixIcon: const Icon(Icons.lock_person_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                           suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            onPressed: () {
                              setDialogState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        style: GoogleFonts.poppins(),
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Konfirmasi password tidak boleh kosong';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Konfirmasi password tidak cocok';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) {
                           if (!_isChangingPassword) {
                             // Panggil _submitChangePasswordForm dari context utama screen, bukan dialogContext
                             _submitChangePasswordForm();
                           }
                        },
                      ),
                       const SizedBox(height: 10), // Sedikit spasi sebelum tombol
                    ],
                  ),
                ),
              ),
              actionsAlignment: MainAxisAlignment.end,
              actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              actions: <Widget>[
                TextButton(
                  onPressed: _isChangingPassword ? null : () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Batal', style: GoogleFonts.poppins(color: Colors.grey[700], fontWeight: FontWeight.w500)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                  ),
                  onPressed: _isChangingPassword ? null : () {
                     // Panggil _submitChangePasswordForm dari context utama screen, bukan dialogContext
                     // Ini penting agar setState(_isChangingPassword) di _submitChangePasswordForm
                     // juga mengupdate state tombol di dialog melalui StatefulBuilder
                     _submitChangePasswordForm().then((_) {
                        // Jika dialog masih ada (misalnya error dan tidak di-pop), update state dialog
                        if (dialogContext.mounted && _isChangingPassword) {
                           setDialogState(() {}); // Rebuild dialog untuk update tombol loading
                        }
                     });
                  },
                  child: _isChangingPassword
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: textOnThemeColor),
                        )
                      : Text('Simpan', style: GoogleFonts.poppins(color: textOnThemeColor, fontWeight: FontWeight.w600)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _handleChangePassword() {
    _showChangePasswordDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profil Saya',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (_isSaving) return;
            Navigator.pop(context, false);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey[300]!)
                ),
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email (Tidak dapat diubah)',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.currentUser.email,
                        style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),

              Text(
                "Nama Pengguna",
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF182420)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama pengguna Anda',
                  prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  if (value.trim().length < 3) {
                      return 'Nama minimal 3 karakter';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              Text(
                "Bio",
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF182420)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(
                  hintText: 'Ceritakan tentang diri Anda...',
                  prefixIcon: Icon(Icons.info_outline, color: Colors.grey[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
                maxLines: 4,
                maxLength: 200,
                validator: (value) {
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!_isSaving) _submitForm();
                },
              ),
              const SizedBox(height: 30),

              _isSaving
                  ? Center(child: CircularProgressIndicator(color: themeColor))
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save_alt_outlined, color: Colors.black87),
                      label: Text('Simpan Perubahan', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600)),
                      onPressed: _isSaving ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                    ),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                icon: Icon(Icons.lock_outline, color: Colors.grey[700]),
                label: Text('Ubah Password', style: GoogleFonts.poppins(color: Colors.grey[700], fontWeight: FontWeight.w600)),
                onPressed: _isSaving ? null : _handleChangePassword,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}