import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'app_language_service.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

class InterestedSchemeItem {
  final String schemeId;
  final String schemeName;
  final String deadlineText; // "Open / Ongoing", "Deadline not available", or ISO date e.g. "2026-10-31"
  final DateTime savedAt;
  final int? reminderDaysBefore; // 30, 14, 7, 3, 1
  final bool isReminderEnabled;

  InterestedSchemeItem({
    required this.schemeId,
    required this.schemeName,
    required this.deadlineText,
    required this.savedAt,
    this.reminderDaysBefore,
    this.isReminderEnabled = false,
  });

  Map<String, dynamic> toJson() => {
        'schemeId': schemeId,
        'schemeName': schemeName,
        'deadlineText': deadlineText,
        'savedAt': savedAt.toIso8601String(),
        'reminderDaysBefore': reminderDaysBefore,
        'isReminderEnabled': isReminderEnabled,
      };

  factory InterestedSchemeItem.fromJson(Map<String, dynamic> json) => InterestedSchemeItem(
        schemeId: json['schemeId'] ?? '',
        schemeName: json['schemeName'] ?? '',
        deadlineText: json['deadlineText'] ?? 'Deadline not available',
        savedAt: json['savedAt'] != null ? DateTime.parse(json['savedAt']) : DateTime.now(),
        reminderDaysBefore: json['reminderDaysBefore'],
        isReminderEnabled: json['isReminderEnabled'] ?? false,
      );
}

class InterestedSchemeService {
  static final InterestedSchemeService _instance = InterestedSchemeService._internal();
  factory InterestedSchemeService() => _instance;
  InterestedSchemeService._internal();

  static const String _storageKeyPrefix = 'interested_schemes_user_';

  String _getUserKey() {
    final user = AuthService.instance.currentUser;
    final uid = user?.uid ?? 'guest';
    return '$_storageKeyPrefix$uid';
  }

  /// Retrieves list of saved interested schemes for current user.
  Future<List<InterestedSchemeItem>> getInterestedSchemes() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getUserKey();
    final rawJson = prefs.getString(key);
    if (rawJson == null || rawJson.isEmpty) return [];
    try {
      final List list = jsonDecode(rawJson);
      return list.map((e) => InterestedSchemeItem.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Checks if a scheme is saved as interested by current user.
  Future<bool> isSchemeInterested(String schemeId) async {
    final list = await getInterestedSchemes();
    return list.any((item) => item.schemeId == schemeId);
  }

  /// Saves or updates an interested scheme for current user.
  Future<void> saveInterestedScheme(InterestedSchemeItem item) async {
    final list = await getInterestedSchemes();
    list.removeWhere((e) => e.schemeId == item.schemeId);
    list.add(item);
    await _saveList(list);

    // Cloud sync to Supabase if authenticated
    try {
      final user = AuthService.instance.currentUser;
      if (user != null && !user.isAnonymous) {
        await SupabaseService.instance.saveUserData('interested_schemes', {
          'user_id': user.uid,
          'schemes_json': jsonEncode(list.map((e) => e.toJson()).toList()),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (_) {}
  }

  /// Removes an interested scheme for current user.
  Future<void> removeInterestedScheme(String schemeId) async {
    final list = await getInterestedSchemes();
    list.removeWhere((e) => e.schemeId == schemeId);
    await _saveList(list);
  }

  Future<void> _saveList(List<InterestedSchemeItem> list) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getUserKey();
    final rawJson = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(key, rawJson);
  }

  /// Enables a deadline reminder for an interested scheme if a valid future deadline exists.
  Future<bool> enableDeadlineReminder({
    required String schemeId,
    required String schemeName,
    required String deadlineText,
    required int daysBefore,
  }) async {
    // Parse deadline date
    DateTime? deadlineDate;
    try {
      deadlineDate = DateTime.parse(deadlineText);
    } catch (_) {
      // Cannot schedule reminder if deadline is not a valid future date
      return false;
    }

    final reminderTime = deadlineDate.subtract(Duration(days: daysBefore));
    if (reminderTime.isBefore(DateTime.now())) {
      // Deadline or reminder date has already passed
      return false;
    }

    final lang = AppLanguageService();
    final title = 'Scheme Deadline Reminder: $schemeName';
    final body =
        'According to available scheme information, the application deadline for $schemeName is approaching ($deadlineText). Please verify details at official government source.';

    final notificationId = schemeId.hashCode.abs() % 100000;
    await NotificationService.instance.scheduleNotification(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: reminderTime,
    );

    final item = InterestedSchemeItem(
      schemeId: schemeId,
      schemeName: schemeName,
      deadlineText: deadlineText,
      savedAt: DateTime.now(),
      reminderDaysBefore: daysBefore,
      isReminderEnabled: true,
    );
    await saveInterestedScheme(item);
    return true;
  }
}
