import 'package:flutter/material.dart';
import 'package:real/widgets/textfield_login.dart';
import 'package:real/controllers/login_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real/screens/login/register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Buat instance dari LoginController
  final LoginController controller = LoginController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih
      body: SafeArea(
        // Menghindari area status bar/notch
        child: Center(
          // Pusatkan konten
          child: SingleChildScrollView(
            // Agar bisa discroll jika layar kecil
            padding: const EdgeInsets.all(24.0), // Padding di sekitar konten
            child: ConstrainedBox(
              // Batasi lebar maksimum konten
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
                mainAxisSize: MainAxisSize.min, // Ukuran kolom seperlunya
                children: [
                  // Judul Halaman
                  Text(
                    "Sign In",
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge, // Ambil style dari tema
                  ),
                  const SizedBox(height: 24), // Jarak vertikal

                  // Input Username
                  const CustomTextField(
                    label: "Username",
                    hintText: "Username",
                    icon: Icons.person_outline,
                  ), //
                  const SizedBox(height: 16), // Jarak vertikal

                  // Input Password
                  const CustomTextField(
                    label: "Password",
                    hintText: "Password",
                    icon: Icons.lock_outline,
                    isPassword: true, // Aktifkan mode password
                  ), //
                  const SizedBox(height: 24), // Jarak vertikal

                  // Tombol Sign In
                  SizedBox(
                    width: double.infinity, // Lebar tombol penuh
                    child: ElevatedButton(
                      // Panggil controller.login DENGAN context saat ditekan
                      onPressed: () {
                        controller.login(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                            0xFFDAF365), // Warna tombol hijau (sesuai prototype/register)
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(70), // Border radius besar
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14.0), // Padding vertikal dalam tombol
                        child: Text(
                          "Sign In",
                          style: GoogleFonts.poppins(
                            // Font Poppins
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF182420), // Warna teks tombol
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24), // Jarak vertikal

                  // Tautan ke Halaman Daftar
                  Center(
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Pusatkan teks dalam baris
                      children: [
                        Text(
                          "Belum punya akun? ",
                          style: GoogleFonts.poppins(
                            // Font Poppins
                            fontSize: 14,
                            color: const Color(0xFF182420), // Warna teks
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          // Widget agar teks bisa di-tap
                          onTap: () {
                            // Navigasi ke RegisterScreen saat di-tap
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
                              // Font Poppins
                              fontSize: 14,
                              color: const Color(
                                  0xFFDAF365), // Warna teks link hijau (sesuai tombol)
                              fontWeight: FontWeight.w600, // Sedikit tebal
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
