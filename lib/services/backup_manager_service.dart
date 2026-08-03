import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'diary_service.dart';
import 'profile_service.dart';
import 'settings_service.dart';
import 'task_service.dart';
import 'transaction_service.dart';

enum CloudSyncStatus { synced, syncing, offline, waitingForInternet }

/// Backup Manager & Multi-Device Sync Service for Lifemate.
class BackupManagerService {
  static const String _prefCloudBackupEnabledKey = 'lifemate_cloud_backup_enabled_v1';
  static const String _prefLastBackupTimeKey = 'lifemate_last_backup_time_v1';
  static const String _prefLastRestoreTimeKey = 'lifemate_last_restore_time_v1';

  static final BackupManagerService instance = BackupManagerService._();
  BackupManagerService._();

  bool _isCloudBackupEnabled = true;
  DateTime? _lastBackupTime;
  DateTime? _lastRestoreTime;
  CloudSyncStatus _syncStatus = CloudSyncStatus.synced;

  bool get isCloudBackupEnabled => _isCloudBackupEnabled;
  DateTime? get lastBackupTime => _lastBackupTime;
  DateTime? get lastRestoreTime => _lastRestoreTime;
  CloudSyncStatus get syncStatus => _syncStatus;

  String get syncStatusText {
    switch (_syncStatus) {
      case CloudSyncStatus.synced:
        return 'Synced';
      case CloudSyncStatus.syncing:
        return 'Syncing...';
      case CloudSyncStatus.offline:
        return 'Offline';
      case CloudSyncStatus.waitingForInternet:
        return 'Waiting for internet';
    }
  }

  /// Initialize backup & restore state from local storage.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isCloudBackupEnabled = prefs.getBool(_prefCloudBackupEnabledKey) ?? true;
      
      final backupTimeStr = prefs.getString(_prefLastBackupTimeKey);
      if (backupTimeStr != null) {
        _lastBackupTime = DateTime.parse(backupTimeStr);
      }

      final restoreTimeStr = prefs.getString(_prefLastRestoreTimeKey);
      if (restoreTimeStr != null) {
        _lastRestoreTime = DateTime.parse(restoreTimeStr);
      }

      if (AuthService.instance.isLoggedIn && !AuthService.instance.isGuestMode) {
        await performFullCloudRestore();
      }
    } catch (e) {
      debugPrint('[BACKUP MANAGER] Error loading backup settings: $e');
    }
  }

  /// Toggle cloud backup & automatic sync feature.
  Future<void> setCloudBackupEnabled(bool enabled) async {
    _isCloudBackupEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefCloudBackupEnabledKey, enabled);
    if (enabled) {
      await triggerFullSync();
    }
  }

  /// Perform full automatic cloud restore across Profile, Tasks, Diary, Expenses, and Settings.
  Future<bool> performFullCloudRestore() async {
    if (!AuthService.instance.isLoggedIn || AuthService.instance.isGuestMode) {
      return false;
    }

    try {
      _syncStatus = CloudSyncStatus.syncing;
      debugPrint('[BACKUP RESTORE] Initiating full cloud data restore from Firestore...');

      await ProfileService.instance.fetchFromCloud();
      await TaskService.instance.load();
      await DiaryService.instance.load();
      await TransactionService.instance.load();
      await SettingsService.instance.load();

      _lastRestoreTime = DateTime.now();
      _lastBackupTime = DateTime.now();
      _syncStatus = CloudSyncStatus.synced;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefLastRestoreTimeKey, _lastRestoreTime!.toIso8601String());
      await prefs.setString(_prefLastBackupTimeKey, _lastBackupTime!.toIso8601String());

      debugPrint('[BACKUP RESTORE SUCCESS] All cloud modules restored successfully!');
      return true;
    } catch (e) {
      debugPrint('[BACKUP RESTORE ERROR] Error during cloud restore: $e');
      _syncStatus = CloudSyncStatus.offline;
      return false;
    }
  }

  /// Trigger manual/automatic full cloud sync of all modules.
  Future<bool> triggerFullSync() async {
    if (!AuthService.instance.isLoggedIn || AuthService.instance.isGuestMode) {
      return false;
    }

    try {
      _syncStatus = CloudSyncStatus.syncing;
      debugPrint('[BACKUP SYNC] Initiating full cloud sync across all modules...');

      await ProfileService.instance.syncToCloud();
      TaskService.instance.initCloudSync();
      DiaryService.instance.initCloudSync();
      TransactionService.instance.initCloudSync();
      await SettingsService.instance.syncToCloud();

      _lastBackupTime = DateTime.now();
      _syncStatus = CloudSyncStatus.synced;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefLastBackupTimeKey, _lastBackupTime!.toIso8601String());

      debugPrint('[BACKUP SYNC SUCCESS] All modules synchronized with Cloud Firestore!');
      return true;
    } catch (e) {
      debugPrint('[BACKUP SYNC ERROR] Error during full sync: $e');
      _syncStatus = CloudSyncStatus.offline;
      return false;
    }
  }

  /// Estimated total data storage usage formatted as String (e.g., '1.8 MB').
  String get storageUsageFormatted {
    final taskBytes = TaskService.instance.all.length * 256;
    final diaryBytes = DiaryService.instance.all.length * 512;
    final txBytes = TransactionService.instance.all.length * 200;
    final totalBytes = taskBytes + diaryBytes + txBytes + 150000;
    
    if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
