import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real/screens/post_ad/post_ad_screen.dart'; // Import halaman Pasang Iklan

class ProfileScreen extends StatelessWidget {
  // Hapus const jika ingin menambahkan data dinamis nanti
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Hilangkan shadow app bar
        title: Text(
          "Profile",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Column(
          children: [
            // 1. Info Pengguna
            Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  // Ganti dengan gambar asli atau placeholder
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                  backgroundColor: Colors.grey,
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Anderson", // Ganti dengan nama pengguna asli
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Real Estate Agent", // Ganti dengan role/status pengguna
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 25),

            // 2. Tombol Edit & Pasang Iklan (Kecil - Sesuai Prototype Kiri)
            // Anda bisa mengimplementasikan aksi untuk tombol ini nanti
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Aksi untuk Edit Profile
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Edit Profile",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigasi ke halaman Pasang Iklan saat tombol ini ditekan
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PostAdScreen()),
                      );
                    },
                     style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200], // Warna tombol Pasang Iklan kecil
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                       shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Pasang Iklan",
                       style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),

            // Spacer untuk mendorong tombol besar ke bawah (jika perlu)
            // atau gunakan layout lain sesuai kebutuhan
            const Spacer(),

            // 3. Tombol Besar "Pasang Iklan & Prediksi Harga"
            InkWell( // Gunakan InkWell agar area bisa di-tap
              onTap: () {
                // Navigasi ke halaman Pasang Iklan
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostAdScreen()),
                );
              },
              borderRadius: BorderRadius.circular(15), // Efek ripple mengikuti border
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                decoration: BoxDecoration(
                  color: Colors.grey[100], // Warna latar area tombol besar
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[300]!)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle_outline, size: 40, color: Colors.black54,),
                    const SizedBox(width: 15),
                    Flexible( // Agar teks bisa wrap jika terlalu panjang
                      child: Text(
                        "Pasang Iklan Propertimu & Prediksi Harganya",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
             const SizedBox(height: 20), // Jarak dari bawah
          ],
        ),
      ),
    );
  }
}