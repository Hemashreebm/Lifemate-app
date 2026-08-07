import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data class holding real hardware and OS metadata for the current physical device.
class DeviceInfoResult {
  final String deviceId;
  final String deviceName;
  final String deviceModel;
  final String manufacturer;
  final String androidVersion;
  final String platform;
  final String appVersion;

  const DeviceInfoResult({
    required this.deviceId,
    required this.deviceName,
    required this.deviceModel,
    required this.manufacturer,
    required this.androidVersion,
    required this.platform,
    required this.appVersion,
  });
}

/// Service that reads real hardware & OS information using `device_info_plus`.
class DeviceInfoService {
  static const String _prefDeviceIdKey = 'lifemate_safe_device_id_v1';
  static final DeviceInfoService instance = DeviceInfoService._();
  DeviceInfoService._();

  DeviceInfoResult? _cachedInfo;
  DeviceInfoResult? get cachedInfo => _cachedInfo;

  /// Read real device information using `device_info_plus`.
  Future<DeviceInfoResult> getDeviceInfo() async {
    if (_cachedInfo != null) return _cachedInfo!;

    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString(_prefDeviceIdKey);
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = 'dev_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (DateTime.now().microsecond % 8999))}';
      await prefs.setString(_prefDeviceIdKey, deviceId);
    }

    final plugin = DeviceInfoPlugin();
    String deviceName = 'Mobile Device';
    String deviceModel = 'Unknown Model';
    String manufacturer = 'Generic';
    String androidVersion = 'Android';
    String platform = 'Mobile';
    const String appVersion = '1.0.3+4';

    try {
      if (kIsWeb) {
        platform = 'Web Browser';
        final web = await plugin.webBrowserInfo;
        deviceName = web.browserName.name.toUpperCase();
        deviceModel = web.userAgent ?? 'Web Browser';
        manufacturer = web.vendor ?? 'Browser';
        androidVersion = 'Web';
      } else if (Platform.isAndroid) {
        platform = 'Android';
        final android = await plugin.androidInfo;
        manufacturer = _capitalize(android.manufacturer);
        deviceModel = android.model;
        deviceName = '$manufacturer ${android.model}';
        androidVersion = 'Android ${android.version.release} (API ${android.version.sdkInt})';
      } else if (Platform.isIOS) {
        platform = 'iOS';
        final ios = await plugin.iosInfo;
        deviceName = ios.name;
        deviceModel = ios.model;
        manufacturer = 'Apple';
        androidVersion = 'iOS ${ios.systemVersion}';
      } else if (Platform.isWindows) {
        platform = 'Windows PC';
        final win = await plugin.windowsInfo;
        deviceName = win.computerName;
        deviceModel = 'Windows PC';
        manufacturer = 'Microsoft';
        androidVersion = 'Windows ${win.majorVersion}.${win.minorVersion}';
      }
    } catch (e) {
      debugPrint('[DEVICE INFO] Error fetching hardware info: $e');
    }

    _cachedInfo = DeviceInfoResult(
      deviceId: deviceId,
      deviceName: deviceName,
      deviceModel: deviceModel,
      manufacturer: manufacturer,
      androidVersion: androidVersion,
      platform: platform,
      appVersion: appVersion,
    );

    return _cachedInfo!;
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
