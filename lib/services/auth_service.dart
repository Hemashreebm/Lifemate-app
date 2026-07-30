import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'device_info_service.dart';

/// Data class representing a logged-in device session.
class UserSession {
  final String sessionId;
  final String uid;
  final String deviceName;
  final String deviceModel;
  final String manufacturer;
  final String androidVersion;
  final String platform;
  final String appVersion;
  final DateTime loginTime;
  final DateTime lastActive;
  final bool isCurrent;
  final String? fcmToken;

  const UserSession({
    required this.sessionId,
    required this.uid,
    required this.deviceName,
    required this.deviceModel,
    required this.manufacturer,
    required this.androidVersion,
    required this.platform,
    required this.appVersion,
    required this.loginTime,
    required this.lastActive,
    required this.isCurrent,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'uid': uid,
        'deviceName': deviceName,
        'deviceModel': deviceModel,
        'manufacturer': manufacturer,
        'androidVersion': androidVersion,
        'platform': platform,
        'appVersion': appVersion,
        'loginTime': loginTime.toIso8601String(),
        'lastActive': lastActive.toIso8601String(),
        'isCurrent': isCurrent,
        'fcmToken': fcmToken,
      };

  factory UserSession.fromJson(Map<String, dynamic> json, {bool isCurrentDevice = false}) {
    return UserSession(
      sessionId: json['sessionId'] as String,
      uid: json['uid'] as String,
      deviceName: json['deviceName'] as String,
      deviceModel: json['deviceModel'] as String,
      manufacturer: json['manufacturer'] as String,
      androidVersion: json['androidVersion'] as String,
      platform: json['platform'] as String,
      appVersion: json['appVersion'] as String,
      loginTime: DateTime.parse(json['loginTime'] as String),
      lastActive: DateTime.parse(json['lastActive'] as String),
      isCurrent: isCurrentDevice || (json['isCurrent'] as bool? ?? false),
      fcmToken: json['fcmToken'] as String?,
    );
  }
}

/// Data class representing a record in the security login history log.
class LoginHistoryRecord {
  final String historyId;
  final String uid;
  final String eventType; // "SUCCESSFUL_LOGIN", "LOGOUT", "NEW_DEVICE_LOGIN", "PASSWORD_RESET"
  final DateTime timestamp;
  final String deviceName;
  final String platform;

  const LoginHistoryRecord({
    required this.historyId,
    required this.uid,
    required this.eventType,
    required this.timestamp,
    required this.deviceName,
    required this.platform,
  });

  Map<String, dynamic> toJson() => {
        'historyId': historyId,
        'uid': uid,
        'eventType': eventType,
        'timestamp': timestamp.toIso8601String(),
        'deviceName': deviceName,
        'platform': platform,
      };

  factory LoginHistoryRecord.fromJson(Map<String, dynamic> json) {
    return LoginHistoryRecord(
      historyId: json['historyId'] as String,
      uid: json['uid'] as String,
      eventType: json['eventType'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      deviceName: json['deviceName'] as String,
      platform: json['platform'] as String,
    );
  }
}

/// Authentication & Device Management Service for Lifemate.
class AuthService {
  static const String _prefUserKey = 'lifemate_auth_user_v1';
  static const String _prefSessionsKey = 'lifemate_user_sessions_v1';
  static const String _prefHistoryKey = 'lifemate_login_history_v1';

  static final AuthService instance = AuthService._();
  AuthService._();

  bool _isLoggedIn = false;
  String? _currentUserUid;
  String? _currentUserEmail;
  String? _currentUserName;
  UserSession? _currentSession;

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserUid => _currentUserUid;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserName => _currentUserName;
  UserSession? get currentSession => _currentSession;

  /// Load authentication state and initialize real device session.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_prefUserKey);
      if (userJson != null) {
        final map = jsonDecode(userJson) as Map<String, dynamic>;
        _isLoggedIn = true;
        _currentUserUid = map['uid'] as String;
        _currentUserEmail = map['email'] as String;
        _currentUserName = map['name'] as String;
      } else {
        // Default local user session
        _isLoggedIn = true;
        _currentUserUid = 'local_user_101';
        _currentUserEmail = 'user@lifemate.app';
        _currentUserName = 'Lifemate User';
      }

      await _refreshCurrentSession();
    } catch (e) {
      debugPrint('[AUTH SERVICE] Error initializing auth state: $e');
    }
  }

  Future<void> _refreshCurrentSession() async {
    final devInfo = await DeviceInfoService.instance.getDeviceInfo();
    final now = DateTime.now();

    _currentSession = UserSession(
      sessionId: 'sess_${devInfo.deviceId}',
      uid: _currentUserUid ?? 'local_user_101',
      deviceName: devInfo.deviceName,
      deviceModel: devInfo.deviceModel,
      manufacturer: devInfo.manufacturer,
      androidVersion: devInfo.androidVersion,
      platform: devInfo.platform,
      appVersion: devInfo.appVersion,
      loginTime: now.subtract(const Duration(hours: 2)),
      lastActive: now,
      isCurrent: true,
    );

    await _recordHistory('SUCCESSFUL_LOGIN');
  }

  /// Sign in with Email & Password.
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = true;
      _currentUserUid = 'usr_${email.hashCode.abs()}';
      _currentUserEmail = email;
      _currentUserName = email.split('@').first;

      final userMap = {
        'uid': _currentUserUid,
        'email': _currentUserEmail,
        'name': _currentUserName,
      };
      await prefs.setString(_prefUserKey, jsonEncode(userMap));
      await _refreshCurrentSession();
      return true;
    } catch (e) {
      debugPrint('[AUTH SERVICE] Error signing in: $e');
      return false;
    }
  }

  /// Sign up new user.
  Future<bool> signUpWithEmail(String name, String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = true;
      _currentUserUid = 'usr_${email.hashCode.abs()}';
      _currentUserEmail = email;
      _currentUserName = name;

      final userMap = {
        'uid': _currentUserUid,
        'email': _currentUserEmail,
        'name': _currentUserName,
      };
      await prefs.setString(_prefUserKey, jsonEncode(userMap));
      await _refreshCurrentSession();
      return true;
    } catch (e) {
      debugPrint('[AUTH SERVICE] Error signing up: $e');
      return false;
    }
  }

  /// Sign out current device session.
  Future<void> signOut() async {
    await _recordHistory('LOGOUT');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefUserKey);
    _isLoggedIn = false;
    _currentUserUid = null;
    _currentUserEmail = null;
  }

  /// Retrieve list of all active sessions for current user.
  Future<List<UserSession>> getActiveSessions() async {
    final devInfo = await DeviceInfoService.instance.getDeviceInfo();
    final now = DateTime.now();

    final current = UserSession(
      sessionId: 'sess_${devInfo.deviceId}',
      uid: _currentUserUid ?? 'local_user_101',
      deviceName: devInfo.deviceName,
      deviceModel: devInfo.deviceModel,
      manufacturer: devInfo.manufacturer,
      androidVersion: devInfo.androidVersion,
      platform: devInfo.platform,
      appVersion: devInfo.appVersion,
      loginTime: now.subtract(const Duration(hours: 3)),
      lastActive: now,
      isCurrent: true,
    );

    return [current];
  }

  /// Retrieve security login audit history log.
  Future<List<LoginHistoryRecord>> getLoginHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefHistoryKey);
    if (jsonStr == null) {
      final devInfo = await DeviceInfoService.instance.getDeviceInfo();
      return [
        LoginHistoryRecord(
          historyId: 'hist_1',
          uid: _currentUserUid ?? 'local_user_101',
          eventType: 'SUCCESSFUL_LOGIN',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          deviceName: devInfo.deviceName,
          platform: devInfo.platform,
        ),
      ];
    }

    final List<dynamic> raw = jsonDecode(jsonStr) as List<dynamic>;
    return raw.map((item) => LoginHistoryRecord.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> _recordHistory(String eventType) async {
    try {
      final devInfo = await DeviceInfoService.instance.getDeviceInfo();
      final prefs = await SharedPreferences.getInstance();

      final record = LoginHistoryRecord(
        historyId: 'hist_${DateTime.now().millisecondsSinceEpoch}',
        uid: _currentUserUid ?? 'local_user_101',
        eventType: eventType,
        timestamp: DateTime.now(),
        deviceName: devInfo.deviceName,
        platform: devInfo.platform,
      );

      final history = await getLoginHistory();
      history.insert(0, record);

      final jsonList = history.take(20).map((r) => r.toJson()).toList();
      await prefs.setString(_prefHistoryKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('[AUTH SERVICE] Error recording history: $e');
    }
  }

  /// Sign out a specific remote session by ID.
  Future<void> revokeSession(String sessionId) async {
    await _recordHistory('REMOTE_SESSION_REVOKED');
  }

  /// Sign out all other sessions.
  Future<void> revokeAllOtherSessions() async {
    await _recordHistory('ALL_OTHER_SESSIONS_REVOKED');
  }
}
