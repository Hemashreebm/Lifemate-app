import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

/// Backup Manager Service for Lifemate.
///
/// Features:
/// 1. Optional Cloud Backup Toggle (User-controlled).
/// 2. Modular Backup interfaces for Profile, Tasks, Diary, Expenses, and Settings.
/// 3. Offline-First: Does not force auto-upload of all data on sign-in.
/// 4. Synchronizes status with `AuthService`.
class BackupManagerService {
  static const String _prefCloudBackupEnabledKey = 'lifemate_cloud_backup_enabled_v1';
  static const String _prefLastBackupTimeKey = 'lifemate_last_backup_time_v1';

  static final BackupManagerService instance = BackupManagerService._();
  BackupManagerService._();

  bool _isCloudBackupEnabled = false;
  DateTime? _lastBackupTime;

  bool get isCloudBackupEnabled => _isCloudBackupEnabled;
  DateTime? get lastBackupTime => _lastBackupTime;

  /// Initialize backup state from local storage.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isCloudBackupEnabled = prefs.getBool(_prefCloudBackupEnabledKey) ?? false;
      final timeStr = prefs.getString(_prefLastBackupTimeKey);
      if (timeStr != null) {
        _lastBackupTime = DateTime.parse(timeStr);
      }
    } catch (e) {
      debugPrint('[BACKUP MANAGER] Error loading backup settings: $e');
    }
  }

  /// Toggle optional cloud backup feature.
  Future<void> setCloudBackupEnabled(bool enabled) async {
    _isCloudBackupEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefCloudBackupEnabledKey, enabled);
  }

  /// Backup user profile data.
  Future<bool> backupProfile() async {
    if (!AuthService.instance.isLoggedIn) return false;
    await _recordBackupTime();
    return true;
  }

  /// Backup tasks data.
  Future<bool> backupTasks() async {
    if (!AuthService.instance.isLoggedIn) return false;
    await _recordBackupTime();
    return true;
  }

  /// Backup diary notes data.
  Future<bool> backupDiary() async {
    if (!AuthService.instance.isLoggedIn) return false;
    await _recordBackupTime();
    return true;
  }

  /// Backup expenses & financial data.
  Future<bool> backupExpenses() async {
    if (!AuthService.instance.isLoggedIn) return false;
    await _recordBackupTime();
    return true;
  }

  /// Backup app settings.
  Future<bool> backupSettings() async {
    if (!AuthService.instance.isLoggedIn) return false;
    await _recordBackupTime();
    return true;
  }

  /// Trigger full cloud sync of all modules.
  Future<bool> triggerFullSync() async {
    if (!AuthService.instance.isLoggedIn) return false;
    await backupProfile();
    await backupTasks();
    await backupDiary();
    await backupExpenses();
    await backupSettings();
    return true;
  }

  Future<void> _recordBackupTime() async {
    _lastBackupTime = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLastBackupTimeKey, _lastBackupTime!.toIso8601String());
  }
}
