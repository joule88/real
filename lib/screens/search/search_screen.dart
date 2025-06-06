// lib/screens/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:real/models/property.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:real/provider/property_provider.dart';
import 'package:real/widgets/property_list_item.dart';
import 'package:real/screens/detail/detailpost.dart';
import 'package:real/widgets/filter_modal_content.dart';

class SearchScreen extends StatefulWidget {
  final Key? key;
  final bool autoOpenFilterModal;

  const SearchScreen({
    this.key,
    this.autoOpenFilterModal = false,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic> _activeSearchScreenFilters = {};
  bool _hasSearchedAtLeastOnce = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _searchController.text = propertyProvider.pendingSearchKeyword;
      _activeSearchScreenFilters = Map.from(propertyProvider.pendingSearchFilters);
      bool shouldSearchNow = propertyProvider.needsSearchExecution;
      if (shouldSearchNow) {
        setState(() {
          _hasSearchedAtLeastOnce = true;
        });
      }
      if (widget.autoOpenFilterModal) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) _showSearchFilterModal();
        });
        shouldSearchNow = false;
      }
      if (shouldSearchNow &&
          propertyProvider.searchedProperties.isEmpty &&
          !propertyProvider.isLoadingSearch) {
        propertyProvider.performKeywordSearch(authToken: authProvider.token);
      }
    });
    _scrollController.addListener(() {
      final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !propertyProvider.isLoadingSearch &&
          propertyProvider.hasMoreSearchResults) {
        if (propertyProvider.pendingSearchKeyword.isNotEmpty || propertyProvider.pendingSearchFilters.isNotEmpty) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          propertyProvider.performKeywordSearch(loadMore: true, authToken: authProvider.token);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _triggerSearchFromSearchBar() {
    if(mounted) {
      setState(() {
        _hasSearchedAtLeastOnce = true;
      });
    }
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String keyword = _searchController.text.trim();
    propertyProvider.prepareSearchParameters(keyword: keyword, filters: _activeSearchScreenFilters);
    propertyProvider.performKeywordSearch(authToken: authProvider.token);
  }

  Future<void> _refreshSearchResults() async {
    if(mounted) {
      setState(() {
        _hasSearchedAtLeastOnce = true;
      });
    }
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await propertyProvider.performKeywordSearch(loadMore: false, authToken: authProvider.token);
  }
  
  Future<void> _navigateToDetail(Property property) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => const Center(child: CircularProgressIndicator()),
    );

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);

    Property? freshPropertyData = await propertyProvider.fetchPublicPropertyDetail(
      property.id,
      authProvider.token,
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (freshPropertyData != null) {
      if (freshPropertyData.uploaderInfo == null && property.uploaderInfo != null) {
        freshPropertyData = freshPropertyData.copyWith(uploaderInfo: property.uploaderInfo);
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
        const SnackBar(content: Text('Failed to load property details.')),
      );
    }
  }

  void _showSearchFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext modalContext) {
        return FilterModalContent(
          // ENGLISH TRANSLATION
          initialFilters: Map.from(_activeSearchScreenFilters)..addAll({'_title': "Filter Search Results"}),
          onApplyFilters: (appliedFiltersFromModal) {
            Map<String, dynamic> cleanFilters = Map.from(appliedFiltersFromModal);
            cleanFilters.remove('_title');
            setState(() {
              _activeSearchScreenFilters = cleanFilters;
              _hasSearchedAtLeastOnce = true;
            });
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            Provider.of<PropertyProvider>(context, listen: false).prepareSearchParameters(
                keyword: _searchController.text.trim(),
                filters: cleanFilters,
            );
            Provider.of<PropertyProvider>(context, listen: false).performKeywordSearch(authToken: authProvider.token);
          },
          onResetFilters: () {
            setState(() {
              _activeSearchScreenFilters = {};
              _hasSearchedAtLeastOnce = true;
            });
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            Provider.of<PropertyProvider>(context, listen: false).prepareSearchParameters(
                keyword: _searchController.text.trim(),
                filters: {},
            );
            Provider.of<PropertyProvider>(context, listen: false).performKeywordSearch(authToken: authProvider.token);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);

    if (_searchController.text != propertyProvider.pendingSearchKeyword) {
        _searchController.text = propertyProvider.pendingSearchKeyword;
    }
    _activeSearchScreenFilters = Map.from(propertyProvider.pendingSearchFilters);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        // ENGLISH TRANSLATION
        title: Text("Search Properties", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                        )
                      ]
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        // ENGLISH TRANSLATION
                        hintText: 'Type property name, location...',
                        icon: Icon(Icons.search, color: Colors.grey[600]),
                        border: InputBorder.none,
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 15),
                        suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(icon: Icon(Icons.clear, color: Colors.grey[600]), onPressed: () {
                              _searchController.clear();
                              Provider.of<PropertyProvider>(context, listen: false).prepareSearchParameters(keyword: "", filters: _activeSearchScreenFilters);
                              Provider.of<PropertyProvider>(context, listen: false).performKeywordSearch();
                            })
                          : null,
                      ),
                      style: GoogleFonts.poppins(fontSize: 15),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) => _triggerSearchFromSearchBar(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                        )
                      ]
                  ),
                  child: IconButton(
                    icon: Icon(Icons.filter_list_rounded, color: Colors.grey[700]),
                    // ENGLISH TRANSLATION
                    tooltip: 'Search Filters',
                    onPressed: _showSearchFilterModal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            if (_activeSearchScreenFilters.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     // ENGLISH TRANSLATION
                     Text("Active Filters:", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                     const SizedBox(height: 4),
                     Wrap(
                      spacing: 6.0,
                      runSpacing: 6.0,
                      children: _activeSearchScreenFilters.entries.where((entry) => entry.key != '_title').map((entry) {
                        if (entry.value.toString().isEmpty && !(entry.value is bool)) return const SizedBox.shrink();
                        return Chip(
                          label: Text('${_formatFilterKey(entry.key)}: ${entry.value}', style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.black87)),
                          backgroundColor: Colors.grey[200],
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          deleteIconColor: Colors.grey[700],
                          onDeleted: () {
                            Provider.of<PropertyProvider>(context, listen: false).prepareSearchParameters(
                              keyword: _searchController.text.trim(),
                              filters: Map.from(_activeSearchScreenFilters)..remove(entry.key)
                            );
                            Provider.of<PropertyProvider>(context, listen: false).performKeywordSearch();
                          },
                        );
                      }).toList(),
                    ),
                  ],
                )
              ),

            ValueListenableBuilder<int>(
              valueListenable: propertyProvider.listUpdateNotifier,
              builder: (context, _, __) {
                if (propertyProvider.searchedProperties.isNotEmpty || (propertyProvider.isLoadingSearch && propertyProvider.searchedProperties.isEmpty)) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15.0, top: 5.0),
                    child: Text(
                      // ENGLISH TRANSLATION
                      propertyProvider.isLoadingSearch && propertyProvider.searchedProperties.isEmpty
                          ? "Searching for properties..."
                          : "Search Results",
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }
            ),

            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: propertyProvider.listUpdateNotifier,
                builder: (context, value, child) {
                  final currentSearchedProperties = propertyProvider.searchedProperties;
                  final isLoading = propertyProvider.isLoadingSearch;
                  final hasMore = propertyProvider.hasMoreSearchResults;

                  return RefreshIndicator(
                    onRefresh: _refreshSearchResults,
                    child: Builder(
                      builder: (context) {
                        if (isLoading && !_hasSearchedAtLeastOnce && currentSearchedProperties.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!_hasSearchedAtLeastOnce && currentSearchedProperties.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.manage_search_rounded, size: 80, color: Colors.grey[300]),
                                  const SizedBox(height:15),
                                  // ENGLISH TRANSLATION
                                  Text('Type a keyword or use filters to search for properties.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]))
                                ]
                              )
                            )
                          );
                        }
                        if (_hasSearchedAtLeastOnce && currentSearchedProperties.isEmpty && !isLoading) {
                           return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
                                  const SizedBox(height:15),
                                  // ENGLISH TRANSLATION
                                  Text('No Properties Found', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w500)),
                                  const SizedBox(height:8),
                                  // ENGLISH TRANSLATION
                                  Text('Try a different keyword or filter.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]))
                                ]
                              )
                            )
                          );
                        }                        
                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: currentSearchedProperties.length + (isLoading && currentSearchedProperties.isNotEmpty && hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == currentSearchedProperties.length) {
                              return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(strokeWidth: 3)));
                            }
                            final property = currentSearchedProperties[index];
                            return GestureDetector(
                              onTap: () => _navigateToDetail(property),
                              child: PropertyListItem(
                                key: ValueKey(property.id),
                                property: property,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFilterKey(String key) {
    // ENGLISH TRANSLATION
    switch (key) {
      case 'propertyType': return 'Type';
      case 'lokasi': return 'Location';
      case 'minPrice': return 'Min Price';
      case 'maxPrice': return 'Max Price';
      case 'minBedrooms': return 'Min Beds';
      case 'maxBedrooms': return 'Max Beds';
      case 'minBathrooms': return 'Min Baths';
      case 'maxBathrooms': return 'Max Baths';
      case 'furnishing': return 'Furnishing';
      case 'minArea': return 'Min Area';
      case 'mainView': return 'View';
      case 'listingAgeCategory': return 'Listing Age';
      case 'propertyLabel': return 'Label';
      default: return key;
    }
  }
}