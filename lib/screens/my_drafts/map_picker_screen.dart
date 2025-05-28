import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart'; // Opsional

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late MapController _mapController;
  // Default ke Jember, Jawa Timur atau lokasi relevan lainnya
  LatLng _currentMapCenter = const LatLng(-8.1726, 113.7022); 
  LatLng? _selectedLocation;
  String _selectedAddressString = "Geser peta dan pilih lokasi";
  bool _isLoadingAddress = false;
  bool _isFetchingInitialLocation = true; // Untuk indikator loading lokasi awal

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeMapLocation();
  }

  Future<void> _initializeMapLocation() async {
    setState(() {
      _isFetchingInitialLocation = true;
    });
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Jika layanan lokasi mati, gunakan default dan jangan paksa aktifkan
        if (mounted) {
          setState(() {
             _selectedLocation = _currentMapCenter; // Set default
            _isFetchingInitialLocation = false;
          });
          _reverseGeocode(_currentMapCenter);
        }
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
           if (mounted) {
             setState(() {
               _selectedLocation = _currentMapCenter; // Set default
              _isFetchingInitialLocation = false;
            });
            _reverseGeocode(_currentMapCenter);
           }
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _selectedLocation = _currentMapCenter; // Set default
            _isFetchingInitialLocation = false;
          });
          _reverseGeocode(_currentMapCenter);
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium, // Medium sudah cukup
          timeLimit: const Duration(seconds: 10) // Batas waktu
      );
      if (mounted) {
        setState(() {
          _currentMapCenter = LatLng(position.latitude, position.longitude);
          _selectedLocation = _currentMapCenter;
          _isFetchingInitialLocation = false;
        });
        _mapController.move(_currentMapCenter, 16.0);
        _reverseGeocode(_currentMapCenter);
      }
    } catch (e) {
      print("Error getting current location for map: $e");
      if (mounted) {
        setState(() {
          _selectedLocation = _currentMapCenter; // Set default jika gagal
          _isFetchingInitialLocation = false;
        });
         _reverseGeocode(_currentMapCenter); // Reverse geocode default location
      }
    }
  }


  Future<void> _reverseGeocode(LatLng point) async {
    if (!mounted) return;
    setState(() {
      _isLoadingAddress = true;
      _selectedAddressString = "Memuat alamat...";
    });

    final Uri uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${point.latitude}&lon=${point.longitude}&addressdetails=1&accept-language=id'); // Prioritaskan Bahasa Indonesia

    try {
      final response = await http.get(uri, headers: {
        'User-Agent': 'NestoraApp/1.0 (muhammadjulianromadhoni@gmail.com)' // GANTI DENGAN INFO VALID APLIKASI ANDA
      });
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _selectedAddressString = data['display_name'] ?? 'Alamat tidak ditemukan pada koordinat ini.';
        });
      } else {
        setState(() => _selectedAddressString = 'Gagal mendapatkan alamat. Kode: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _selectedAddressString = 'Terjadi kesalahan: ${e.toString()}');
    } finally {
      if (!mounted) return;
      setState(() => _isLoadingAddress = false);
    }
  }

  void _onMapConfirm() {
    if (_selectedLocation != null &&
        _selectedAddressString.isNotEmpty &&
        _selectedAddressString != "Memuat alamat..." &&
        !_selectedAddressString.toLowerCase().contains("gagal") &&
        !_selectedAddressString.toLowerCase().contains("error") &&
        !_selectedAddressString.toLowerCase().contains("tidak ditemukan")) {
      Navigator.pop(context, _selectedAddressString);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat belum valid atau gagal dimuat. Silakan coba lagi atau pilih titik lain.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Lokasi dari Peta', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: GoogleFonts.poppins(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      body: _isFetchingInitialLocation
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentMapCenter,
                    initialZoom: 16.0,
                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture) {
                        // Update _selectedLocation saat peta digeser oleh pengguna
                        // Ini akan membuat marker di tengah "mengikuti"
                         if (_selectedLocation != position.center) { // Hanya update jika berbeda
                            setState(() {
                              _selectedLocation = position.center;
                            });
                         }
                      }
                    },
                    // Hentikan reverse geocode otomatis saat peta bergerak untuk UX yg lebih baik
                    // Cukup saat tap atau saat tombol "gunakan lokasi tengah" ditekan
                    onTap: (tapPosition, point) {
                       setState(() {
                         _selectedLocation = point;
                         // Pindahkan marker ke titik yang di-tap
                         _mapController.move(point, _mapController.camera.zoom);
                       });
                       _reverseGeocode(point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'], // Subdomain untuk tile server OSM
                      userAgentPackageName: 'com.muhammadjulianromadhoni.nestoraapp', // GANTI DENGAN PACKAGE NAME APLIKASI ANDA
                    ),
                    // Marker yang bergerak sesuai _selectedLocation
                    if (_selectedLocation != null)
                       MarkerLayer(
                         markers: [
                           Marker(
                             point: _selectedLocation!,
                             width: 80,
                             height: 80,
                             child: const Icon(Icons.location_pin, color: Colors.redAccent, size: 40),
                           ),
                         ],
                       ),
                  ],
                ),
                // Marker statis di tengah layar (opsional, jika ingin model seperti Gojek/Grab)
                // Positioned.fill(
                //   child: IgnorePointer( // Agar tap tembus ke peta
                //     child: Center(
                //       child: Icon(Icons.location_pin, size: 50, color: Colors.blue),
                //     ),
                //   ),
                // ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: _initializeMapLocation, // Kembali ke lokasi saat ini/awal
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.my_location, color: Colors.blueAccent),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        color: Colors.black.withOpacity(0.75),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _isLoadingAddress ? "Memuat alamat..." : _selectedAddressString,
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16,8,16,16), // Padding untuk tombol
                        color: Colors.black.withOpacity(0.75), // Samakan background atau bedakan sedikit
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text("Gunakan Alamat Ini", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                          onPressed: (_selectedLocation == null || _isLoadingAddress) ? null : _onMapConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
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