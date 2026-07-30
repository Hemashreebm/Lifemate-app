import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_item.dart';
import 'notification_service.dart';

/// Singleton service managing personal tasks and smart reminders on-device.
class TaskService {
  static const String _storageKey = 'lifemate_tasks_v1';

  static final TaskService instance = TaskService._();
  TaskService._();

  List<TaskItem> _tasks = [];

  List<TaskItem> get all => List.unmodifiable(_tasks);

  /// Load tasks from SharedPreferences.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr == null) {
        _tasks = [];
        return;
      }
      final List<dynamic> raw = jsonDecode(jsonStr) as List<dynamic>;
      _tasks = raw
          .map((j) => TaskItem.fromJson(j as Map<String, dynamic>))
          .toList();
      _sort();
    } catch (_) {
      _tasks = [];
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }

  /// Add a new task item and schedule its local notification.
  Future<void> add(TaskItem task) async {
    _tasks.insert(0, task);
    _sort();
    await _save();
    if (task.reminderEnabled && !task.isCompleted) {
      await NotificationService.instance.scheduleTaskReminder(task);
    }
  }

  /// Update an existing task item and update notification schedules.
  Future<void> update(TaskItem task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      _sort();
      await _save();

      if (task.isCompleted || !task.reminderEnabled) {
        await NotificationService.instance.cancelTaskReminder(task.notificationId);
      } else {
        await NotificationService.instance.scheduleTaskReminder(task);
      }
    }
  }

  /// Snooze a task by rescheduling its reminder N minutes into the future.
  Future<void> snoozeTask(String taskId, {int minutes = 10}) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final newDueDate = DateTime.now().add(Duration(minutes: minutes));
      final updated = task.copyWith(
        dueDate: newDueDate,
        hasTime: true,
        modifiedAt: DateTime.now(),
      );
      _tasks[index] = updated;
      _sort();
      await _save();
      await NotificationService.instance.scheduleTaskReminder(updated);
    }
  }

  /// Delete a task item and cancel its notification.
  Future<void> delete(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      await NotificationService.instance.cancelTaskReminder(task.notificationId);
      _tasks.removeAt(index);
      await _save();
    }
  }

  /// Toggle task completion state.
  Future<void> toggleComplete(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      final newCompleted = !task.isCompleted;

      // Handle repeating task logic when marked completed
      if (newCompleted && task.repeat != TaskRepeat.never) {
        _handleRepeatOnCompletion(task);
      }

      final updated = task.copyWith(
        isCompleted: newCompleted,
        modifiedAt: DateTime.now(),
      );

      _tasks[index] = updated;
      _sort();
      await _save();

      if (newCompleted) {
        await NotificationService.instance.cancelTaskReminder(task.notificationId);
      } else if (updated.reminderEnabled && !updated.isOverdue) {
        await NotificationService.instance.scheduleTaskReminder(updated);
      }
    }
  }

  void _handleRepeatOnCompletion(TaskItem task) {
    DateTime nextDueDate = task.dueDate;
    switch (task.repeat) {
      case TaskRepeat.daily:
        nextDueDate = task.dueDate.add(const Duration(days: 1));
        break;
      case TaskRepeat.weekly:
        nextDueDate = task.dueDate.add(const Duration(days: 7));
        break;
      case TaskRepeat.monthly:
        nextDueDate = DateTime(
          task.dueDate.year,
          task.dueDate.month + 1,
          task.dueDate.day,
          task.dueDate.hour,
          task.dueDate.minute,
        );
        break;
      case TaskRepeat.never:
        return;
    }

    final nextTask = TaskItem(
      id: TaskItem.generateId(),
      title: task.title,
      notes: task.notes,
      dueDate: nextDueDate,
      hasTime: task.hasTime,
      priority: task.priority,
      repeat: task.repeat,
      isCompleted: false,
      reminderEnabled: task.reminderEnabled,
      reminderOffsetMinutes: task.reminderOffsetMinutes,
      notificationId: TaskItem.generateNotificationId(),
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
    );

    add(nextTask);
  }

  // ── Filters ───────────────────────────────────────────────────────────────

  List<TaskItem> get todayTasks =>
      _tasks.where((t) => !t.isCompleted && t.isToday).toList();

  List<TaskItem> get upcomingTasks =>
      _tasks.where((t) => !t.isCompleted && t.isUpcoming).toList();

  List<TaskItem> get overdueTasks =>
      _tasks.where((t) => !t.isCompleted && t.isOverdue).toList();

  List<TaskItem> get completedTasks =>
      _tasks.where((t) => t.isCompleted).toList();

  List<TaskItem> get activeTasks =>
      _tasks.where((t) => !t.isCompleted).toList();

  void _sort() {
    _tasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return a.dueDate.compareTo(b.dueDate);
    });
  }

  static String formatDate(DateTime d, bool hasTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (!hasTime) {
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    }
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day} ${months[d.month - 1]} ${d.year}, $hour:$minute $ampm';
  }
}
