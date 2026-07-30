import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/trusted_contact.dart';
import 'location_service.dart';

/// Service managing Trusted Contacts and Safety SOS functions.
class SafetyService {
  static const String _storageKey = 'lifemate_trusted_contacts_v1';

  static final SafetyService instance = SafetyService._();
  SafetyService._();

  List<TrustedContact> _contacts = [];

  List<TrustedContact> get contacts => List.unmodifiable(_contacts);

  // ── Contact Storage ───────────────────────────────────────────────────────

  /// Load saved trusted contacts from SharedPreferences.
  Future<void> loadContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr == null) {
        _contacts = [];
        return;
      }
      final List<dynamic> raw = jsonDecode(jsonStr) as List<dynamic>;
      _contacts = raw
          .map((j) => TrustedContact.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[SafetyService] Error loading contacts: $e');
      _contacts = [];
    }
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_contacts.map((c) => c.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }

  Future<void> addContact(TrustedContact contact) async {
    _contacts.insert(0, contact);
    await _saveContacts();
  }

  Future<void> updateContact(TrustedContact contact) async {
    final i = _contacts.indexWhere((c) => c.id == contact.id);
    if (i != -1) {
      _contacts[i] = contact;
      await _saveContacts();
    }
  }

  Future<void> deleteContact(String id) async {
    _contacts.removeWhere((c) => c.id == id);
    await _saveContacts();
  }

  // ── Quick Phone Call (Dialer) ─────────────────────────────────────────────

  /// Opens the native Android Phone Dialer with the contact's number filled in.
  Future<bool> openDialer(String phoneNumber) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.isEmpty) return false;

    final uri = Uri.parse('tel:$cleaned');
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      // Direct launch fallback
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[SafetyService] Error launching phone dialer: $e');
      return false;
    }
  }

  // ── Emergency Message Formatting ─────────────────────────────────────────

  /// Generates editable emergency text containing current location and Google Maps link.
  String generateEmergencyMessage({
    required LocationAddress address,
    required double latitude,
    required double longitude,
  }) {
    final mapUrl = 'https://maps.google.com/?q=$latitude,$longitude';
    final locationText = address.fullFormatted.isNotEmpty
        ? address.fullFormatted
        : '$latitude, $longitude';

    return 'EMERGENCY SOS: I need help. Please contact me as soon as possible.\n\n'
        'My current location:\n'
        '$locationText\n\n'
        'Latitude: $latitude\n'
        'Longitude: $longitude\n\n'
        'Map Link:\n'
        '$mapUrl';
  }
}
