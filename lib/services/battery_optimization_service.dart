import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles battery optimization exemption request for Lifemate.
///
/// On VIVO/BBK and other aggressive battery-saving Android devices,
/// background alarms are frozen unless the app is whitelisted from
/// battery optimization. This service prompts the user once to grant exemption.
class BatteryOptimizationService {
  static const MethodChannel _channel =
      MethodChannel('com.example.lifemate/battery');

  static const String _prefKey = 'battery_opt_requested';

  /// Returns true if the current platform is Android.
  static bool get isAndroid => Platform.isAndroid;

  /// Check whether the app is already exempt from battery optimization.
  /// Returns true if exempt (i.e., no action needed).
  static Future<bool> isIgnoringBatteryOptimizations() async {
    if (!isAndroid) return true;
    try {
      final result = await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return result ?? false;
    } catch (e) {
      debugPrint('BatteryOptimizationService: isIgnoringBatteryOptimizations error: $e');
      return false;
    }
  }

  /// Request system battery optimization exemption.
  /// Opens Android's native "Battery optimization" settings page for this app.
  static Future<void> requestIgnoreBatteryOptimizations() async {
    if (!isAndroid) return;
    try {
      await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (e) {
      debugPrint('BatteryOptimizationService: requestIgnoreBatteryOptimizations error: $e');
    }
  }

  /// Returns true if we should show the exemption prompt to the user.
  /// Only shows once unless already granted.
  static Future<bool> shouldPrompt() async {
    if (!isAndroid) return false;
    final alreadyExempt = await isIgnoringBatteryOptimizations();
    if (alreadyExempt) return false;

    final prefs = await SharedPreferences.getInstance();
    final alreadyRequested = prefs.getBool(_prefKey) ?? false;
    return !alreadyRequested;
  }

  /// Mark that we have shown the prompt (prevents showing again on every launch).
  static Future<void> markPromptShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }
}
