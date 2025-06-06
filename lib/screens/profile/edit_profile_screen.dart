// lib/screens/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io'; // For File if not on web
import 'package:flutter/foundation.dart' show kIsWeb; // To check platform
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:real/models/user_model.dart';
import 'package:real/provider/auth_provider.dart';

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
  late TextEditingController _phoneController;

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

  XFile? _pickedImageFile;
  bool _removeCurrentImage = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUser.name);
    _bioController = TextEditingController(text: widget.currentUser.bio);
    _phoneController = TextEditingController(text: widget.currentUser.phone);
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImageDirectlyFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
      );
      if (pickedFile != null && mounted) {
        setState(() {
          _pickedImageFile = pickedFile;
          _removeCurrentImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  void _triggerRemoveImage() {
    if (widget.currentUser.profileImage.isNotEmpty || _pickedImageFile != null) {
      setState(() {
        _pickedImageFile = null;
        _removeCurrentImage = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil akan dihapus saat disimpan.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada foto profil untuk dihapus.')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_isSaving) return;
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.updateUserProfile(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        phone: _phoneController.text.trim(),
        profileImageFile: _pickedImageFile,
        removeProfileImage: _removeCurrentImage,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal memperbarui profil.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isSaving = false);
    }
  }

  // --- LOGIKA UBAH PASSWORD YANG DIKEMBALIKAN ---
  Future<void> _submitChangePasswordForm() async {
    if (_isChangingPassword) return;
    if (!(_passwordFormKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isChangingPassword = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      newPasswordConfirmation: _confirmPasswordController.text,
    );

    if (!mounted) return;
    Navigator.of(context).pop(); 

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Password berhasil diubah!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal mengubah password.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    if (mounted) {
      setState(() => _isChangingPassword = false);
    }
  }

  void _showChangePasswordDialog() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    _obscureCurrentPassword = true;
    _obscureNewPassword = true;
    _obscureConfirmPassword = true;
    _isChangingPassword = false;

    showDialog(
      context: context,
      barrierDismissible: !_isChangingPassword,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Ubah Password', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              content: SingleChildScrollView(
                child: Form(
                  key: _passwordFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: _currentPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Password Lama',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureCurrentPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            onPressed: () => setDialogState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                          ),
                        ),
                        obscureText: _obscureCurrentPassword,
                        validator: (v) => v == null || v.isEmpty ? 'Password lama tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _newPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Password Baru',
                          prefixIcon: const Icon(Icons.lock_person_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            onPressed: () => setDialogState(() => _obscureNewPassword = !_obscureNewPassword),
                          ),
                        ),
                        obscureText: _obscureNewPassword,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password baru tidak boleh kosong';
                          if (v.length < 6) return 'Password minimal 6 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi Password Baru',
                          prefixIcon: const Icon(Icons.lock_person_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            onPressed: () => setDialogState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ),
                        obscureText: _obscureConfirmPassword,
                        validator: (v) {
                          if (v != _newPasswordController.text) return 'Password tidak cocok';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: _isChangingPassword ? null : () => Navigator.of(dialogContext).pop(),
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: _isChangingPassword ? null : _submitChangePasswordForm,
                  child: _isChangingPassword
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleChangePassword() {
    _showChangePasswordDialog();
  }
  // --- AKHIR DARI LOGIKA YANG DIKEMBALIKAN ---

  @override
  Widget build(BuildContext context) {
    Widget profileImageWidget;
    if (_pickedImageFile != null) {
      profileImageWidget = kIsWeb
          ? Image.network(_pickedImageFile!.path, width: 100, height: 100, fit: BoxFit.cover)
          : Image.file(File(_pickedImageFile!.path), width: 100, height: 100, fit: BoxFit.cover);
    } else if (!_removeCurrentImage && widget.currentUser.profileImage.isNotEmpty) {
      profileImageWidget = CachedNetworkImage(
        imageUrl: widget.currentUser.profileImage,
        width: 100, height: 100, fit: BoxFit.cover,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.person, size: 50),
      );
    } else {
      profileImageWidget = Container(
        width: 100, height: 100,
        decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
        child: Icon(Icons.person, size: 50, color: Colors.grey[400]),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profil Saya', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => _isSaving ? null : Navigator.pop(context, false),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Stack(
                  children: [
                    ClipOval(child: profileImageWidget),
                    Positioned(
                      bottom: 0, right: 0,
                      child: InkWell(
                        onTap: _pickImageDirectlyFromGallery,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: themeColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                          child: Icon(Icons.camera_alt, color: textOnThemeColor, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.currentUser.profileImage.isNotEmpty || _pickedImageFile != null)
                Center(
                  child: TextButton.icon(
                    icon: Icon(Icons.delete_outline, color: Colors.red[700], size: 18),
                    label: Text('Hapus Foto Profil', style: GoogleFonts.poppins(color: Colors.red[700], fontSize: 13)),
                    onPressed: _triggerRemoveImage,
                  ),
                ),
              const SizedBox(height: 30),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey[300]!)
                ),
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email (Tidak dapat diubah)', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(widget.currentUser.email, style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54)),
                    ],
                  ),
                ),
              ),
              Text("Nama Pengguna", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama pengguna Anda',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true, fillColor: Colors.grey[100],
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),
              Text("Bio", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(
                  hintText: 'Ceritakan tentang diri Anda...',
                  prefixIcon: const Icon(Icons.info_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true, fillColor: Colors.grey[100],
                ),
                maxLines: 4, maxLength: 200,
              ),
              const SizedBox(height: 20),
              Text("Nomor Telepon", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Masukkan nomor telepon Anda',
                  prefixIcon: const Icon(Icons.phone_android),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true, fillColor: Colors.grey[100],
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nomor telepon tidak boleh kosong' : null,
              ),
              const SizedBox(height: 30),
              _isSaving
                  ? Center(child: CircularProgressIndicator(color: themeColor))
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save_alt_outlined),
                      label: const Text('Simpan Perubahan'),
                      onPressed: _isSaving ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: textOnThemeColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.lock_outline),
                label: const Text('Ubah Password'),
                onPressed: _isSaving ? null : _handleChangePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}