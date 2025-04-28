import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real/widgets/textfield_login.dart'; 
import 'package:image_picker/image_picker.dart'; // Untuk upload foto, pastikan di pubspec.yaml sudah ada
import 'dart:io';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({Key? key}) : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  File? _profileImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _completeProfile() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacementNamed(context, '/home'); // Ganti '/home' sesuai route ke Home kamu
    }
  }

  void _skipProfile() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Complete Your Profile",
                      style: Theme.of(context).textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Don't worry, only you can see your personal data.\nNo one else will be able to see it.",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF5C5C5C),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Upload Photo
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFFDAF365),
                        backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                        child: _profileImage == null
                            ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name
                    CustomTextField(
                      label: "Name",
                      hintText: "Enter your name",
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    CustomTextField(
                      label: "Phone Number",
                      hintText: "+62 Enter Phone Number",
                      icon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    CustomTextField(
                      label: "Email Address",
                      hintText: "Enter Email Address",
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 24),

                    // Complete Profile Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _completeProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDAF365),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(70),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          child: Text(
                            "Complete Profile",
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF182420),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Skip Button
                    TextButton(
                      onPressed: _skipProfile,
                      child: Text(
                        "Skip for now",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF5C5C5C),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
