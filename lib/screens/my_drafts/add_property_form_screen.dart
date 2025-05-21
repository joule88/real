// lib/screens/my_drafts/add_property_form_screen.dart
import 'dart:convert'; // Untuk jsonEncode di _processPropertySubmission
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // Untuk formatting IDR
import 'package:real/models/property.dart';
import 'package:real/widgets/property_image_picker.dart';
import 'package:real/services/property_service.dart';
import 'package:provider/provider.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:http/http.dart' as http; // Sebaiknya tidak digunakan langsung di UI screen
// import 'package:real/widgets/property_form_fields.dart'; // Kita akan buat field langsung di sini atau custom widget baru
import 'package:real/widgets/property_action_buttons.dart';
// import 'package:real/widgets/property_price_prediction_modal.dart'; // Modal tidak lagi dipakai untuk tombol ini
import 'package:real/services/api_constants.dart'; // Untuk endpoint submit properti

class AddPropertyFormScreen extends StatefulWidget {
  final Property? propertyToEdit;

  const AddPropertyFormScreen({super.key, this.propertyToEdit});

  @override
  State<AddPropertyFormScreen> createState() => _AddPropertyFormScreenState();
}

class _AddPropertyFormScreenState extends State<AddPropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final PropertyService _propertyService = PropertyService();

  // --- Text Editing Controllers untuk semua field form ---
  late TextEditingController _namaPropertiController;
  late TextEditingController _alamatController;
  late TextEditingController _kamarMandiController;
  late TextEditingController _kamarTidurController;
  late TextEditingController _luasPropertiSqftController; // Diubah ke Sqft
  late TextEditingController _deskripsiController;
  late TextEditingController _hargaManualAedController; // Harga dalam AED
  late TextEditingController _tipePropertiController;
  // Kondisi Perabotan, Pemandangan Utama, Kategori Usia Listing, Label Properti akan pakai Dropdown

  // --- State untuk Dropdown ---
  int? _kondisiFurnishingValue;
  int? _pemandanganUtamaValue;
  int? _kategoriUsiaListingValue;
  int? _labelPropertiValue;

  // --- State untuk gambar ---
  List<XFile> _selectedImages = [];
  List<String> _existingImageUrls = [];

  bool _isEditMode = false;
  PropertyStatus _currentStatus = PropertyStatus.draft;
  bool _isLoadingSubmit = false; // Untuk loading saat submit/ajukan
  bool _isPredictingPrice = false; // Untuk loading saat prediksi harga

  // --- Untuk tampilan konversi IDR ---
  String? _hargaPrediksiIdrFormatted;
  final double _kursAedKeIdr = 4350; // GANTI DENGAN NILAI TUKAR AKTUAL
  final _idrFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.propertyToEdit != null;

    _namaPropertiController = TextEditingController(text: widget.propertyToEdit?.title ?? '');
    _alamatController = TextEditingController(text: widget.propertyToEdit?.address ?? '');
    _kamarMandiController = TextEditingController(text: widget.propertyToEdit?.bathrooms.toString() ?? '');
    _kamarTidurController = TextEditingController(text: widget.propertyToEdit?.bedrooms.toString() ?? '');
    _luasPropertiSqftController = TextEditingController(text: widget.propertyToEdit?.areaSqft.toString() ?? ''); // areaSqft dari model
    _deskripsiController = TextEditingController(text: widget.propertyToEdit?.description ?? '');
    _hargaManualAedController = TextEditingController(text: widget.propertyToEdit?.price.toString() ?? '0');
    _tipePropertiController = TextEditingController(text: widget.propertyToEdit?.propertyType ?? ''); // Misal: Rumah, Apartemen
    
    // Inisialisasi dropdown jika mode edit
    if (_isEditMode && widget.propertyToEdit != null) {
      // Cari value yang cocok untuk dropdown kondisi furnishing
      _kondisiFurnishingValue = kondisiFurnishingOptions.firstWhere(
            (opt) => opt['text'].toString().toLowerCase() == widget.propertyToEdit!.furnishings.toLowerCase(),
            orElse: () => {'value': null} // default jika tidak ketemu
      )['value'];
      // TODO: Inisialisasi dropdown lain (Pemandangan Utama, Kategori Usia, Label) jika datanya ada di model Property
      // dan jika model Property menyimpan nilai numeriknya atau teks yang bisa di-map.
      // Saat ini model Property belum punya field untuk ini.
    }


    _currentStatus = widget.propertyToEdit?.status ?? PropertyStatus.draft;

    if (_isEditMode && widget.propertyToEdit != null) {
      if (widget.propertyToEdit!.imageUrl.isNotEmpty && widget.propertyToEdit!.imageUrl.startsWith('http')) {
        _existingImageUrls.add(widget.propertyToEdit!.imageUrl);
      }
      _existingImageUrls.addAll(
        widget.propertyToEdit!.additionalImageUrls.where((url) => url.startsWith('http'))
      );
      _existingImageUrls = _existingImageUrls.toSet().toList();
    }
  }

  @override
  void dispose() {
    _namaPropertiController.dispose();
    _alamatController.dispose();
    _kamarMandiController.dispose();
    _kamarTidurController.dispose();
    _luasPropertiSqftController.dispose();
    _deskripsiController.dispose();
    _hargaManualAedController.dispose();
    _tipePropertiController.dispose();
    super.dispose();
  }

  // --- Opsi untuk Dropdown ---
  // (Sama seperti di modal, tapi mungkin perlu disesuaikan jika ada perbedaan)
  final List<Map<String, dynamic>> kondisiFurnishingOptions = [
    {'text': 'Unfurnished', 'value': 0},
    {'text': 'Furnished', 'value': 1},
    // Tambahkan opsi lain jika ada, misal 'Semi Furnished' dan pastikan value-nya unik & sesuai API prediksi
  ];

  final List<Map<String, dynamic>> pemandanganUtamaOptions = [
    {'text': 'Lainnya / Tidak Ada', 'value': 0}, {'text': 'Sea View', 'value': 1},
    {'text': 'Burj Khalifa View', 'value': 2}, {'text': 'Golf Course View', 'value': 3},
    {'text': 'Community View', 'value': 4}, {'text': 'City View', 'value': 5},
    {'text': 'Lake View', 'value': 6}, {'text': 'Pool View', 'value': 7},
    {'text': 'Canal View', 'value': 8},
  ];

  final List<Map<String, dynamic>> kategoriUsiaListingOptions = [
    {'text': 'Baru (Kurang dari 3 bulan)', 'value': 0},
    {'text': 'Cukup Lama (3-6 bulan)', 'value': 1},
    {'text': 'Lama (Lebih dari 6 bulan)', 'value': 2},
  ];

  final List<Map<String, dynamic>> labelPropertiOptions = [
    {'text': 'Tidak Ada Keyword Spesifik', 'value': 0},{'text': 'Luxury', 'value': 1},
    {'text': 'Furnished', 'value': 2},{'text': 'Spacious', 'value': 3},
    {'text': 'Prime', 'value': 4},{'text': 'Studio', 'value': 5},
    {'text': 'Penthouse', 'value': 6},{'text': 'Investment', 'value': 7},
    {'text': 'Villa', 'value': 8},{'text': 'Downtown', 'value': 9},
  ];

  // --- Fungsi untuk Tombol Prediksi Harga ---
  Future<void> _predictAndSetPrice() async {
    if (_formKey.currentState!.validate()) { // Validasi field yang dibutuhkan untuk prediksi
      setState(() => _isPredictingPrice = true);

      // Kumpulkan data dari form
      // Pastikan semua controller dan value dropdown sudah terisi sebelum memanggil ini
      try {
        final bathrooms = int.parse(_kamarMandiController.text);
        final bedrooms = int.parse(_kamarTidurController.text);
        final furnishing = _kondisiFurnishingValue;
        final sizeMinSqft = double.parse(_luasPropertiSqftController.text);
        final listingAgeCategory = _kategoriUsiaListingValue;
        final viewType = _pemandanganUtamaValue;
        final titleKeyword = _labelPropertiValue;

        // Validasi tambahan bahwa dropdown sudah dipilih
        if (furnishing == null || listingAgeCategory == null || viewType == null || titleKeyword == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mohon lengkapi semua pilihan dropdown untuk prediksi.'), backgroundColor: Colors.orange),
          );
          setState(() => _isPredictingPrice = false);
          return;
        }

        final defaultVerifiedStatusForPrediction = 0; // 0 = Tidak Terverifikasi

        final result = await _propertyService.predictPropertyPrice(
          bathrooms: bathrooms,
          bedrooms: bedrooms,
          furnishing: furnishing,
          sizeMin: sizeMinSqft, // Kirim dalam SQFT
          verified: defaultVerifiedStatusForPrediction,
          listingAgeCategory: listingAgeCategory,
          viewType: viewType,
          titleKeyword: titleKeyword,
        );

        if (result['success'] == true && result['predicted_price'] != null) {
          final predictedPriceAed = result['predicted_price'];
          setState(() {
            _hargaManualAedController.text = predictedPriceAed.toStringAsFixed(0);
            _hargaPrediksiIdrFormatted = _idrFormatter.format(predictedPriceAed * _kursAedKeIdr);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Harga prediksi AED ${predictedPriceAed.toStringAsFixed(0)} telah diisi.'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Gagal mendapatkan prediksi harga.'), backgroundColor: Colors.red),
          );
          setState(() { // Reset tampilan IDR jika prediksi gagal
             _hargaPrediksiIdrFormatted = null;
          });
        }
      } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi kesalahan: Pastikan semua field prediksi terisi dengan benar. Error: $e'), backgroundColor: Colors.red),
          );
          setState(() {
             _hargaPrediksiIdrFormatted = null;
          });
      } finally {
        setState(() => _isPredictingPrice = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi field yang diperlukan untuk prediksi dengan benar.'), backgroundColor: Colors.orange),
      );
    }
  }


  // --- Fungsi untuk Submit Properti (Simpan Draft / Ajukan) ---
  Future<void> _processPropertySubmission({required PropertyStatus targetStatus}) async {
    if (!_formKey.currentState!.validate()) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua data yang wajib diisi dengan benar.'), backgroundColor: Colors.orange),
      );
      return;
    }
    if ((!_isEditMode && _selectedImages.isEmpty) || (_isEditMode && _existingImageUrls.isEmpty && _selectedImages.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon upload minimal 1 foto properti.')),
      );
      return;
    }

    setState(() => _isLoadingSubmit = true);

    String propertyIdForSubmission = (_isEditMode && widget.propertyToEdit != null && widget.propertyToEdit!.id.isNotEmpty)
        ? widget.propertyToEdit!.id
        : DateTime.now().toIso8601String(); // ID sementara unik jika buat baru

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login terlebih dahulu untuk mengirim properti.')),
      );
      setState(() => _isLoadingSubmit = false);
      return;
    }

    // Ambil nama teks dari kondisi furnishing untuk disimpan di model Property
    String furnishingText = _kondisiFurnishingValue != null
        ? kondisiFurnishingOptions.firstWhere((opt) => opt['value'] == _kondisiFurnishingValue, orElse: () => {'text': ''})['text']
        : '';

    // Membuat objek Property
    final propertyData = Property(
      id: propertyIdForSubmission,
      title: _namaPropertiController.text,
      description: _deskripsiController.text,
      uploader: userId, // Atau bisa juga nama user jika modelnya begitu
      imageUrl: '', // Akan diisi oleh backend setelah upload gambar pertama
      additionalImageUrls: [], // Akan diisi backend
      price: double.tryParse(_hargaManualAedController.text) ?? 0.0,
      address: _alamatController.text,
      city: '', // TODO: Tambahkan field kota jika perlu di form
      stateZip: '', // TODO: Tambahkan field state/zip jika perlu di form
      bedrooms: int.tryParse(_kamarTidurController.text) ?? 0,
      bathrooms: int.tryParse(_kamarMandiController.text) ?? 0,
      areaSqft: double.tryParse(_luasPropertiSqftController.text) ?? 0.0,
      propertyType: _tipePropertiController.text,
      furnishings: furnishingText, // Menyimpan teks furnishing, bukan value int
      status: targetStatus,
      // TODO: Inisialisasi field lain dari model Property jika ada di form ini
      // seperti Pemandangan Utama, Kategori Usia, Label Properti jika ingin disimpan juga
    );

    final token = authProvider.token;
    if (token == null || token.isEmpty) {
      setState(() => _isLoadingSubmit = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi Anda berakhir. Silakan login ulang.')),
      );
      return;
    }
    
    // Panggil service untuk mengirim data
    // PERHATIAN: property_service.dart yang lama menggunakan MultipartRequest.
    // Jika API Laravel Miaw di /properties menerima JSON dan gambar di-handle terpisah (misal POST ke /properties, lalu POST ke /properties/{id}/images)
    // maka logic di sini dan di service perlu disesuaikan.
    // Asumsi saat ini: _propertyService.submitProperty MENGHANDLE upload gambar dan data teks.
    final result = await _propertyService.submitProperty(
      property: propertyData,
      newSelectedImages: _selectedImages,
      existingImageUrls: _existingImageUrls, // Untuk mode edit
      token: token,
    );

    setState(() => _isLoadingSubmit = false);

    if (mounted) {
      if (result['success'] == true) {
        String successMessage = targetStatus == PropertyStatus.draft
            ? "Draft berhasil disimpan!"
            : "Properti berhasil diajukan untuk verifikasi!";
        if (_isEditMode && targetStatus != PropertyStatus.draft) {
            successMessage = "Properti berhasil diperbarui dan diajukan!";
        } else if (_isEditMode) {
            successMessage = "Draft berhasil diperbarui!";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Kirim true untuk refresh di halaman sebelumnya
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Terjadi kesalahan saat mengirim properti.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Helper untuk membangun Text Field
  Widget _buildTextField(String label,
      {required TextEditingController controller,
      int maxLines = 1,
      TextInputType keyboardType = TextInputType.text,
      bool enabled = true,
      String? hint,
      FormFieldValidator<String>? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            enabled: enabled,
            decoration: InputDecoration(
              filled: true,
              fillColor: enabled ? Colors.grey[100] : Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              hintText: hint ?? 'Masukkan $label',
              hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
            ),
            validator: validator ?? (value) {
              if (value == null || value.isEmpty) {
                return '$label tidak boleh kosong';
              }
              if (keyboardType == TextInputType.number || keyboardType == TextInputType.numberWithOptions(decimal: true)) {
                if (num.tryParse(value) == null) {
                  return 'Masukkan angka yang valid untuk $label';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Helper untuk membangun Dropdown
  Widget _buildDropdownFormField({
    required String label,
    required dynamic value,
    required List<Map<String, dynamic>> options,
    required ValueChanged<dynamic?> onChanged,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<dynamic>(
            decoration: InputDecoration(
              filled: true,
              fillColor: enabled ? Colors.grey[100] : Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            ),
            value: value,
            hint: Text('Pilih $label', style: GoogleFonts.poppins(color: Colors.grey[500])),
            isExpanded: true,
            items: options.map((option) {
              return DropdownMenuItem<dynamic>(
                value: option['value'],
                child: Text(option['text'].toString(), style: GoogleFonts.poppins()),
              );
            }).toList(),
            onChanged: enabled ? onChanged : null,
            validator: (value) => value == null ? '$label harus dipilih' : null,
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    bool canEditFields = _currentStatus == PropertyStatus.draft;

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
          _isEditMode ? "Edit Properti" : "Tambah Properti Baru",
          style: GoogleFonts.poppins(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PropertyImagePicker(
                initialSelectedImages: _selectedImages,
                initialExistingImageUrls: _existingImageUrls,
                canEdit: canEditFields,
                onSelectedImagesChanged: (updatedSelectedImages) {
                  setState(() => _selectedImages = updatedSelectedImages);
                },
                onExistingImageUrlsChanged: (updatedExistingUrls) {
                  setState(() => _existingImageUrls = updatedExistingUrls);
                },
              ),
              const SizedBox(height: 20),

              _buildTextField("Nama Properti", controller: _namaPropertiController, enabled: canEditFields),
              _buildTextField("Alamat Lengkap", controller: _alamatController, maxLines: 3, enabled: canEditFields),
              _buildTextField("Tipe Properti", controller: _tipePropertiController, hint: "Contoh: Apartemen, Rumah, Villa", enabled: canEditFields),
              
              Row(
                children: [
                  Expanded(child: _buildTextField("Kamar Tidur", controller: _kamarTidurController, keyboardType: TextInputType.number, enabled: canEditFields, hint: "Contoh: 2")),
                  const SizedBox(width: 15),
                  Expanded(child: _buildTextField("Kamar Mandi", controller: _kamarMandiController, keyboardType: TextInputType.number, enabled: canEditFields, hint: "Contoh: 1")),
                ],
              ),
              _buildTextField(
                "Luas Properti (sqft)", // Label diubah ke SQFT
                controller: _luasPropertiSqftController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                enabled: canEditFields,
                hint: "Contoh: 1200.50"
              ),

              _buildDropdownFormField(
                label: "Kondisi Furnishing",
                value: _kondisiFurnishingValue,
                options: kondisiFurnishingOptions,
                enabled: canEditFields,
                onChanged: (value) => setState(() => _kondisiFurnishingValue = value),
              ),
              _buildDropdownFormField(
                label: "Pemandangan Utama",
                value: _pemandanganUtamaValue,
                options: pemandanganUtamaOptions,
                enabled: canEditFields,
                onChanged: (value) => setState(() => _pemandanganUtamaValue = value),
              ),
              _buildDropdownFormField(
                label: "Kategori Usia Listing",
                value: _kategoriUsiaListingValue,
                options: kategoriUsiaListingOptions,
                enabled: canEditFields,
                onChanged: (value) => setState(() => _kategoriUsiaListingValue = value),
              ),
              _buildDropdownFormField(
                label: "Label Properti / Tag",
                value: _labelPropertiValue,
                options: labelPropertiOptions,
                enabled: canEditFields,
                onChanged: (value) => setState(() => _labelPropertiValue = value),
              ),
              
              _buildTextField("Deskripsi Tambahan", controller: _deskripsiController, maxLines: 4, enabled: canEditFields, validator: null), // Deskripsi boleh kosong

              const SizedBox(height: 10),
              // --- Tombol Prediksi Harga ---
              if (canEditFields)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _isPredictingPrice
                        ? Container(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87))
                        : Icon(Icons.online_prediction_outlined, color: Colors.black87),
                    label: Text("Prediksi & Isi Harga", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 15)),
                    onPressed: _isPredictingPrice ? null : _predictAndSetPrice,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDAF365),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              const SizedBox(height: 10),

              _buildTextField(
                "Harga (AED)",
                controller: _hargaManualAedController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                enabled: canEditFields,
                hint: "Harga dalam AED"
              ),

              // Estimasi rupiah
              if (_hargaPrediksiIdrFormatted != null && _hargaPrediksiIdrFormatted!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0, bottom: 15.0), // Satu Padding untuk semua info
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Estimasi: $_hargaPrediksiIdrFormatted",
                        style: GoogleFonts.poppins(color: Colors.green[700], fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),

                      // Kurs
                      Text(
                        "Kurs AED ke IDR: ${_idrFormatter.format(_kursAedKeIdr)} (dapat berubah).",
                        style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 2),

                      // Disclaimer Prediksi
                      Text(
                        "Prediksi dapat membuat kesalahan. Periksa kembali respon harga.",
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 10),

              if (_currentStatus != PropertyStatus.draft && !_isLoadingSubmit)
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
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12)),
                      backgroundColor:
                          _currentStatus == PropertyStatus.pendingVerification
                              ? Colors.orangeAccent.shade700
                              : _currentStatus == PropertyStatus.approved
                                  ? Colors.green.shade600
                                  : _currentStatus == PropertyStatus.rejected
                                      ? Colors.redAccent.shade400
                                      : Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              PropertyActionButtons(
                isLoading: _isLoadingSubmit,
                currentStatus: _currentStatus,
                onSubmit: _processPropertySubmission,
                onEdit: () => setState(() => _currentStatus = PropertyStatus.draft),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}