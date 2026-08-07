import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/saved_place.dart';

/// Structured location address result.
class LocationAddress {
  final String area;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String fullFormatted;

  const LocationAddress({
    required this.area,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.fullFormatted,
  });

  factory LocationAddress.fallback(double lat, double lng) {
    return LocationAddress(
      area: '',
      city: '',
      state: '',
      country: '',
      postalCode: '',
      fullFormatted: 'Coordinates (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})',
    );
  }
}

/// Status of location service / permissions.
enum LocationStatus {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  ready,
}

/// Service managing Smart Location (on-demand, foreground-only, battery-friendly).
class LocationService {
  static const String _storageKey = 'lifemate_saved_places_v1';

  static final LocationService instance = LocationService._();
  LocationService._();

  List<SavedPlace> _savedPlaces = [];

  List<SavedPlace> get savedPlaces => List.unmodifiable(_savedPlaces);

  //  Permission & Status Check 

  /// Verify location permissions and device GPS enablement.
  Future<LocationStatus> checkStatus() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationStatus.serviceDisabled;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationStatus.permissionDenied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationStatus.permissionDeniedForever;
    }

    return LocationStatus.ready;
  }

  /// Request runtime location permission while using app.
  Future<LocationStatus> requestPermission() async {
    var permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return LocationStatus.permissionDenied;
    }
    if (permission == LocationPermission.deniedForever) {
      return LocationStatus.permissionDeniedForever;
    }
    return LocationStatus.ready;
  }

  /// Open device Location / App settings.
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  //  Single-Shot Location Retrieval 

  /// Get current GPS position on-demand. Returns null if service/permission disabled.
  Future<Position?> getCurrentPosition() async {
    try {
      final status = await checkStatus();
      if (status != LocationStatus.ready) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (e) {
      debugPrint('[SmartLocation] Error getting current position: $e');
      return null;
    }
  }

  /// Reverse-geocode coordinates into a structured [LocationAddress].
  Future<LocationAddress> getDetailedAddress(double lat, double lng) async {
    try {
      debugPrint('[SmartLocation] Performing reverse geocoding for ($lat, $lng)...');
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        debugPrint(
          '[SmartLocation] Placemark received: name="${p.name}", subLocality="${p.subLocality}", '
          'locality="${p.locality}", subAdmin="${p.subAdministrativeArea}", admin="${p.administrativeArea}", '
          'country="${p.country}", postal="${p.postalCode}"',
        );

        final area = (p.subLocality?.isNotEmpty == true)
            ? p.subLocality!
            : (p.thoroughfare?.isNotEmpty == true)
                ? p.thoroughfare!
                : (p.name?.isNotEmpty == true && p.name != p.postalCode)
                    ? p.name!
                    : '';

        final city = (p.locality?.isNotEmpty == true)
            ? p.locality!
            : (p.subAdministrativeArea?.isNotEmpty == true)
                ? p.subAdministrativeArea!
                : '';

        final state = p.administrativeArea ?? '';
        final country = p.country ?? '';
        final postalCode = p.postalCode ?? '';

        final parts = <String>[];
        if (area.isNotEmpty) parts.add(area);
        if (city.isNotEmpty && !parts.contains(city)) parts.add(city);
        if (state.isNotEmpty && !parts.contains(state)) parts.add(state);
        if (country.isNotEmpty && !parts.contains(country)) parts.add(country);

        final formatted = parts.isNotEmpty
            ? parts.join(', ')
            : 'Coordinates (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';

        return LocationAddress(
          area: area,
          city: city,
          state: state,
          country: country,
          postalCode: postalCode,
          fullFormatted: formatted,
        );
      }
    } catch (e, st) {
      debugPrint('[SmartLocation] Reverse geocoding Exception: $e\n$st');
    }

    return LocationAddress.fallback(lat, lng);
  }

  /// Format address string for simple display.
  Future<String> getReadableAddress(double lat, double lng) async {
    final addr = await getDetailedAddress(lat, lng);
    return addr.fullFormatted;
  }

  /// Calculate distance in meters between two coordinates.
  double calculateDistanceMeters(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Format distance into readable string e.g. "2.4 km" or "450 m".
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  //  Open in Maps 

  /// Open coordinates in native Google Maps app or installed maps application.
  Future<bool> openInMaps(double lat, double lng, {String? label}) async {
    final labelPart = (label != null && label.isNotEmpty) ? '(${Uri.encodeComponent(label)})' : '';

    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng$labelPart');
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    final fallbackUrl = Uri.parse('https://maps.google.com/?q=$lat,$lng');

    debugPrint('[SmartLocation] Attempting to open maps with geoUri: $geoUri');

    // 1. Try native geo: intent first
    try {
      if (await canLaunchUrl(geoUri)) {
        final success = await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        if (success) return true;
      } else {
        // Force attempt launchUrl on Android even if canLaunchUrl returns false
        final success = await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        if (success) return true;
      }
    } catch (e) {
      debugPrint('[SmartLocation] geoUri launch attempt error: $e');
    }

    // 2. Try standard Google Maps web search URL
    try {
      debugPrint('[SmartLocation] Attempting googleMapsUrl: $googleMapsUrl');
      if (await canLaunchUrl(googleMapsUrl)) {
        final success = await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
        if (success) return true;
      } else {
        final success = await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
        if (success) return true;
      }
    } catch (e) {
      debugPrint('[SmartLocation] googleMapsUrl launch attempt error: $e');
    }

    // 3. Try legacy google maps fallback URL
    try {
      debugPrint('[SmartLocation] Attempting fallbackUrl: $fallbackUrl');
      return await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[SmartLocation] fallbackUrl launch attempt error: $e');
    }

    return false;
  }

  //  Saved Places Storage 

  /// Load all saved places from SharedPreferences.
  Future<void> loadSavedPlaces() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr == null) {
        _savedPlaces = [];
        return;
      }
      final List<dynamic> raw = jsonDecode(jsonStr) as List<dynamic>;
      _savedPlaces = raw
          .map((j) => SavedPlace.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _savedPlaces = [];
    }
  }

  Future<void> _saveSavedPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_savedPlaces.map((p) => p.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }

  Future<void> addPlace(SavedPlace place) async {
    _savedPlaces.insert(0, place);
    await _saveSavedPlaces();
  }

  Future<void> updatePlace(SavedPlace place) async {
    final i = _savedPlaces.indexWhere((p) => p.id == place.id);
    if (i != -1) {
      _savedPlaces[i] = place;
      await _saveSavedPlaces();
    }
  }

  Future<void> deletePlace(String id) async {
    _savedPlaces.removeWhere((p) => p.id == id);
    await _saveSavedPlaces();
  }
}
