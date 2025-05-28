// // lib/screens/profile/edit_profile_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// // GANTI 'nama_proyek_anda' dengan nama folder proyek Anda yang sebenarnya
// import 'package:real/models/user_model.dart';
// import 'package:real/provider/auth_provider.dart';
// // Jika Anda punya widget form field kustom, import di sini
// // import 'package:nama_proyek_anda/widgets/custom_form_field.dart';

// class EditProfileScreen extends StatefulWidget {
//   final User currentUser;

//   const EditProfileScreen({super.key, required this.currentUser});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _nameController;
//   late TextEditingController _bioController;

//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     // 1. Inisialisasi Controller: Sudah benar
//     _nameController = TextEditingController(text: widget.currentUser.name);
//     _bioController = TextEditingController(text: widget.currentUser.bio);
//   }

//   @override
//   void dispose() {
//     // 7. Dispose Controller: Sudah benar
//     _nameController.dispose();
//     _bioController.dispose();
//     super.dispose();
//   }

//   Future<void> _submitForm() async {
//     // Cek 'mounted' sebelum operasi async untuk menghindari error jika widget sudah di-dispose
//     if (!mounted) return;

//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true; // 4. Loading State: Sudah benar
//       });

//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final newName = _nameController.text.trim();
//       final newBio = _bioController.text.trim();

//       // 2. Pemanggilan AuthProvider: Sudah benar
//       final Map<String, dynamic> result = await authProvider.updateUserProfile(
//         name: newName,
//         bio: newBio,
//       );

//       // Cek 'mounted' lagi setelah operasi async
//       if (!mounted) return;

//       setState(() {
//         _isLoading = false;
//       });

//       // 3. Penanganan Respons: Sudah cukup baik
//       if (result['success'] == true) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(result['message'] ?? 'Profil berhasil diperbarui!'),
//             backgroundColor: Colors.green, // Feedback visual yang baik
//           ),
//         );
//         // 8. Navigasi Kembali: Kirim 'true' untuk menandakan update
//         Navigator.pop(context, true);
//       } else {
//         String errorMessage = result['message'] ?? 'Gagal memperbarui profil.';
//         // Tambahan: Menampilkan detail error validasi jika ada
//         if (result['errors'] != null && result['errors'] is Map) {
//           final errorsMap = result['errors'] as Map;
//           if (errorsMap.isNotEmpty) {
//             // Mengambil semua pesan error dari map dan menggabungkannya
//             // API Laravel biasanya mengirimkan error validasi dalam format: {'field': ['message1', 'message2']}
//             StringBuffer errorDetails = StringBuffer();
//             errorsMap.forEach((field, messages) {
//               if (messages is List && messages.isNotEmpty) {
//                 errorDetails.writeln('- ${messages.join(', ')}');
//               }
//             });
//             if (errorDetails.isNotEmpty) {
//               errorMessage += '\n\nDetail:\n${errorDetails.toString()}';
//             }
//           }
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(errorMessage),
//             backgroundColor: Colors.red, // Feedback visual yang baik
//           ),
//         );
//       }
//     }
//   }

//   void _handleChangePassword() {
//     // 6. Tombol Ubah Password: Masih placeholder, ini oke untuk sekarang
//     print('Tombol Ubah Password ditekan');
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Fitur Ubah Password belum diimplementasikan.')),
//     );
//     // Nanti: Navigasi ke layar baru atau tampilkan dialog untuk ubah password
//     // Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordScreen()));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context); // Untuk styling yang konsisten dengan tema aplikasi

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Profil'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context, false); // Kirim 'false' jika tidak ada perubahan
//           },
//         ),
//       ),
//       body: SingleChildScrollView( // Agar bisa di-scroll jika konten melebihi layar
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch, // Tombol jadi full-width
//             children: <Widget>[
//               // Menampilkan Email (Tidak Bisa Diedit)
//               Card(
//                 elevation: 1,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 margin: const EdgeInsets.only(bottom: 20),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Email (Tidak dapat diubah)',
//                         style: theme.textTheme.labelSmall?.copyWith( // Bisa pakai labelSmall atau labelMedium
//                           color: Colors.grey[700],
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         widget.currentUser.email,
//                         style: theme.textTheme.titleMedium?.copyWith(color: Colors.black54),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // Field Nama
//               TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(
//                   labelText: 'Nama Pengguna',
//                   hintText: 'Masukkan nama pengguna Anda',
//                   border: const OutlineInputBorder(),
//                   prefixIcon: const Icon(Icons.person_outline),
//                   // fillColor: theme.inputDecorationTheme.fillColor, // Opsional: styling dari tema
//                   // filled: theme.inputDecorationTheme.filled,
//                 ),
//                 // 5. Validasi Form: Bisa ditambahkan lebih detail
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Nama tidak boleh kosong';
//                   }
//                   if (value.trim().length < 3) {
//                     return 'Nama minimal 3 karakter';
//                   }
//                   // Anda bisa menambahkan validasi lain jika perlu (misal, karakter alfanumerik)
//                   return null;
//                 },
//                 textInputAction: TextInputAction.next, // Pindah ke field berikutnya saat enter
//               ),
//               const SizedBox(height: 20),

//               // Field Bio
//               TextFormField(
//                 controller: _bioController,
//                 decoration: InputDecoration(
//                   labelText: 'Bio',
//                   hintText: 'Ceritakan tentang diri Anda...',
//                   border: const OutlineInputBorder(),
//                   prefixIcon: const Icon(Icons.info_outline),
//                   // fillColor: theme.inputDecorationTheme.fillColor,
//                   // filled: theme.inputDecorationTheme.filled,
//                 ),
//                 maxLines: 3,
//                 maxLength: 150, // Batasan karakter untuk bio
//                 validator: (value) {
//                   // Bio bisa opsional, tidak ada validasi wajib kosong
//                   // Bisa tambahkan validasi panjang jika diisi
//                   // if (value != null && value.isNotEmpty && value.length > 150) {
//                   //   return 'Bio maksimal 150 karakter';
//                   // }
//                   return null;
//                 },
//                 textInputAction: TextInputAction.done, // Selesai input, bisa submit form
//                 onFieldSubmitted: (_) { // Submit form jika user tekan "done" di keyboard
//                   if (!_isLoading) { // Hanya submit jika tidak sedang loading
//                     _submitForm();
//                   }
//                 },
//               ),
//               const SizedBox(height: 30),

//               // Tombol Simpan Perubahan
//               _isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : ElevatedButton.icon(
//                       icon: const Icon(Icons.save_alt_outlined),
//                       label: const Text('Simpan Perubahan'),
//                       onPressed: _submitForm,
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 14), // Sedikit lebih tinggi
//                         textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                         // backgroundColor: theme.primaryColor, // Konsisten dengan tema
//                         // foregroundColor: theme.colorScheme.onPrimary,
//                       ),
//                     ),
//               const SizedBox(height: 20),

//               // Tombol Ubah Password
//               OutlinedButton.icon(
//                 icon: const Icon(Icons.lock_outline),
//                 label: const Text('Ubah Password'),
//                 onPressed: _handleChangePassword,
//                 style: OutlinedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   // side: BorderSide(color: theme.primaryColor), // Konsisten dengan tema
//                   // foregroundColor: theme.primaryColor,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }