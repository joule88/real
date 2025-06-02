import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:real/models/property.dart';
import 'package:real/widgets/bookmark_button.dart';
import 'package:real/widgets/contact.dart'; // Import widget ContactAgentWidget
import 'package:cached_network_image/cached_network_image.dart';

class PropertyDetailPage extends StatefulWidget { // Ubah menjadi StatefulWidget
  final Property property;

  const PropertyDetailPage({super.key, required this.property});

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> { // State untuk halaman
  late String _currentMainImageUrl; // State untuk menyimpan URL gambar utama saat ini
  late List<String> _allImageUrls; // State untuk menyimpan semua URL gambar

  static const Color colorPaletHijauGelap = Color(0xFF121212); // Ganti dengan hex hijau gelap sesuai palet

  @override
  void initState() {
    super.initState();
    // Inisialisasi _allImageUrls terlebih dahulu
    _allImageUrls = [
      if (widget.property.imageUrl.isNotEmpty && Uri.tryParse(widget.property.imageUrl)?.isAbsolute == true)
        widget.property.imageUrl,
      ...widget.property.additionalImageUrls
          .where((url) => url.isNotEmpty && Uri.tryParse(url)?.isAbsolute == true)
    ]
    .toSet()
    .toList();

    // Tentukan _currentMainImageUrl
    if (_allImageUrls.isNotEmpty) {
      _currentMainImageUrl = _allImageUrls.first;
    } else if (widget.property.imageUrl.isNotEmpty && Uri.tryParse(widget.property.imageUrl)?.isAbsolute == true) {
      _currentMainImageUrl = widget.property.imageUrl;
    }
     else {
      _currentMainImageUrl = '';
    }
  }

  // Fungsi untuk membangun placeholder saat gambar error
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

  // Fungsi untuk membangun placeholder saat gambar loading
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
          color: colorPaletHijauGelap, // Gunakan warna hijau gelap
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'ar_AE', symbol: 'AED ', decimalDigits: 0);
    final screenWidth = MediaQuery.of(context).size.width; // Ambil lebar layar

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan tombol kembali, tulisan "Detail", dan bookmark
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol Kembali
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  // Tulisan "Detail"
                  Expanded(
                    child: Text(
                      "Detail",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Tombol Bookmark
                  BookmarkButton(
                    isBookmarked: widget.property.isFavorite,
                    onPressed: () {
                      setState(() {
                        widget.property.toggleFavorite();
                      });
                    },
                  ),
                ],
              ),
            ),

            // --- BAGIAN GAMBAR PROPERTI (UTAMA DAN THUMBNAIL) ---
            Column(
              children: [
                // Gambar Utama
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
                            errorWidget: (context, url, error) => _imageErrorPlaceholder(240, customText: "Gambar utama tidak tersedia"),
                          )
                        : _imageErrorPlaceholder(240, customText: "Tidak ada gambar utama"),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Galeri Thumbnail (selalu tampil jika ada setidaknya 1 gambar)
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
                                    offset: Offset(0,2)
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
                        child: Center(child: Text("Tidak ada gambar galeri.", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]))),
                    ),
                 const SizedBox(height: 10), // Jarak setelah galeri
              ],
            ),
            // --- AKHIR BAGIAN GAMBAR PROPERTI ---

            // DETAIL PROPERTI
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      // Harga 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            currencyFormatter.format(widget.property.price),
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      //lokasi
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 18, color: Colors.red),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.property.address, // Langsung gunakan property.address
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Detail Properti (3 kolom)
                      // ========== AWAL PERUBAHAN ==========
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailItem(Icons.king_bed_outlined, '${widget.property.bedrooms} Kamar Tidur', screenWidth),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDetailItem(Icons.bathtub_outlined, '${widget.property.bathrooms} Kamar Mandi', screenWidth),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDetailItem(Icons.straighten_outlined, '${widget.property.areaSqft.toStringAsFixed(0)} sqft', screenWidth),
                          ),
                        ],
                      ),
                      // ========== AKHIR PERUBAHAN ==========
                      const SizedBox(height: 20),


                      // Deskripsi (Opsional)
                      Text(
                        'Deskripsi',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.property.description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // BAGIAN KONTAK PENGIKLAN
            ContactAgentWidget(owner: widget.property.uploaderInfo),
            SizedBox(height: MediaQuery.of(context).padding.bottom > 0 ? 10 : 20), // Padding tambahan jika ada notch/gestur sistem
          ],
        ),
      ),
    );
  }

  // Modifikasi _buildDetailItem untuk menerima screenWidth dan menyesuaikan ukuran
  Widget _buildDetailItem(IconData icon, String text, double screenWidth) {
    // Tidak lagi menggunakan Expanded di sini karena Wrap akan menangani layoutnya
    return Container( // Bisa dibungkus Container untuk padding jika perlu
      padding: const EdgeInsets.symmetric(vertical: 4), // Sedikit padding vertikal
      child: Row( // Atau Column jika ingin ikon di atas teks
        mainAxisSize: MainAxisSize.min, // Agar tidak mengambil lebar penuh jika di dalam Wrap
        children: [
          Icon(icon, size: screenWidth < 360 ? 16 : 18, color: Colors.grey[700]),
          SizedBox(width: screenWidth < 360 ? 3 : 5),
          Flexible( // Tambahkan Flexible agar teks bisa wrap jika terlalu panjang
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: screenWidth < 360 ? 9.5 : 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
              softWrap: true, // Izinkan teks untuk wrap
            ),
          ),
        ],
      ),
    );
  }
}
