import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task_item.dart';
import 'task_service.dart';
import 'native_alarm_service.dart';

/// Top-level background notification response handler for Stop and Snooze buttons.
@pragma('vm:entry-point')
void notificationActionBackgroundHandler(NotificationResponse details) async {
  debugPrint('Background notification action triggered: ${details.actionId}, payload: ${details.payload}');
  NotificationService.instance.stopRinging();
  await NativeAlarmService.instance.stopAlarm();
  if (details.actionId == 'snooze_reminder' && details.payload != null && details.payload!.isNotEmpty) {
    await TaskService.instance.load();
    await TaskService.instance.snoozeTask(details.payload!, minutes: 10);
  }
}

/// Service managing local Android notifications and Ringing Reminders (3s, 5s, 10s, 15s, 30s playback).
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  static const String _normalChannelId = 'lifemate_task_reminders_v2';
  static const String _ringingChannelId = 'lifemate_task_reminders_ringing_res_v1';

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  AudioPlayer? _ringPlayer;
  Timer? _ringDurationTimer;
  Timer? _scheduledRingTimer;
  bool _isRinging = false;
  int _ringStartTimeMs = 0;

  bool get isRinging => _isRinging;

  bool _initialized = false;

  /// Initialize local notifications, audio context, and Android channels.
  Future<void> init() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();

      // Configure AudioContext for reliable notification ringtone playback
      AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            stayAwake: true,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.notificationRingtone,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) async {
          debugPrint('Notification tapped/action: ${details.actionId}, payload: ${details.payload}');
          stopRinging();
          await NativeAlarmService.instance.stopAlarm();
          if (details.actionId == 'snooze_reminder' && details.payload != null && details.payload!.isNotEmpty) {
            await TaskService.instance.snoozeTask(details.payload!, minutes: 10);
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationActionBackgroundHandler,
      );

      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // Normal Notification Channel (Plays default Android system chime)
        const normalChannel = AndroidNotificationChannel(
          _normalChannelId,
          'Task Reminders (Normal)',
          description: 'Standard notification chime for task reminders',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        );
        await androidPlugin.createNotificationChannel(normalChannel);

        // Ringing Reminder Channel (Configured with raw native sound resource for 100% background playback!)
        const ringingChannel = AndroidNotificationChannel(
          _ringingChannelId,
          'Task Reminders (Ringing)',
          description: 'Extended ringing audio reminders for busy moments',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('reminder_ring'),
          enableVibration: true,
          showBadge: true,
        );
        await androidPlugin.createNotificationChannel(ringingChannel);
      }

      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  /// Request Android 13+ runtime notification permission.
  Future<bool> requestPermission() async {
    await init();
    try {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Query pending scheduled notifications for diagnostics.
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    await init();
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Error fetching pending notifications: $e');
      return [];
    }
  }

  /// Schedule a notification and optional Ringing Reminder for a task.
  Future<bool> scheduleTaskReminder(TaskItem task) async {
    await init();

    // Prevent duplicate alarms by cancelling any existing schedule for this notification ID
    await cancelTaskReminder(task.notificationId);

    if (!task.reminderEnabled || task.isCompleted) return false;

    final scheduledTime = task.scheduledReminderTime;
    final now = DateTime.now();

    if (scheduledTime.isBefore(now)) return false; // Don't schedule past times

    // Register with Native Android AlarmManager for Real Clock Alarm behaviour
    if (task.reminderStyle == ReminderStyle.ringing) {
      final scheduled = await NativeAlarmService.instance.scheduleAlarm(task);
      debugPrint('Native Clock Alarm scheduled for task ${task.id} (ID: ${task.notificationId}) at $scheduledTime');
      return scheduled;
    }

    try {
      final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

      // Select channel ID according to task's chosen ReminderStyle
      final channelId = _normalChannelId;
      final channelName = 'Task Reminders (Normal)';

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'Lifemate task reminder notification',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        visibility: NotificationVisibility.public,
        icon: '@mipmap/ic_launcher',
        actions: const <AndroidNotificationAction>[
          AndroidNotificationAction(
            'stop_reminder',
            '¸ Stop',
            cancelNotification: true,
            showsUserInterface: false,
          ),
          AndroidNotificationAction(
            'snooze_reminder',
            ' Snooze (10m)',
            cancelNotification: true,
            showsUserInterface: false,
          ),
        ],
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      String bodyText = 'Due: ${_formatShortTime(task.dueDate, task.hasTime)}';
      if (task.notes.isNotEmpty) {
        bodyText += '  ${task.notes}';
      }

      // Schedule notification using alarmClock mode for normal chime
      try {
        await _notifications.zonedSchedule(
          task.notificationId,
          'Lifemate Reminder: ${task.title}',
          bodyText,
          tzScheduledTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: task.id,
        );
      } catch (e) {
        debugPrint('alarmClock schedule failed with error: $e');
        rethrow;
      }

      debugPrint('Notification scheduled for task ${task.id} (ID: ${task.notificationId}) at $tzScheduledTime (alarmClock mode)');
      return true;
    } catch (e) {
      debugPrint('Error scheduling notification for task ${task.id}: $e');
      return false;
    }
  }

  /// Schedule a general notification for scheme deadlines or reminders.
  Future<bool> scheduleGeneralNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await init();
    if (scheduledDate.isBefore(DateTime.now())) return false;

    try {
      final tzScheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);
      const androidDetails = AndroidNotificationDetails(
        _normalChannelId,
        'Task Reminders (Normal)',
        channelDescription: 'Lifemate notification',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );
      const notificationDetails = NotificationDetails(android: androidDetails);

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      return true;
    } catch (e) {
      debugPrint('Error scheduling general notification: $e');
      return false;
    }
  }

  /// Start playing ringing audio for the exact requested duration (3s, 5s, 10s, 15s, 30s).
  Future<void> startRinging(int durationSeconds) async {
    stopRinging(); // Stop any active playback & reset single timer

    _isRinging = true;
    _ringStartTimeMs = DateTime.now().millisecondsSinceEpoch;
    _ringPlayer = AudioPlayer();

    debugPrint('Ringing started: $_ringStartTimeMs, Requested duration: $durationSeconds seconds');

    try {
      await _ringPlayer!.setReleaseMode(ReleaseMode.loop);
      await _ringPlayer!.play(AssetSource('sounds/reminder_ring.wav'));
    } catch (e) {
      debugPrint('Error playing ringtone audio: $e');
    }

    // Single timer: automatically stop ringing after exact requested duration
    _ringDurationTimer = Timer(Duration(seconds: durationSeconds), () {
      stopRinging();
    });
  }

  /// Immediately stop ringing audio and release resources (manual early stop or auto timeout).
  void stopRinging() {
    _scheduledRingTimer?.cancel();
    _scheduledRingTimer = null;

    _ringDurationTimer?.cancel();
    _ringDurationTimer = null;

    if (_ringPlayer != null) {
      try {
        _ringPlayer!.stop();
        _ringPlayer!.dispose();
      } catch (_) {}
      _ringPlayer = null;
    }

    if (_ringStartTimeMs > 0) {
      final elapsedMs = DateTime.now().millisecondsSinceEpoch - _ringStartTimeMs;
      debugPrint('Player actually stopped at: ${DateTime.now().millisecondsSinceEpoch}. Observed internal duration: $elapsedMs ms');
      _ringStartTimeMs = 0;
    }

    _isRinging = false;
  }

  /// Cancel a scheduled local notification and ring timer by ID.
  Future<void> cancelTaskReminder(int notificationId) async {
    await init();
    stopRinging();
    await NativeAlarmService.instance.cancelAlarm(notificationId);
    try {
      await _notifications.cancel(notificationId);
    } catch (e) {
      debugPrint('Error cancelling notification $notificationId: $e');
    }
  }

  /// Cancel all scheduled local notifications and stop ringing.
  Future<void> cancelAll() async {
    await init();
    stopRinging();
    try {
      await _notifications.cancelAll();
    } catch (_) {}
  }

  String _formatShortTime(DateTime d, bool hasTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (!hasTime) {
      return '${d.day} ${months[d.month - 1]}';
    }
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day} ${months[d.month - 1]}, $hour:$minute $ampm';
  }
}
