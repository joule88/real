// lib/screens/profile/my_property_detail_screen.dart
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
  
  // INDONESIAN DATE FORMAT RETAINED as requested by the user
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

  static const Color colorNavbarBg = Color(0xFF182420);
  static const Color colorLemonGreen = Color(0xFFDDEF6D);
  static const Color colorPrimaryBlue = Color(0xFF205295);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

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
    setState(() {
      _isLoadingStats = true;
      _statsError = null;
      _processedDailyStats = {};
      _processedMonthlyStats = {};
    });

    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final statsData = await propertyProvider.fetchPropertyStatistics(widget.property.id, authProvider.token);
      if (mounted && statsData != null) {
        setState(() {
          _processedDailyStats = _getProcessedDailyData(Map<String, dynamic>.from(statsData['daily'] ?? {}));
          _processedMonthlyStats = _getProcessedMonthlyData(Map<String, dynamic>.from(statsData['monthly'] ?? {}));
        });
      } else if (mounted) {
        setState(() {
          // ENGLISH TRANSLATION
          _statsError = "Failed to load statistics or no data found for this property.";
          _processedDailyStats = {};
          _processedMonthlyStats = {};
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // ENGLISH TRANSLATION
          _statsError = "An error occurred while fetching statistics: ${e.toString()}";
          _processedDailyStats = {};
          _processedMonthlyStats = {};
        });
      }
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
          labelColor: colorNavbarBg,
          unselectedLabelColor: Colors.grey[700],
          indicatorColor: colorNavbarBg,
          indicatorWeight: 2.5,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14.5),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14.5),
          // ENGLISH TRANSLATION
          tabs: const [
            Tab(text: "Property Details"),
            Tab(text: "Statistics"),
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
    ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: colorPrimaryBlue,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
    );

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
                            // ENGLISH TRANSLATION
                            errorWidget: (context, url, error) => _imageErrorPlaceholder(220, customText: "Main image unavailable"),
                          )
                        // ENGLISH TRANSLATION
                        : _imageErrorPlaceholder(220, customText: "No main image"),
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
                        // ENGLISH TRANSLATION
                        child: Center(child: Text("No images for this property.", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]))),
                    ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ENGLISH TRANSLATION
                _buildStatItem(
                    EvaIcons.eyeOutline, '${widget.property.viewsCount} Views'),
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
                        color: colorNavbarBg),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(EvaIcons.pinOutline, color: Colors.red, size: 18),
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
                      // ENGLISH TRANSLATION
                      _buildFeatureItem(Icons.king_bed_outlined,
                          '${widget.property.bedrooms} Bedrooms'),
                      _buildFeatureItem(Icons.bathtub_outlined,
                          '${widget.property.bathrooms} Bathrooms'),
                      _buildFeatureItem(Icons.aspect_ratio_outlined,
                          '${widget.property.areaSqft.toStringAsFixed(0)} sqft'),
                    ],
                  ),
                  const Divider(height: 30, thickness: 0.7),
                  // ENGLISH TRANSLATION
                  _buildInfoRow(
                    "Property Status:",
                    widget.property.status.name.replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (match) => ' ${match.group(0)}').replaceFirstMapped(RegExp(r'^[a-z]'), (m) => m[0]!.toUpperCase()),
                    chipColor: _getStatusColor(widget.property.status).withOpacity(0.12),
                    textColor: _getStatusColor(widget.property.status),
                    isChip: true,
                  ),
                   if (widget.property.propertyType.isNotEmpty)
                    _buildInfoRow("Property Type:", widget.property.propertyType),
                  if (widget.property.furnishings.isNotEmpty)
                    _buildInfoRow("Furnishing:", widget.property.furnishings),
                   if (widget.property.mainView != null && widget.property.mainView!.isNotEmpty)
                    _buildInfoRow("Main View:", widget.property.mainView!),
                  if (widget.property.listingAgeCategory != null && widget.property.listingAgeCategory!.isNotEmpty)
                    _buildInfoRow("Listing Age:", widget.property.listingAgeCategory!),
                  if (widget.property.propertyLabel != null && widget.property.propertyLabel!.isNotEmpty)
                    _buildInfoRow("Property Label:", widget.property.propertyLabel!),

                  if (widget.property.approvalDate != null)
                    _buildInfoRow("Live Since:", // ENGLISH TRANSLATION
                        _dateFormatter.format(widget.property.approvalDate!)), // INDONESIAN DATE FORMAT RETAINED
                  if (widget.property.submissionDate != null && widget.property.status == PropertyStatus.pendingVerification)
                     _buildInfoRow("Submitted On:", // ENGLISH TRANSLATION
                        _dateFormatter.format(widget.property.submissionDate!)), // INDONESIAN DATE FORMAT RETAINED
                  if (widget.property.rejectionReason != null && widget.property.status == PropertyStatus.rejected)
                    _buildInfoRow("Rejection Reason:", widget.property.rejectionReason!, valueColor: Colors.red[700]), // ENGLISH TRANSLATION

                  if(widget.property.description.isNotEmpty) ...[
                    const Divider(height: 30, thickness: 0.7),
                    Text(
                      "Description", // ENGLISH TRANSLATION
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
                    "Actions", // ENGLISH TRANSLATION
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
                        icon: const Icon(EvaIcons.edit2Outline, size: 20, color: Colors.white),
                        // ENGLISH TRANSLATION
                        label: Text("Edit Listing", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
                        style: primaryButtonStyle,
                      ),
                    ),
                  if (widget.property.status == PropertyStatus.approved || widget.property.status == PropertyStatus.draft || widget.property.status == PropertyStatus.rejected)
                      const SizedBox(height: 12),

                  if (widget.property.status == PropertyStatus.approved)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.archive_outlined, size: 20, color: Colors.white),
                        // ENGLISH TRANSLATION
                        label: Text("Archive Listing", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
                        onPressed: () => _updatePropertyStatus(PropertyStatus.archived, "Archive Property?", "This property will be moved to the archive and will no longer be public.", authProvider, propertyProvider),
                        style: primaryButtonStyle.copyWith(
                          backgroundColor: WidgetStateProperty.all(Colors.grey[700]),
                        ),
                      ),
                    ),
                  if (widget.property.status == PropertyStatus.approved) const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(EvaIcons.externalLinkOutline, size: 20, color: colorNavbarBg),
                      // ENGLISH TRANSLATION
                      label: Text("View Public Page", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: colorNavbarBg)),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext dialogContext) => const Center(child: CircularProgressIndicator()),
                        );

                        Property? freshPropertyData = await propertyProvider.fetchPublicPropertyDetail(
                          widget.property.id,
                          authProvider.token,
                        );

                        if (!mounted) return;
                        Navigator.pop(context); // Close dialog

                        if (freshPropertyData != null) {
                          if (freshPropertyData.uploaderInfo == null && widget.property.uploaderInfo != null) {
                            freshPropertyData = freshPropertyData.copyWith(uploaderInfo: widget.property.uploaderInfo);
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangeNotifierProvider.value(
                                value: freshPropertyData!,
                                child: PropertyDetailPage(
                                  key: ValueKey(freshPropertyData.id),
                                  property: freshPropertyData,
                                ),
                              ),
                            ),
                          );
                        } else {
                          // ENGLISH TRANSLATION
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to load public property details.')),
                          );
                        }
                      },
                      style: primaryButtonStyle.copyWith(
                        backgroundColor: WidgetStateProperty.all(colorLemonGreen),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  if (widget.property.status == PropertyStatus.approved)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.paid_outlined, size: 20, color: colorLemonGreen),
                        // ENGLISH TRANSLATION
                        label: Text("Mark as Sold", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: colorLemonGreen)),
                        onPressed: () => _updatePropertyStatus(PropertyStatus.sold, "Mark Property as Sold?", "The property's status will be changed to 'Sold'. It will no longer be publicly visible.", authProvider, propertyProvider),
                        style: primaryButtonStyle.copyWith(
                          backgroundColor: WidgetStateProperty.all(colorNavbarBg),
                        ),
                      ),
                    ),

                  if (widget.property.status == PropertyStatus.draft ||
                      widget.property.status == PropertyStatus.rejected ||
                      widget.property.status == PropertyStatus.approved ||
                      widget.property.status == PropertyStatus.archived) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.white),
                        // ENGLISH TRANSLATION
                        label: Text("Delete This Listing", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
                        onPressed: () {
                          _confirmAndDeleteProperty(authProvider, propertyProvider);
                        },
                        style: primaryButtonStyle.copyWith(
                          backgroundColor: WidgetStateProperty.all(Colors.red[700]),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
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
                // ENGLISH TRANSLATION
                label: const Text("Try Again"),
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
              // ENGLISH TRANSLATION
              Text(
                "No significant view activity for this period yet.",
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
              // ENGLISH TRANSLATION
              Text(
                "View statistics for this property are not available yet.",
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
            // ENGLISH TRANSLATION
            "Listing View Analytics",
            style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Text(
            // ENGLISH TRANSLATION
            "See the trend of how many times this listing has been viewed by other users, both daily and monthly.",
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
            color: colorNavbarBg,
        ),
        ),
    );
  }

  Widget _imageErrorPlaceholder(double height, {double iconSize = 40, String customText = "Image unavailable"}){
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
    Color confirmButtonColor = colorPrimaryBlue;
    Color confirmTextColor = Colors.white;

    if (newStatus == PropertyStatus.sold) {
      confirmButtonColor = colorNavbarBg;
      confirmTextColor = colorLemonGreen;
    } else if (newStatus == PropertyStatus.archived) {
      confirmButtonColor = Colors.grey[700]!;
    } else if (newStatus == PropertyStatus.approved) {
      confirmButtonColor = Colors.green[600]!;
    }

    _showConfirmationDialog(
      context,
      title: dialogTitle,
      content: dialogContent,
      confirmButtonColor: confirmButtonColor,
      confirmTextColor: confirmTextColor,
      onConfirm: () async {
        if (authProvider.token != null) {
          final result = await propertyProvider.updatePropertyStatus(
            widget.property.id,
            newStatus,
            authProvider.token!,
          );
          if (mounted) {
            if (result['success'] == true) {
              // ENGLISH TRANSLATION
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Property status successfully updated to ${newStatus.name}.'), backgroundColor: Colors.green),
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
              // ENGLISH TRANSLATION
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update status: ${result['message'] ?? "An error occurred."}')),
              );
            }
          }
        } else {
            if (mounted) {
                // ENGLISH TRANSLATION
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid session. Please log in again.')),
                );
            }
        }
      },
    );
  }

  Future<void> _confirmAndDeleteProperty(AuthProvider authProvider, PropertyProvider propertyProvider) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          // ENGLISH TRANSLATION
          title: Text("Confirm Deletion", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: Text("Are you sure you want to permanently delete the property '${widget.property.title}'? This action cannot be undone.", style: GoogleFonts.poppins()),
          actionsAlignment: MainAxisAlignment.end,
          actions: <Widget>[
            TextButton(
              // ENGLISH TRANSLATION
              child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey[700])),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
              // ENGLISH TRANSLATION
              child: Text("Delete", style: GoogleFonts.poppins(color: Colors.white)),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      if (authProvider.token != null) {
        final result = await propertyProvider.deleteProperty(
          widget.property.id,
          authProvider.token!,
        );

        if (!mounted) return;

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            // ENGLISH TRANSLATION
            SnackBar(content: Text(result['message'] ?? 'Property successfully deleted.'), backgroundColor: Colors.green),
          );
          int count = 0;
          Navigator.of(context).popUntil((_) => count++ >= 1);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            // ENGLISH TRANSLATION
            SnackBar(content: Text(result['message'] ?? 'Failed to delete property.'), backgroundColor: Colors.red),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          // ENGLISH TRANSLATION
          const SnackBar(content: Text('Invalid session. Please log in again.')),
        );
      }
    }
  }

  Future<void> _showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onConfirm,
    Color? confirmButtonColor,
    Color? confirmTextColor,
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
              // ENGLISH TRANSLATION
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey[700], fontWeight: FontWeight.w500)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: confirmButtonColor ?? colorPrimaryBlue),
              // ENGLISH TRANSLATION
              child: Text('Confirm', style: GoogleFonts.poppins(color: confirmTextColor ?? Colors.white, fontWeight: FontWeight.w500)),
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