// lib/screens/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:real/models/property.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:real/provider/property_provider.dart';
import 'package:real/widgets/property_list_item.dart';
import 'package:real/screens/detail/detailpost.dart';
// Import FilterModalContent yang sudah dibuat
import 'package:real/widgets/filter_modal_content.dart'; 
// custom_form_field.dart tidak perlu diimpor di sini jika semua form ada di FilterModalContent

class SearchScreen extends StatefulWidget {
  final Key? key;
  final bool autoOpenFilterModal; // Parameter baru

  const SearchScreen({
    this.key,
    this.autoOpenFilterModal = false, // Default false
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  // State untuk menyimpan filter yang aktif *khusus* untuk SearchScreen
  Map<String, dynamic> _activeSearchScreenFilters = {};

  @override
  void initState() {
    super.initState();
    print("SearchScreen initState CALLED (Key: {widget.key}, autoOpenFilter: {widget.autoOpenFilterModal})");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
      
      // Isi search bar dengan keyword dari provider jika ada (dari navigasi HomeScreen)
      _searchController.text = propertyProvider.pendingSearchKeyword;
      // Ambil filter yang mungkin sudah di-set dari HomeScreen
      _activeSearchScreenFilters = Map.from(propertyProvider.pendingSearchFilters); 

      bool shouldSearchNow = propertyProvider.needsSearchExecution;
      if (widget.autoOpenFilterModal) {
        print("SearchScreen: Auto opening filter modal.");
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            _showSearchFilterModal();
          }
        });
        shouldSearchNow = false; 
      }
      // Otomatis jalankan pencarian jika ada parameter pending dan belum ada hasil
      if (shouldSearchNow &&
          propertyProvider.searchedProperties.isEmpty &&
          !propertyProvider.isLoadingSearch) {
        print("SearchScreen: Auto-triggering search from initState. Keyword: {propertyProvider.pendingSearchKeyword}, Filters: {propertyProvider.pendingSearchFilters}");
        propertyProvider.performKeywordSearch(); 
      } else if (propertyProvider.searchedProperties.isNotEmpty) {
        // Jika sudah ada hasil (misalnya dari navigasi kembali), tidak perlu auto-search
         // Kecuali jika parameter pending berbeda dari yang menghasilkan result saat ini
        print("SearchScreen: Already has search results or no fresh execution needed immediately.");
      }
    });

    _scrollController.addListener(() {
      final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !propertyProvider.isLoadingSearch &&
          propertyProvider.hasMoreSearchResults) {
        // Gunakan keyword dan filter yang sudah ada di provider untuk loadMore
        if (propertyProvider.pendingSearchKeyword.isNotEmpty || propertyProvider.pendingSearchFilters.isNotEmpty) {
          print("SearchScreen: Mencapai akhir scroll, memanggil loadMore.");
          propertyProvider.performKeywordSearch(loadMore: true);
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
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    String keyword = _searchController.text.trim();
    // Saat search dari bar di SearchScreen, kita gunakan filter yang sudah aktif di _activeSearchScreenFilters
    propertyProvider.prepareSearchParameters(keyword: keyword, filters: _activeSearchScreenFilters);
    propertyProvider.performKeywordSearch();
  }
  
  Future<void> _refreshSearchResults() async {
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    // Refresh akan menggunakan parameter (keyword & filter) yang sudah ada di provider
    await propertyProvider.performKeywordSearch(loadMore: false);
  }

  void _showSearchFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext modalContext) {
        return FilterModalContent(
          initialFilters: Map.from(_activeSearchScreenFilters)..addAll({'_title': "Filter Hasil Pencarian"}),
          onApplyFilters: (appliedFiltersFromModal) {
            Map<String, dynamic> cleanFilters = Map.from(appliedFiltersFromModal);
            cleanFilters.remove('_title');
            setState(() {
              _activeSearchScreenFilters = cleanFilters;
            });
            Provider.of<PropertyProvider>(context, listen: false).prepareSearchParameters(
                keyword: _searchController.text.trim(),
                filters: cleanFilters,
            );
            Provider.of<PropertyProvider>(context, listen: false).performKeywordSearch();
          },
          onResetFilters: () {
            setState(() {
              _activeSearchScreenFilters = {};
            });
            Provider.of<PropertyProvider>(context, listen: false).prepareSearchParameters(
                keyword: _searchController.text.trim(),
                filters: {},
            );
            Provider.of<PropertyProvider>(context, listen: false).performKeywordSearch();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = Provider.of<PropertyProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false, 
        title: Text("Cari Properti", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
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
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Ketik nama properti, lokasi...',
                        icon: Icon(Icons.search, color: Colors.grey[600]),
                        border: InputBorder.none,
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 15),
                        suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(icon: Icon(Icons.clear, color: Colors.grey[600]), onPressed: () {
                              _searchController.clear();
                              setState(() {}); 
                              Provider.of<PropertyProvider>(context, listen: false).prepareSearchParameters(keyword: "", filters: _activeSearchScreenFilters);
                              Provider.of<PropertyProvider>(context, listen: false).performKeywordSearch();
                            })
                          : null,
                      ),
                      style: GoogleFonts.poppins(fontSize: 15),
                      textInputAction: TextInputAction.search,
                      onChanged: (value) => setState(() {}), 
                      onSubmitted: (value) => _triggerSearchFromSearchBar(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container( 
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
                  child: IconButton(
                    icon: Icon(Icons.filter_list_rounded, color: Colors.grey[700]),
                    tooltip: 'Filter Pencarian',
                    onPressed: _showSearchFilterModal, // Panggil modal filter
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15), // Mengurangi sedikit jarak

            // Tampilkan filter yang aktif jika ada
            if (_activeSearchScreenFilters.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text("Filter Aktif:", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
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
                            setState(() {
                              _activeSearchScreenFilters.remove(entry.key);
                            });
                            Provider.of<PropertyProvider>(context, listen: false).prepareSearchParameters(keyword: _searchController.text.trim(), filters: _activeSearchScreenFilters);
                            Provider.of<PropertyProvider>(context, listen: false).performKeywordSearch();
                          },
                        );
                      }).toList(),
                    ),
                  ],
                )
              ),
            
            // Judul Hasil Pencarian
            if (propertyProvider.pendingSearchKeyword.isNotEmpty || propertyProvider.pendingSearchFilters.isNotEmpty || propertyProvider.searchedProperties.isNotEmpty || propertyProvider.isLoadingSearch)
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0, top: 5.0), // Tambahkan top padding jika ada filter aktif
                child: Text(
                  propertyProvider.isLoadingSearch && propertyProvider.searchedProperties.isEmpty
                      ? "Mencari properti..."
                      : (propertyProvider.pendingSearchKeyword.isNotEmpty || propertyProvider.pendingSearchFilters.isNotEmpty)
                          ? "Hasil (${propertyProvider.searchedProperties.length}) untuk ${propertyProvider.pendingSearchKeyword.isNotEmpty ? '\"' + propertyProvider.pendingSearchKeyword + '\"' : 'filter saat ini'}"
                          : "Menampilkan hasil pencarian",
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ),
            
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshSearchResults,
                child: Builder(
                  builder: (context) {
                    if (propertyProvider.isLoadingSearch && propertyProvider.searchedProperties.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (propertyProvider.searchError != null && propertyProvider.searchedProperties.isEmpty) {
                       return Center(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.error_outline_rounded, color: Colors.red.shade300, size: 50), const SizedBox(height:10), Text('Error: ${propertyProvider.searchError}', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700])), const SizedBox(height:15), ElevatedButton.icon(icon: const Icon(Icons.refresh), label: const Text("Coba Lagi"), onPressed: _triggerSearchFromSearchBar)])));
                    }
                    if (propertyProvider.searchedProperties.isEmpty && (propertyProvider.pendingSearchKeyword.isNotEmpty || propertyProvider.pendingSearchFilters.isNotEmpty) && !propertyProvider.isLoadingSearch) {
                      return Center(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off_rounded, color: Colors.grey.shade400, size: 70), const SizedBox(height:15), Text('Properti tidak ditemukan', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w500)), const SizedBox(height:8), Text('Coba kata kunci atau filter lain.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]))])));
                    }
                     if (propertyProvider.searchedProperties.isEmpty && propertyProvider.pendingSearchKeyword.isEmpty && propertyProvider.pendingSearchFilters.isEmpty && !propertyProvider.isLoadingSearch) {
                        return Center(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.manage_search_rounded, size: 80, color: Colors.grey[300]), const SizedBox(height:15), Text('Ketik kata kunci atau gunakan filter untuk mencari properti.', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]))])));
                    }

                    return ListView.builder(
                        controller: _scrollController,
                        itemCount: propertyProvider.searchedProperties.length + (propertyProvider.isLoadingSearch && propertyProvider.searchedProperties.isNotEmpty && propertyProvider.hasMoreSearchResults ? 1 : 0),
                        itemBuilder: (context, index) {
                           if (index == propertyProvider.searchedProperties.length) {
                             return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(strokeWidth: 3)));
                           }
                           final property = propertyProvider.searchedProperties[index];
                           return GestureDetector(
                             onTap: () async { 
                               showDialog(context: context, barrierDismissible: false, builder: (BuildContext dialogContext) => const Center(child: CircularProgressIndicator()));
                               final authProvider = Provider.of<AuthProvider>(context, listen: false);
                               Property? freshPropertyData = await Provider.of<PropertyProvider>(context, listen: false).fetchPublicPropertyDetail(property.id, authProvider.token);
                               if (!mounted) return; 
                               Navigator.pop(context); 
                               if (freshPropertyData != null) {
                                 Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeNotifierProvider.value(value: freshPropertyData, child: PropertyDetailPage(property: freshPropertyData))));
                               } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memuat detail properti.')));
                               }
                             },
                             child: PropertyListItem(property: property),
                           );
                        }
                    );
                  }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFilterKey(String key) {
    switch (key) {
      case 'propertyType': return 'Tipe';
      case 'lokasi': return 'Lokasi';
      case 'minPrice': return 'Min Harga';
      case 'maxPrice': return 'Max Harga';
      case 'minBedrooms': return 'Min KM Tdr';
      case 'maxBedrooms': return 'Max KM Tdr';
      case 'minBathrooms': return 'Min KM Mdi';
      case 'maxBathrooms': return 'Max KM Mdi';
      case 'furnishing': return 'Furnishing';
      case 'minArea': return 'Min Luas';
      case 'mainView': return 'Pemandangan';
      case 'listingAgeCategory': return 'Usia Listing';
      case 'propertyLabel': return 'Label';
      default: return key;
    }
  }
}