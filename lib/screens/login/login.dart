// lib/screens/login/login.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real/app/themes/app_themes.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:real/screens/login/register.dart';
import 'package:real/widgets/textfield_login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real/screens/login/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoginButtonLoading = false;

  final Color themeColor = const Color.fromARGB(255, 209, 247, 43);
  final Color textOnThemeColor = Colors.black87;

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

    Map<String, dynamic>? loginResult;

    try {
      loginResult = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } catch (e) {
      // ENGLISH TRANSLATION
      loginResult = {'success': false, 'message': 'An error occurred: $e'};
    }

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) { 
        if (!mounted) return;

        if (loginResult != null) {
          if (loginResult['success'] != true) {
            // ENGLISH TRANSLATION
            final String errorMessage = loginResult['message'] ?? 'Login failed or result unknown.';
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
           if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              // ENGLISH TRANSLATION
              const SnackBar(
                content: Text('Login process failed due to an unknown error.'),
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
                    'Welcome Back!', // ENGLISH
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue', // ENGLISH
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
                        return 'Email cannot be empty'; // ENGLISH
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email'; // ENGLISH
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFieldLogin(
                    label: 'Password',
                    controller: _passwordController,
                    hintText: 'Your Password',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password cannot be empty'; // ENGLISH
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters'; // ENGLISH
                      }
                      return null;
                    },
                  ),
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
                          'Forgot Password?', // ENGLISH
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF5C5C5C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _isLoginButtonLoading
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.nearlyBlack))
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
                          child: Text(
                            'Sign In', // ENGLISH
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
                        "Don't have an account?", // ENGLISH
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
                          'Register here', // ENGLISH
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