import 'dart:math';

/// Priority levels for a task.
enum TaskPriority { low, medium, high }

/// Recurrence pattern for repeating tasks.
enum TaskRepeat { never, daily, weekly, monthly }

/// Notification style: Normal Chime vs Ringing Audio for selected duration.
enum ReminderStyle { normal, ringing }

/// Represents a single personal task item and smart reminder.
class TaskItem {
  final String id;
  final String title;
  final String notes;
  final DateTime dueDate;
  final bool hasTime;
  final TaskPriority priority;
  final TaskRepeat repeat;
  final bool isCompleted;
  final bool reminderEnabled;
  final int reminderOffsetMinutes; // 0, 10, 30, 60
  final ReminderStyle reminderStyle; // normal or ringing
  final int ringDurationSeconds; // 3, 5, 10, 15, 30
  final int notificationId;
  final DateTime createdAt;
  final DateTime modifiedAt;

  const TaskItem({
    required this.id,
    required this.title,
    required this.notes,
    required this.dueDate,
    required this.hasTime,
    required this.priority,
    required this.repeat,
    required this.isCompleted,
    required this.reminderEnabled,
    required this.reminderOffsetMinutes,
    this.reminderStyle = ReminderStyle.normal,
    this.ringDurationSeconds = 5,
    required this.notificationId,
    required this.createdAt,
    required this.modifiedAt,
  });

  /// Generate a unique integer ID for Android Local Notifications.
  static int generateNotificationId() {
    final rand = Random().nextInt(1000000);
    final ts = (DateTime.now().millisecondsSinceEpoch ~/ 1000) % 1000000;
    return ts + rand;
  }

  /// Generate a unique string ID for task storage.
  static String generateId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rand = Random().nextInt(99999);
    return 'task_${ts}_$rand';
  }

  /// Exact DateTime when the reminder notification should fire (normalized to 00 seconds & 00 milliseconds).
  DateTime get scheduledReminderTime {
    final d = dueDate.subtract(Duration(minutes: reminderOffsetMinutes));
    return DateTime(d.year, d.month, d.day, d.hour, d.minute, 0, 0, 0);
  }

  /// Whether the task is overdue (past due date & time and incomplete).
  bool get isOverdue {
    if (isCompleted) return false;
    final now = DateTime.now();
    return dueDate.isBefore(now);
  }

  /// Whether due date falls on current calendar day.
  bool get isToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  /// Whether due date is in the future beyond today.
  bool get isUpcoming {
    if (isCompleted) return false;
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return dueDate.isAfter(todayEnd);
  }

  TaskItem copyWith({
    String? id,
    String? title,
    String? notes,
    DateTime? dueDate,
    bool? hasTime,
    TaskPriority? priority,
    TaskRepeat? repeat,
    bool? isCompleted,
    bool? reminderEnabled,
    int? reminderOffsetMinutes,
    ReminderStyle? reminderStyle,
    int? ringDurationSeconds,
    int? notificationId,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dueDate: dueDate ?? this.dueDate,
      hasTime: hasTime ?? this.hasTime,
      priority: priority ?? this.priority,
      repeat: repeat ?? this.repeat,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderOffsetMinutes:
          reminderOffsetMinutes ?? this.reminderOffsetMinutes,
      reminderStyle: reminderStyle ?? this.reminderStyle,
      ringDurationSeconds: ringDurationSeconds ?? this.ringDurationSeconds,
      notificationId: notificationId ?? this.notificationId,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'notes': notes,
        'dueDate': dueDate.toIso8601String(),
        'hasTime': hasTime,
        'priority': priority.name,
        'repeat': repeat.name,
        'isCompleted': isCompleted,
        'reminderEnabled': reminderEnabled,
        'reminderOffsetMinutes': reminderOffsetMinutes,
        'reminderStyle': reminderStyle.name,
        'ringDurationSeconds': ringDurationSeconds,
        'notificationId': notificationId,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
      };

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String,
      title: json['title'] as String,
      notes: (json['notes'] as String?) ?? '',
      dueDate: DateTime.parse(json['dueDate'] as String),
      hasTime: (json['hasTime'] as bool?) ?? false,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      repeat: TaskRepeat.values.firstWhere(
        (e) => e.name == json['repeat'],
        orElse: () => TaskRepeat.never,
      ),
      isCompleted: (json['isCompleted'] as bool?) ?? false,
      reminderEnabled: (json['reminderEnabled'] as bool?) ?? false,
      reminderOffsetMinutes: (json['reminderOffsetMinutes'] as int?) ?? 0,
      reminderStyle: ReminderStyle.values.firstWhere(
        (e) => e.name == json['reminderStyle'],
        orElse: () => ReminderStyle.normal,
      ),
      ringDurationSeconds: (json['ringDurationSeconds'] as int?) ?? 5,
      notificationId: (json['notificationId'] as int?) ?? generateNotificationId(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
    );
  }
}
