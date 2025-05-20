import 'package:flutter/material.dart';
import 'package:real/widgets/textfield_login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real/screens/login/register.dart';
import 'package:provider/provider.dart';
import 'package:real/provider/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Sign In",
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: emailController,
                    label: "Email",
                    hintText: "user@gmail.com",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: passwordController,
                    label: "Password",
                    hintText: "Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                    onPressed: () async {
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      bool success = await authProvider.login(
                        emailController.text,
                        passwordController.text,
                      );

                      if (success) {
                        final user = authProvider.user;
                        if (user != null) {
                          Provider.of<AuthProvider>(context, listen: false).setUser(user);
                        }
                        Navigator.pushReplacementNamed(context, '/home'); // ini penting
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Login gagal, periksa email/password")),
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
                                "Sign In",
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF182420),
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Belum punya akun? ",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF182420),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Daftar disini",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFFDAF365),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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
