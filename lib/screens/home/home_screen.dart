// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:real/app/themes/app_themes.dart';
import 'package:real/models/property.dart';
import 'package:real/provider/property_provider.dart';
import 'package:real/screens/main_screen.dart';
import 'package:real/widgets/property_card.dart';
import 'package:real/provider/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  // ENGLISH TRANSLATION
  String _selectedCategoryLabel = "Recommended"; 
  final List<String> _categories = ["Recommended", "Most Viewed"];
  Map<String, dynamic> _activeFilters = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _resetToInitialAndLoad(isInitialLoad: true, authToken: authProvider.token);
    });
    _scrollController.addListener(() {
      final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !propertyProvider.isLoadingPublicProperties &&
          propertyProvider.hasMorePublicProperties) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        propertyProvider.fetchPublicProperties(
          loadMore: true,
          category: _selectedCategoryLabel,
          filters: _activeFilters,
          authToken: authProvider.token,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProperties({
    required String category,
    required Map<String, dynamic> filters,
    bool isRefresh = false,
    bool isInitialLoad = false,
    String? authToken,
  }) async {
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    await propertyProvider.fetchPublicProperties(
      loadMore: false,
      category: category,
      filters: filters,
      authToken: authToken,
    );
    if (isRefresh && mounted && !isInitialLoad) {
      ScaffoldMessenger.of(context).showSnackBar(
        // ENGLISH TRANSLATION
        SnackBar(content: Text('Loading properties for "$category"...'), duration: const Duration(seconds: 1)),
      );
    }
  }

  Future<void> _refreshProperties() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await _loadProperties(
      category: _selectedCategoryLabel,
      filters: _activeFilters,
      isRefresh: true,
      authToken: authProvider.token,
    );
  }

  void _resetToInitialAndLoad({bool isInitialLoad = false, String? authToken}) {
    setState(() {
      _activeFilters = {};
      // ENGLISH TRANSLATION
      _selectedCategoryLabel = "Recommended";
    });
    _loadProperties(
      category: _selectedCategoryLabel,
      filters: _activeFilters,
      isRefresh: !isInitialLoad,
      isInitialLoad: isInitialLoad,
      authToken: authToken,
    );
  }

  Widget _buildCategoryChip(String label, {required bool isActive, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Chip(
          label: Text(label),
          labelStyle: GoogleFonts.poppins(
            color: isActive ? Colors.black : Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: isActive ? const Color(0xFFDAF365) : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          elevation: isActive ? 2.0 : 1.5,
          shadowColor: Colors.grey.withOpacity(0.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), 
              side: BorderSide.none
          ),
        ),
      ),
    );
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<PropertyProvider>(
          builder: (context, propertyProvider, child) {
            Widget bodyContent;
            if (propertyProvider.isLoadingPublicProperties && propertyProvider.publicProperties.isEmpty && _activeFilters.isEmpty) {
              bodyContent = const Center(child: CircularProgressIndicator(color: AppTheme.nearlyBlack));
            } else if (propertyProvider.publicPropertiesError != null && propertyProvider.publicProperties.isEmpty) {
              bodyContent = Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[400], size: 50),
                      const SizedBox(height: 10),
                      // ENGLISH TRANSLATION
                      Text('Failed to load properties: ${propertyProvider.publicPropertiesError}', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700])),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        // ENGLISH TRANSLATION
                        label: const Text("Try Again"),
                        onPressed: _refreshProperties,
                        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
                      )
                    ],
                  ),
                )
              );
            } else if (propertyProvider.publicProperties.isEmpty && !propertyProvider.isLoadingPublicProperties) {
               List<Widget> emptyStateWidgets = [
                Icon(Icons.home_work_outlined, color: Colors.grey[400], size: 60),
                const SizedBox(height: 15),
                Text(
                  // ENGLISH TRANSLATION
                  "No properties available for ${_activeFilters.isNotEmpty ? 'this filter' : 'the "$_selectedCategoryLabel" category'}.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 10),
                // ENGLISH TRANSLATION
                Text("Please check back later or change your filter/category.", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("Refresh"),
                  onPressed: _refreshProperties,
                ),
              ];
              if (_activeFilters.isNotEmpty) {
                emptyStateWidgets.add(const SizedBox(height: 10));
                emptyStateWidgets.add(
                  OutlinedButton.icon(
                    icon: Icon(Icons.clear_all_rounded, color: Theme.of(context).primaryColorDark),
                    // ENGLISH TRANSLATION
                    label: Text("Clear Filters & Reset", style: GoogleFonts.poppins(color: Theme.of(context).primaryColorDark, fontWeight: FontWeight.w500)),
                    onPressed: _resetToInitialAndLoad,
                    style: OutlinedButton.styleFrom(side: BorderSide(color: Theme.of(context).primaryColorDark.withOpacity(0.7))),
                  )
                );
              }
               bodyContent = Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: emptyStateWidgets)));
            } else {
              final List<Property> allProps = propertyProvider.publicProperties;
              final List<Property> featuredProps = allProps.take(5).toList();
              bodyContent = ListView(
                clipBehavior: Clip.none,
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Let's Find your", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black87)),
                        Text("Favorite Home", style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  // --- PERUBAHAN AKSI KLIK SEARCH BAR ---
                                  final mainScreenState = context.findAncestorStateOfType<MainScreenState>();
                                  mainScreenState?.changeTabAndPrepareSearch(
                                    1, // Pindah ke tab Search (indeks 1)
                                    autoFocusSearch: true, // Beri perintah untuk fokus
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                                  child: Row(children: [
                                    Icon(Icons.search, color: Colors.grey[600]),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        'Search address, city, location',
                                        style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 15),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                              child: IconButton(
                                icon: Icon(Icons.filter_list_rounded, color: Colors.grey[700]),
                                // ENGLISH TRANSLATION
                                tooltip: 'Filter Properties',
                                onPressed: () {
                                  // --- PERUBAHAN AKSI KLIK TOMBOL FILTER ---
                                  final mainScreenState = context.findAncestorStateOfType<MainScreenState>();
                                  mainScreenState?.changeTabAndPrepareSearch(
                                    1, // Pindah ke tab Search (indeks 1)
                                    filters: _activeFilters,
                                    autoOpenFilter: true, // Beri perintah untuk buka modal
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final categoryLabel = _categories[index];
                              return _buildCategoryChip(
                                categoryLabel,
                                isActive: _selectedCategoryLabel == categoryLabel,
                                onTap: () {
                                  if (_selectedCategoryLabel != categoryLabel) {
                                    setState(() { _selectedCategoryLabel = categoryLabel; });
                                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                    _loadProperties(category: categoryLabel, filters: _activeFilters, authToken: authProvider.token);
                                  }
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 25),
                      ],
                    ),
                  ),

                  if (featuredProps.isNotEmpty)
                    SizedBox(
                      height: 280,
                      child: ListView.builder(
                        clipBehavior: Clip.none,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        itemCount: featuredProps.length,
                        itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.only(
                            right: index == featuredProps.length - 1 ? 0 : 15.0,
                            // Hindari padding bottom di sini!
                          ),
                          child: PropertyCard(
                            property: featuredProps[index],
                            isHorizontalVariant: true,
                          ),
                        ),
                      ),
                    ),
                  if (featuredProps.isNotEmpty) const SizedBox(height: 25),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              // ENGLISH TRANSLATION
                              _selectedCategoryLabel == "Recommended" && _activeFilters.isEmpty
                                  ? "For You"
                                  : _activeFilters.isNotEmpty
                                      ? "Filter Results"
                                      : _selectedCategoryLabel,
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: allProps.length,
                            itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: PropertyCard(property: allProps[index], isHorizontalVariant: false),
                              )),
                        if (propertyProvider.isLoadingPublicProperties && propertyProvider.publicProperties.isNotEmpty)
                          const Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: Center(child: CircularProgressIndicator(color: AppTheme.nearlyBlack))),
                        if (!propertyProvider.hasMorePublicProperties && propertyProvider.publicProperties.isNotEmpty)
                           Padding(
                             padding: const EdgeInsets.symmetric(vertical: 20.0),
                             // ENGLISH TRANSLATION
                             child: Center(child: Text("You've reached the end of the list.", style: GoogleFonts.poppins(color: Colors.grey[600]))),
                           ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return RefreshIndicator(onRefresh: _refreshProperties, child: bodyContent);
          },
        ),
      ),
    );
  }
}