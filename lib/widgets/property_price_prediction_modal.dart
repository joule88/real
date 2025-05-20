import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showPredictionModal(BuildContext context, TextEditingController hargaManualController) {
  final kamarMandiCtrl = TextEditingController();
  final kamarTidurCtrl = TextEditingController();
  final luasPropertiCtrl = TextEditingController();
  final perabotanCtrl = TextEditingController();
  final hargaPrediksiCtrl = TextEditingController();

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
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                top: 20, left: 20, right: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
              ),
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
                  Text("Prediksi Harga", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Memperkirakan harga properti dengan cepat berdasarkan data yang Anda masukkan.",
                      style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 20),
                  // ...field prediksi...
                  ElevatedButton(
                    onPressed: () async {
                      await Future.delayed(const Duration(seconds: 1));
                      setModalState(() {
                        hargaPrediksiCtrl.text = "650000";
                      });
                    },
                    child: Text("Prediksi Harga"),
                  ),
                  if (hargaPrediksiCtrl.text.isNotEmpty)
                    Column(
                      children: [
                        Text("Harga Prediksi Properti"),
                        Text("AED ${hargaPrediksiCtrl.text}"),
                        TextButton(
                          onPressed: () {
                            hargaManualController.text = hargaPrediksiCtrl.text;
                            Navigator.pop(modalContext);
                          },
                          child: Text("Gunakan Harga Prediksi Ini"),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}