import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:real/models/property.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:real/provider/property_provider.dart';
import 'package:real/screens/detail/detailpost.dart';
import 'package:real/screens/my_drafts/add_property_form_screen.dart';
import 'package:real/widgets/view_stats_chart.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyPropertyDetailScreen extends StatefulWidget {
  final Property property;

  const MyPropertyDetailScreen({super.key, required this.property});

  @override
  State<MyPropertyDetailScreen> createState() => _MyPropertyDetailScreenState();
}

class _MyPropertyDetailScreenState extends State<MyPropertyDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _dateFormatter = DateFormat('dd MMMM yyyy', 'id_ID');
  final DateFormat _labelDailyFormatter = DateFormat('dd MMM', 'id_ID');
  final DateFormat _labelMonthlyFormatter = DateFormat('MMM yy', 'id_ID');
  final DateFormat _backendDailyParser = DateFormat('yyyy-MM-dd');
  final DateFormat _backendMonthlyParser = DateFormat('yyyy-MM');

  Map<String, int> _processedDailyStats = {};
  Map<String, int> _processedMonthlyStats = {};
  bool _isLoadingStats = true;
  String? _statsError;

  late String _currentMainImageUrlOnDetailTab;
  late List<String> _allImageUrlsForDetailTab;

  static const Color colorPaletHitam = Color(0xFF182420);
  static const Color colorPaletHijauMuda = Color(0xFFDDEF6D);
  static const Color colorPaletHijauGelap = Color(0xFF121212);


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    print(
        "_MyPropertyDetailScreenState initState: ID Properti yang diterima adalah ${widget.property.id} untuk judul '${widget.property.title}'");

    _allImageUrlsForDetailTab = {
      if (widget.property.imageUrl.isNotEmpty && Uri.tryParse(widget.property.imageUrl)?.isAbsolute == true)
        widget.property.imageUrl,
      ...widget.property.additionalImageUrls
          .where((url) => url.isNotEmpty && Uri.tryParse(url)?.isAbsolute == true)
    }
    .toList();

    if (_allImageUrlsForDetailTab.isNotEmpty) {
      _currentMainImageUrlOnDetailTab = _allImageUrlsForDetailTab.first;
    } else if (widget.property.imageUrl.isNotEmpty && Uri.tryParse(widget.property.imageUrl)?.isAbsolute == true) {
      _currentMainImageUrlOnDetailTab = widget.property.imageUrl;
    }
     else {
      _currentMainImageUrlOnDetailTab = '';
    }
    _fetchAndProcessStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAndProcessStatistics() async {
    if (!mounted) return;
    print("_MyPropertyDetailScreenState _fetchAndProcessStatistics: Memulai untuk ID ${widget.property.id}");
    setState(() {
      _isLoadingStats = true;
      _statsError = null;
      _processedDailyStats = {};
      _processedMonthlyStats = {};
    });

    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      print("_MyPropertyDetailScreenState _fetchAndProcessStatistics: Memanggil provider dengan ID ${widget.property.id}");
      final statsData = await propertyProvider.fetchPropertyStatistics(widget.property.id, authProvider.token);
      print('_MyPropertyDetailScreenState: Data statistik mentah diterima untuk ID ${widget.property.id}: $statsData');
      
      if (mounted && statsData != null) {
        setState(() {
          _processedDailyStats = _getProcessedDailyData(Map<String, dynamic>.from(statsData['daily'] ?? {}));
          _processedMonthlyStats = _getProcessedMonthlyData(Map<String, dynamic>.from(statsData['monthly'] ?? {}));
          print('_MyPropertyDetailScreenState: Processed Daily Stats untuk ID ${widget.property.id}: $_processedDailyStats');
          print('_MyPropertyDetailScreenState: Processed Monthly Stats untuk ID ${widget.property.id}: $_processedMonthlyStats');
        });
      } else if (mounted) {
        setState(() {
          _statsError = "Gagal mengambil data statistik atau data tidak ditemukan untuk properti ini.";
          _processedDailyStats = {}; 
          _processedMonthlyStats = {};
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statsError = "Terjadi kesalahan saat mengambil statistik: ${e.toString()}";
          _processedDailyStats = {};
          _processedMonthlyStats = {};
        });
      }
      print("Error fetching/processing stats for ID ${widget.property.id}: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  Map<String, int> _getProcessedDailyData(Map<String, dynamic> rawDailyMap) {
    Map<String, int> processedData = {};
    var sortedKeys = rawDailyMap.keys.toList()..sort();
    for (var key in sortedKeys) {
      try {
        DateTime date = _backendDailyParser.parse(key);
        processedData[_labelDailyFormatter.format(date)] = rawDailyMap[key] as int;
      } catch (e) {
        print("Error parsing daily date $key: $e");
      }
    }
    return processedData;
  }

  Map<String, int> _getProcessedMonthlyData(Map<String, dynamic> rawMonthlyMap) {
    Map<String, int> processedData = {};
    var sortedKeys = rawMonthlyMap.keys.toList()..sort();
    for (var key in sortedKeys) {
      try {
        DateTime date = _backendMonthlyParser.parse(key);
        processedData[_labelMonthlyFormatter.format(date)] = rawMonthlyMap[key] as int;
      } catch (e) {
        print("Error parsing monthly date $key: $e");
      }
    }
    return processedData;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'ar_AE', symbol: 'AED ', decimalDigits: 0);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.property.title,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorPaletHitam, // Perubahan warna
          unselectedLabelColor: Colors.grey[700],
          indicatorColor: colorPaletHitam, // Perubahan warna
          indicatorWeight: 2.5,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14.5),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14.5),
          tabs: const [
            Tab(text: "Detail Properti"),
            Tab(text: "Statistik"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailTabContent(context, currencyFormatter, authProvider, propertyProvider),
          _buildStatisticsTabContent(context),
        ],
      ),
    );
  }

  Widget _buildDetailTabContent(BuildContext context, NumberFormat currencyFormatter, AuthProvider authProvider, PropertyProvider propertyProvider) {
    return SingleChildScrollView(
      key: const PageStorageKey<String>('myPropertyDetailTab'),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Hero(
                      tag: 'my_property_image_${widget.property.id}',
                      child: (_currentMainImageUrlOnDetailTab.isNotEmpty && Uri.tryParse(_currentMainImageUrlOnDetailTab)?.isAbsolute == true)
                        ? CachedNetworkImage(
                            imageUrl: _currentMainImageUrlOnDetailTab,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => _imageLoadingPlaceholder(220, null),
                            errorWidget: (context, url, error) => _imageErrorPlaceholder(220, customText: "Gambar utama tidak tersedia"),
                          )
                        : _imageErrorPlaceholder(220, customText: "Tidak ada gambar utama"),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (_allImageUrlsForDetailTab.length > 1)
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _allImageUrlsForDetailTab.length,
                      itemBuilder: (context, index) {
                        final imageUrl = _allImageUrlsForDetailTab[index];
                        bool isSelected = imageUrl == _currentMainImageUrlOnDetailTab;
                        return GestureDetector(
                          onTap: () {
                            if (mounted) {
                              setState(() {
                                _currentMainImageUrlOnDetailTab = imageUrl;
                              });
                            }
                          },
                          child: Opacity(
                            opacity: isSelected ? 1.0 : 0.6,
                            child: Container(
                              width: 70,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: isSelected ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 3,
                                    offset: const Offset(0,1)
                                  )
                                ] : [],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: (imageUrl.isNotEmpty && Uri.tryParse(imageUrl)?.isAbsolute == true)
                                  ? CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(color: Colors.grey[200]),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.grey[200],
                                        child: Icon(Icons.broken_image_outlined, color: Colors.grey[400], size: 24),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.grey[200],
                                      child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 24),
                                    ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (_allImageUrlsForDetailTab.isEmpty)
                     Padding(
                        padding: const EdgeInsets.only(top:8.0, bottom: 10),
                        child: Center(child: Text("Tidak ada gambar untuk properti ini.", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]))),
                    ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 8.0),
            child: Row( // Hanya menampilkan "Dilihat"
              mainAxisAlignment: MainAxisAlignment.center, // Pusatkan jika hanya satu item
              children: [
                _buildStatItem(
                    EvaIcons.eyeOutline, '${widget.property.viewsCount} Dilihat'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.property.title,
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currencyFormatter.format(widget.property.price),
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorPaletHitam), // Perubahan warna harga
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(EvaIcons.pinOutline, color: Colors.red, size: 18), // Perubahan warna ikon lokasi
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.property.address,
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFeatureItem(Icons.king_bed_outlined,
                          '${widget.property.bedrooms} Kamar Tidur'),
                      _buildFeatureItem(Icons.bathtub_outlined,
                          '${widget.property.bathrooms} Kamar Mandi'),
                      _buildFeatureItem(Icons.aspect_ratio_outlined,
                          '${widget.property.areaSqft.toStringAsFixed(0)} sqft'),
                    ],
                  ),
                  const Divider(height: 30, thickness: 0.7),
                  _buildInfoRow(
                    "Status Properti:",
                    widget.property.status.name.replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (match) => ' ${match.group(0)}').replaceFirstMapped(RegExp(r'^[a-z]'), (m) => m[0]!.toUpperCase()),
                    chipColor: _getStatusColor(widget.property.status).withOpacity(0.12),
                    textColor: _getStatusColor(widget.property.status),
                    isChip: true,
                  ),
                   if (widget.property.propertyType.isNotEmpty)
                    _buildInfoRow("Tipe Properti:", widget.property.propertyType),
                  if (widget.property.furnishings.isNotEmpty)
                    _buildInfoRow("Kondisi Furnishing:", widget.property.furnishings),
                   if (widget.property.mainView != null && widget.property.mainView!.isNotEmpty)
                    _buildInfoRow("Pemandangan Utama:", widget.property.mainView!),
                  if (widget.property.listingAgeCategory != null && widget.property.listingAgeCategory!.isNotEmpty)
                    _buildInfoRow("Usia Listing:", widget.property.listingAgeCategory!),
                  if (widget.property.propertyLabel != null && widget.property.propertyLabel!.isNotEmpty)
                    _buildInfoRow("Label Properti:", widget.property.propertyLabel!),

                  if (widget.property.approvalDate != null)
                    _buildInfoRow("Tanggal Tayang:",
                        _dateFormatter.format(widget.property.approvalDate!)),
                  if (widget.property.submissionDate != null && widget.property.status == PropertyStatus.pendingVerification)
                     _buildInfoRow("Tanggal Diajukan:",
                        _dateFormatter.format(widget.property.submissionDate!)),
                  if (widget.property.rejectionReason != null && widget.property.status == PropertyStatus.rejected)
                    _buildInfoRow("Alasan Ditolak:", widget.property.rejectionReason!, valueColor: Colors.red[700]),

                  if(widget.property.description.isNotEmpty) ...[
                    const Divider(height: 30, thickness: 0.7),
                    Text(
                      "Deskripsi",
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                       widget.property.description,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[850],
                          height: 1.6),
                    ),
                  ],

                  const Divider(height: 30, thickness: 0.7),
                  Text(
                    "Tindakan",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  if (widget.property.status == PropertyStatus.approved || widget.property.status == PropertyStatus.draft || widget.property.status == PropertyStatus.rejected)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(EvaIcons.edit2Outline, size: 20),
                        label: Text("Edit Iklan", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddPropertyFormScreen(propertyToEdit: widget.property),
                            ),
                          ).then((updated) async {
                             if (updated == true && mounted) {
                                final String? token = authProvider.token;
                                if (token != null) {
                                  await Future.wait([
                                    propertyProvider.fetchUserApprovedProperties(token),
                                    propertyProvider.fetchUserManageableProperties(token),
                                    propertyProvider.fetchUserSoldProperties(token),
                                    propertyProvider.fetchPublicProperties()
                                  ]);
                                }
                                if (mounted) Navigator.pop(context); 
                              }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  if (widget.property.status == PropertyStatus.approved || widget.property.status == PropertyStatus.draft || widget.property.status == PropertyStatus.rejected)
                      const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(EvaIcons.externalLinkOutline, size: 20),
                      label: Text("Lihat Halaman Publik", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider.value(
                              value: widget.property,
                              child: PropertyDetailPage(property: widget.property),
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (widget.property.status == PropertyStatus.approved)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.archive_outlined, size: 20, color: Colors.orange.shade800),
                        label: Text("Arsipkan Iklan", style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.orange.shade800)),
                        onPressed: () => _updatePropertyStatus(PropertyStatus.archived, "Arsipkan Properti?", "Properti ini akan dipindahkan ke arsip dan tidak akan tampil di publik.", authProvider, propertyProvider),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.orange.shade700.withOpacity(0.7)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  if (widget.property.status == PropertyStatus.approved) const SizedBox(height: 12),

                  if (widget.property.status == PropertyStatus.approved)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.paid_outlined, size: 20, color: colorPaletHitam), // Perubahan warna ikon
                        label: Text("Tandai sebagai Terjual", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: colorPaletHitam)), // Perubahan warna teks
                        onPressed: () => _updatePropertyStatus(PropertyStatus.sold, "Tandai Properti Terjual?", "Status properti akan diubah menjadi 'Terjual'. Properti ini tidak akan tampil di publik lagi.", authProvider, propertyProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPaletHijauMuda, // Perubahan warna background
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatisticsTabContent(BuildContext context) {
    if (_isLoadingStats) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ));
    }
    if (_statsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.red.shade300, size: 50),
              const SizedBox(height:10),
              Text(
                _statsError!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height:15),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Coba Lagi"),
                onPressed: _fetchAndProcessStatistics,
              )
            ],
          ),
        ),
      );
    }
    if (_processedDailyStats.values.every((count) => count == 0) &&
        _processedMonthlyStats.values.every((count) => count == 0) &&
        _processedDailyStats.isNotEmpty && _processedMonthlyStats.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trending_flat_rounded, color: Colors.grey.shade300, size: 70),
              const SizedBox(height:15),
              Text(
                "Belum ada aktivitas tampilan yang signifikan untuk periode ini.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      );
    }
    if (_processedDailyStats.isEmpty && _processedMonthlyStats.isEmpty && _statsError == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart_rounded, color: Colors.grey.shade300, size: 70),
              const SizedBox(height:15),
              Text(
                "Data statistik tampilan untuk properti ini belum tersedia.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      );
    }
    return SingleChildScrollView(
      key: const PageStorageKey<String>('statisticsTab'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Grafik Tampilan Postingan",
            style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Text(
            "Lihat tren berapa kali postingan ini dilihat oleh pengguna lain, baik secara harian maupun bulanan.",
            style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.grey[700], height: 1.5),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                 BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
              ]
            ),
            child: ViewStatsChart(
              dailyChartData: _processedDailyStats,
              monthlyChartData: _processedMonthlyStats,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _imageLoadingPlaceholder(double height, ImageChunkEvent? loadingProgress){
    return Container(
        height: height,
        width: double.infinity,
        color: Colors.grey[100],
        child: Center(
        child: CircularProgressIndicator(
            value: loadingProgress != null && loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
            strokeWidth: 2.5,
            color: colorPaletHijauGelap,
        ),
        ),
    );
  }

  Widget _imageErrorPlaceholder(double height, {double iconSize = 40, String customText = "Gambar tidak tersedia"}){
      return Container(
        height: height,
        width: double.infinity,
        color: Colors.grey[200],
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported_outlined,
                    size: iconSize, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(customText, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]), textAlign: TextAlign.center),
              ],
            )
        ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey[700], size: 15),
        const SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 22, color: Colors.grey[800]),
          const SizedBox(height: 5),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? chipColor, Color? textColor, bool isChip = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: isChip ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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
              child: isChip && chipColor != null
                  ? Chip(
                      label: Text(value,
                          style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: textColor ?? Colors.black87,
                              fontWeight: FontWeight.w600)),
                      backgroundColor: chipColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1.5),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    )
                  : Text(
                      value,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: valueColor ?? Colors.black87,
                          fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.approved:
        return Colors.green.shade700;
      case PropertyStatus.pendingVerification:
        return Colors.orange.shade800;
      case PropertyStatus.draft:
        return Colors.blueGrey.shade700;
      case PropertyStatus.rejected:
        return Colors.red.shade700;
      case PropertyStatus.archived:
        return Colors.brown.shade700;
      case PropertyStatus.sold:
        return Colors.purple.shade700;
    }
  }

  Future<void> _updatePropertyStatus(PropertyStatus newStatus, String dialogTitle, String dialogContent, AuthProvider authProvider, PropertyProvider propertyProvider) async {
    _showConfirmationDialog(
      context,
      title: dialogTitle,
      content: dialogContent,
      onConfirm: () async {
        if (authProvider.token != null) {
          final result = await propertyProvider.updatePropertyStatus(
            widget.property.id,
            newStatus,
            authProvider.token!,
          );
          if (mounted) { 
            if (result['success'] == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Status properti berhasil diperbarui ke ${newStatus.name}.'), backgroundColor: Colors.green),
              );
              final String? token = authProvider.token; 
               if (token != null) {
                 await Future.wait([
                    propertyProvider.fetchUserApprovedProperties(token),
                    propertyProvider.fetchUserManageableProperties(token),
                    propertyProvider.fetchUserSoldProperties(token),
                    propertyProvider.fetchPublicProperties(), 
                 ]);
              }
              if (mounted) Navigator.pop(context); 
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal memperbarui status: ${result['message'] ?? "Terjadi kesalahan."}')),
              );
            }
          }
        } else {
            if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sesi tidak valid. Silakan login ulang.')),
                );
            }
        }
      },
    );
  }

  Future<void> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 17)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(content, style: GoogleFonts.poppins(fontSize: 14)),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.end,
          actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          actions: <Widget>[
            TextButton(
              child: Text('Batal', style: GoogleFonts.poppins(color: Colors.grey[700], fontWeight: FontWeight.w500)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColorDark),
              child: Text('Konfirmasi', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500)),
              onPressed: () {
                Navigator.of(dialogContext).pop(); 
                onConfirm(); 
              },
            ),
          ],
        );
      },
    );
  }
}