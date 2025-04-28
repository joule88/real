import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PostAdScreen extends StatefulWidget {
  const PostAdScreen({super.key});

  @override
  State<PostAdScreen> createState() => _PostAdScreenState();
}

class _PostAdScreenState extends State<PostAdScreen> {
  // Controller untuk text field jika diperlukan nanti
  // final _namaController = TextEditingController();
  // ... controller lainnya

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton( // Tombol kembali
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Pasang Iklan",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView( // Agar bisa discroll jika form panjang
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Kamu juga bisa menentukan harga secara otomatis melalui menu Prediksi Harga",
              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 20),

            // --- Form Fields ---
            _buildTextField("Nama Properti"),
            _buildTextField("Alamat"),
            _buildTextField("Kamar Mandi", keyboardType: TextInputType.number),
            _buildTextField("Kamar Tidur", keyboardType: TextInputType.number),
            _buildTextField("Tipe Properti"), // Mungkin Dropdown nanti?
            _buildTextField("Luas Properti (sqrt)", keyboardType: TextInputType.number),
            _buildTextField("Perabotan"), // Mungkin Dropdown/Checkbox nanti?
            _buildTextField("Deskripsi", maxLines: 3),

            const SizedBox(height: 30), // Jarak sebelum tombol

            // --- Tombol Aksi ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Panggil fungsi untuk menampilkan modal prediksi harga
                  _showPredictionModal(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDAF365), // Warna hijau
                  padding: const EdgeInsets.symmetric(vertical: 14),
                   shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Prediksi Harga",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Aksi konfirmasi simpan iklan
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDAF365).withOpacity(0.7), // Warna lebih pudar
                  padding: const EdgeInsets.symmetric(vertical: 14),
                   shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Konfirmasi",
                   style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk membuat text field form
  Widget _buildTextField(String label, {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          TextFormField(
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none, // Hilangkan border default
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12)
            ),
            // TODO: Tambahkan controller, validator, dll.
          ),
        ],
      ),
    );
  }

  // --- Fungsi untuk Menampilkan Modal Prediksi Harga ---
  void _showPredictionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Penting agar modal bisa lebih tinggi
      shape: const RoundedRectangleBorder( // Sudut atas modal melengkung
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        // Gunakan Padding + SingleChildScrollView agar konten modal bisa di-scroll
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: 20, left: 20, right: 20,
              // Padding bawah mengikuti keyboard jika muncul
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Tinggi modal sesuai konten
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center( // Handle drag kecil di atas modal
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10)
                    ),
                  )
                ),
                const SizedBox(height: 20),
                Text(
                  "Prediksi Harga",
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Memperkirakan harga properti dengan cepat berdasarkan data yang Anda masukkan.",
                   style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 20),

                // --- Input Fields untuk Prediksi ---
                _buildTextField("Kamar Mandi", keyboardType: TextInputType.number),
                _buildTextField("Kamar Tidur", keyboardType: TextInputType.number),
                _buildTextField("Luas Properti (sqrt)", keyboardType: TextInputType.number),
                _buildTextField("Perabotan"), // Sesuaikan input type jika perlu
                const SizedBox(height: 20),

                // Tombol Prediksi Harga di dalam Modal
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                     onPressed: () {
                        // TODO: Panggil API Prediksi
                        print("Tombol Prediksi di Modal ditekan");
                     },
                    style: ElevatedButton.styleFrom( backgroundColor: const Color(0xFFDAF365), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),),
                    child: Text("Prediksi Harga", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Hasil Prediksi (Contoh) ---
                 Center(
                   child: Column(
                     children: [
                       Text("Harga Prediksi Properti", style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 12)),
                       const SizedBox(height: 5),
                       Text(
                         "AED 5000000", // TODO: Tampilkan hasil prediksi asli
                         style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                       ),
                       const SizedBox(height: 5),
                       Text("Prediksi dapat membuat kesalahan. Periksa harga lebih lanjut.", style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 11), textAlign: TextAlign.center,),
                     ],
                   ),
                 ),
                 const SizedBox(height: 20),

                // Input Harga Manual
                 _buildTextField("Harga Manual", keyboardType: TextInputType.number),
                 const SizedBox(height: 10),


                 // Tombol Konfirmasi di dalam Modal
                 SizedBox(
                   width: double.infinity,
                   child: ElevatedButton(
                     onPressed: () {
                       // TODO: Aksi konfirmasi harga (manual atau prediksi) & tutup modal
                       Navigator.pop(context); // Tutup modal
                     },
                     style: ElevatedButton.styleFrom( backgroundColor: const Color(0xFFDAF365).withOpacity(0.7), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),),
                    child: Text("Konfirmasi", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),),
                   ),
                 ),
              ],
            ),
          ),
        );
      },
    );
  }
}