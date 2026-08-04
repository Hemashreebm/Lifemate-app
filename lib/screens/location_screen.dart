import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../models/saved_place.dart';
import '../services/location_service.dart';
import 'safety_screen.dart';

/// Main Smart Location screen (Foreground-only, privacy-safe, battery-friendly).
class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final _locSvc = LocationService.instance;

  LocationStatus _status = LocationStatus.permissionDenied;
  Position? _currentPosition;
  LocationAddress _detailedAddress = LocationAddress.fallback(0, 0);
  DateTime? _lastUpdated;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    await _locSvc.loadSavedPlaces();
    await _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    final status = await _locSvc.checkStatus();
    setState(() => _status = status);

    if (status == LocationStatus.ready) {
      final pos = await _locSvc.getCurrentPosition();
      if (pos != null) {
        final addr = await _locSvc.getDetailedAddress(pos.latitude, pos.longitude);
        if (mounted) {
          setState(() {
            _currentPosition = pos;
            _detailedAddress = addr;
            _lastUpdated = DateTime.now();
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _detailedAddress = LocationAddress(
              area: '',
              city: '',
              state: '',
              country: '',
              postalCode: '',
              fullFormatted: 'Could not determine position. Please tap Refresh.',
            );
          });
        }
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _copyLocation() {
    if (_currentPosition == null) return;
    final text = 'My Location:\n'
        'Area: ${_detailedAddress.area}\n'
        'City: ${_detailedAddress.city}\n'
        'State: ${_detailedAddress.state}\n'
        'Country: ${_detailedAddress.country}\n'
        'Full Address: ${_detailedAddress.fullFormatted}\n'
        'Latitude: ${_currentPosition!.latitude}\n'
        'Longitude: ${_currentPosition!.longitude}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location coordinates copied to clipboard! ðŸ“‹'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openInMaps(double lat, double lng, {String? label}) async {
    final launched = await _locSvc.openInMaps(lat, lng, label: label);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No compatible map application available to open coordinates.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showAddPlaceDialog() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please refresh current location first.')),
      );
      return;
    }

    final nameCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Save Current Place', style: TextStyle(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Coordinates: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 4),
              Text(
                'Address: ${_detailedAddress.fullFormatted}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Place Name (e.g. Home, College, Work)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Optional Note',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirm == true && nameCtrl.text.trim().isNotEmpty) {
      final newPlace = SavedPlace(
        id: SavedPlace.generateId(),
        name: nameCtrl.text.trim(),
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        address: _detailedAddress.fullFormatted,
        note: noteCtrl.text.trim(),
        createdAt: DateTime.now(),
      );
      await _locSvc.addPlace(newPlace);
      setState(() {});
    }
  }

  Future<void> _deletePlace(SavedPlace place) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete "${place.name}"?'),
        content: const Text('Are you sure you want to delete this saved place?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _locSvc.deletePlace(place.id);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
      appBar: AppBar(
        title: const Text('Smart Location', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // â”€â”€ Header Subtitle â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            const Text(
              'Your location, when you need it.',
              style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),

            // â”€â”€ Permission / GPS Status Banner (If disabled) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            if (_status != LocationStatus.ready) _buildStatusWarningCard(),

            // â”€â”€ Current Location Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildCurrentLocationCard(),

            const SizedBox(height: 20),

            // â”€â”€ Saved Places Section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildSavedPlacesHeader(),
            const SizedBox(height: 12),
            _buildSavedPlacesList(),

            const SizedBox(height: 24),

            // â”€â”€ Privacy Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildPrivacyCard(),

            const SizedBox(height: 20),

            // â”€â”€ Safety — Coming Later Section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildSafetyComingLaterCard(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // â”€â”€ Card Builders â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildStatusWarningCard() {
    String msg = '';
    VoidCallback? action;
    String actionBtn = '';

    if (_status == LocationStatus.serviceDisabled) {
      msg = 'Location/GPS is turned off on your device.';
      actionBtn = 'Open Location Settings';
      action = () => _locSvc.openLocationSettings();
    } else if (_status == LocationStatus.permissionDenied) {
      msg = 'Location permission is required to detect your location.';
      actionBtn = 'Grant Permission';
      action = () async {
        await _locSvc.requestPermission();
        _fetchLocation();
      };
    } else if (_status == LocationStatus.permissionDeniedForever) {
      msg = 'Location permission is permanently denied. Please enable it in Settings.';
      actionBtn = 'Open App Settings';
      action = () => _locSvc.openAppSettings();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 20),
              SizedBox(width: 8),
              Text(
                'Location Action Needed',
                style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFB45309), fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(msg, style: const TextStyle(fontSize: 13, color: Color(0xFF92400E))),
          if (action != null) ...[
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: action,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(actionBtn),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: Color(0xFF8B5CF6), size: 24),
              const SizedBox(width: 10),
              const Text(
                'Current Location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E)),
              ),
              const Spacer(),
              if (_isLoading)
                const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Structured Address Fields
          if (_detailedAddress.area.isNotEmpty) ...[
            const Text('AREA / LOCALITY:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
            const SizedBox(height: 2),
            Text(
              _detailedAddress.area,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 10),
          ],

          Row(
            children: [
              if (_detailedAddress.city.isNotEmpty)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CITY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                      const SizedBox(height: 2),
                      Text(
                        _detailedAddress.city,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                      ),
                    ],
                  ),
                ),
              if (_detailedAddress.state.isNotEmpty)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('STATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                      const SizedBox(height: 2),
                      Text(
                        _detailedAddress.state,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          if (_detailedAddress.country.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('COUNTRY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                      const SizedBox(height: 2),
                      Text(
                        _detailedAddress.country,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                      ),
                    ],
                  ),
                ),
                if (_detailedAddress.postalCode.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('POSTAL CODE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                        const SizedBox(height: 2),
                        Text(
                          _detailedAddress.postalCode,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],

          const SizedBox(height: 10),
          const Text('FULL ADDRESS:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
          const SizedBox(height: 2),
          Text(
            _detailedAddress.fullFormatted,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 14),

          // Coordinates Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LATITUDE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                    const SizedBox(height: 2),
                    Text(
                      _currentPosition != null ? _currentPosition!.latitude.toStringAsFixed(6) : '---',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LONGITUDE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
                    const SizedBox(height: 2),
                    Text(
                      _currentPosition != null ? _currentPosition!.longitude.toStringAsFixed(6) : '---',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Accuracy & Last Updated
          Row(
            children: [
              Text(
                'Accuracy: ${_currentPosition != null ? "Â±${_currentPosition!.accuracy.round()} m" : "---"}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const Spacer(),
              Text(
                'Updated: ${_lastUpdated != null ? _formatTime(_lastUpdated!) : "---"}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Actions Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _fetchLocation,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Refresh'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8B5CF6),
                    side: const BorderSide(color: Color(0xFF8B5CF6)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _currentPosition != null
                      ? () => _openInMaps(_currentPosition!.latitude, _currentPosition!.longitude)
                      : null,
                  icon: const Icon(Icons.map_rounded, size: 18),
                  label: const Text('Open Maps'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _currentPosition != null ? _copyLocation : null,
                icon: const Icon(Icons.copy_rounded, color: Color(0xFF8B5CF6)),
                tooltip: 'Copy Location',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPlacesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'â­ Saved Places',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E)),
        ),
        TextButton.icon(
          onPressed: _showAddPlaceDialog,
          icon: const Icon(Icons.add_location_alt_rounded, size: 18),
          label: const Text('+ Save Place'),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF8B5CF6)),
        ),
      ],
    );
  }

  Widget _buildSavedPlacesList() {
    final places = _locSvc.savedPlaces;
    if (places.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'No saved places yet. Tap "+ Save Place" to save your home, college, or work coordinates.',
          style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: places.length,
      itemBuilder: (ctx, i) {
        final p = places[i];
        String distanceStr = '';
        if (_currentPosition != null) {
          final meters = _locSvc.calculateDistanceMeters(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            p.latitude,
            p.longitude,
          );
          distanceStr = '${_locSvc.formatDistance(meters)} away';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF8B5CF6).withAlpha(31),
              child: const Icon(Icons.star_rounded, color: Color(0xFF8B5CF6)),
            ),
            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
            subtitle: Text(
              distanceStr.isNotEmpty ? '$distanceStr • ${p.address}' : p.address,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.map_outlined, color: Color(0xFF8B5CF6)),
                  onPressed: () => _openInMaps(p.latitude, p.longitude, label: p.name),
                  tooltip: 'Open in Maps',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                  onPressed: () => _deletePlace(p),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrivacyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: const [
          Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy First',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1A1A2E)),
                ),
                SizedBox(height: 2),
                Text(
                  'Location is accessed on-demand only when you open or refresh this screen. No background tracking.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyComingLaterCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SafetyScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withAlpha(31),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.sos_rounded, color: Color(0xFFEF4444), size: 28),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ðŸ†˜ Safety & SOS',
                    style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF991B1B), fontSize: 16),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Emergency SOS, Trusted Contacts, Quick Call & Share',
                    style: TextStyle(fontSize: 12, color: Color(0xFF7F1D1D)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFEF4444)),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime d) {
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final min = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $ampm';
  }
}

