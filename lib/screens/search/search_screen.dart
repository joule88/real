import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:real/models/property.dart';
import 'package:real/provider/auth_provider.dart';
import 'package:real/provider/property_provider.dart';
import 'package:real/widgets/property_list_item.dart';
import 'package:real/screens/detail/detailpost.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _previousSearchKeyword = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Jika ingin membersihkan hasil search sebelumnya saat layar dibuka, uncomment baris di bawah
      // Provider.of<PropertyProvider>(context, listen: false).clearSearchResults();
    });

    _scrollController.addListener(() {
      final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !propertyProvider.isLoadingSearch &&
          propertyProvider.hasMoreSearchResults) {
        if (propertyProvider.currentSearchKeyword.isNotEmpty) {
          print("SearchScreen: Mencapai akhir scroll, memanggil loadMore untuk keyword: ${propertyProvider.currentSearchKeyword}");
          propertyProvider.performKeywordSearch(propertyProvider.currentSearchKeyword, loadMore: true);
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

  void _triggerSearch({bool loadMore = false}) {
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    String keyword = _searchController.text.trim();

    if (loadMore) {
      if (propertyProvider.currentSearchKeyword.isNotEmpty) {
        propertyProvider.performKeywordSearch(propertyProvider.currentSearchKeyword, loadMore: true);
      }
    } else {
      if (keyword.isNotEmpty) {
        _previousSearchKeyword = keyword; 
        propertyProvider.performKeywordSearch(keyword, loadMore: false);
      } else {
        propertyProvider.clearSearchResults();
        _previousSearchKeyword = "";
      }
    }
  }
  
  Future<void> _refreshSearchResults() async {
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    if (propertyProvider.currentSearchKeyword.isNotEmpty) {
      await propertyProvider.performKeywordSearch(propertyProvider.currentSearchKeyword, loadMore: false);
    } else {
      propertyProvider.clearSearchResults();
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = Provider.of<PropertyProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        // Tombol kembali akan otomatis ditambahkan oleh Navigator jika SearchScreen di-push
        // Jika ingin kustomisasi, bisa tambahkan leading: IconButton(...)
        title: Text(
          "Cari Properti",
          style: GoogleFonts.poppins(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: Colors.grey[300]!)
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true, // --- TAMBAHKAN INI ---
                decoration: InputDecoration(
                  hintText: 'Ketik nama properti, lokasi, tipe...',
                  icon: Icon(Icons.search, color: Colors.grey[600]),
                  border: InputBorder.none,
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 15),
                ),
                style: GoogleFonts.poppins(fontSize: 15),
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  _triggerSearch();
                },
              ),
            ),
            const SizedBox(height: 20),

            if (propertyProvider.currentSearchKeyword.isNotEmpty || propertyProvider.searchedProperties.isNotEmpty || propertyProvider.isLoadingSearch)
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Text(
                  propertyProvider.isLoadingSearch && propertyProvider.searchedProperties.isEmpty
                      ? "Mencari properti untuk \"${propertyProvider.currentSearchKeyword}\"..."
                      : propertyProvider.currentSearchKeyword.isNotEmpty
                          ? "Hasil pencarian (${propertyProvider.searchedProperties.length}) untuk \"${propertyProvider.currentSearchKeyword}\""
                          : "Menampilkan hasil pencarian",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
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
                       return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[400], size: 40),
                              const SizedBox(height: 10),
                              Text(
                                'Gagal mencari: ${propertyProvider.searchError}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text("Coba Lagi"),
                                onPressed: () => _triggerSearch(),
                              )
                            ],
                          ),
                        )
                      );
                    }
                    if (propertyProvider.searchedProperties.isEmpty && propertyProvider.currentSearchKeyword.isNotEmpty && !propertyProvider.isLoadingSearch) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[400]),
                            const SizedBox(height: 15),
                            Text(
                              'Properti tidak ditemukan',
                              style: GoogleFonts.poppins(fontSize: 17, color: Colors.grey[800], fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Coba kata kunci lain.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      );
                    }
                     if (propertyProvider.searchedProperties.isEmpty && propertyProvider.currentSearchKeyword.isEmpty && !propertyProvider.isLoadingSearch) {
                      return Center( 
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.manage_search_rounded, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 15),
                            Text(
                              'Ketik kata kunci untuk mencari properti.',
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: propertyProvider.searchedProperties.length + 
                                 (propertyProvider.isLoadingSearch && propertyProvider.searchedProperties.isNotEmpty && propertyProvider.hasMoreSearchResults ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == propertyProvider.searchedProperties.length) {
                          return propertyProvider.isLoadingSearch && propertyProvider.hasMoreSearchResults
                              ? const Center(child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(strokeWidth: 3),
                                ))
                              : const SizedBox.shrink();
                        }
                        
                        final property = propertyProvider.searchedProperties[index];
                        return GestureDetector(
                          onTap: () async { 
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext dialogContext) {
                                return const Center(child: CircularProgressIndicator());
                              },
                            );

                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                            Property? freshPropertyData = await propertyProvider.fetchPublicPropertyDetail(
                              property.id,
                              authProvider.token
                            );

                            if (!mounted) return; 
                            Navigator.pop(context); 

                            if (freshPropertyData != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChangeNotifierProvider.value(
                                    value: freshPropertyData,
                                    child: PropertyDetailPage(property: freshPropertyData),
                                  ),
                                ),
                              );
                            } else {
                               ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Gagal memuat detail properti. Coba lagi nanti.')),
                              );
                            }
                          },
                          child: PropertyListItem(
                            property: property,
                          ),
                        );
                      },
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
}