import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure Storage Service using Android KeyStore & iOS Keychain (AES-256 GCM encryption).
///
/// Ensures authentication tokens, session secrets, emergency SOS contacts, and sensitive local credentials
/// are NEVER stored in plain SharedPreferences.
class SecureStorageService {
  static final SecureStorageService instance = SecureStorageService._();
  SecureStorageService._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String _keyAuthToken = 'lifemate_sec_auth_token_v1';
  static const String _keyRefreshToken = 'lifemate_sec_refresh_token_v1';
  static const String _keyMasterKey = 'lifemate_sec_master_key_v1';
  static const String _keyTrustedContacts = 'lifemate_sec_trusted_contacts_v1';

  /// Save Auth Token securely in Android KeyStore
  Future<void> setAuthToken(String token) async {
    try {
      await _storage.write(key: _keyAuthToken, value: token);
    } catch (e) {
      debugPrint('[SECURE STORAGE] Error writing auth token: $e');
    }
  }

  /// Read Auth Token securely
  Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: _keyAuthToken);
    } catch (e) {
      debugPrint('[SECURE STORAGE] Error reading auth token: $e');
      return null;
    }
  }

  /// Save Refresh Token securely
  Future<void> setRefreshToken(String token) async {
    try {
      await _storage.write(key: _keyRefreshToken, value: token);
    } catch (e) {
      debugPrint('[SECURE STORAGE] Error writing refresh token: $e');
    }
  }

  /// Read Refresh Token securely
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _keyRefreshToken);
    } catch (e) {
      debugPrint('[SECURE STORAGE] Error reading refresh token: $e');
      return null;
    }
  }

  /// Save Trusted SOS Contacts securely
  Future<void> setTrustedContacts(String jsonStr) async {
    try {
      await _storage.write(key: _keyTrustedContacts, value: jsonStr);
    } catch (e) {
      debugPrint('[SECURE STORAGE] Error writing trusted contacts: $e');
    }
  }

  /// Read Trusted SOS Contacts securely
  Future<String?> getTrustedContacts() async {
    try {
      return await _storage.read(key: _keyTrustedContacts);
    } catch (e) {
      debugPrint('[SECURE STORAGE] Error reading trusted contacts: $e');
      return null;
    }
  }

  /// Delete all tokens on logout
  Future<void> clearAllTokens() async {
    try {
      await _storage.delete(key: _keyAuthToken);
      await _storage.delete(key: _keyRefreshToken);
    } catch (e) {
      debugPrint('[SECURE STORAGE] Error clearing tokens: $e');
    }
  }
}
