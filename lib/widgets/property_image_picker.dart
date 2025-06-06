// lib/widgets/property_image_picker.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PropertyImagePicker extends StatefulWidget {
  final List<XFile> initialSelectedImages;
  final List<String> initialExistingImageUrls;
  final bool canEdit;
  final Function(List<XFile> updatedSelectedImages) onSelectedImagesChanged;
  final Function(List<String> updatedExistingImageUrls) onExistingImageUrlsChanged;
  final int maxImages;

  const PropertyImagePicker({
    super.key,
    this.initialSelectedImages = const [],
    this.initialExistingImageUrls = const [],
    required this.canEdit,
    required this.onSelectedImagesChanged,
    required this.onExistingImageUrlsChanged,
    this.maxImages = 5,
  });

  @override
  _PropertyImagePickerState createState() => _PropertyImagePickerState();
}

class _PropertyImagePickerState extends State<PropertyImagePicker> {
  late List<XFile> _selectedImages;
  late List<String> _existingImageUrls;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedImages = List.from(widget.initialSelectedImages);
    _existingImageUrls = List.from(widget.initialExistingImageUrls);
  }

  @override
  void didUpdateWidget(covariant PropertyImagePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelectedImages != oldWidget.initialSelectedImages) {
      _selectedImages = List.from(widget.initialSelectedImages);
    }
    if (widget.initialExistingImageUrls != oldWidget.initialExistingImageUrls) {
      _existingImageUrls = List.from(widget.initialExistingImageUrls);
    }
  }

  Future<void> _pickImages() async {
    if (!widget.canEdit) return;
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(imageQuality: 80);
      if (pickedFiles.isNotEmpty) {
        setState(() {
          int currentTotalAfterPick = _existingImageUrls.length + _selectedImages.length + pickedFiles.length;
          if (currentTotalAfterPick <= widget.maxImages) {
            _selectedImages.addAll(pickedFiles);
            widget.onSelectedImagesChanged(List.from(_selectedImages));
          } else {
            int remainingSlots = widget.maxImages - (_existingImageUrls.length + _selectedImages.length);
            if (remainingSlots > 0 && pickedFiles.length > remainingSlots) {
                 _selectedImages.addAll(pickedFiles.take(remainingSlots));
                 widget.onSelectedImagesChanged(List.from(_selectedImages));
                 if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                    // ENGLISH TRANSLATION
                    SnackBar(
                        content: Text('Only the first $remainingSlots images were added. Maximum ${widget.maxImages} images allowed.'),
                    ),
                    );
                 }
            } else if (remainingSlots <=0 && mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                 // ENGLISH TRANSLATION
                 SnackBar(
                    content: Text('Maximum of ${widget.maxImages} images has been reached.'),
                 ),
                 );
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        // ENGLISH TRANSLATION
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick images: $e')));
      }
    }
  }

  void _removeNewImage(int index) {
    if (!widget.canEdit) return;
    setState(() {
      _selectedImages.removeAt(index);
      widget.onSelectedImagesChanged(List.from(_selectedImages));
    });
  }

  void _removeExistingImage(int index) {
    if (!widget.canEdit) return;
    setState(() {
      _existingImageUrls.removeAt(index);
      widget.onExistingImageUrlsChanged(List.from(_existingImageUrls));
    });
  }

  Widget _buildImageTile(dynamic imageData, int index, bool isExisting) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, top: 8, bottom: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: isExisting
                  ? Image.network(
                      imageData as String,
                      height: 150, width: 100, fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                          height: 150, width: 100, color: Colors.grey[200],
                          child: Icon(Icons.error_outline, color: Colors.red[300])),
                    )
                  : kIsWeb
                      ? Image.network(
                          (imageData as XFile).path,
                          height: 150,
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                              height: 150,
                              width: 100,
                              color: Colors.grey[200],
                              child: Icon(Icons.error_outline, color: Colors.red[300], semanticLabel: 'Web image load error')),
                        )
                      : Image.file(
                          File((imageData as XFile).path),
                          height: 150,
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 150,
                            width: 100,
                            color: Colors.grey[200],
                            child: Icon(Icons.error_outline, color: Colors.red[300], semanticLabel: 'Mobile image load error')),
                        ),
            ),
          ),
          if (widget.canEdit)
            Positioned(
              top: -8,
              right: -8,
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () => isExisting ? _removeExistingImage(index) : _removeNewImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0,1))]
                    ),
                    child: Icon(Icons.cancel, color: Colors.redAccent, size: 22),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int currentTotalImages = _existingImageUrls.length + _selectedImages.length;
    bool canAddMoreImages = currentTotalImages < widget.maxImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          // ENGLISH TRANSLATION
          "Property Photos (Maximum ${widget.maxImages})",
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        if (currentTotalImages > 0)
          SizedBox(
            height: 165,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ..._existingImageUrls.asMap().entries.map((entry) {
                  return _buildImageTile(entry.value, entry.key, true);
                }),
                ..._selectedImages.asMap().entries.map((entry) {
                  return _buildImageTile(entry.value, entry.key, false);
                }),
                if (widget.canEdit && canAddMoreImages)
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      margin: const EdgeInsets.only(right: 8.0, top: 8, bottom: 8),
                      height: 150,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                           BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                          )
                        ]
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, size: 30, color: Colors.grey[600]),
                           const SizedBox(height: 4),
                           // ENGLISH TRANSLATION
                           Text("Add", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (widget.canEdit && currentTotalImages == 0)
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                   BoxShadow(
                    color: Colors.grey.withOpacity(0.25),
                    spreadRadius: 1,
                    blurRadius: 4,
                  )
                ]
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey[600]),
                  const SizedBox(height: 8),
                  // ENGLISH TRANSLATION
                  Text("Tap to add photos", style: GoogleFonts.poppins(color: Colors.grey[600])),
                ],
              ),
            ),
          ),
      ],
    );
  }
}