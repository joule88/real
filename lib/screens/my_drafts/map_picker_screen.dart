// lib/screens/my_drafts/map_picker_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late MapController _mapController;
  // Default to a general location
  LatLng _currentMapCenter = const LatLng(-8.1726, 113.7022); 
  LatLng? _selectedLocation;
  // ENGLISH TRANSLATION
  String _selectedAddressString = "Pan the map and select a location";
  bool _isLoadingAddress = false;
  bool _isFetchingInitialLocation = true;

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
        if (mounted) {
          setState(() {
            _selectedLocation = _currentMapCenter;
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
              _selectedLocation = _currentMapCenter;
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
            _selectedLocation = _currentMapCenter;
            _isFetchingInitialLocation = false;
          });
          _reverseGeocode(_currentMapCenter);
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10)
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
      if (mounted) {
        setState(() {
          _selectedLocation = _currentMapCenter;
          _isFetchingInitialLocation = false;
        });
         _reverseGeocode(_currentMapCenter);
      }
    }
  }


  Future<void> _reverseGeocode(LatLng point) async {
    if (!mounted) return;
    setState(() {
      _isLoadingAddress = true;
      // ENGLISH TRANSLATION
      _selectedAddressString = "Loading address...";
    });

    // Request in English
    final Uri uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${point.latitude}&lon=${point.longitude}&addressdetails=1&accept-language=en');

    try {
      final response = await http.get(uri, headers: {
        'User-Agent': 'NestoraApp/1.0 (muhammadjulianromadhoni@gmail.com)'
      });
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // ENGLISH TRANSLATION
          _selectedAddressString = data['display_name'] ?? 'Address not found for these coordinates.';
        });
      } else {
        // ENGLISH TRANSLATION
        setState(() => _selectedAddressString = 'Failed to get address. Code: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      // ENGLISH TRANSLATION
      setState(() => _selectedAddressString = 'An error occurred: ${e.toString()}');
    } finally {
      if (!mounted) return;
      setState(() => _isLoadingAddress = false);
    }
  }

  void _onMapConfirm() {
    if (_selectedLocation != null &&
        _selectedAddressString.isNotEmpty &&
        !_selectedAddressString.toLowerCase().contains("loading") &&
        !_selectedAddressString.toLowerCase().contains("failed") &&
        !_selectedAddressString.toLowerCase().contains("error") &&
        !_selectedAddressString.toLowerCase().contains("not found")) {
      Navigator.pop(context, _selectedAddressString);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        // ENGLISH TRANSLATION
        const SnackBar(content: Text('Address is not valid or failed to load. Please try again or pick another point.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ENGLISH TRANSLATION
        title: Text('Select Location from Map', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
                         if (_selectedLocation != position.center) {
                            setState(() {
                              _selectedLocation = position.center;
                            });
                         }
                      }
                    },
                    onTap: (tapPosition, point) {
                       setState(() {
                         _selectedLocation = point;
                         _mapController.move(point, _mapController.camera.zoom);
                       });
                       _reverseGeocode(point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.muhammadjulianromadhoni.nestoraapp',
                    ),
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
                Positioned(
                  top: 10,
                  right: 10,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: _initializeMapLocation,
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
                                // ENGLISH TRANSLATION
                                _isLoadingAddress ? "Loading address..." : _selectedAddressString,
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
                        padding: const EdgeInsets.fromLTRB(16,8,16,16),
                        color: Colors.black.withOpacity(0.75),
                        child: ElevatedButton.icon(
                          // ENGLISH TRANSLATION
                          label: Text("Use This Address", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                          icon: const Icon(Icons.check_circle),
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