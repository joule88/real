// lib/screens/my_drafts/my_drafts_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real/models/property.dart';
import 'package:real/screens/my_drafts/add_property_form_screen.dart'; // Halaman form

class MyDraftsScreen extends StatefulWidget {
  const MyDraftsScreen({super.key});

  @override
  State<MyDraftsScreen> createState() => _MyDraftsScreenState();
}

class _MyDraftsScreenState extends State<MyDraftsScreen> {
  // Daftar properti yang berstatus draft atau pendingVerification
  // Nantinya ini akan difilter dari semua properti pengguna berdasarkan status
  final List<Property> _myDraftProperties = [
    Property(
        id: 'draftProp1',
        title: 'Rumah Impian (Draft)',
        description: 'Belum selesai deskripsinya...',
        uploader: 'CurrentUser',
        imageUrl: 'https://via.placeholder.com/150/e0e0e0/969696?Text=Draft1',
        price: 0, // Mungkin harga belum diisi
        address: 'Jl. Contoh Draft',
        city: 'Kota Draft',
        stateZip: 'Provinsi',
        bedrooms: 3,
        bathrooms: 1,
        areaSqft: 100,
        propertyType: "Rumah",
        furnishings: "Unfurnished",
        status: PropertyStatus.draft),
    Property(
        id: 'draftProp2',
        title: 'Apartemen Siap Diajukan (Draft)',
        description: 'Sudah lengkap, tinggal ajukan.',
        uploader: 'CurrentUser',
        imageUrl: 'https://via.placeholder.com/150/d0d0d0/888888?Text=Draft2',
        price: 1500000,
        address: 'Jl. Contoh Apartemen Draft',
        city: 'Kota Draft Lain',
        stateZip: 'Provinsi',
        bedrooms: 2,
        bathrooms: 2,
        areaSqft: 75,
        propertyType: "Apartemen",
        furnishings: "Full Furnished",
        status: PropertyStatus.pendingVerification), // Contoh yg sudah diajukan
  ];

  void _navigateToForm({Property? existingProperty}) async {
    // Navigasi ke halaman form, bawa properti jika mode edit
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPropertyFormScreen(propertyToEdit: existingProperty),
      ),
    );

    if (result == true || result != null) { // Anggap ada perubahan jika result tidak null
      setState(() {
        // TODO: Logika untuk refresh data _myDraftProperties dari database/state
        // atau update item yang diedit, atau tambah item baru jika `existingProperty` null
        print("Kembali dari form draft, idealnya refresh data draft di sini.");
        // Contoh sederhana jika form mengembalikan properti baru/diedit:
        // if (result is Property) {
        //   if (existingProperty == null) { // Tambah baru
        //     _myDraftProperties.add(result);
        //   } else { // Update yang ada
        //     final index = _myDraftProperties.indexWhere((p) => p.id == result.id);
        //     if (index != -1) {
        //       _myDraftProperties[index] = result;
        //     }
        //   }
        // }
      });
    }
  }

  String _getStatusText(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.draft:
        return 'Status: Draft';
      case PropertyStatus.pendingVerification:
        return 'Status: Menunggu Verifikasi';
      case PropertyStatus.approved:
        return 'Status: Disetujui';
      case PropertyStatus.rejected:
        return 'Status: Ditolak';
      default:
        return 'Status: Tidak Diketahui';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Draft Iklan Saya",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: _myDraftProperties.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_add_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    "Belum ada draft iklan.",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Buat draft iklan properti Anda sekarang!",
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text("Buat Draft Baru", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    onPressed: () => _navigateToForm(), // Panggil tanpa properti untuk draft baru
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDAF365),
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListView.builder(
                itemCount: _myDraftProperties.length,
                itemBuilder: (context, index) {
                  final property = _myDraftProperties[index];
                  // Kita bisa buat widget Card khusus untuk Draft atau pakai PropertyListItem dengan modifikasi
                  return Card( // Contoh sederhana menggunakan Card
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          property.imageUrl.isNotEmpty ? property.imageUrl : 'https://via.placeholder.com/80/e0e0e0/969696?Text=NoImage',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)),
                        ),
                      ),
                      title: Text(property.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(property.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(_getStatusText(property.status), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: property.status == PropertyStatus.pendingVerification ? Colors.orange[700] : Colors.grey[600])),
                        ],
                      ),
                      trailing: const Icon(Icons.edit_outlined, color: Colors.grey),
                      onTap: () {
                        _navigateToForm(existingProperty: property); // Buka form untuk edit draft ini
                      },
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: _myDraftProperties.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _navigateToForm(), // Panggil tanpa properti untuk draft baru
              backgroundColor: const Color(0xFF1F2937),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text("Draft Baru", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
    );
  }
}