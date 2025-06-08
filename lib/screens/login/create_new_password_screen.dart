// lib/screens/login/create_new_password_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:real/widgets/textfield_login.dart';
import 'package:real/screens/login/login.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  final String email;
  final String code;

  const CreateNewPasswordScreen({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitNewPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.resetPasswordWithVerifiedCode(
      email: widget.email,
      code: widget.code,
      newPassword: _newPasswordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'An error occurred.'), // ENGLISH
        backgroundColor: result['success'] ?? false ? Colors.green : Colors.red,
      ),
    );

    if (result['success'] == true) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFFDAF365);
    const Color textOnThemeColor = Colors.black87;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Create New Password', // ENGLISH
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter your new password for account:', // ENGLISH
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
                ),
                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 30),
                TextFieldLogin(
                  label: 'New Password', // ENGLISH
                  controller: _newPasswordController,
                  hintText: 'Minimum 6 characters', // ENGLISH
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'New password cannot be empty'; // ENGLISH
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters'; // ENGLISH
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFieldLogin(
                  label: 'Confirm New Password', // ENGLISH
                  controller: _confirmPasswordController,
                  hintText: 'Repeat your new password', // ENGLISH
                  prefixIcon: Icons.lock_reset_outlined,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password confirmation cannot be empty'; // ENGLISH
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match'; // ENGLISH
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: themeColor))
                    : ElevatedButton(
                        onPressed: _submitNewPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Save New Password', // ENGLISH
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textOnThemeColor,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}