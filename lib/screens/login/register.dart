import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real/widgets/textfield_login.dart'; 

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
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
              constraints: BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sign Up",
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 24),

                  // Username Field
                  CustomTextField(
                    label: "Username",
                    hintText: "Username",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  CustomTextField(
                    label: "Email",
                    hintText: "Email",
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  CustomTextField(
                    label: "Password",
                    hintText: "Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 24),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Aksi saat register ditekan
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDAF365),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(70),
                        ),
                      ),
                      child: Padding(
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
