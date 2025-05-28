// lib/screens/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Untuk styling jika perlu

// Sesuaikan path import ini jika berbeda di proyek Anda
import 'package:real/models/user_model.dart';
import 'package:real/provider/auth_provider.dart';
// Anda mungkin punya widget text field kustom, jika ada, import di sini
// import 'package:real/widgets/textfield_login.dart'; // Atau widget form field lain

class EditProfileScreen extends StatefulWidget {
  final User currentUser; // Menerima data user saat ini

  const EditProfileScreen({super.key, required this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  // Email tidak diedit, jadi tidak perlu controller, cukup tampilkan dari widget.currentUser.email

  bool _isSaving = false; // State untuk loading tombol simpan

  // Definisikan warna tema Anda jika ingin digunakan di sini
  final Color themeColor = const Color(0xFFDAF365);
  final Color textOnThemeColor = Colors.black87;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUser.name);
    // Untuk bio, jika bisa null di model, tangani dengan ?? ''
    _bioController = TextEditingController(text: widget.currentUser.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_isSaving) return; // Mencegah submit ganda

    if (_formKey.currentState?.validate() ?? false) {
      if (mounted) {
        setState(() {
          _isSaving = true;
        });
      } else {
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final newName = _nameController.text.trim();
      final newBio = _bioController.text.trim();

      print('EditProfileScreen: Menyimpan profil -> Nama: $newName, Bio: $newBio');

      Map<String, dynamic>? result;
      try {
        result = await authProvider.updateUserProfile(
          name: newName,
          bio: newBio,
        );
        print('EditProfileScreen: Hasil dari authProvider.updateUserProfile: $result');
      } catch (e) {
        print('EditProfileScreen: Exception saat memanggil authProvider.updateUserProfile: $e');
        result = {'success': false, 'message': 'Terjadi kesalahan: $e'};
      }

      if (!mounted) return;

      if (result != null) {
        if (result['success'] == true) {
          print('EditProfileScreen: Update SUKSES. Pesan: ${result['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Profil berhasil diperbarui!'),
              backgroundColor: Colors.green,
            ),
          );
          // Kembali ke ProfileScreen dan kirim 'true' untuk menandakan ada update
          Navigator.pop(context, true);
        } else {
          final String errorMessage = result['message'] ?? 'Gagal memperbarui profil.';
          print('EditProfileScreen: Update GAGAL. Pesan: $errorMessage');
          if (result['errors'] != null && result['errors'] is Map) {
            // Anda bisa memformat error validasi dari API di sini jika ada
            // final errorsMap = result['errors'] as Map;
            // ... (logika format error)
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print('EditProfileScreen: Hasil update tidak diketahui karena exception.');
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Proses update gagal karena kesalahan tidak diketahui.'),
              backgroundColor: Colors.orange,
            ),
          );
      }

      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    } else {
      if (_isSaving && mounted) {
         setState(() { _isSaving = false; });
      }
    }
  }

  void _handleChangePassword() {
    // TODO: Navigasi ke layar ubah password atau tampilkan dialog
    // Ini akan kita implementasikan di Bagian berikutnya (Ubah Password)
    print('Tombol Ubah Password ditekan (belum diimplementasikan).');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur Ubah Password belum diimplementasikan.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profil Saya',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black), // Warna ikon back
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isSaving) return; // Jangan pop jika sedang saving
            Navigator.pop(context, false); // Kirim 'false' jika tidak ada perubahan atau batal
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Menampilkan Email (Tidak Bisa Diedit)
              Card(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey[300]!)
                ),
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email (Tidak dapat diubah)',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.currentUser.email,
                        style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),

              // Field Nama
              // Menggunakan widget TextFieldLogin yang sudah ada jika sesuai,
              // atau TextFormField standar jika lebih cocok.
              // Untuk konsistensi, kita buat TextFormField standar di sini.
              Text(
                "Nama Pengguna",
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF182420)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama pengguna Anda',
                  prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  if (value.trim().length < 3) {
                     return 'Nama minimal 3 karakter';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),

              // Field Bio
              Text(
                "Bio",
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF182420)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(
                  hintText: 'Ceritakan tentang diri Anda...',
                  prefixIcon: Icon(Icons.info_outline, color: Colors.grey[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
                maxLines: 4, // Bio bisa beberapa baris
                maxLength: 200, // Batasi panjang bio
                validator: (value) {
                  // Bio bisa opsional
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!_isSaving) _submitForm();
                },
              ),
              const SizedBox(height: 30),

              // Tombol Simpan Perubahan
              _isSaving
                  ? Center(child: CircularProgressIndicator(color: themeColor))
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save_alt_outlined, color: Colors.black), // Ikon putih
                      label: Text('Simpan Perubahan', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w600)), // Teks putih
                      onPressed: _isSaving ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor, // Warna tema Anda
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                    ),
              const SizedBox(height: 16),

              // Tombol Ubah Password
              OutlinedButton.icon(
                icon: Icon(Icons.lock_outline, color: Colors.grey[700]),
                label: Text('Ubah Password', style: GoogleFonts.poppins(color: Colors.grey[700], fontWeight: FontWeight.w600)),
                onPressed: _isSaving ? null : _handleChangePassword, // Nonaktifkan jika sedang menyimpan
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                   shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}