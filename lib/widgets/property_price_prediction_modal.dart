// lib/widgets/property_price_prediction_modal.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:real/provider/auth_provider.dart'; // Pastikan path ini benar
import 'package:real/services/property_service.dart'; // Pastikan path ini benar
import 'package:intl/intl.dart'; // Untuk formatting angka (IDR)

// Helper widget untuk Dropdown (tetap sama)
Widget _buildDropdownField({
  required BuildContext context,
  required String label,
  required dynamic value,
  required List<DropdownMenuItem<dynamic>> items,
  required ValueChanged<dynamic> onChanged,
  String? hint,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      DropdownButtonFormField<dynamic>(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          hintText: hint ?? 'Pilih $label',
        ),
        value: value,
        items: items,
        onChanged: onChanged,
        isExpanded: true,
        validator: (value) => value == null ? 'Field ini tidak boleh kosong' : null,
      ),
      const SizedBox(height: 15),
    ],
  );
}

// Helper widget untuk TextField Angka (tetap sama)
Widget _buildNumberField({
  required BuildContext context,
  required String label,
  required TextEditingController controller,
  String? hint,
  bool isDouble = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: isDouble),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          hintText: hint ?? 'Masukkan $label',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Field ini tidak boleh kosong';
          }
          if (isDouble) {
            if (double.tryParse(value) == null) return 'Masukkan angka desimal yang valid';
          } else {
            if (int.tryParse(value) == null) return 'Masukkan angka bulat yang valid';
          }
          return null;
        },
      ),
      const SizedBox(height: 15),
    ],
  );
}


void showPredictionModal(BuildContext context, TextEditingController hargaManualController) {
  final _formKey = GlobalKey<FormState>();
  final PropertyService propertyService = PropertyService();

  final kamarMandiCtrl = TextEditingController();
  final kamarTidurCtrl = TextEditingController();
  final ukuranPropertiSqftCtrl = TextEditingController();
  final hargaPrediksiAedCtrl = TextEditingController(); // Ganti nama untuk kejelasan
  final hargaPrediksiIdrCtrl = TextEditingController(); // Controller untuk harga IDR

  // --- Variabel Terverifikasi tidak lagi diisi user dari modal ---
  // int? terverifikasiValue;
  final int defaultVerifiedStatusForPrediction = 0; // Asumsi 0 = Tidak Terverifikasi

  int? kondisiFurnishingValue;
  int? pemandanganUtamaValue;
  int? kategoriUsiaListingValue;
  int? labelPropertiValue;

  bool _isPredicting = false;
  final double kursAedKeIdr = 4350; // GANTI DENGAN NILAI TUKAR AKTUAL ATAU MEKANISME DINAMIS

  // Opsi dropdowns (Kecuali 'Terverifikasi')
  final List<Map<String, dynamic>> kondisiFurnishingOptions = [
    {'text': 'Unfurnished', 'value': 0},
    {'text': 'Furnished', 'value': 1},
  ];

  final List<Map<String, dynamic>> pemandanganUtamaOptions = [
    {'text': 'Lainnya / Tidak Ada', 'value': 0},
    {'text': 'Sea View', 'value': 1},
    {'text': 'Burj Khalifa View', 'value': 2},
    {'text': 'Golf Course View', 'value': 3},
    {'text': 'Community View', 'value': 4},
    {'text': 'City View', 'value': 5},
    {'text': 'Lake View', 'value': 6},
    {'text': 'Pool View', 'value': 7},
    {'text': 'Canal View', 'value': 8},
  ];

  final List<Map<String, dynamic>> kategoriUsiaListingOptions = [
    {'text': 'Baru (Kurang dari 3 bulan)', 'value': 0},
    {'text': 'Cukup Lama (3-6 bulan)', 'value': 1},
    {'text': 'Lama (Lebih dari 6 bulan)', 'value': 2},
  ];

  final List<Map<String, dynamic>> labelPropertiOptions = [
    {'text': 'Tidak Ada Keyword Spesifik', 'value': 0},
    {'text': 'Luxury', 'value': 1},
    {'text': 'Furnished', 'value': 2},
    {'text': 'Spacious', 'value': 3},
    {'text': 'Prime', 'value': 4},
    {'text': 'Studio', 'value': 5},
    {'text': 'Penthouse', 'value': 6},
    {'text': 'Investment', 'value': 7},
    {'text': 'Villa', 'value': 8},
    {'text': 'Downtown', 'value': 9},
  ];

  // Formatter untuk IDR
  final idrFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);


  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Colors.white,
    builder: (BuildContext modalContext) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              top: 20, left: 20, right: 20,
              bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text("Prediksi Harga Properti (Dubai)", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      "Masukkan detail properti untuk mendapatkan estimasi harga pasar.",
                      style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13)
                    ),
                    const SizedBox(height: 25),

                    _buildNumberField(context: context, label: "Jumlah Kamar Mandi", controller: kamarMandiCtrl, hint: "Contoh: 2"),
                    _buildNumberField(context: context, label: "Jumlah Kamar Tidur", controller: kamarTidurCtrl, hint: "Contoh: 3"),
                    _buildDropdownField(
                      context: context,
                      label: "Kondisi Furnishing",
                      value: kondisiFurnishingValue,
                      items: kondisiFurnishingOptions.map((item) => DropdownMenuItem(value: item['value'], child: Text(item['text']))).toList(),
                      onChanged: (value) => setModalState(() => kondisiFurnishingValue = value),
                    ),
                    _buildNumberField(
                        context: context,
                        label: "Ukuran Properti (sqft)",
                        controller: ukuranPropertiSqftCtrl,
                        hint: "Contoh: 1200",
                        isDouble: true
                    ),
                    // --- Dropdown "Terverifikasi" DIHILANGKAN dari tampilan modal ---
                    _buildDropdownField(
                      context: context,
                      label: "Kategori Usia Listing",
                      value: kategoriUsiaListingValue,
                      items: kategoriUsiaListingOptions.map((item) => DropdownMenuItem(value: item['value'], child: Text(item['text']))).toList(),
                      onChanged: (value) => setModalState(() => kategoriUsiaListingValue = value),
                    ),
                    _buildDropdownField(
                      context: context,
                      label: "Pemandangan Utama",
                      value: pemandanganUtamaValue,
                      items: pemandanganUtamaOptions.map((item) => DropdownMenuItem(value: item['value'], child: Text(item['text']))).toList(),
                      onChanged: (value) => setModalState(() => pemandanganUtamaValue = value),
                    ),
                    _buildDropdownField(
                      context: context,
                      label: "Label Properti / Tag",
                      value: labelPropertiValue,
                      items: labelPropertiOptions.map((item) => DropdownMenuItem(value: item['value'], child: Text(item['text']))).toList(),
                      onChanged: (value) => setModalState(() => labelPropertiValue = value),
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _isPredicting
                            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87))
                            : Icon(Icons.online_prediction_outlined, color: Colors.black87),
                        label: Text("Prediksi Harga", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 15)),
                        onPressed: _isPredicting ? null : () async {
                          if (_formKey.currentState!.validate()) {
                            setModalState(() {
                              _isPredicting = true;
                              hargaPrediksiAedCtrl.clear();
                              hargaPrediksiIdrCtrl.clear();
                            });

                            final result = await propertyService.predictPropertyPrice(
                              bathrooms: int.parse(kamarMandiCtrl.text),
                              bedrooms: int.parse(kamarTidurCtrl.text),
                              furnishing: kondisiFurnishingValue!,
                              sizeMin: double.parse(ukuranPropertiSqftCtrl.text),
                              verified: defaultVerifiedStatusForPrediction, // --- Mengirim default value ---
                              listingAgeCategory: kategoriUsiaListingValue!,
                              viewType: pemandanganUtamaValue!,
                              titleKeyword: labelPropertiValue!,
                            );

                            setModalState(() => _isPredicting = false);

                            if (result['success'] == true && result['predicted_price'] != null) {
                              final predictedPriceAed = result['predicted_price'];
                              final predictedPriceIdr = predictedPriceAed * kursAedKeIdr;

                              setModalState(() {
                                hargaPrediksiAedCtrl.text = predictedPriceAed.toStringAsFixed(0);
                                hargaPrediksiIdrCtrl.text = idrFormatter.format(predictedPriceIdr);
                              });
                              ScaffoldMessenger.of(modalContext).showSnackBar(
                                SnackBar(content: Text('Prediksi harga berhasil: AED ${hargaPrediksiAedCtrl.text}'), backgroundColor: Colors.green),
                              );
                            } else {
                              ScaffoldMessenger.of(modalContext).showSnackBar(
                                SnackBar(content: Text(result['message'] ?? 'Gagal mendapatkan prediksi harga.'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDAF365),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                    const SizedBox(height: 15),

                    if (hargaPrediksiAedCtrl.text.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.shade200)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Estimasi Harga Properti:",
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green[800])
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "AED ${hargaPrediksiAedCtrl.text}",
                              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[700]),
                            ),
                            const SizedBox(height: 5),
                            // --- TAMPILAN KONVERSI IDR ---
                            Text(
                              "(Estimasi: ${hargaPrediksiIdrCtrl.text})",
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.green[600]),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () {
                                  hargaManualController.text = hargaPrediksiAedCtrl.text; // Tetap isi dengan AED
                                  Navigator.pop(modalContext);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Harga prediksi (AED) telah dimasukkan ke form."), backgroundColor: Colors.blue),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.green[600],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                                ),
                                child: Text("Gunakan Harga Prediksi Ini (AED)", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}