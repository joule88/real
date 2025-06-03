// lib/screens/my_drafts/add_property_form_screen.dart
import 'dart:async';
// import 'dart:convert'; // Tidak secara langsung digunakan di sini lagi
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:real/models/property.dart';
import 'package:real/widgets/property_image_picker.dart';
import 'package:real/services/property_service.dart';
import 'package:provider/provider.dart';
import 'package:real/provider/auth_provider.dart';
// import 'package:http/http.dart' as http; // Tidak secara langsung digunakan di sini lagi
import 'package:real/widgets/property_action_buttons.dart';
import 'map_picker_screen.dart';
import 'package:real/widgets/custom_form_field.dart';
// lib/screens/my_drafts/add_property_form_screen.dart

class AddPropertyFormScreen extends StatefulWidget {
  final Property? propertyToEdit;
  // final bool isSoldView; // Parameter ini bisa ditambahkan jika perlu logika khusus selain read-only

  const AddPropertyFormScreen({
    super.key, 
    this.propertyToEdit,
    // this.isSoldView = false, 
  });

  @override
  State<AddPropertyFormScreen> createState() => _AddPropertyFormScreenState();
}

class _AddPropertyFormScreenState extends State<AddPropertyFormScreen> {
  // ... (state dan controller yang sudah ada) ...
  final _formKey = GlobalKey<FormState>();
  final PropertyService _propertyService = PropertyService();

  late TextEditingController _namaPropertiController;
  late TextEditingController _alamatController;
  late TextEditingController _luasPropertiSqftController;
  late TextEditingController _deskripsiController;
  late TextEditingController _hargaManualAedController;

  late TextEditingController _kamarMandiController;
  late TextEditingController _kamarTidurController;

  String? _tipePropertiValue;
  int? _kondisiFurnishingValue; 
  int? _pemandanganSekitarValue;
  int? _usiaPropertiValue;
  int? _labelPropertiValue;

  List<dynamic> _addressSuggestions = []; 
  final bool _isFetchingAddressSuggestions = false;
  Timer? _debounceAddressSearch;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  List<XFile> _newlySelectedImages = [];
  List<String> _currentExistingImageUrls = [];

  bool _isEditMode = false;
  PropertyStatus _currentStatus = PropertyStatus.draft;
  bool _isLoadingSubmit = false;
  bool _isPredictingPrice = false;
  String? _hargaPrediksiIdrFormatted;

  final double _kursAedKeIdr = 4426; 
  final _idrFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  final List<String> _tipePropertiOptions = [
    'Rumah', 'Apartemen', 'Villa', 'Ruko', 'Tanah', 'Gudang', 'Kantor', 'Lainnya'
  ];

  final List<Map<String, dynamic>> kondisiFurnishingOptions = [
    {'text': 'NO', 'value': 1}, 
    {'text': 'PARTLY', 'value': 2},
    {'text': 'YES', 'value': 0},
  ];

  final List<Map<String, dynamic>> pemandanganSekitarOptions = [
    {'text': 'Lainnya / Tidak Spesifik', 'value': 0},
    {'text': 'Pemandangan Laut', 'value': 1},
    {'text': 'Pemandangan Burj Khalifa', 'value': 2},
    {'text': 'Pemandangan Golf', 'value': 3},
    {'text': 'Pemandangan Komunitas', 'value': 4},
    {'text': 'Pemandangan Kota', 'value': 5},
    {'text': 'Pemandangan Danau', 'value': 6},
    {'text': 'Pemandangan Kolam Renang', 'value': 7},
    {'text': 'Pemandangan Sungai', 'value': 8},
  ];

  final List<Map<String, dynamic>> usiaPropertiOptions = [
    {'text': 'Kurang dari 3 bulan', 'value': 0},
    {'text': '3-6 Bulan', 'value': 1},
    {'text': 'Lebih dari 6 Bulan', 'value': 2},
  ];

  final List<Map<String, dynamic>> labelPropertiOptions = [
    {'text': 'Tidak Ada Keyword Spesifik', 'value': 0},{'text': 'Luxury', 'value': 1},
    {'text': 'Furnished', 'value': 2},{'text': 'Spacious', 'value': 3},
    {'text': 'Prime Location', 'value': 4},{'text': 'Studio', 'value': 5},
    {'text': 'Penthouse', 'value': 6},{'text': 'Investment', 'value': 7},
    {'text': 'Villa', 'value': 8}, {'text': 'Downtown', 'value': 9},
  ];


  @override
  void initState() {
    super.initState();
    _isEditMode = widget.propertyToEdit != null;
    Property? p = widget.propertyToEdit;

    _namaPropertiController = TextEditingController(text: p?.title ?? '');
    _alamatController = TextEditingController(text: p?.address ?? '');
    _luasPropertiSqftController = TextEditingController(text: p?.areaSqft.toStringAsFixed(0) ?? '');
    _deskripsiController = TextEditingController(text: p?.description ?? '');
    _hargaManualAedController = TextEditingController(text: p?.price.toStringAsFixed(0) ?? '0');
    _kamarMandiController = TextEditingController(text: p?.bathrooms.toString() ?? '0');
    _kamarTidurController = TextEditingController(text: p?.bedrooms.toString() ?? '0');
    
    _newlySelectedImages = [];
    _currentExistingImageUrls = [];

    if (_isEditMode && p != null) {
      // === AWAL PERUBAHAN LOGIKA STATUS UNTUK EDIT ===
      if (p.status == PropertyStatus.approved) {
        _currentStatus = PropertyStatus.draft;
      } else {
        _currentStatus = p.status;
      }
      // === AKHIR PERUBAHAN LOGIKA STATUS UNTUK EDIT ===

      if (p.imageUrl.isNotEmpty && p.imageUrl.startsWith('http')) {
        _currentExistingImageUrls.add(p.imageUrl);
      }
      if (p.additionalImageUrls.isNotEmpty) {
        _currentExistingImageUrls.addAll(
            p.additionalImageUrls.where((url) => url.isNotEmpty && url.startsWith('http')));
      }
      _currentExistingImageUrls = _currentExistingImageUrls.toSet().toList();

      if (p.propertyType.isNotEmpty && _tipePropertiOptions.contains(p.propertyType)) {
        _tipePropertiValue = p.propertyType;
      }
      if (p.furnishings.isNotEmpty) {
        var found = kondisiFurnishingOptions.firstWhere(
              (opt) => opt['text'].toString().toLowerCase() == p.furnishings.toLowerCase(),
              orElse: () => <String, dynamic>{} 
        );
        if (found.isNotEmpty) _kondisiFurnishingValue = found['value'];
      }
      if (p.mainView != null && p.mainView!.isNotEmpty) {
        var found = pemandanganSekitarOptions.firstWhere(
              (opt) => opt['text'].toString() == p.mainView,
              orElse: () => <String, dynamic>{}
        );
        if (found.isNotEmpty) _pemandanganSekitarValue = found['value'];
      }
      if (p.listingAgeCategory != null && p.listingAgeCategory!.isNotEmpty) {
         var found = usiaPropertiOptions.firstWhere(
              (opt) => opt['text'].toString() == p.listingAgeCategory,
              orElse: () => <String, dynamic>{}
        );
        if (found.isNotEmpty) _usiaPropertiValue = found['value'];
      }
      if (p.propertyLabel != null && p.propertyLabel!.isNotEmpty) {
        var found = labelPropertiOptions.firstWhere(
              (opt) => opt['text'].toString() == p.propertyLabel,
              orElse: () => <String, dynamic>{}
        );
        if (found.isNotEmpty) _labelPropertiValue = found['value'];
      }
    } else {
      _currentStatus = PropertyStatus.draft;
    }

    _alamatController.addListener(() {
      if (_alamatController.text.isEmpty) {
        _removeOverlay();
        if (mounted) {
          setState(() => _addressSuggestions = []);
        }
      }
    });
  }
  // ... (dispose, _onAddressSearchChanged, _openMapPicker, _removeOverlay, _predictAndSetPrice, _processPropertySubmission tetap sama) ...
  void _onAddressSearchChanged(String query) {
    if (_debounceAddressSearch?.isActive ?? false) _debounceAddressSearch!.cancel();
    _debounceAddressSearch = Timer(const Duration(milliseconds: 700), () {
      if (query.trim().isNotEmpty && _alamatController.text == query) {
        print("Alamat dicari: $query"); 
      } else if (query.trim().isEmpty) {
        _removeOverlay();
        if (mounted) setState(() => _addressSuggestions = []);
      }
    });
  }

  Future<void> _openMapPicker() async {
    _removeOverlay();
    final selectedAddress = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );

    if (selectedAddress != null && selectedAddress.isNotEmpty && mounted) {
      setState(() {
        _alamatController.text = selectedAddress;
        _addressSuggestions = [];
      });
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
   Future<void> _predictAndSetPrice() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Mohon lengkapi field yang diperlukan untuk prediksi.'), backgroundColor: Colors.orange)
       );
       }
      return;
    }
      if(mounted) setState(() => _isPredictingPrice = true);
      try {
        final bathrooms = int.tryParse(_kamarMandiController.text);
        final bedrooms = int.tryParse(_kamarTidurController.text);
        final furnishing = _kondisiFurnishingValue;
        final double luasPropertiSqft = double.tryParse(_luasPropertiSqftController.text) ?? 0.0;
        final listingAgeCategory = _usiaPropertiValue;
        final viewType = _pemandanganSekitarValue;
        final titleKeyword = _labelPropertiValue;

        if (bathrooms == null || bedrooms == null || furnishing == null || luasPropertiSqft <= 0 || listingAgeCategory == null || viewType == null || titleKeyword == null) {
          if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pastikan semua field (kamar, luas, furnishing, usia, pemandangan, label) terisi dengan benar untuk prediksi.'), backgroundColor: Colors.orange),
            );
          }
          if(mounted) setState(() => _isPredictingPrice = false);
          return;
        }
        
        final defaultVerifiedStatusForPrediction = 0;

        final result = await _propertyService.predictPropertyPrice(
          bathrooms: bathrooms,
          bedrooms: bedrooms,
          furnishing: furnishing,
          sizeMin: luasPropertiSqft,
          verified: defaultVerifiedStatusForPrediction,
          listingAgeCategory: listingAgeCategory,
          viewType: viewType,
          titleKeyword: titleKeyword,
        );

         if (mounted && result['success'] == true && result['predicted_price'] != null) {
          final predictedPriceAed = result['predicted_price'];
          setState(() {
            _hargaManualAedController.text = predictedPriceAed.toStringAsFixed(0);
            _hargaPrediksiIdrFormatted = _idrFormatter.format(predictedPriceAed * _kursAedKeIdr);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Harga prediksi AED ${predictedPriceAed.toStringAsFixed(0)} telah diisi.'), backgroundColor: Colors.green),
          );
        } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'] ?? 'Gagal mendapatkan prediksi harga.'), backgroundColor: Colors.red),
            );
           setState(() {
             _hargaPrediksiIdrFormatted = null;
          });
        }
      } catch (e) {
         if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error prediksi: Pastikan semua field prediksi terisi. Error: $e'), backgroundColor: Colors.red),
            );
         }
          if(mounted) {
            setState(() {
             _hargaPrediksiIdrFormatted = null;
          });
          }
      } finally {
        if(mounted) setState(() => _isPredictingPrice = false);
      }
  }

  Future<void> _processPropertySubmission({required PropertyStatus targetStatus}) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon lengkapi semua data yang wajib diisi dengan benar.'), backgroundColor: Colors.orange),
        );
      }
      return;
    }
    bool isImageRequiredAndMissing = (!_isEditMode && _newlySelectedImages.isEmpty) ||
                                  (_isEditMode && _currentExistingImageUrls.isEmpty && _newlySelectedImages.isEmpty);

    if (isImageRequiredAndMissing && targetStatus != PropertyStatus.sold && targetStatus != PropertyStatus.archived) { // Gambar tidak wajib jika hanya ubah status ke sold/archived
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon upload minimal 1 foto properti.')),
        );
      }
      return;
    }

    if(mounted) setState(() => _isLoadingSubmit = true);

    String propertyIdForSubmission = (_isEditMode && widget.propertyToEdit != null && widget.propertyToEdit!.id.isNotEmpty)
        ? widget.propertyToEdit!.id
        : DateTime.now().toIso8601String(); 
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId == null || (authProvider.token?.isEmpty ?? true)) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesi tidak valid. Silakan login ulang.')),
        );
        setState(() => _isLoadingSubmit = false);
      }
      return;
    }

    String furnishingText = _kondisiFurnishingValue != null
        ? kondisiFurnishingOptions.firstWhere((opt) => opt['value'] == _kondisiFurnishingValue, orElse: () => {'text': ''})['text']
        : widget.propertyToEdit?.furnishings ?? ''; 
    String? pemandanganSekitarText = _pemandanganSekitarValue != null
        ? pemandanganSekitarOptions.firstWhere((opt) => opt['value'] == _pemandanganSekitarValue, orElse: () => {'text': null})['text']
        : widget.propertyToEdit?.mainView;
    String? usiaPropertiText = _usiaPropertiValue != null
        ? usiaPropertiOptions.firstWhere((opt) => opt['value'] == _usiaPropertiValue, orElse: () => {'text': null})['text']
        : widget.propertyToEdit?.listingAgeCategory;
    String? labelPropertiText = _labelPropertiValue != null
        ? labelPropertiOptions.firstWhere((opt) => opt['value'] == _labelPropertiValue, orElse: () => {'text': null})['text']
        : widget.propertyToEdit?.propertyLabel;

    final propertyData = Property(
      id: propertyIdForSubmission,
      title: _namaPropertiController.text,
      description: _deskripsiController.text,
      uploader: userId, // user_id dari authProvider
      uploaderInfo: authProvider.user, // Sertakan objek User jika perlu
      imageUrl: widget.propertyToEdit?.imageUrl ?? '', 
      additionalImageUrls: widget.propertyToEdit?.additionalImageUrls ?? [], 
      price: double.tryParse(_hargaManualAedController.text) ?? widget.propertyToEdit?.price ?? 0.0,
      address: _alamatController.text,
      bedrooms: int.tryParse(_kamarTidurController.text) ?? widget.propertyToEdit?.bedrooms ?? 0,
      bathrooms: int.tryParse(_kamarMandiController.text) ?? widget.propertyToEdit?.bathrooms ?? 0,
      areaSqft: double.tryParse(_luasPropertiSqftController.text) ?? widget.propertyToEdit?.areaSqft ?? 0.0,
      propertyType: _tipePropertiValue ?? widget.propertyToEdit?.propertyType ?? '',
      furnishings: furnishingText,
      status: targetStatus, // Gunakan targetStatus dari tombol yang ditekan
      mainView: pemandanganSekitarText,
      listingAgeCategory: usiaPropertiText,
      propertyLabel: labelPropertiText,
      bookmarkCount: widget.propertyToEdit?.bookmarkCount ?? 0,
      viewsCount: widget.propertyToEdit?.viewsCount ?? 0,
      inquiriesCount: widget.propertyToEdit?.inquiriesCount ?? 0,
      submissionDate: (targetStatus == PropertyStatus.pendingVerification && (widget.propertyToEdit == null || widget.propertyToEdit!.submissionDate == null))
                          ? DateTime.now()
                          : widget.propertyToEdit?.submissionDate,
      approvalDate: (targetStatus == PropertyStatus.approved && (widget.propertyToEdit == null ||widget.propertyToEdit!.approvalDate == null || widget.propertyToEdit!.status != PropertyStatus.approved))
                          ? DateTime.now() 
                          : widget.propertyToEdit?.approvalDate,
      rejectionReason: targetStatus == PropertyStatus.rejected ? widget.propertyToEdit?.rejectionReason : null, // Hanya relevan jika status rejected
      viewStatistics: widget.propertyToEdit?.viewStatistics ?? {},
    );
    
    final result = await _propertyService.submitProperty(
      property: propertyData,
      newSelectedImages: _newlySelectedImages,
      existingImageUrls: _currentExistingImageUrls,
      token: authProvider.token!,
    );

    if (mounted) {
      setState(() => _isLoadingSubmit = false);
      if (result['success'] == true) {
        String successMessage = "Properti berhasil diproses dengan status: ${targetStatus.name}";
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Terjadi kesalahan saat mengirim properti.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Logika canEditFields: TIDAK BISA diedit jika statusnya archived atau sold.
    // Hanya bisa diedit jika draft atau rejected.
    bool canEditFields = (_currentStatus == PropertyStatus.draft || _currentStatus == PropertyStatus.rejected);

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
          _isEditMode ? (_currentStatus == PropertyStatus.sold ? "Detail Properti Terjual" : "Edit Properti") : "Tambah Properti Baru",
          style: GoogleFonts.poppins(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          _removeOverlay();
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PropertyImagePicker( // Gambar tetap bisa dilihat meski tidak bisa diedit
                  initialSelectedImages: _newlySelectedImages,
                  initialExistingImageUrls: _currentExistingImageUrls,
                  canEdit: canEditFields, // Nonaktifkan jika tidak bisa edit
                  onSelectedImagesChanged: (updatedSelectedImages) {
                    if(canEditFields) setState(() => _newlySelectedImages = updatedSelectedImages);
                  },
                  onExistingImageUrlsChanged: (updatedExistingUrls) {
                     if(canEditFields) setState(() => _currentExistingImageUrls = updatedExistingUrls);
                  },
                ),
                const SizedBox(height: 20),

                CustomTextFormField(
                  label: "Nama Properti",
                  controller: _namaPropertiController,
                  enabled: canEditFields,
                ),
                CompositedTransformTarget(
                  link: _layerLink,
                  child: CustomTextFormField(
                      label: "Alamat Lengkap",
                      controller: _alamatController,
                      maxLines: 3,
                      enabled: canEditFields,
                      onChanged: canEditFields ? _onAddressSearchChanged : null,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.map_outlined, color: Theme.of(context).primaryColor),
                        onPressed: canEditFields ? _openMapPicker : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Alamat tidak boleh kosong';
                        return null;
                      }),
                ),

                CustomDropdownStringField(
                  label: "Tipe Properti",
                  value: _tipePropertiValue,
                  options: _tipePropertiOptions,
                  onChanged: canEditFields ? (String? newValue) { 
                    if (mounted) {
                      setState(() {
                        _tipePropertiValue = newValue;
                      });
                    }
                  } : null,
                  hint: "Pilih Tipe Properti",
                  enabled: canEditFields,
                ),

                Row(
                  children: [
                    Expanded(
                      child: NumberInputWithControls(
                        label: "Kamar Tidur",
                        controller: _kamarTidurController,
                        enabled: canEditFields,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: NumberInputWithControls(
                        label: "Kamar Mandi",
                        controller: _kamarMandiController,
                        enabled: canEditFields,
                      ),
                    ),
                  ],
                ),
                CustomTextFormField(
                    label: "Luas Properti (sqft)",
                    controller: _luasPropertiSqftController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    enabled: canEditFields,
                    hint: "Contoh: 1200.50"),

                CustomDropdownMapField(
                  label: "Kondisi Furnishing",
                  value: _kondisiFurnishingValue,
                  options: kondisiFurnishingOptions,
                  enabled: canEditFields,
                  onChanged: canEditFields ? (dynamic newValue) { 
                    if(mounted) setState(() => _kondisiFurnishingValue = newValue as int?);
                  } : null,
                ),
                CustomDropdownMapField(
                  label: "Pemandangan Sekitar",
                  value: _pemandanganSekitarValue,
                  options: pemandanganSekitarOptions,
                  enabled: canEditFields,
                  onChanged: canEditFields ? (dynamic newValue) { 
                     if(mounted) setState(() => _pemandanganSekitarValue = newValue as int?);
                  } : null,
                ),
                CustomDropdownMapField(
                  label: "Usia Properti",
                  value: _usiaPropertiValue,
                  options: usiaPropertiOptions,
                  enabled: canEditFields,
                  onChanged: canEditFields ? (dynamic newValue) { 
                     if(mounted) setState(() => _usiaPropertiValue = newValue as int?);
                  } : null,
                ),
                CustomDropdownMapField(
                  label: "Label Properti / Tag",
                  value: _labelPropertiValue,
                  options: labelPropertiOptions,
                  enabled: canEditFields,
                  onChanged: canEditFields ? (dynamic newValue) { 
                     if(mounted) setState(() => _labelPropertiValue = newValue as int?);
                  } : null,
                ),

                CustomTextFormField(
                  label: "Deskripsi Tambahan",
                  controller: _deskripsiController,
                  maxLines: 4,
                  enabled: canEditFields,
                  validator: null,
                ),

                const SizedBox(height: 10),
                if (canEditFields) // Tombol prediksi hanya jika bisa edit
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: _isPredictingPrice
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87))
                          : const Icon(Icons.online_prediction_outlined, color: Colors.black87),
                      label: Text("Prediksi & Isi Harga", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 15)),
                      onPressed: _isPredictingPrice ? null : _predictAndSetPrice,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDAF365),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                const SizedBox(height: 10),

                CustomTextFormField(
                    label: "Harga (AED)",
                    controller: _hargaManualAedController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    enabled: canEditFields,
                    hint: "Harga dalam AED"),

                if (_hargaPrediksiIdrFormatted != null && _hargaPrediksiIdrFormatted!.isNotEmpty && canEditFields)
                  Padding(
                     padding: const EdgeInsets.only(left: 4.0, right: 4.0, bottom: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Estimasi: $_hargaPrediksiIdrFormatted",
                          style: GoogleFonts.poppins(color: Colors.green[700], fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Kurs 1 AED ke IDR: ${_idrFormatter.format(_kursAedKeIdr)} (dapat berubah).",
                          style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                         const SizedBox(height: 2),
                        Text(
                          "Prediksi dapat membuat kesalahan. Periksa kembali respon harga.",
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                
                // Menampilkan status jika tidak bisa diedit (archived, sold, pending, approved)
                if (!canEditFields && !_isLoadingSubmit)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Center(
                      child: Chip(
                        label: Text(
                            "Status Saat Ini: ${_currentStatus.name.replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (Match m) => ' ${m[0]}').replaceFirstMapped(RegExp(r'^[a-z]'), (m) => m[0]!.toUpperCase())}",
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12)),
                        backgroundColor: _getStatusColorForChip(_currentStatus),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),

                // PropertyActionButtons hanya akan menampilkan tombol jika statusnya draft, rejected, atau archived
                // Untuk status 'sold', 'pendingVerification', 'approved', widget ini tidak akan menampilkan tombol apapun.
                if (_currentStatus != PropertyStatus.sold && _currentStatus != PropertyStatus.pendingVerification && _currentStatus != PropertyStatus.approved)
                  PropertyActionButtons(
                      isLoading: _isLoadingSubmit,
                      currentStatus: _currentStatus, 
                      onSubmit: _processPropertySubmission,
                      onEdit: () { 
                        if (mounted) {
                          setState(() {
                            _currentStatus = PropertyStatus.draft;
                          });
                        }
                      }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColorForChip(PropertyStatus status) {
    // ... (method _getStatusColorForChip tetap sama) ...
     switch (status) {
      case PropertyStatus.pendingVerification: return Colors.orangeAccent.shade700;
      case PropertyStatus.approved: return Colors.green.shade600;
      case PropertyStatus.archived: return Colors.grey.shade700;
      case PropertyStatus.sold: return Colors.purple.shade700;
      case PropertyStatus.rejected: return Colors.red.shade600;
      default: return Colors.blueGrey.shade700; // draft
    }
  }
}