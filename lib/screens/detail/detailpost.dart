// lib/screens/detail/detailpost.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real/models/property.dart';
import 'package:real/widgets/bookmark_button.dart';
import 'package:real/widgets/contact.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:real/provider/property_provider.dart';

class PropertyDetailPage extends StatefulWidget {
  final Property property;

  const PropertyDetailPage({super.key, required this.property});

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  late String _currentMainImageUrl;
  late List<String> _allImageUrls;
  late bool _isBookmarked;

  static const Color colorPaletHijauGelap = Color(0xFF121212);
  static const Color colorPaletHitam = Color(0xFF182420);

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.property.isFavorite;

    _allImageUrls = {
      if (widget.property.imageUrl.isNotEmpty && Uri.tryParse(widget.property.imageUrl)?.isAbsolute == true)
        widget.property.imageUrl,
      ...widget.property.additionalImageUrls
          .where((url) => url.isNotEmpty && Uri.tryParse(url)?.isAbsolute == true)
    }.toList();

    if (_allImageUrls.isNotEmpty) {
      _currentMainImageUrl = _allImageUrls.first;
    } else if (widget.property.imageUrl.isNotEmpty && Uri.tryParse(widget.property.imageUrl)?.isAbsolute == true) {
      _currentMainImageUrl = widget.property.imageUrl;
    } else {
      _currentMainImageUrl = '';
    }
  }

  Widget _imageErrorPlaceholder(double height, {double iconSize = 50, String? customText}) {
    return Container(
      height: height,
      width: double.infinity,
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined, size: iconSize, color: Colors.grey[400]),
            if (customText != null) ...[
              const SizedBox(height: 8),
              Text(customText, style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12))
            ]
          ],
        )
      ),
    );
  }

  Widget _imageLoadingPlaceholder(double height, ImageChunkEvent? loadingProgress) {
    return Container(
      height: height,
      width: double.infinity,
      color: Colors.grey[100],
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress != null && loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
              : null,
          strokeWidth: 2.5,
          color: colorPaletHijauGelap,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: valueColor ?? colorPaletHitam,
                          fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'ar_AE', symbol: 'AED ', decimalDigits: 0);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      // ==========================================================
      //         PERUBAHAN UTAMA DIMULAI DI SINI
      // ==========================================================
      body: Stack(
        children: [
          // Widget utama yang berisi konten yang bisa di-scroll
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Details", // ENGLISH
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      BookmarkButton(
                        isBookmarked: _isBookmarked,
                        onPressed: () {
                          setState(() {
                            _isBookmarked = !_isBookmarked;
                          });
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          Provider.of<PropertyProvider>(context, listen: false)
                              .togglePropertyBookmark(widget.property.id, authProvider.token);
                        },
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Hero(
                           tag: 'property_image_${widget.property.id}',
                           child: (_currentMainImageUrl.isNotEmpty && Uri.tryParse(_currentMainImageUrl)?.isAbsolute == true)
                            ? CachedNetworkImage(
                                imageUrl: _currentMainImageUrl,
                                width: double.infinity,
                                height: 240,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => _imageLoadingPlaceholder(240, null),
                                errorWidget: (context, url, error) => _imageErrorPlaceholder(240, customText: "Main image unavailable"), // ENGLISH
                              )
                            : _imageErrorPlaceholder(240, customText: "No main image"), // ENGLISH
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_allImageUrls.length > 1)
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _allImageUrls.length,
                          itemBuilder: (context, index) {
                            final imageUrl = _allImageUrls[index];
                            bool isSelected = imageUrl == _currentMainImageUrl;
                            return GestureDetector(
                              onTap: () {
                                if (mounted) {
                                  setState(() {
                                    _currentMainImageUrl = imageUrl;
                                  });
                                }
                              },
                              child: Opacity(
                                opacity: isSelected ? 1.0 : 0.6,
                                child: Container(
                                  width: 80,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: isSelected ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0,2)
                                      )
                                    ] : [],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: (imageUrl.isNotEmpty && Uri.tryParse(imageUrl)?.isAbsolute == true)
                                      ? CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(color: Colors.grey[200]),
                                          errorWidget: (context, url, error) => Container(
                                            color: Colors.grey[200],
                                            child: Icon(Icons.broken_image_outlined, color: Colors.grey[400], size: 30),
                                          ),
                                        )
                                      : Container(
                                          color: Colors.grey[200],
                                          child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 30),
                                        ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if (_allImageUrls.isEmpty)
                        Padding(
                            padding: const EdgeInsets.only(top:8.0, bottom: 10),
                            child: Center(child: Text("No gallery images.", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]))), // ENGLISH
                        ),
                     const SizedBox(height: 10),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    // Menambahkan padding di bawah agar konten terakhir tidak tertutup widget kontak
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    child: Container(
                      margin: const EdgeInsets.only(top: 4, bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.property.title,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: colorPaletHitam,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                currencyFormatter.format(widget.property.price),
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorPaletHitam,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on_outlined, size: 18, color: Colors.red),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.property.address,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailItem(Icons.king_bed_outlined, '${widget.property.bedrooms} Bedrooms', screenWidth), // ENGLISH
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildDetailItem(Icons.bathtub_outlined, '${widget.property.bathrooms} Bathrooms', screenWidth), // ENGLISH
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildDetailItem(Icons.straighten_outlined, '${widget.property.areaSqft.toStringAsFixed(0)} sqft', screenWidth),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          const Divider(height: 20, thickness: 0.7),
                          if (widget.property.propertyType.isNotEmpty)
                            _buildInfoRow("Property Type:", widget.property.propertyType), // ENGLISH
                          if (widget.property.furnishings.isNotEmpty)
                            _buildInfoRow("Furnishing:", widget.property.furnishings), // ENGLISH
                          if (widget.property.mainView != null && widget.property.mainView!.isNotEmpty)
                            _buildInfoRow("Main View:", widget.property.mainView!), // ENGLISH
                          if (widget.property.listingAgeCategory != null && widget.property.listingAgeCategory!.isNotEmpty)
                            _buildInfoRow("Listing Age:", widget.property.listingAgeCategory!), // ENGLISH
                          if (widget.property.propertyLabel != null && widget.property.propertyLabel!.isNotEmpty)
                            _buildInfoRow("Property Label:", widget.property.propertyLabel!), // ENGLISH
                          const Divider(height: 20, thickness: 0.7),
                          
                          const SizedBox(height: 10),

                          Text(
                            'Description', // ENGLISH
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            // ENGLISH
                            widget.property.description.isNotEmpty ? widget.property.description : "No description for this property.",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: widget.property.description.isNotEmpty ? Colors.grey[700] : Colors.grey[500],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // ContactAgentWidget dan SizedBox di bawahnya telah dipindahkan dari sini
              ],
            ),
          ),
          // Widget kontak yang "mengambang" di lapisan atas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ContactAgentWidget(owner: widget.property.uploaderInfo),
          ),
        ],
      ),
      // ==========================================================
      //          PERUBAHAN UTAMA SELESAI DI SINI
      // ==========================================================
    );
  }

  Widget _buildDetailItem(IconData icon, String text, double screenWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: screenWidth < 360 ? 16 : 18, color: Colors.grey[700]),
          SizedBox(width: screenWidth < 360 ? 3 : 5),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: screenWidth < 360 ? 9.5 : 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}