// lib/widgets/custom_form_field.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. Custom TextFormField
class CustomTextFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType keyboardType;
  final bool enabled;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  const CustomTextFormField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.hint,
    this.validator,
    this.onChanged,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
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
              suffixIcon: suffixIcon,
            ),
            validator: validator ?? (value) {
              if (value == null || value.isEmpty) {
                return '$label tidak boleh kosong';
              }
              if (keyboardType == TextInputType.number || keyboardType == const TextInputType.numberWithOptions(decimal: true)) {
                if (num.tryParse(value) == null) {
                  return 'Masukkan angka yang valid untuk $label';
                }
              }
              return null;
            },
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// 2. Custom Dropdown untuk Opsi Map<String, dynamic>
class CustomDropdownMapField extends StatelessWidget {
  final String label;
  final dynamic value;
  final List<Map<String, dynamic>> options;
  final ValueChanged<dynamic> onChanged;
  final bool enabled;
  final String? hint;
  final FormFieldValidator<dynamic>? validator;


  const CustomDropdownMapField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.enabled = true,
    this.hint,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
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
              hintText: hint ?? 'Pilih $label',
              hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
            ),
            value: value,
            isExpanded: true,
            items: options.map((option) {
              return DropdownMenuItem<dynamic>(
                value: option['value'],
                child: Text(option['text'].toString(), style: GoogleFonts.poppins()),
              );
            }).toList(),
            onChanged: enabled ? onChanged : null,
            validator: validator ?? (value) => value == null ? '$label harus dipilih' : null,
          ),
        ],
      ),
    );
  }
}

// 3. Custom Dropdown untuk Opsi String
class CustomDropdownStringField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  final String? hint;
  final FormFieldValidator<String>? validator;

  const CustomDropdownStringField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.enabled = true,
    this.hint,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              filled: true,
              fillColor: enabled ? Colors.grey[100] : Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              hintText: hint ?? 'Pilih $label',
              hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
            ),
            value: value,
            isExpanded: true,
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option, style: GoogleFonts.poppins()),
              );
            }).toList(),
            onChanged: enabled ? onChanged : null,
            validator: validator ?? (value) {
              if (value == null || value.isEmpty) {
                return '$label harus dipilih';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

// 4. Custom Number Input dengan Tombol Kontrol +/-
class NumberInputWithControls extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final int minValue;
  final int maxValue;
  final bool enabled;

  const NumberInputWithControls({
    super.key,
    required this.label,
    required this.controller,
    this.minValue = 0,
    this.maxValue = 99,
    this.enabled = true,
  });

  @override
  State<NumberInputWithControls> createState() => _NumberInputWithControlsState();
}

class _NumberInputWithControlsState extends State<NumberInputWithControls> {
  @override
  void initState() {
    super.initState();
    if (widget.controller.text.isEmpty || int.tryParse(widget.controller.text) == null) {
      widget.controller.text = widget.minValue.toString();
    }
    // Listener untuk memastikan nilai selalu dalam rentang saat diedit manual
    widget.controller.addListener(_validateManualInput);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validateManualInput);
    super.dispose();
  }

  void _validateManualInput() {
    if (!widget.enabled) return;
    final text = widget.controller.text;
    if (text.isEmpty) return; // Biarkan kosong untuk validasi TextFormField

    final value = int.tryParse(text);
    if (value != null) {
      if (value < widget.minValue) {
        widget.controller.text = widget.minValue.toString();
        widget.controller.selection = TextSelection.fromPosition(TextPosition(offset: widget.controller.text.length));
      } else if (value > widget.maxValue) {
        widget.controller.text = widget.maxValue.toString();
        widget.controller.selection = TextSelection.fromPosition(TextPosition(offset: widget.controller.text.length));
      }
    }
  }


  void _increment() {
    if (!widget.enabled) return;
    int currentValue = int.tryParse(widget.controller.text) ?? widget.minValue;
    if (currentValue < widget.maxValue) {
      setState(() {
        currentValue++;
        widget.controller.text = currentValue.toString();
      });
    }
  }

  void _decrement() {
    if (!widget.enabled) return;
    int currentValue = int.tryParse(widget.controller.text) ?? widget.minValue;
    if (currentValue > widget.minValue) {
      setState(() {
        currentValue--;
        widget.controller.text = currentValue.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            height: 50, // Tinggi tetap untuk konsistensi
            decoration: BoxDecoration(
              color: widget.enabled ? Colors.grey[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              // border: Border.all( // Opsional: tambahkan border tipis jika suka
              //   color: widget.enabled ? Colors.grey[400]! : Colors.grey[300]!,
              //   width: 1.0,
              // ),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: widget.enabled ? _decrement : null,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0), // Padding untuk area tap
                    child: Icon(
                      Icons.remove,
                      size: 20, // Ukuran ikon disesuaikan
                      color: widget.enabled ? Theme.of(context).primaryColorDark : Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: widget.controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    enabled: widget.enabled,
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: widget.enabled ? Colors.black87 : Colors.grey[700]),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0), // Kurangi padding vertikal internal
                      fillColor: Colors.transparent, // Sudah diatur di container
                      filled: true,
                      counterText: "", // Menghilangkan counter default
                    ),
                    maxLength: 2, // Batasi input maksimal 2 digit (0-99)
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib';
                      }
                      final n = int.tryParse(value);
                      if (n == null) {
                        return '!Angka';
                      }
                      if (n < widget.minValue) {
                        return '<${widget.minValue}';
                      }
                      if (n > widget.maxValue) {
                        return '>${widget.maxValue}';
                      }
                      return null;
                    },
                  ),
                ),
                InkWell(
                  onTap: widget.enabled ? _increment : null,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0), // Padding untuk area tap
                    child: Icon(
                      Icons.add,
                      size: 20, // Ukuran ikon disesuaikan
                      color: widget.enabled ? Theme.of(context).primaryColorDark : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}