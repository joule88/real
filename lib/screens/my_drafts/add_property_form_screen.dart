// lib/screens/my_drafts/add_property_form_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:real/models/property.dart';
import 'package:real/widgets/property_image_picker.dart';
import 'package:real/services/property_service.dart';
import 'package:provider/provider.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:real/widgets/property_action_buttons.dart';
import 'map_picker_screen.dart';
import 'package:real/widgets/custom_form_field.dart';

class AddPropertyFormScreen extends StatefulWidget {
  final Property? propertyToEdit;

  const AddPropertyFormScreen({
    super.key,
    this.propertyToEdit,
  });

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

  static const Color colorNavbarBg = Color(0xFF182420);
  static const Color colorLemonGreen = Color(0xFFDDEF6D);

  final List<String> _tipePropertiOptions = [
    'House', 'Apartment', 'Villa', 'Shop', 'Land', 'Warehouse', 'Office', 'Other'
  ];

  final List<Map<String, dynamic>> kondisiFurnishingOptions = [
    {'text': 'NO', 'value': 1},
    {'text': 'PARTLY', 'value': 2},
    {'text': 'YES', 'value': 0},
  ];

  final List<Map<String, dynamic>> pemandanganSekitarOptions = [
    {'text': 'Other / Not Specific', 'value': 0},
    {'text': 'Sea View', 'value': 1},
    {'text': 'Burj Khalifa View', 'value': 2},
    {'text': 'Golf View', 'value': 3},
    {'text': 'Community View', 'value': 4},
    {'text': 'City View', 'value': 5},
    {'text': 'Lake View', 'value': 6},
    {'text': 'Pool View', 'value': 7},
    {'text': 'River View', 'value': 8},
  ];

  final List<Map<String, dynamic>> usiaPropertiOptions = [
    {'text': 'Less than 3 months', 'value': 0},
    {'text': '3-6 Months', 'value': 1},
    {'text': 'More than 6 Months', 'value': 2},
  ];

  final List<Map<String, dynamic>> labelPropertiOptions = [
    {'text': 'No Specific Keyword', 'value': 0},{'text': 'Luxury', 'value': 1},
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
      // PERUBAHAN LOGIKA STATUS: Saat mengedit, selalu anggap sebagai 'draft'
      // agar semua field bisa diubah dan tombol aksi yang relevan muncul.
      _currentStatus = PropertyStatus.draft;

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
  
  void _onAddressSearchChanged(String query) {
    if (_debounceAddressSearch?.isActive ?? false) _debounceAddressSearch!.cancel();
    _debounceAddressSearch = Timer(const Duration(milliseconds: 700), () {
      if (query.trim().isNotEmpty && _alamatController.text == query) {
        print("Address searched: $query"); 
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
         const SnackBar(content: Text('Please complete the required fields for prediction.'), backgroundColor: Colors.orange)
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
              const SnackBar(content: Text('Ensure all fields (beds, baths, size, furnishing, age, view, label) are filled correctly for prediction.'), backgroundColor: Colors.orange),
            );
          }
          if(mounted) setState(() => _isPredictingPrice = false);
          return;
        }
        
        const defaultVerifiedStatusForPrediction = 0;

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
            SnackBar(content: Text('Predicted price AED ${predictedPriceAed.toStringAsFixed(0)} has been filled.'), backgroundColor: Colors.green),
          );
        } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'] ?? 'Failed to get price prediction.'), backgroundColor: Colors.red),
            );
           setState(() {
             _hargaPrediksiIdrFormatted = null;
          });
        }
      } catch (e) {
         if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Prediction Error: Make sure all prediction fields are filled. Error: $e'), backgroundColor: Colors.red),
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
          const SnackBar(content: Text('Please complete all required fields correctly.'), backgroundColor: Colors.orange),
        );
      }
      return;
    }
    bool isImageRequiredAndMissing = (!_isEditMode && _newlySelectedImages.isEmpty) ||
                                  (_isEditMode && _currentExistingImageUrls.isEmpty && _newlySelectedImages.isEmpty);

    if (isImageRequiredAndMissing && targetStatus != PropertyStatus.sold && targetStatus != PropertyStatus.archived) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload at least 1 property photo.')),
        );
      }
      return;
    }

    if(mounted) setState(() => _isLoadingSubmit = true);

    // Gunakan ID yang ada jika sedang mengedit, jika tidak (mode tambah baru), backend akan meng-generate ID.
    // Mengirim ID null atau kosong ke backend untuk operasi 'create'.
    String? propertyIdForSubmission = _isEditMode ? widget.propertyToEdit!.id : null;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId == null || (authProvider.token?.isEmpty ?? true)) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid session. Please log in again.')),
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
      id: propertyIdForSubmission ?? '', // Kirim string kosong jika null
      title: _namaPropertiController.text,
      description: _deskripsiController.text,
      uploader: userId,
      uploaderInfo: authProvider.user,
      imageUrl: widget.propertyToEdit?.imageUrl ?? '', 
      additionalImageUrls: widget.propertyToEdit?.additionalImageUrls ?? [], 
      price: double.tryParse(_hargaManualAedController.text) ?? widget.propertyToEdit?.price ?? 0.0,
      address: _alamatController.text,
      bedrooms: int.tryParse(_kamarTidurController.text) ?? widget.propertyToEdit?.bedrooms ?? 0,
      bathrooms: int.tryParse(_kamarMandiController.text) ?? widget.propertyToEdit?.bathrooms ?? 0,
      areaSqft: double.tryParse(_luasPropertiSqftController.text) ?? widget.propertyToEdit?.areaSqft ?? 0.0,
      propertyType: _tipePropertiValue ?? widget.propertyToEdit?.propertyType ?? '',
      furnishings: furnishingText,
      status: targetStatus,
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
      rejectionReason: targetStatus == PropertyStatus.rejected ? widget.propertyToEdit?.rejectionReason : null,
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
        String successMessage = "Property successfully processed with status: ${targetStatus.name}";
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'An error occurred while submitting the property.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // PERUBAHAN LOGIKA UTAMA: Semua field bisa diedit kecuali untuk status 'sold' atau 'pendingVerification'.
    bool canEditFields = _currentStatus != PropertyStatus.sold && 
                         _currentStatus != PropertyStatus.pendingVerification;
    
    // Jika kita sedang dalam mode edit, kita set 'canEditFields' menjadi true,
    // kecuali properti yang diedit sudah sold atau pending.
    if (_isEditMode) {
      PropertyStatus originalStatus = widget.propertyToEdit!.status;
      canEditFields = originalStatus != PropertyStatus.sold && 
                      originalStatus != PropertyStatus.pendingVerification;
    }

    final Color statusChipTextColor;
    if (_currentStatus == PropertyStatus.pendingVerification) {
      statusChipTextColor = colorNavbarBg;
    } else if (_currentStatus == PropertyStatus.sold) {
      statusChipTextColor = colorLemonGreen;
    } else {
      statusChipTextColor = Colors.white;
    }

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
          _isEditMode ? (_currentStatus == PropertyStatus.sold ? "Sold Property Details" : "Edit Property") : "Add New Property",
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
                  canEdit: canEditFields,
                  onSelectedImagesChanged: (updatedSelectedImages) {
                    if(canEditFields) setState(() => _newlySelectedImages = updatedSelectedImages);
                  },
                  onExistingImageUrlsChanged: (updatedExistingUrls) {
                     if(canEditFields) setState(() => _currentExistingImageUrls = updatedExistingUrls);
                  },
                ),
                const SizedBox(height: 20),

                CustomTextFormField(
                  label: "Property Name",
                  controller: _namaPropertiController,
                  enabled: canEditFields,
                ),
                CompositedTransformTarget(
                  link: _layerLink,
                  child: CustomTextFormField(
                      label: "Full Address",
                      controller: _alamatController,
                      maxLines: 3,
                      enabled: canEditFields,
                      onChanged: canEditFields ? _onAddressSearchChanged : null,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.map_outlined, color: Theme.of(context).primaryColor),
                        onPressed: canEditFields ? _openMapPicker : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Address cannot be empty';
                        return null;
                      }),
                ),

                CustomDropdownStringField(
                  label: "Property Type",
                  value: _tipePropertiValue,
                  options: _tipePropertiOptions,
                  onChanged: canEditFields ? (String? newValue) { 
                    if (mounted) {
                      setState(() {
                        _tipePropertiValue = newValue;
                      });
                    }
                  } : null,
                  hint: "Select Property Type",
                  enabled: canEditFields,
                ),

                Row(
                  children: [
                    Expanded(
                      child: NumberInputWithControls(
                        label: "Bedrooms",
                        controller: _kamarTidurController,
                        enabled: canEditFields,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: NumberInputWithControls(
                        label: "Bathrooms",
                        controller: _kamarMandiController,
                        enabled: canEditFields,
                      ),
                    ),
                  ],
                ),
                CustomTextFormField(
                    label: "Property Size (sqft)",
                    controller: _luasPropertiSqftController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    enabled: canEditFields,
                    hint: "Example: 1200.50"),

                CustomDropdownMapField(
                  label: "Furnishing Condition",
                  value: _kondisiFurnishingValue,
                  options: kondisiFurnishingOptions,
                  enabled: canEditFields,
                  onChanged: canEditFields ? (dynamic newValue) { 
                    if(mounted) setState(() => _kondisiFurnishingValue = newValue as int?);
                  } : null,
                ),
                CustomDropdownMapField(
                  label: "Main View",
                  value: _pemandanganSekitarValue,
                  options: pemandanganSekitarOptions,
                  enabled: canEditFields,
                  onChanged: canEditFields ? (dynamic newValue) { 
                     if(mounted) setState(() => _pemandanganSekitarValue = newValue as int?);
                  } : null,
                ),
                CustomDropdownMapField(
                  label: "Listing Age",
                  value: _usiaPropertiValue,
                  options: usiaPropertiOptions,
                  enabled: canEditFields,
                  onChanged: canEditFields ? (dynamic newValue) { 
                     if(mounted) setState(() => _usiaPropertiValue = newValue as int?);
                  } : null,
                ),
                CustomDropdownMapField(
                  label: "Property Label / Tag",
                  value: _labelPropertiValue,
                  options: labelPropertiOptions,
                  enabled: canEditFields,
                  onChanged: canEditFields ? (dynamic newValue) { 
                     if(mounted) setState(() => _labelPropertiValue = newValue as int?);
                  } : null,
                ),

                CustomTextFormField(
                  label: "Additional Description",
                  controller: _deskripsiController,
                  maxLines: 4,
                  enabled: canEditFields,
                  validator: null,
                ),

                const SizedBox(height: 10),
                if (canEditFields)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: _isPredictingPrice
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87))
                          : const Icon(Icons.online_prediction_outlined, color: Colors.black87),
                      label: Text("Predict & Fill Price", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 15)),
                      onPressed: _isPredictingPrice ? null : _predictAndSetPrice,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDAF365),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                const SizedBox(height: 10),

                CustomTextFormField(
                    label: "Price (AED)",
                    controller: _hargaManualAedController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    enabled: canEditFields,
                    hint: "Price in AED"),

                if (_hargaPrediksiIdrFormatted != null && _hargaPrediksiIdrFormatted!.isNotEmpty && canEditFields)
                  Padding(
                     padding: const EdgeInsets.only(left: 4.0, right: 4.0, bottom: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Estimate: $_hargaPrediksiIdrFormatted",
                          style: GoogleFonts.poppins(color: Colors.green[700], fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Exchange rate 1 AED to IDR: ${_idrFormatter.format(_kursAedKeIdr)} (subject to change).",
                          style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                         const SizedBox(height: 2),
                        Text(
                          "Prediction can make mistakes. Please double-check the price.",
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                
                // Menampilkan status asli jika ada (hanya untuk info)
                if (_isEditMode && !canEditFields)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Center(
                      child: Chip(
                        label: Text(
                            "Current Status: ${widget.propertyToEdit!.status.name.replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (Match m) => ' ${m[0]}').replaceFirstMapped(RegExp(r'^[a-z]'), (m) => m[0]!.toUpperCase())}",
                            style: GoogleFonts.poppins(color: statusChipTextColor, fontWeight: FontWeight.w600, fontSize: 12)),
                        backgroundColor: _getStatusColorForChip(widget.propertyToEdit!.status),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),

                // Selalu tampilkan tombol aksi jika `canEditFields` true
                if (canEditFields)
                  PropertyActionButtons(
                      isLoading: _isLoadingSubmit,
                      currentStatus: _currentStatus, 
                      onSubmit: _processPropertySubmission,
                      onEdit: () { 
                        if (mounted) {
                          setState(() {
                            // Ini sudah default, tapi untuk kejelasan
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

  // ==========================================================
  //         PERUBAHAN LOGIKA WARNA DIMULAI DI SINI
  // ==========================================================
  Color _getStatusColorForChip(PropertyStatus status) {
    // Logika ini disalin dari my_drafts_screen.dart untuk memastikan konsistensi
    switch (status) {
      case PropertyStatus.draft:
        return Colors.blueGrey[600]!;
      case PropertyStatus.pendingVerification:
        return colorLemonGreen;
      case PropertyStatus.approved:
        return Colors.green[600]!;
      case PropertyStatus.rejected:
        return Colors.red[700]!;
      case PropertyStatus.archived:
        return Colors.grey[700]!;
      case PropertyStatus.sold:
        return colorNavbarBg;
      default:
        return Colors.grey;
    }
  }
  // ==========================================================
  //          PERUBAHAN LOGIKA WARNA SELESAI DI SINI
  // ==========================================================
}