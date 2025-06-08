// lib/widgets/filter_modal_content.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real/widgets/custom_form_field.dart';

typedef OnApplyFilters = void Function(Map<String, dynamic> appliedFilters);
typedef OnResetFilters = void Function();

class FilterModalContent extends StatefulWidget {
  final Map<String, dynamic> initialFilters;
  final OnApplyFilters onApplyFilters;
  final OnResetFilters onResetFilters;

  // ENGLISH TRANSLATION: Options translated to English
  final List<String> propertyTypeOptions = const [
    'House', 'Apartment', 'Villa', 'Shop', 'Land', 'Warehouse', 'Office', 'Other'
  ];
  final List<String> furnishingOptions = const ['YES', 'NO', 'PARTLY'];
  final List<String> pemandanganUtamaOptions = const [
    'Sea View', 'Burj Khalifa View', 'Golf View',
    'Community View', 'City View', 'Lake View',
    'Pool View', 'River View', 'Other / Not Specific',
  ];
  final List<String> usiaPropertiOptions = const [
    'Less than 3 months', '3-6 Months', 'More than 6 Months',
  ];
  final List<String> labelPropertiOptions = const [
    'Luxury', 'Furnished', 'Spacious', 'Prime Location', 'Studio',
    'Penthouse', 'Investment', 'Villa', 'Downtown', 'No Specific Keyword',
  ];


  const FilterModalContent({
    super.key,
    required this.initialFilters,
    required this.onApplyFilters,
    required this.onResetFilters,
  });

  @override
  State<FilterModalContent> createState() => _FilterModalContentState();
}

class _FilterModalContentState extends State<FilterModalContent> {
  late String? _modalFilterPropertyType;
  late TextEditingController _modalFilterMinPriceController;
  late TextEditingController _modalFilterMaxPriceController;
  late TextEditingController _modalFilterMinBedroomsController;
  late TextEditingController _modalFilterMaxBedroomsController;
  late TextEditingController _modalFilterMinBathroomsController;
  late TextEditingController _modalFilterMaxBathroomsController;
  late String? _modalFilterFurnishing;
  late TextEditingController _modalFilterMinAreaController;
  late TextEditingController _modalFilterLokasiController;
  late String? _modalFilterPemandanganUtama;
  late String? _modalFilterUsiaProperti;
  late String? _modalFilterLabelProperti;

  @override
  void initState() {
    super.initState();
    _modalFilterPropertyType = widget.initialFilters['propertyType'] as String?;
    _modalFilterMinPriceController = TextEditingController(text: widget.initialFilters['minPrice']?.toString() ?? '');
    _modalFilterMaxPriceController = TextEditingController(text: widget.initialFilters['maxPrice']?.toString() ?? '');
    _modalFilterMinBedroomsController = TextEditingController(text: widget.initialFilters['minBedrooms']?.toString() ?? '0');
    _modalFilterMaxBedroomsController = TextEditingController(text: widget.initialFilters['maxBedrooms']?.toString() ?? '0');
    _modalFilterMinBathroomsController = TextEditingController(text: widget.initialFilters['minBathrooms']?.toString() ?? '0');
    _modalFilterMaxBathroomsController = TextEditingController(text: widget.initialFilters['maxBathrooms']?.toString() ?? '0');
    _modalFilterFurnishing = widget.initialFilters['furnishing'] as String?;
    _modalFilterMinAreaController = TextEditingController(text: widget.initialFilters['minArea']?.toString() ?? '');
    _modalFilterLokasiController = TextEditingController(text: widget.initialFilters['lokasi'] as String? ?? '');
    _modalFilterPemandanganUtama = widget.initialFilters['mainView'] as String?;
    _modalFilterUsiaProperti = widget.initialFilters['listingAgeCategory'] as String?;
    _modalFilterLabelProperti = widget.initialFilters['propertyLabel'] as String?;
  }

  @override
  void dispose() {
    _modalFilterMinPriceController.dispose();
    _modalFilterMaxPriceController.dispose();
    _modalFilterMinBedroomsController.dispose();
    _modalFilterMaxBedroomsController.dispose();
    _modalFilterMinBathroomsController.dispose();
    _modalFilterMaxBathroomsController.dispose();
    _modalFilterMinAreaController.dispose();
    _modalFilterLokasiController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final Map<String, dynamic> newFilters = {};
    if (_modalFilterPropertyType != null) newFilters['propertyType'] = _modalFilterPropertyType;
    if (_modalFilterLokasiController.text.trim().isNotEmpty) newFilters['lokasi'] = _modalFilterLokasiController.text.trim();
    if (_modalFilterMinPriceController.text.isNotEmpty) newFilters['minPrice'] = double.tryParse(_modalFilterMinPriceController.text);
    if (_modalFilterMaxPriceController.text.isNotEmpty) newFilters['maxPrice'] = double.tryParse(_modalFilterMaxPriceController.text);
    if (_modalFilterMinBedroomsController.text.isNotEmpty && int.tryParse(_modalFilterMinBedroomsController.text)! >= 0) newFilters['minBedrooms'] = int.tryParse(_modalFilterMinBedroomsController.text);
    if (_modalFilterMaxBedroomsController.text.isNotEmpty && int.tryParse(_modalFilterMaxBedroomsController.text)! >= 0) newFilters['maxBedrooms'] = int.tryParse(_modalFilterMaxBedroomsController.text);
    if (_modalFilterMinBathroomsController.text.isNotEmpty && int.tryParse(_modalFilterMinBathroomsController.text)! >= 0) newFilters['minBathrooms'] = int.tryParse(_modalFilterMinBathroomsController.text);
    if (_modalFilterMaxBathroomsController.text.isNotEmpty && int.tryParse(_modalFilterMaxBathroomsController.text)! >= 0) newFilters['maxBathrooms'] = int.tryParse(_modalFilterMaxBathroomsController.text);
    if (_modalFilterFurnishing != null) newFilters['furnishing'] = _modalFilterFurnishing;
    if (_modalFilterMinAreaController.text.isNotEmpty) newFilters['minArea'] = double.tryParse(_modalFilterMinAreaController.text);
    if (_modalFilterPemandanganUtama != null) newFilters['mainView'] = _modalFilterPemandanganUtama;
    if (_modalFilterUsiaProperti != null) newFilters['listingAgeCategory'] = _modalFilterUsiaProperti;
    if (_modalFilterLabelProperti != null) newFilters['propertyLabel'] = _modalFilterLabelProperti;
    
    newFilters.removeWhere((key, value) => value == null || (value is String && value.isEmpty) || ((key.contains('Bedrooms') || key.contains('Bathrooms')) && (value is num && value == 0)));
    
    widget.onApplyFilters(newFilters);
    Navigator.pop(context);
  }

  void _resetInternalFiltersAndCallback() {
    setState(() {
      _modalFilterPropertyType = null;
      _modalFilterLokasiController.clear();
      _modalFilterMinPriceController.clear();
      _modalFilterMaxPriceController.clear();
      _modalFilterMinBedroomsController.text = '0';
      _modalFilterMaxBedroomsController.text = '0';
      _modalFilterMinBathroomsController.text = '0';
      _modalFilterMaxBathroomsController.text = '0';
      _modalFilterFurnishing = null;
      _modalFilterMinAreaController.clear();
      _modalFilterPemandanganUtama = null;
      _modalFilterUsiaProperti = null;
      _modalFilterLabelProperti = null;
    });
    widget.onResetFilters();
    Navigator.pop(context);
  }

  Widget _buildStyledDropdown<T>({
    required String label,
    required T? currentValue,
    required String hintText,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonFormField<T>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                hintText: hintText,
                hintStyle: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 15),
              ),
              style: GoogleFonts.poppins(color: Colors.black87, fontSize: 15),
              value: currentValue,
              isExpanded: true,
              items: items,
              onChanged: onChanged,
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color navbarBgColor = Color(0xFF182420);
    const Color lemonGreenColor = Color(0xFFDDEF6D);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20, left: 20, right: 20
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 15),
            Text(
              // ENGLISH TRANSLATION
              widget.initialFilters.containsKey('_title') ? widget.initialFilters['_title'] as String : "Filter Properties",
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
            ),
            const SizedBox(height: 20),

            // ENGLISH TRANSLATION for labels and hints
            _buildStyledDropdown<String?>(
              label: "Property Type", currentValue: _modalFilterPropertyType, hintText: "All Types",
              items: [ const DropdownMenuItem<String?>(value: null, child: Text("All Types")), ...widget.propertyTypeOptions.map((opt) => DropdownMenuItem<String?>(value: opt, child: Text(opt)))].toList(),
              onChanged: (val) => setState(() => _modalFilterPropertyType = val),
            ),
            CustomTextFormField(label: "Location", controller: _modalFilterLokasiController, hint: "Enter Location", validator: null),
            Row(children: [
              Expanded(child: CustomTextFormField(label: "Min Price (AED)", controller: _modalFilterMinPriceController, keyboardType: TextInputType.number, validator: null)),
              const SizedBox(width: 10),
              Expanded(child: CustomTextFormField(label: "Max Price (AED)", controller: _modalFilterMaxPriceController, keyboardType: TextInputType.number, validator: null)),
            ]),
            Row(children: [
              Expanded(child: NumberInputWithControls(label: "Min Bedrooms", controller: _modalFilterMinBedroomsController, minValue: 0, maxValue: 20)),
              const SizedBox(width: 10),
              Expanded(child: NumberInputWithControls(label: "Max Bedrooms", controller: _modalFilterMaxBedroomsController, minValue: 0, maxValue: 20)),
            ]),
            Row(children: [
              Expanded(child: NumberInputWithControls(label: "Min Bathrooms", controller: _modalFilterMinBathroomsController, minValue: 0, maxValue: 20)),
              const SizedBox(width: 10),
              Expanded(child: NumberInputWithControls(label: "Max Bathrooms", controller: _modalFilterMaxBathroomsController, minValue: 0, maxValue: 20)),
            ]),
            _buildStyledDropdown<String?>(
              label: "Furnishing Condition", currentValue: _modalFilterFurnishing, hintText: "All Conditions",
              items: [const DropdownMenuItem<String?>(value: null, child: Text("All Conditions")), ...widget.furnishingOptions.map((opt) => DropdownMenuItem<String?>(value: opt, child: Text(opt)))].toList(),
              onChanged: (val) => setState(() => _modalFilterFurnishing = val),
            ),
            CustomTextFormField(label: "Minimum Area (sqft)", controller: _modalFilterMinAreaController, keyboardType: TextInputType.number, validator: null),
            _buildStyledDropdown<String?>(
              label: "Main View", currentValue: _modalFilterPemandanganUtama, hintText: "All Views",
              items: [const DropdownMenuItem<String?>(value: null, child: Text("All Views")), ...widget.pemandanganUtamaOptions.map((opt) => DropdownMenuItem<String?>(value: opt, child: Text(opt)))].toList(),
              onChanged: (val) => setState(() => _modalFilterPemandanganUtama = val),
            ),
            _buildStyledDropdown<String?>(
              label: "Property Listing Age", currentValue: _modalFilterUsiaProperti, hintText: "All Ages",
              items: [const DropdownMenuItem<String?>(value: null, child: Text("All Ages")), ...widget.usiaPropertiOptions.map((opt) => DropdownMenuItem<String?>(value: opt, child: Text(opt)))].toList(),
              onChanged: (val) => setState(() => _modalFilterUsiaProperti = val),
            ),
            _buildStyledDropdown<String?>(
              label: "Property Label (Tag)", currentValue: _modalFilterLabelProperti, hintText: "All Labels",
              items: [const DropdownMenuItem<String?>(value: null, child: Text("All Labels")), ...widget.labelPropertiOptions.map((opt) => DropdownMenuItem<String?>(value: opt, child: Text(opt)))].toList(),
              onChanged: (val) => setState(() => _modalFilterLabelProperti = val),
            ),
            
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  // ENGLISH TRANSLATION
                  onPressed: _resetInternalFiltersAndCallback,
                  // ENGLISH TRANSLATION
                  child: Text("Reset Filters", style: GoogleFonts.poppins(color: Colors.grey[700], fontWeight: FontWeight.w500)),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline, color: lemonGreenColor),
                  // ENGLISH TRANSLATION
                  label: Text("Apply", style: GoogleFonts.poppins(color: lemonGreenColor, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navbarBgColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  onPressed: _applyFilters,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}