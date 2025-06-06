// lib/screens/login/register.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real/app/themes/app_themes.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:real/widgets/textfield_login.dart';
import 'package:google_fonts/google_fonts.dart';

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

  bool _isRegisterButtonLoading = false;

  final Color themeColor = const Color(0xFFDAF365);
  final Color textOnThemeColor = Colors.black87;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_isRegisterButtonLoading) return;

    if (_formKey.currentState?.validate() ?? false) {
      if (mounted) {
        setState(() {
          _isRegisterButtonLoading = true;
        });
      } else {
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Map<String, dynamic>? result;
      try {
        result = await authProvider.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          phone: _phoneController.text.trim(),
        );
      } catch (e) {
        // ENGLISH TRANSLATION
        result = {'success': false, 'message': 'An internal error occurred: $e'};
      }

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          // ENGLISH TRANSLATION
          SnackBar(
            content: Text(result['message'] ?? 'Registration successful! Please log in.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          // ENGLISH TRANSLATION
          SnackBar(
            content: Text(result['message'] ?? 'Registration failed. Please try again.'),
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
          icon: Icon(Icons.arrow_back_ios_new, color: const Color.fromARGB(255, 0, 0, 0)),
          onPressed: () {
            if (_isRegisterButtonLoading) return;
            Navigator.of(context).pop();
          }
        ),
        title: Text(
          'Create New Account', // ENGLISH
          style: GoogleFonts.poppins(
              color: const Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold),
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
                  TextFieldLogin(
                    label: 'Full Name',
                    controller: _nameController,
                    hintText: 'Enter your full name',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name cannot be empty';
                      }
                      if (value.length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFieldLogin(
                    label: 'Email',
                    controller: _emailController,
                    hintText: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email cannot be empty';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFieldLogin(
                    label: 'Phone Number',
                    controller: _phoneController,
                    hintText: 'Enter your phone number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Phone number cannot be empty';
                      }
                      if (value.length < 9) {
                        return 'Invalid phone number (min 9 digits)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFieldLogin(
                    label: 'Password',
                    controller: _passwordController,
                    hintText: 'Create your password',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password cannot be empty';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFieldLogin(
                    label: 'Confirm Password',
                    controller: _confirmPasswordController,
                    hintText: 'Repeat your password',
                    prefixIcon: Icons.lock_reset_outlined,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password confirmation cannot be empty';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  _isRegisterButtonLoading
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.nearlyBlack))
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
                            'Register',
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
                        'Already have an account?',
                        style: GoogleFonts.poppins(color: Colors.grey[700]),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_isRegisterButtonLoading) return;
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Sign in here',
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