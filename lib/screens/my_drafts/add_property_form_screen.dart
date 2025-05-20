import 'dart:convert'; // Untuk jsonEncode di _processPropertySubmission
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:real/models/property.dart';
import 'package:real/widgets/property_image_picker.dart'; // Impor widget baru
import 'package:real/services/property_service.dart'; // Impor service baru
import 'package:provider/provider.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:real/widgets/property_form_fields.dart';
import 'package:real/widgets/property_action_buttons.dart';
import 'package:real/widgets/property_price_prediction_modal.dart';
import 'package:real/services/api_constants.dart';

class AddPropertyFormScreen extends StatefulWidget {
  final Property? propertyToEdit;

  const AddPropertyFormScreen({super.key, this.propertyToEdit});

  @override
  State<AddPropertyFormScreen> createState() => _AddPropertyFormScreenState();
}

class _AddPropertyFormScreenState extends State<AddPropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final PropertyService _propertyService = PropertyService(); // Instance service

  late TextEditingController _namaPropertiController;
  late TextEditingController _alamatController;
  late TextEditingController _kamarMandiController;
  late TextEditingController _kamarTidurController;
  late TextEditingController _luasPropertiController;
  late TextEditingController _deskripsiController;
  late TextEditingController _hargaManualController;
  late TextEditingController _tipePropertiController;
  late TextEditingController _perabotanController;

  List<XFile> _selectedImages = [];
  List<String> _existingImageUrls = []; // Hanya URL yang sudah ada di server

  bool _isEditMode = false;
  PropertyStatus _currentStatus = PropertyStatus.draft;
  bool _isLoading = false; // Untuk indikator loading saat submit

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.propertyToEdit != null;

    _namaPropertiController = TextEditingController(text: widget.propertyToEdit?.title ?? '');
    _alamatController = TextEditingController(text: widget.propertyToEdit?.address ?? '');
    _kamarMandiController = TextEditingController(text: widget.propertyToEdit?.bathrooms.toString() ?? '');
    _kamarTidurController = TextEditingController(text: widget.propertyToEdit?.bedrooms.toString() ?? '');
    _luasPropertiController = TextEditingController(text: widget.propertyToEdit?.areaSqft.toString() ?? '');
    _deskripsiController = TextEditingController(text: widget.propertyToEdit?.description ?? '');
    _hargaManualController = TextEditingController(text: widget.propertyToEdit?.price.toString() ?? '0');
    _tipePropertiController = TextEditingController(text: widget.propertyToEdit?.propertyType ?? '');
    _perabotanController = TextEditingController(text: widget.propertyToEdit?.furnishings ?? '');
    _currentStatus = widget.propertyToEdit?.status ?? PropertyStatus.draft;

    if (_isEditMode) {
      if (widget.propertyToEdit!.imageUrl.isNotEmpty && widget.propertyToEdit!.imageUrl.startsWith('http')) {
        _existingImageUrls.add(widget.propertyToEdit!.imageUrl);
      }
      _existingImageUrls.addAll(
        widget.propertyToEdit!.additionalImageUrls.where((url) => url.startsWith('http'))
      );
      // Pastikan tidak ada duplikasi jika imageUrl juga ada di additionalImageUrls
      _existingImageUrls = _existingImageUrls.toSet().toList();
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

  Future<void> _processPropertySubmission({required PropertyStatus targetStatus}) async {
    if (!_formKey.currentState!.validate()) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua data yang wajib diisi dengan benar.')),
      );
      return;
    }
    // Validasi gambar hanya jika membuat baru atau jika edit tapi tidak ada gambar sama sekali
    if ((!_isEditMode && _selectedImages.isEmpty) || (_isEditMode && _existingImageUrls.isEmpty && _selectedImages.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon upload minimal 1 foto properti.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Tentukan ID properti
    // Jika _isEditMode dan widget.propertyToEdit.id valid, gunakan itu.
    // Jika tidak, backend akan membuat ID baru (kirim null atau string kosong untuk id).
    String propertyIdForSubmission = (_isEditMode && widget.propertyToEdit != null && widget.propertyToEdit!.id.isNotEmpty)
        ? widget.propertyToEdit!.id
        : ''; // Backend akan generate ID jika kosong

    // Siapkan data Property
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
final userId = authProvider.user?.id;

if (userId == null) {
  // User belum login
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Anda harus login terlebih dahulu')),
  );
  return;
}


    final propertyData = {
      'title': _namaPropertiController.text,
      'description': _deskripsiController.text,
      'price': double.parse(_hargaManualController.text),
      'bedrooms': int.parse(_kamarTidurController.text),
      'bathrooms': int.parse(_kamarMandiController.text),
      'sizeMin': double.parse(_luasPropertiController.text),
      'furnishing': _perabotanController.text,
      'address': _alamatController.text,
      'user_id': userId, // kirim ke backend
    };

    // Panggil service untuk mengirim data
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null || token.isEmpty) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login terlebih dahulu untuk mengirim properti.')),
      );
      return;
    }
    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.propertiesEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(propertyData),
    );

    if (response.statusCode == 401) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token tidak valid atau sudah expired. Silakan login ulang.')),
      );
      // Bisa redirect ke halaman login jika perlu
      return;
    }

    setState(() => _isLoading = false);

    if (mounted) { // Pastikan widget masih ada di tree
        if (response.statusCode == 200) {
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
            // Kirim kembali hasil (Property yang diupdate/baru dari API jika ada)
            // atau cukup true untuk menandakan sukses
            Navigator.pop(context, Property.fromJson(jsonDecode(response.body)['property']));
            final propertyId = jsonDecode(response.body)['property']['_id'];
            await _uploadImagesToServer(propertyId, token);
        } else {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.body}'), backgroundColor: Colors.red),
            );
        }
    }
  }

  Future<void> _uploadImagesToServer(String propertyId, String token) async {
    var uri = Uri.parse(ApiConstants.baseUrl + "/properties/$propertyId/images");

    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    for (XFile image in _selectedImages) {
      var file = await http.MultipartFile.fromPath('images[]', image.path);
      request.files.add(file);
    }

    var response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Gagal mengunggah gambar');
    }
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
                  setState(() {
                    _selectedImages = updatedSelectedImages;
                  });
                },
                onExistingImageUrlsChanged: (updatedExistingUrls) {
                  setState(() {
                    _existingImageUrls = updatedExistingUrls;
                  });
                },
              ),
              const SizedBox(height: 20),
              PropertyFormFields(
                namaPropertiController: _namaPropertiController,
                alamatController: _alamatController,
                kamarTidurController: _kamarTidurController,
                kamarMandiController: _kamarMandiController,
                luasPropertiController: _luasPropertiController,
                tipePropertiController: _tipePropertiController,
                perabotanController: _perabotanController,
                deskripsiController: _deskripsiController,
                hargaManualController: _hargaManualController,
                canEditFields: canEditFields,
              ),
              const SizedBox(height: 10),
              if (canEditFields)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.online_prediction_outlined, color: Colors.black87),
                    label: Text("Prediksi & Isi Harga", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 15)),
                    onPressed: _isLoading ? null : () => showPredictionModal(context, _hargaManualController),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDAF365),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              const SizedBox(height: 25),
              if (_currentStatus != PropertyStatus.draft && !_isLoading) // Tampilkan status jika bukan draft dan tidak loading
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
                                      : "Status Tidak Diketahui", // Seharusnya tidak terjadi
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
                isLoading: _isLoading,
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