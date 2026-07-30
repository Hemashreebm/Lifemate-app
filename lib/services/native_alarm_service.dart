import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/task_item.dart';

/// Dart wrapper for native Android AlarmManager and Full-Screen Lock Screen Alarm.
class NativeAlarmService {
  static final NativeAlarmService instance = NativeAlarmService._();
  NativeAlarmService._();

  static const MethodChannel _channel =
      MethodChannel('com.example.lifemate/alarm_manager');

  /// Schedule a native Android AlarmManager alarm (wakes screen & shows full screen UI over lock screen).
  Future<bool> scheduleAlarm(TaskItem task) async {
    if (!task.reminderEnabled || task.isCompleted) return false;

    final scheduledTime = task.scheduledReminderTime;
    final now = DateTime.now();
    if (scheduledTime.isBefore(now)) return false;

    try {
      final scheduledTimeMs = scheduledTime.millisecondsSinceEpoch;
      final result = await _channel.invokeMethod<bool>('scheduleAlarm', {
        'taskId': task.id,
        'title': task.title,
        'notes': task.notes,
        'scheduledTimeMs': scheduledTimeMs,
        'notificationId': task.notificationId,
      });

      debugPrint(
          'Native Alarm scheduled for "${task.title}" at $scheduledTime (ID: ${task.notificationId})');
      return result ?? true;
    } catch (e) {
      debugPrint('Error scheduling native alarm: $e');
      return false;
    }
  }

  /// Cancel a scheduled native Android alarm.
  Future<bool> cancelAlarm(int notificationId) async {
    try {
      final result = await _channel.invokeMethod<bool>('cancelAlarm', {
        'notificationId': notificationId,
      });
      return result ?? true;
    } catch (e) {
      debugPrint('Error cancelling native alarm: $e');
      return false;
    }
  }

  /// Stop currently ringing native alarm.
  Future<bool> stopAlarm() async {
    try {
      final result = await _channel.invokeMethod<bool>('stopAlarm');
      return result ?? true;
    } catch (e) {
      debugPrint('Error stopping native alarm: $e');
      return false;
    }
  }
}
