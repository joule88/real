import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PropertyFormFields extends StatelessWidget {
  final TextEditingController namaPropertiController;
  final TextEditingController alamatController;
  final TextEditingController kamarTidurController;
  final TextEditingController kamarMandiController;
  final TextEditingController luasPropertiController;
  final TextEditingController tipePropertiController;
  final TextEditingController perabotanController;
  final TextEditingController deskripsiController;
  final TextEditingController hargaManualController;
  final bool canEditFields;

  const PropertyFormFields({
    super.key,
    required this.namaPropertiController,
    required this.alamatController,
    required this.kamarTidurController,
    required this.kamarMandiController,
    required this.luasPropertiController,
    required this.tipePropertiController,
    required this.perabotanController,
    required this.deskripsiController,
    required this.hargaManualController,
    required this.canEditFields,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField("Nama Properti", controller: namaPropertiController, enabled: canEditFields),
        _buildTextField("Alamat Lengkap", controller: alamatController, maxLines: 2, enabled: canEditFields),
        _buildTextField("Kamar Tidur", controller: kamarTidurController, keyboardType: TextInputType.number, enabled: canEditFields),
        _buildTextField("Kamar Mandi", controller: kamarMandiController, keyboardType: TextInputType.number, enabled: canEditFields),
        _buildTextField("Luas Properti (sqft)", controller: luasPropertiController, keyboardType: TextInputType.number, enabled: canEditFields),
        _buildTextField("Tipe Properti", controller: tipePropertiController, enabled: canEditFields),
        _buildTextField("Kondisi Perabotan", controller: perabotanController, enabled: canEditFields),
        _buildTextField("Deskripsi Tambahan", controller: deskripsiController, maxLines: 4, enabled: canEditFields),
        _buildTextField("Harga (AED)", controller: hargaManualController, keyboardType: TextInputType.number, enabled: canEditFields),
      ],
    );
  }

  Widget _buildTextField(String label,
      {TextEditingController? controller,
      int maxLines = 1,
      TextInputType? keyboardType,
      bool enabled = true}) {
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
              hintText: 'Masukkan $label',
            ),
          ),
        ],
      ),
    );
  }
}