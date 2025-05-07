// lib/screens/post_ad/add_property_form_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:real/models/property.dart'; // Import model Property

class AddPropertyFormScreen extends StatefulWidget {
  final Property? propertyToEdit; // Properti yang akan diedit (jika ada)

  const AddPropertyFormScreen({super.key, this.propertyToEdit});

  @override
  State<AddPropertyFormScreen> createState() => _AddPropertyFormScreenState();
}

class _AddPropertyFormScreenState extends State<AddPropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaPropertiController;
  late TextEditingController _alamatController;
  late TextEditingController _kamarMandiController;
  late TextEditingController _kamarTidurController;
  late TextEditingController _luasPropertiController;
  late TextEditingController _deskripsiController;
  late TextEditingController _hargaManualController;
  late TextEditingController _tipePropertiController; // Tambah controller
  late TextEditingController _perabotanController; // Tambah controller

  final List<XFile> _selectedImages = []; // Untuk gambar baru yang diupload
  final List<String> _existingImageUrls =
      []; // Untuk URL gambar lama (mode edit)
  final ImagePicker _picker = ImagePicker();

  bool _isEditMode = false;
  PropertyStatus _currentStatus = PropertyStatus.draft;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.propertyToEdit != null;

    _namaPropertiController =
        TextEditingController(text: widget.propertyToEdit?.title ?? '');
    _alamatController =
        TextEditingController(text: widget.propertyToEdit?.address ?? '');
    _kamarMandiController = TextEditingController(
        text: widget.propertyToEdit?.bathrooms.toString() ?? '');
    _kamarTidurController = TextEditingController(
        text: widget.propertyToEdit?.bedrooms.toString() ?? '');
    _luasPropertiController = TextEditingController(
        text: widget.propertyToEdit?.areaSqft.toString() ?? '');
    _deskripsiController =
        TextEditingController(text: widget.propertyToEdit?.description ?? '');
    _hargaManualController = TextEditingController(
        text: widget.propertyToEdit?.price.toString() ?? '');
    _tipePropertiController =
        TextEditingController(text: widget.propertyToEdit?.propertyType ?? '');
    _perabotanController =
        TextEditingController(text: widget.propertyToEdit?.furnishings ?? '');
    _currentStatus = widget.propertyToEdit?.status ?? PropertyStatus.draft;

    if (_isEditMode && widget.propertyToEdit!.imageUrl.isNotEmpty) {
      _existingImageUrls.add(widget.propertyToEdit!.imageUrl); // Gambar utama
    }
    if (_isEditMode) {
      _existingImageUrls.addAll(widget.propertyToEdit!.additionalImageUrls);
    }
  }

  @override
  void dispose() {
    _namaPropertiController.dispose();
    _alamatController.dispose();
    _kamarMandiController.dispose();
    _kamarTidurController.dispose();
    _luasPropertiController.dispose();
    _deskripsiController.dispose();
    _hargaManualController.dispose();
    _tipePropertiController.dispose();
    _perabotanController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles =
          await _picker.pickMultiImage(imageQuality: 80);
      if (pickedFiles.isNotEmpty) {
        setState(() {
          // Batasi jumlah total gambar (existing + new)
          int totalImages = _existingImageUrls.length +
              _selectedImages.length +
              pickedFiles.length;
          if (totalImages <= 5) {
            _selectedImages.addAll(pickedFiles);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Maksimal 5 gambar (termasuk yang sudah ada). Sisa slot: ${5 - (_existingImageUrls.length + _selectedImages.length)}')),
            );
          }
        });
      }
    } catch (e) {
      print("Error picking images: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
      // TODO: Nantinya, Anda juga perlu melacak gambar mana yang dihapus untuk dikirim ke backend
      // saat update properti, agar backend bisa menghapus referensi URL atau file fisiknya.
    });
  }

  Widget _buildTextField(String label,
      {TextEditingController? controller,
      int maxLines = 1,
      TextInputType? keyboardType,
      String? Function(String?)? validator,
      bool enabled = true}) {
    // Tambah parameter enabled
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: enabled
                    ? Colors.black87
                    : Colors.grey[500]), // Warna label jika disabled
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            enabled: enabled, // Set enabled/disabled
            decoration: InputDecoration(
                filled: true,
                fillColor: enabled
                    ? Colors.grey[100]
                    : Colors.grey[200], // Warna field jika disabled
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                hintText: 'Masukkan $label',
                hintStyle: GoogleFonts.poppins(color: Colors.grey[500])),
            validator: validator,
          ),
        ],
      ),
    );
  }

  void _showPredictionModal(BuildContext context) {
    // ... (Isi modal prediksi harga sama seperti sebelumnya, pastikan controller harga manual adalah _hargaManualController)
    // ... Anda bisa memanggil _buildTextField dari sini juga untuk field di modal ...
    final kamarMandiPrediksiCtrl =
        TextEditingController(text: _kamarMandiController.text);
    final kamarTidurPrediksiCtrl =
        TextEditingController(text: _kamarTidurController.text);
    final luasPropertiPrediksiCtrl =
        TextEditingController(text: _luasPropertiController.text);
    final perabotanPrediksiCtrl = TextEditingController(
        text: _perabotanController.text); // Ambil dari form utama

    // Controller untuk harga hasil prediksi di dalam modal
    final hargaPrediksiHasilCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext modalContext) {
        // Menggunakan StatefulBuilder agar bisa update UI di dalam modal
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 20),
                  Text("Prediksi Harga",
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                      "Memperkirakan harga properti dengan cepat berdasarkan data yang Anda masukkan.",
                      style: GoogleFonts.poppins(
                          color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 20),
                  // Field untuk input prediksi (bisa pakai _buildTextField yang sudah ada)
                  _buildTextField("Kamar Mandi (Prediksi)",
                      controller: kamarMandiPrediksiCtrl,
                      keyboardType: TextInputType.number),
                  _buildTextField("Kamar Tidur (Prediksi)",
                      controller: kamarTidurPrediksiCtrl,
                      keyboardType: TextInputType.number),
                  _buildTextField("Luas Properti (sqft) (Prediksi)",
                      controller: luasPropertiPrediksiCtrl,
                      keyboardType: TextInputType.number),
                  _buildTextField("Kondisi Perabotan (Prediksi)",
                      controller:
                          perabotanPrediksiCtrl), // Sesuaikan jika dropdown
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Panggil API Prediksi dengan data dari controller prediksi
                        print(
                            "Tombol Prediksi di Modal ditekan. Data: ${kamarMandiPrediksiCtrl.text}, ${kamarTidurPrediksiCtrl.text}, ${luasPropertiPrediksiCtrl.text}, ${perabotanPrediksiCtrl.text}");
                        // Simulasi hasil prediksi
                        setModalState(() {
                          hargaPrediksiHasilCtrl.text =
                              "600000"; // Contoh hasil dari API (sebagai string)
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDAF365),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: Text("Prediksi Harga",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (hargaPrediksiHasilCtrl.text.isNotEmpty)
                    Center(
                      child: Column(
                        children: [
                          Text("Harga Prediksi Properti",
                              style: GoogleFonts.poppins(
                                  color: Colors.grey[700], fontSize: 12)),
                          const SizedBox(height: 5),
                          Text(
                            "AED ${hargaPrediksiHasilCtrl.text}", // Tampilkan hasil prediksi
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          const SizedBox(height: 5),
                          Text(
                              "Prediksi dapat membuat kesalahan. Periksa harga lebih lanjut.",
                              style: GoogleFonts.poppins(
                                  color: Colors.grey[600], fontSize: 11),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              // Set _hargaManualController dengan nilai prediksi
                              _hargaManualController.text =
                                  hargaPrediksiHasilCtrl.text;
                              Navigator.pop(modalContext); // Tutup modal
                              // Mungkin panggil setState di form utama jika perlu update UI lain
                              setState(() {});
                            },
                            child: Text("Gunakan Harga Prediksi Ini",
                                style: GoogleFonts.poppins(
                                    color: Theme.of(context).primaryColor)),
                          )
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  _buildTextField("Atau Isi Harga Manual",
                      controller: _hargaManualController,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Jika harga manual diisi, _hargaManualController.text akan digunakan di form utama.
                        Navigator.pop(modalContext); // Tutup modal
                        // Panggil setState di form utama untuk update UI jika harga manual diubah di sini
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFDAF365).withOpacity(0.7),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: Text("Konfirmasi Harga Manual",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87)),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _saveDraft() {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty && _existingImageUrls.isEmpty) {
        // Cek apakah ada gambar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Mohon upload minimal 1 foto properti.')),
        );
        return;
      }
      // TODO: Logika untuk menyimpan draft (ke local storage atau API)
      // Kumpulkan data:
      String propertyId = widget.propertyToEdit?.id ??
          DateTime.now().toIso8601String(); // ID baru atau ID lama
      String mainImageUrl = _existingImageUrls.isNotEmpty
          ? _existingImageUrls.first
          : (_selectedImages.isNotEmpty ? _selectedImages.first.path : '');
      List<String> additionalImages = [];
      if (_existingImageUrls.length > 1) {
        additionalImages.addAll(_existingImageUrls.sublist(1));
      }
      additionalImages
          .addAll(_selectedImages.map((xfile) => xfile.path).toList());

      Property propertyData = Property(
        id: propertyId,
        title: _namaPropertiController.text,
        description: _deskripsiController.text,
        uploader: "CurrentUser", // Ganti dengan ID user asli
        imageUrl:
            mainImageUrl, // Untuk saat ini ambil yg pertama atau path lokal
        additionalImageUrls: additionalImages, // Path lokal untuk gambar baru
        price: double.tryParse(_hargaManualController.text) ?? 0,
        address: _alamatController.text,
        city: "Kota Contoh", // Ambil dari inputan atau pisahkan alamat
        stateZip: "Provinsi Contoh",
        bedrooms: int.tryParse(_kamarTidurController.text) ?? 0,
        bathrooms: int.tryParse(_kamarMandiController.text) ?? 0,
        areaSqft: double.tryParse(_luasPropertiController.text) ?? 0,
        propertyType: _tipePropertiController.text,
        furnishings: _perabotanController.text,
        status: PropertyStatus.draft, // Selalu draft saat disimpan
      );

      print("Draft disimpan (simulasi): ${propertyData.title}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Draft berhasil disimpan (Simulasi aja).')),
      );
      Navigator.pop(context, true); // Kirim true untuk indikasi ada perubahan
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Mohon lengkapi semua data yang wajib diisi dengan benar.')),
      );
    }
  }

  void _submitForVerification() {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty && _existingImageUrls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Mohon upload minimal 1 foto properti.')),
        );
        return;
      }
      // TODO: Logika untuk menyimpan data DAN mengubah status menjadi pendingVerification (ke API)
      // Kumpulkan data seperti _saveDraft, tapi statusnya PropertyStatus.pendingVerification
      String propertyId =
          widget.propertyToEdit?.id ?? DateTime.now().toIso8601String();
      String mainImageUrl = _existingImageUrls.isNotEmpty
          ? _existingImageUrls.first
          : (_selectedImages.isNotEmpty ? _selectedImages.first.path : '');
      List<String> additionalImages = [];
      if (_existingImageUrls.length > 1) {
        additionalImages.addAll(_existingImageUrls.sublist(1));
      }
      additionalImages
          .addAll(_selectedImages.map((xfile) => xfile.path).toList());

      Property propertyData = Property(
        id: propertyId,
        title: _namaPropertiController.text,
        // ... isi field lainnya seperti di _saveDraft ...
        description: _deskripsiController.text,
        uploader: "CurrentUser",
        imageUrl: mainImageUrl,
        additionalImageUrls: additionalImages,
        price: double.tryParse(_hargaManualController.text) ?? 0,
        address: _alamatController.text,
        city: "Kota Contoh",
        stateZip: "Provinsi Contoh",
        bedrooms: int.tryParse(_kamarTidurController.text) ?? 0,
        bathrooms: int.tryParse(_kamarMandiController.text) ?? 0,
        areaSqft: double.tryParse(_luasPropertiController.text) ?? 0,
        propertyType: _tipePropertiController.text,
        furnishings: _perabotanController.text,
        status: PropertyStatus.pendingVerification, // Status diubah
        submissionDate: DateTime.now(),
      );

      print(
          "Properti diajukan untuk verifikasi (simulasi): ${propertyData.title}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Properti diajukan untuk verifikasi (simulasi).')),
      );
      Navigator.pop(context, true); // Kirim true untuk indikasi ada perubahan
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Mohon lengkapi semua data yang wajib diisi dengan benar sebelum mengajukan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan apakah field bisa diedit berdasarkan status properti
    // Jika status pendingVerification, approved, atau rejected, field di-disable
    bool canEditFields = _currentStatus == PropertyStatus.draft;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // ... (AppBar sama seperti sebelumnya, judul bisa dinamis "Edit Draft" atau "Tambah Draft")
        title: Text(
          _isEditMode ? "Edit Draft Properti" : "Tambah Draft Properti",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Bagian Upload Foto ---
              Text(
                "Foto Properti (Maksimal 5)", /* ... */
              ),
              const SizedBox(height: 8),
              // Tampilkan gambar yang sudah ada (_existingImageUrls)
              if (_existingImageUrls.isNotEmpty)
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _existingImageUrls.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            right: 8.0, top: 8, bottom: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                // Asumsi URL dari internet jika sudah ada
                                _existingImageUrls[index],
                                height: 150, width: 100, fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                        height: 150,
                                        width: 100,
                                        color: Colors.grey[200],
                                        child: Icon(Icons.error_outline,
                                            color: Colors.red[300])),
                              ),
                            ),
                            if (canEditFields) // Hanya tampilkan tombol hapus jika bisa edit
                              Positioned(
                                top: -5,
                                right: -5,
                                child: IconButton(
                                  icon: const Icon(Icons.remove_circle,
                                      color: Colors.redAccent, size: 24),
                                  onPressed: () => _removeExistingImage(index),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              // Tampilkan area untuk menambah gambar baru atau list gambar baru yang dipilih
              (_existingImageUrls.length + _selectedImages.length) < 5 &&
                      canEditFields
                  ? GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        margin: EdgeInsets.only(
                            top: _existingImageUrls.isNotEmpty ||
                                    _selectedImages.isNotEmpty
                                ? 8
                                : 0),
                        height: _selectedImages.isEmpty &&
                                _existingImageUrls.isEmpty
                            ? 150
                            : 60, // Lebih kecil jika sudah ada gambar
                        width: _selectedImages.isEmpty &&
                                _existingImageUrls.isEmpty
                            ? double.infinity
                            : 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.grey[400]!,
                              style: BorderStyle.solid),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined,
                                size: _selectedImages.isEmpty &&
                                        _existingImageUrls.isEmpty
                                    ? 40
                                    : 24,
                                color: Colors.grey[600]),
                            if (_selectedImages.isEmpty &&
                                _existingImageUrls.isEmpty)
                              Text("Ketuk untuk menambah foto",
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              if (_selectedImages.isNotEmpty &&
                  canEditFields) // Tampilkan list gambar baru yang dipilih
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            right: 8.0, top: 8, bottom: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                  File(_selectedImages[index].path),
                                  height: 150,
                                  width: 100,
                                  fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: -5,
                              right: -5,
                              child: IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.redAccent, size: 24),
                                onPressed: () => _removeNewImage(index),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),

              // --- Form Fields dengan kondisi enabled ---
              _buildTextField("Nama Properti",
                  controller: _namaPropertiController,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  enabled: canEditFields),
              _buildTextField("Alamat Lengkap",
                  controller: _alamatController,
                  maxLines: 2,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  enabled: canEditFields),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField("Kamar Tidur",
                          controller: _kamarTidurController,
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Wajib' : null,
                          enabled: canEditFields)),
                  const SizedBox(width: 15),
                  Expanded(
                      child: _buildTextField("Kamar Mandi",
                          controller: _kamarMandiController,
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Wajib' : null,
                          enabled: canEditFields)),
                ],
              ),
              _buildTextField("Luas Properti (sqft)",
                  controller: _luasPropertiController,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Wajib' : null,
                  enabled: canEditFields),
              _buildTextField("Tipe Properti (cth: Rumah)",
                  controller: _tipePropertiController,
                  validator: (v) => v!.isEmpty ? 'Wajib' : null,
                  enabled: canEditFields),
              _buildTextField("Kondisi Perabotan (cth: Full Furnished)",
                  controller: _perabotanController,
                  validator: (v) => v!.isEmpty ? 'Wajib' : null,
                  enabled: canEditFields),
              _buildTextField("Deskripsi Tambahan",
                  controller: _deskripsiController,
                  maxLines: 4,
                  enabled: canEditFields),
              const SizedBox(height: 10),
              _buildTextField("Harga (AED)",
                  controller: _hargaManualController,
                  keyboardType: TextInputType.number, validator: (v) {
                if (v == null || v.isEmpty) return 'Harga wajib diisi';
                if (double.tryParse(v) == null || double.parse(v) <= 0)
                  return 'Masukkan harga valid';
                return null;
              }, enabled: canEditFields // Harga bisa diedit jika status draft
                  ),
              const SizedBox(height: 20),

              // Tombol Prediksi Harga hanya muncul jika bisa edit
              if (canEditFields)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showPredictionModal(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDAF365),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Text("Prediksi Harga & Isi Harga Manual",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87)),
                  ),
                ),
              const SizedBox(height: 20),

              // Tampilkan status jika bukan draft
              if (_currentStatus != PropertyStatus.draft)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Center(
                    child: Chip(
                      label: Text(
                          _currentStatus == PropertyStatus.pendingVerification
                              ? "Status: Menunggu Verifikasi Admin"
                              : _currentStatus == PropertyStatus.approved
                                  ? "Status: Sudah Disetujui & Tayang"
                                  : _currentStatus == PropertyStatus.rejected
                                      ? "Status: Ditolak Admin (Alasan: ${widget.propertyToEdit?.rejectionReason ?? 'Tidak ada alasan'})"
                                      : "Status Tidak Diketahui",
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500)),
                      backgroundColor:
                          _currentStatus == PropertyStatus.pendingVerification
                              ? Colors.orangeAccent
                              : _currentStatus == PropertyStatus.approved
                                  ? Colors.green
                                  : _currentStatus == PropertyStatus.rejected
                                      ? Colors.redAccent
                                      : Colors.grey,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ),

              // Tombol Aksi berdasarkan status
              if (_currentStatus == PropertyStatus.draft) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveDraft,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[700],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Text("Simpan Draft",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForVerification,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F2937),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Text("Ajukan untuk Verifikasi",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white)),
                  ),
                ),
              ] else if (_currentStatus == PropertyStatus.rejected) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Ubah status kembali ke draft agar bisa diedit dan diajukan ulang
                      setState(() {
                        _currentStatus = PropertyStatus.draft;
                        // widget.propertyToEdit?.updateStatus(PropertyStatus.draft); // Panggil method di model jika ingin langsung update state global (jika pakai provider)
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Status diubah ke Draft. Anda bisa mengedit dan mengajukan ulang.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[800],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Text("Edit Ulang (Revisi)",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white)),
                  ),
                ),
              ]
              // Jika pending atau approved, mungkin tidak ada aksi utama di sini, atau tombol "Tarik Pengajuan", "Nonaktifkan Iklan", dll.
            ],
          ),
        ),
      ),
    );
  }
}
