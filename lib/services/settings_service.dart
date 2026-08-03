import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

/// Singleton service managing user settings with local SharedPreferences cache and Cloud Firestore sync.
class SettingsService {
  static final SettingsService instance = SettingsService._internal();
  SettingsService._internal();

  static const String _keyTheme = 'settings_theme';
  static const String _keyLanguage = 'settings_language';
  static const String _keyNotificationEnabled = 'settings_notification_enabled';
  static const String _keyReminderSound = 'settings_reminder_sound';
  static const String _keyVoiceEnabled = 'settings_voice_enabled';
  static const String _keyTranslationLanguage = 'settings_translation_language';
  static const String _keyBackupEnabled = 'settings_backup_enabled';
  static const String _keyBiometricEnabled = 'settings_biometric_enabled';
  static const String _keyDarkMode = 'settings_dark_mode';

  String theme = 'Default';
  String language = 'English';
  bool notificationEnabled = true;
  String reminderSound = 'Default Chime';
  bool voiceEnabled = true;
  String translationLanguage = 'English';
  bool backupEnabled = true;
  bool biometricEnabled = false;
  bool darkMode = false;

  StreamSubscription<DocumentSnapshot>? _settingsSubscription;

  /// Load settings from local SharedPreferences and subscribe to Firestore real-time updates.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      theme = prefs.getString(_keyTheme) ?? 'Default';
      language = prefs.getString(_keyLanguage) ?? 'English';
      notificationEnabled = prefs.getBool(_keyNotificationEnabled) ?? true;
      reminderSound = prefs.getString(_keyReminderSound) ?? 'Default Chime';
      voiceEnabled = prefs.getBool(_keyVoiceEnabled) ?? true;
      translationLanguage = prefs.getString(_keyTranslationLanguage) ?? 'English';
      backupEnabled = prefs.getBool(_keyBackupEnabled) ?? true;
      biometricEnabled = prefs.getBool(_keyBiometricEnabled) ?? false;
      darkMode = prefs.getBool(_keyDarkMode) ?? false;

      // Initialize real-time Cloud Firestore sync
      initCloudSync();
    } catch (e) {
      debugPrint('[SETTINGS SERVICE] Error loading local settings: $e');
    }
  }

  /// Subscribe to real-time Cloud Firestore updates for users/{uid}/settings/preferences
  void initCloudSync() {
    _settingsSubscription?.cancel();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || AuthService.instance.isGuestMode) {
      debugPrint('[SETTINGS CLOUD] Guest mode or unauthenticated. Using local storage only.');
      return;
    }

    final docPath = 'users/${user.uid}/settings/preferences';
    debugPrint('[SETTINGS CLOUD] Subscribing to real-time settings document at $docPath...');

    _settingsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('preferences')
        .snapshots()
        .listen(
      (snapshot) async {
        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data()!;
          debugPrint('[SETTINGS CLOUD STREAM] Received settings update from Firestore');
          theme = (data['theme'] as String?) ?? theme;
          language = (data['language'] as String?) ?? language;
          notificationEnabled = (data['notificationEnabled'] as bool?) ?? notificationEnabled;
          reminderSound = (data['reminderSound'] as String?) ?? reminderSound;
          voiceEnabled = (data['voiceEnabled'] as bool?) ?? voiceEnabled;
          translationLanguage = (data['translationLanguage'] as String?) ?? translationLanguage;
          backupEnabled = (data['backupEnabled'] as bool?) ?? backupEnabled;
          biometricEnabled = (data['biometricEnabled'] as bool?) ?? biometricEnabled;
          darkMode = (data['darkMode'] as bool?) ?? darkMode;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_keyTheme, theme);
          await prefs.setString(_keyLanguage, language);
          await prefs.setBool(_keyNotificationEnabled, notificationEnabled);
          await prefs.setString(_keyReminderSound, reminderSound);
          await prefs.setBool(_keyVoiceEnabled, voiceEnabled);
          await prefs.setString(_keyTranslationLanguage, translationLanguage);
          await prefs.setBool(_keyBackupEnabled, backupEnabled);
          await prefs.setBool(_keyBiometricEnabled, biometricEnabled);
          await prefs.setBool(_keyDarkMode, darkMode);
        } else {
          // Document does not exist yet — upload current settings
          await syncToCloud();
        }
      },
      onError: (error) {
        debugPrint('[SETTINGS CLOUD STREAM ERROR] Error listening to settings stream: $error');
      },
    );
  }

  /// Stop active Cloud Firestore real-time settings subscription
  void stopCloudSync() {
    _settingsSubscription?.cancel();
    _settingsSubscription = null;
  }

  /// Update settings locally and sync to Cloud Firestore
  Future<void> updateSettings({
    String? newTheme,
    String? newLanguage,
    bool? newNotificationEnabled,
    String? newReminderSound,
    bool? newVoiceEnabled,
    String? newTranslationLanguage,
    bool? newBackupEnabled,
    bool? newBiometricEnabled,
    bool? newDarkMode,
  }) async {
    try {
      if (newTheme != null) theme = newTheme;
      if (newLanguage != null) language = newLanguage;
      if (newNotificationEnabled != null) notificationEnabled = newNotificationEnabled;
      if (newReminderSound != null) reminderSound = newReminderSound;
      if (newVoiceEnabled != null) voiceEnabled = newVoiceEnabled;
      if (newTranslationLanguage != null) translationLanguage = newTranslationLanguage;
      if (newBackupEnabled != null) backupEnabled = newBackupEnabled;
      if (newBiometricEnabled != null) biometricEnabled = newBiometricEnabled;
      if (newDarkMode != null) darkMode = newDarkMode;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyTheme, theme);
      await prefs.setString(_keyLanguage, language);
      await prefs.setBool(_keyNotificationEnabled, notificationEnabled);
      await prefs.setString(_keyReminderSound, reminderSound);
      await prefs.setBool(_keyVoiceEnabled, voiceEnabled);
      await prefs.setString(_keyTranslationLanguage, translationLanguage);
      await prefs.setBool(_keyBackupEnabled, backupEnabled);
      await prefs.setBool(_keyBiometricEnabled, biometricEnabled);
      await prefs.setBool(_keyDarkMode, darkMode);

      // Cloud Firestore Sync
      await syncToCloud();
    } catch (e) {
      debugPrint('[SETTINGS SERVICE] Error saving settings: $e');
    }
  }

  /// Upload current settings map to Cloud Firestore users/{uid}/settings/preferences
  Future<bool> syncToCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || AuthService.instance.isGuestMode) return false;

      final settingsMap = {
        'theme': theme,
        'language': language,
        'notificationEnabled': notificationEnabled,
        'reminderSound': reminderSound,
        'voiceEnabled': voiceEnabled,
        'translationLanguage': translationLanguage,
        'backupEnabled': backupEnabled,
        'biometricEnabled': biometricEnabled,
        'darkMode': darkMode,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      debugPrint('[SETTINGS CLOUD] Uploading settings to users/${user.uid}/settings/preferences...');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('preferences')
          .set(settingsMap, SetOptions(merge: true))
          .timeout(const Duration(seconds: 12));

      debugPrint('[SETTINGS CLOUD SUCCESS] Settings saved in Firestore users/${user.uid}/settings/preferences');
      return true;
    } on FirebaseException catch (e) {
      debugPrint('[SETTINGS CLOUD ERROR] FirebaseException uploading settings: ${e.code} - ${e.message}');
    } catch (e) {
      debugPrint('[SETTINGS CLOUD ERROR] Error uploading settings: $e');
    }
    return false;
  }
}
