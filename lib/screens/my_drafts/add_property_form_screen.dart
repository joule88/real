// File: lib/screens/my_drafts/add_property_form_screen.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:real/models/property.dart';
import 'package:real/widgets/property_image_picker.dart';
import 'package:real/services/property_service.dart';
import 'package:provider/provider.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:real/widgets/property_action_buttons.dart';
import 'map_picker_screen.dart';
import 'package:real/widgets/custom_form_field.dart';

class AddPropertyFormScreen extends StatefulWidget {
  final Property? propertyToEdit;

  const AddPropertyFormScreen({super.key, this.propertyToEdit});

  @override
  State<AddPropertyFormScreen> createState() => _AddPropertyFormScreenState();
}

class _AddPropertyFormScreenState extends State<AddPropertyFormScreen> {
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
  bool _isFetchingAddressSuggestions = false;
  Timer? _debounceAddressSearch;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  List<XFile> _newlySelectedImages = [];
  List<String> _currentExistingImageUrls = [];

  bool _isEditMode = false;
  PropertyStatus _currentStatus = PropertyStatus.draft; // Status internal form
  bool _isLoadingSubmit = false;
  bool _isPredictingPrice = false;
  String? _hargaPrediksiIdrFormatted;

  final double _kursAedKeIdr = 4350;
  final _idrFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  final List<String> _tipePropertiOptions = [
    'Rumah', 'Apartemen', 'Villa', 'Ruko', 'Tanah', 'Gudang', 'Kantor', 'Lainnya'
  ];

  final List<Map<String, dynamic>> kondisiFurnishingOptions = [
    {'text': 'Unfurnished', 'value': 1},
    {'text': 'Semi Furnished', 'value': 2},
    {'text': 'Furnished', 'value': 0},
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
    
    // Inisialisasi _currentStatus berdasarkan properti yang diedit
    // Jika properti baru, default ke draft
    _currentStatus = p?.status ?? PropertyStatus.draft;

    _newlySelectedImages = [];
    _currentExistingImageUrls = [];

    if (_isEditMode && p != null) {
      // Jika properti yang diedit statusnya rejected,
      // maka di form ini statusnya diubah menjadi draft agar bisa direvisi.
      if (p.status == PropertyStatus.rejected) {
        _currentStatus = PropertyStatus.draft;
      }
      // Jika statusnya pendingVerification, _currentStatus akan tetap pendingVerification,
      // yang akan membuat canEditFields menjadi false.

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

  @override
  void dispose() {
    _namaPropertiController.dispose();
    _alamatController.dispose();
    _kamarMandiController.dispose();
    _kamarTidurController.dispose();
    _luasPropertiSqftController.dispose();
    _deskripsiController.dispose();
    _hargaManualAedController.dispose();
    _debounceAddressSearch?.cancel();
    _removeOverlay();
    super.dispose();
  }

  Future<void> _predictAndSetPrice() async {
    if (!_formKey.currentState!.validate()) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Mohon lengkapi field yang diperlukan untuk prediksi.'), backgroundColor: Colors.orange)
       );
      return;
    }
      setState(() => _isPredictingPrice = true);
      try {
        final bathrooms = int.parse(_kamarMandiController.text);
        final bedrooms = int.parse(_kamarTidurController.text);
        final furnishing = _kondisiFurnishingValue;

        final double luasPropertiSqft = double.tryParse(_luasPropertiSqftController.text) ?? 0.0;
        if (luasPropertiSqft <= 0) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Luas properti (sqft) harus lebih dari 0 untuk prediksi.'), backgroundColor: Colors.orange),
          );
          setState(() => _isPredictingPrice = false);
          return;
        }

        final listingAgeCategory = _usiaPropertiValue;
        final viewType = _pemandanganSekitarValue;
        final titleKeyword = _labelPropertiValue;

        if (furnishing == null || listingAgeCategory == null || viewType == null || titleKeyword == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mohon lengkapi semua pilihan dropdown (Furnishing, Usia, Pemandangan, Label) untuk prediksi.'), backgroundColor: Colors.orange),
          );
          setState(() => _isPredictingPrice = false);
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

         if (result['success'] == true && result['predicted_price'] != null) {
          final predictedPriceAed = result['predicted_price'];
          setState(() {
            _hargaManualAedController.text = predictedPriceAed.toStringAsFixed(0);
            _hargaPrediksiIdrFormatted = _idrFormatter.format(predictedPriceAed * _kursAedKeIdr);
          });
          if(mounted){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Harga prediksi AED ${predictedPriceAed.toStringAsFixed(0)} telah diisi.'), backgroundColor: Colors.green),
            );
          }
        } else {
           if(mounted){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'] ?? 'Gagal mendapatkan prediksi harga.'), backgroundColor: Colors.red),
            );
           }
          setState(() {
             _hargaPrediksiIdrFormatted = null;
          });
        }
      } catch (e) {
         if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Terjadi kesalahan: Pastikan semua field prediksi terisi dengan benar. Error: $e'), backgroundColor: Colors.red),
            );
         }
          setState(() {
             _hargaPrediksiIdrFormatted = null;
          });
      } finally {
        if(mounted) setState(() => _isPredictingPrice = false);
      }
  }

  Future<void> _processPropertySubmission({required PropertyStatus targetStatus}) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua data yang wajib diisi dengan benar.'), backgroundColor: Colors.orange),
      );
      return;
    }
    if ((!_isEditMode && _newlySelectedImages.isEmpty) ||
        (_isEditMode && _currentExistingImageUrls.isEmpty && _newlySelectedImages.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon upload minimal 1 foto properti.')),
      );
      return;
    }

    setState(() => _isLoadingSubmit = true);

    String propertyIdForSubmission = (_isEditMode && widget.propertyToEdit != null && widget.propertyToEdit!.id.isNotEmpty)
        ? widget.propertyToEdit!.id
        : DateTime.now().toIso8601String();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login terlebih dahulu untuk mengirim properti.')),
      );
      if (mounted) setState(() => _isLoadingSubmit = false);
      return;
    }

    String furnishingText = _kondisiFurnishingValue != null
        ? kondisiFurnishingOptions.firstWhere((opt) => opt['value'] == _kondisiFurnishingValue, orElse: () => {'text': ''})['text']
        : '';
    String? pemandanganSekitarText = _pemandanganSekitarValue != null
        ? pemandanganSekitarOptions.firstWhere((opt) => opt['value'] == _pemandanganSekitarValue, orElse: () => {'text': null})['text']
        : null;
    String? usiaPropertiText = _usiaPropertiValue != null
        ? usiaPropertiOptions.firstWhere((opt) => opt['value'] == _usiaPropertiValue, orElse: () => {'text': null})['text']
        : null;
    String? labelPropertiText = _labelPropertiValue != null
        ? labelPropertiOptions.firstWhere((opt) => opt['value'] == _labelPropertiValue, orElse: () => {'text': null})['text']
        : null;

    final propertyData = Property(
      id: propertyIdForSubmission,
      title: _namaPropertiController.text,
      description: _deskripsiController.text,
      uploader: userId,
      imageUrl: '',
      additionalImageUrls: [],
      price: double.tryParse(_hargaManualAedController.text) ?? 0.0,
      address: _alamatController.text,
      bedrooms: int.tryParse(_kamarTidurController.text) ?? 0,
      bathrooms: int.tryParse(_kamarMandiController.text) ?? 0,
      areaSqft: double.tryParse(_luasPropertiSqftController.text) ?? 0.0,
      propertyType: _tipePropertiValue ?? '',
      furnishings: furnishingText,
      status: targetStatus, // Menggunakan targetStatus yang diterima dari tombol
      mainView: pemandanganSekitarText,
      listingAgeCategory: usiaPropertiText,
      propertyLabel: labelPropertiText,
      bookmarkCount: widget.propertyToEdit?.bookmarkCount ?? 0,
      viewsCount: widget.propertyToEdit?.viewsCount ?? 0,
      inquiriesCount: widget.propertyToEdit?.inquiriesCount ?? 0,
      submissionDate: (targetStatus == PropertyStatus.pendingVerification && widget.propertyToEdit?.submissionDate == null)
                          ? DateTime.now()
                          : widget.propertyToEdit?.submissionDate,
      approvalDate: widget.propertyToEdit?.approvalDate,
    );

    final token = authProvider.token;
    if (token == null || token.isEmpty) {
      if (mounted) {
        setState(() => _isLoadingSubmit = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesi Anda berakhir. Silakan login ulang.')),
        );
      }
      return;
    }

    print('DEBUG AddPropertyFormScreen: Mengirim properti dengan status: ${propertyData.status}');

    final result = await _propertyService.submitProperty(
      property: propertyData,
      newSelectedImages: _newlySelectedImages,
      existingImageUrls: _currentExistingImageUrls,
      token: token,
    );

    if (mounted) {
      setState(() => _isLoadingSubmit = false);
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
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Terjadi kesalahan saat mengirim properti.'), backgroundColor: Colors.red),
        );
      }
    }
  }


  Future<void> _fetchAddressSuggestions(String query) async {
    if (query.trim().isEmpty) {
      _removeOverlay();
      if (mounted) {
        setState(() {
          _addressSuggestions = [];
          _isFetchingAddressSuggestions = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isFetchingAddressSuggestions = true;
      });
    }

    final Uri uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=jsonv2&addressdetails=1&limit=5&countrycodes=ID');

    try {
      final response = await http.get(uri, headers: {
        'User-Agent': 'NamaAplikasiAnda/1.0 (emailanda@example.com)'
      });

      if (mounted) {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is List) {
            setState(() {
              _addressSuggestions = data;
            });
            if (_addressSuggestions.isNotEmpty) {
              _showOverlay();
            } else {
              _removeOverlay();
            }
          }
        } else {
          print('Error fetching address: ${response.statusCode}');
          _removeOverlay();
        }
      }
    } catch (e) {
      print('Exception fetching address: $e');
      if (mounted) _removeOverlay();
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingAddressSuggestions = false;
        });
      }
    }
  }

  void _onAddressSearchChanged(String query) {
    if (_debounceAddressSearch?.isActive ?? false) _debounceAddressSearch!.cancel();
    _debounceAddressSearch = Timer(const Duration(milliseconds: 700), () {
      if (query.trim().isNotEmpty && _alamatController.text == query) {
        _fetchAddressSuggestions(query);
      } else if (query.trim().isEmpty) {
        _removeOverlay();
        if (mounted) setState(() => _addressSuggestions = []);
      }
    });
  }

  void _showOverlay() {
    _removeOverlay();
    assert(_overlayEntry == null);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 40,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0.0, 58.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 3,
                    )
                  ]),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _addressSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _addressSuggestions[index];
                  final displayName = suggestion['display_name'] ?? 'Alamat tidak tersedia';
                  return ListTile(
                    title: Text(displayName, style: GoogleFonts.poppins(fontSize: 13)),
                    dense: true,
                    onTap: () {
                      _alamatController.text = displayName;
                      _removeOverlay();
                      if (mounted) {
                        setState(() {
                          _addressSuggestions = [];
                        });
                      }
                      FocusScope.of(context).unfocus();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _openMapPicker() async {
    _removeOverlay();
    final selectedAddress = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );

    if (selectedAddress != null && selectedAddress.isNotEmpty) {
      if (mounted) {
        setState(() {
          _alamatController.text = selectedAddress;
          _addressSuggestions = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menentukan apakah field form bisa diedit berdasarkan status properti (_currentStatus) di form ini.
    // Jika _currentStatus adalah draft atau rejected (setelah revisi), maka field bisa diedit.
    // Jika _currentStatus adalah pendingVerification, approved, dll., maka field tidak bisa diedit.
    bool canEditFields = _currentStatus == PropertyStatus.draft || _currentStatus == PropertyStatus.rejected;

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
                PropertyImagePicker(
                  initialSelectedImages: _newlySelectedImages,
                  initialExistingImageUrls: _currentExistingImageUrls,
                  canEdit: canEditFields, // Kontrol editability PropertyImagePicker
                  onSelectedImagesChanged: (updatedSelectedImages) {
                    setState(() => _newlySelectedImages = updatedSelectedImages);
                  },
                  onExistingImageUrlsChanged: (updatedExistingUrls) {
                    setState(() => _currentExistingImageUrls = updatedExistingUrls);
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
                      onChanged: _onAddressSearchChanged,
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
                  onChanged: (String? newValue) { // Selalu berikan fungsi non-null
                    if (canEditFields && mounted) {
                      setState(() {
                        _tipePropertiValue = newValue;
                      });
                    }
                  },
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
                  onChanged: (dynamic? newValue) { // Selalu berikan fungsi non-null
                    if (canEditFields) {
                      setState(() => _kondisiFurnishingValue = newValue as int?);
                    }
                  },
                ),
                CustomDropdownMapField(
                  label: "Pemandangan Sekitar",
                  value: _pemandanganSekitarValue,
                  options: pemandanganSekitarOptions,
                  enabled: canEditFields,
                  onChanged: (dynamic? newValue) { // Selalu berikan fungsi non-null
                    if (canEditFields) {
                      setState(() => _pemandanganSekitarValue = newValue as int?);
                    }
                  },
                ),
                CustomDropdownMapField(
                  label: "Usia Properti",
                  value: _usiaPropertiValue,
                  options: usiaPropertiOptions,
                  enabled: canEditFields,
                  onChanged: (dynamic? newValue) { // Selalu berikan fungsi non-null
                    if (canEditFields) {
                      setState(() => _usiaPropertiValue = newValue as int?);
                    }
                  },
                ),
                CustomDropdownMapField(
                  label: "Label Properti / Tag",
                  value: _labelPropertiValue,
                  options: labelPropertiOptions,
                  enabled: canEditFields,
                  onChanged: (dynamic? newValue) { // Selalu berikan fungsi non-null
                    if (canEditFields) {
                      setState(() => _labelPropertiValue = newValue as int?);
                    }
                  },
                ),

                CustomTextFormField(
                  label: "Deskripsi Tambahan",
                  controller: _deskripsiController,
                  maxLines: 4,
                  enabled: canEditFields,
                  validator: null,
                ),

                const SizedBox(height: 10),
                if (canEditFields) // Tombol prediksi hanya muncul jika bisa diedit
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

                if (_hargaPrediksiIdrFormatted != null && _hargaPrediksiIdrFormatted!.isNotEmpty)
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
                          "Kurs AED ke IDR: ${_idrFormatter.format(_kursAedKeIdr)} (dapat berubah).",
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

                // Menampilkan status properti saat ini jika form TIDAK BOLEH DIEDIT
                // Ini akan menampilkan chip status seperti "Menunggu Verifikasi Admin"
                if (!canEditFields && !_isLoadingSubmit)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Center(
                      child: Chip(
                        label: Text(
                            _currentStatus == PropertyStatus.pendingVerification
                                ? "Status: Menunggu Verifikasi Admin"
                                : _currentStatus == PropertyStatus.approved
                                    ? "Status: Sudah Disetujui & Tayang"
                                    : "Status: ${_currentStatus.name.replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (Match m) => ' ${m[0]}').replaceFirstMapped(RegExp(r'^[a-z]'), (m) => m[0]!.toUpperCase())}",
                            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12)),
                        backgroundColor:
                            _currentStatus == PropertyStatus.pendingVerification
                                ? Colors.orangeAccent.shade700
                                : _currentStatus == PropertyStatus.approved
                                    ? Colors.green.shade600
                                    : Colors.grey[700], // Warna default jika status lain
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),

                // Tombol Aksi hanya akan ditampilkan jika canEditFields == true (status draft atau rejected)
                // Sesuai logika di dalam PropertyActionButtons, jika _currentStatus adalah pendingVerification,
                // tombol tidak akan muncul.
                PropertyActionButtons(
                    isLoading: _isLoadingSubmit,
                    currentStatus: _currentStatus,
                    onSubmit: _processPropertySubmission,
                    onEdit: () {
                      if (mounted) {
                        setState(() {
                          // Ini dipanggil ketika properti yang REJECTED ingin direvisi.
                          // Status form diubah menjadi DRAFT agar bisa diedit.
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
}
