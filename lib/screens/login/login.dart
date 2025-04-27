import 'package:flutter/material.dart';
import 'package:real/app/themes/app_themes.dart';
import 'package:real/widgets/textfield_login.dart'; 
import 'package:real/controllers/login_controller.dart';
import 'package:google_fonts/google_fonts.dart';

// Import halaman Register
import 'package:real/screens/login/register.dart'; // Pastikan path ini sesuai project Anda

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController controller = LoginController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
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
                    label: "Username",
                    hintText: "Username",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: "Password",
                    hintText: "Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDAF365),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(70),
                        ),
                      ),
                      child: Padding(
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
                            color: Color(0xFF182420),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Daftar disini",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Color(0xFFDAF365),
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
