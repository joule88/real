import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import '../../widgets/textfield_login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sign Up",
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 24),

                  // Input Username
                  CustomTextField(
                    controller: nameCtrl,
                    label: "Username",
                    hintText: "Enter your username",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),

                  // Input Email
                  CustomTextField(
                    controller: emailCtrl,
                    label: "Email",
                    hintText: "Enter your email",
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),

                  // Input Password
                  CustomTextField(
                    controller: passCtrl,
                    label: "Password",
                    hintText: "Enter your password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),

                  // Input Phone
                  CustomTextField(
                    controller: phoneCtrl,
                    label: "Phone",
                    hintText: "Enter your phone number",
                    icon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 24),

                  // Tombol Register
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              setState(() => isLoading = true);
                              bool success = await authProvider.register(
                                name: nameCtrl.text,
                                email: emailCtrl.text,
                                password: passCtrl.text,
                                phone: phoneCtrl.text,
                              );
                              setState(() => isLoading = false);

                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Register Berhasil')),
                                );
                                Navigator.pushReplacementNamed(context, '/home');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Register Gagal')),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDAF365),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(70),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14.0),
                              child: Text(
                                "Register",
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF182420),
                                ),
                              ),
                            ),
                    ),
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