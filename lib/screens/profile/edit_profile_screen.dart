// lib/screens/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:real/models/user_model.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:real/helpers/notification_helper.dart';

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
      if(mounted) {
        // ENGLISH TRANSLATION
        showTopNotification(context, 'Failed to pick image: $e', isError: true);
      }
    }
  }

  void _triggerRemoveImage() {
      if (widget.currentUser.profileImage.isNotEmpty || _pickedImageFile != null) {
          setState(() {
            _pickedImageFile = null;
            _removeCurrentImage = true;
          });
          // ENGLISH TRANSLATION
          showTopNotification(context, 'Profile photo will be removed upon saving.');
      } else {
          // ENGLISH TRANSLATION
          showTopNotification(context, 'No profile photo to remove.', isError: true);
      }
  }

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

  Future<void> _submitForm() async {
    if (_isSaving) return;
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final newName = _nameController.text.trim();
      final newBio = _bioController.text.trim();
      final newPhone = _phoneController.text.trim();
      Map<String, dynamic>? result;
      try {
        result = await authProvider.updateUserProfile(
          name: newName,
          bio: newBio,
          phone: newPhone,
          profileImageFile: _pickedImageFile,
          removeProfileImage: _removeCurrentImage,
        );
      } catch (e) {
        // ENGLISH TRANSLATION
        result = {'success': false, 'message': 'An error occurred: $e'};
      }
      if (!mounted) return;

      if (result['success'] == true) {
        // ENGLISH TRANSLATION
        showTopNotification(context, result['message'] ?? 'Profile updated successfully!');
        Navigator.pop(context, true);
      } else {
        // ENGLISH TRANSLATION
        final String errorMessage = result['message'] ?? 'Failed to update profile.';
        showTopNotification(context, errorMessage, isError: true);
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

    setState(() {
      _isChangingPassword = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      newPasswordConfirmation: _confirmPasswordController.text,
    );

    if (!mounted) return;

    Navigator.of(context).pop();

    if (result['success'] == true) {
      // ENGLISH TRANSLATION
      showTopNotification(context, result['message'] ?? 'Password changed successfully!');
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } else {
      // ENGLISH TRANSLATION
      showTopNotification(context, result['message'] ?? 'Failed to change password.', isError: true);
    }

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
    _isChangingPassword = false;

    showDialog(
      context: context,
      barrierDismissible: !_isChangingPassword,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              // ENGLISH TRANSLATION
              title: Text('Change Password', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
                          labelText: 'Current Password', // ENGLISH
                          hintText: 'Enter your current password', // ENGLISH
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureCurrentPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            onPressed: () => setDialogState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                          ),
                        ),
                        obscureText: _obscureCurrentPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Current password cannot be empty'; // ENGLISH
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _newPasswordController,
                        decoration: InputDecoration(
                          labelText: 'New Password', // ENGLISH
                          hintText: 'Minimum 6 characters', // ENGLISH
                          prefixIcon: const Icon(Icons.lock_person_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            onPressed: () => setDialogState(() => _obscureNewPassword = !_obscureNewPassword),
                          ),
                        ),
                        obscureText: _obscureNewPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'New password cannot be empty'; // ENGLISH
                          }
                          if (value.length < 6) {
                            return 'New password must be at least 6 characters'; // ENGLISH
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password', // ENGLISH
                          hintText: 'Repeat your new password', // ENGLISH
                          prefixIcon: const Icon(Icons.lock_person_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                           suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            onPressed: () => setDialogState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ),
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password confirmation cannot be empty'; // ENGLISH
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match'; // ENGLISH
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) {
                           if (!_isChangingPassword) {
                             _submitChangePasswordForm();
                           }
                        },
                      ),
                       const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: _isChangingPassword ? null : () => Navigator.of(dialogContext).pop(),
                  child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey[700], fontWeight: FontWeight.w500)), // ENGLISH
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                  ),
                  onPressed: _isChangingPassword ? null : () {
                     _submitChangePasswordForm().then((_) {
                        if (dialogContext.mounted && _isChangingPassword) {
                           setDialogState(() {});
                        }
                     });
                  },
                  child: _isChangingPassword
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: textOnThemeColor),
                        )
                      : Text('Save', style: GoogleFonts.poppins(color: textOnThemeColor, fontWeight: FontWeight.w600)), // ENGLISH
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
        key: ValueKey(widget.currentUser.profileImage),
        imageUrl: widget.currentUser.profileImage,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 100, height: 100, color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) {
          return Container(
            width: 100, height: 100, color: Colors.grey[200],
            child: Icon(Icons.person, size: 50, color: Colors.grey[400]),
          );
        },
      );
    } else {
      profileImageWidget = Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.person, size: 50, color: Colors.grey[400]),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit My Profile', // ENGLISH
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
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
              Text(
                "Profile Photo", // ENGLISH
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF182420)),
              ),
              const SizedBox(height: 8),
              Center(
                child: Stack(
                  children: [
                    ClipOval(child: profileImageWidget),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImageDirectlyFromGallery,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: themeColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2)
                          ),
                          child: Icon(Icons.camera_alt, color: textOnThemeColor, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.currentUser.profileImage.isNotEmpty || _pickedImageFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
                  child: Center(
                    child: TextButton.icon(
                      icon: Icon(Icons.delete_outline, color: Colors.red[700], size: 18),
                      label: Text('Remove Profile Photo', style: GoogleFonts.poppins(color: Colors.red[700], fontSize: 13)), // ENGLISH
                      onPressed: _triggerRemoveImage,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
                      ),
                    ),
                  ),
                ),

              Card(
                elevation: 1.5,
                shadowColor: Colors.grey.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide.none,
                ),
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email (Cannot be changed)', // ENGLISH
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(widget.currentUser.email, style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54)),
                    ],
                  ),
                ),
              ),

              Text(
                "Username", // ENGLISH
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF182420)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your username', // ENGLISH
                  prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name cannot be empty'; // ENGLISH
                  }
                  if (value.trim().length < 3) {
                      return 'Name must be at least 3 characters'; // ENGLISH
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              Text(
                "Phone Number", // ENGLISH
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF182420)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: 'Enter your phone number', // ENGLISH
                  prefixIcon: Icon(Icons.phone_android, color: Colors.grey[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number cannot be empty'; // ENGLISH
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              
              Text(
                "Bio", // ENGLISH
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF182420)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(
                  hintText: 'Tell us about yourself...', // ENGLISH
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
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
              const SizedBox(height: 20),

              _isSaving
                  ? Center(child: CircularProgressIndicator(color: themeColor))
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save_alt_outlined, color: Colors.black87),
                      label: Text('Save Changes', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600)), // ENGLISH
                      onPressed: _isSaving ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: textOnThemeColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                icon: Icon(Icons.lock_outline, color: Colors.grey[700]),
                label: Text('Change Password', style: GoogleFonts.poppins(color: Colors.grey[700], fontWeight: FontWeight.w600)), // ENGLISH
                onPressed: _isSaving ? null : _handleChangePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                  elevation: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}