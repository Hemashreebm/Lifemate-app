import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_item.dart';
import 'auth_service.dart';
import 'notification_service.dart';

/// Singleton service managing personal tasks with local persistence and Cloud Firestore sync.
class TaskService {
  static const String _storageKey = 'lifemate_tasks_v1';

  static final TaskService instance = TaskService._();
  TaskService._();

  List<TaskItem> _tasks = [];
  StreamSubscription<QuerySnapshot>? _tasksSubscription;

  List<TaskItem> get all => List.unmodifiable(_tasks);

  /// Load tasks from SharedPreferences and subscribe to Firestore real-time updates.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null) {
        final List<dynamic> raw = jsonDecode(jsonStr) as List<dynamic>;
        _tasks = raw
            .map((j) => TaskItem.fromJson(j as Map<String, dynamic>))
            .toList();
        _sort();
      } else {
        _tasks = [];
      }

      // Initialize real-time Cloud Firestore sync
      initCloudSync();
    } catch (e) {
      debugPrint('[TASK SERVICE] Error loading local tasks: $e');
      _tasks = [];
    }
  }

  /// Initialize real-time Cloud Firestore listener for users/{uid}/tasks
  void initCloudSync() {
    _tasksSubscription?.cancel();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || AuthService.instance.isGuestMode) {
      debugPrint('[TASK CLOUD] Guest mode or unauthenticated. Using local storage only.');
      return;
    }

    final collectionPath = 'users/${user.uid}/tasks';
    debugPrint('[TASK CLOUD] Subscribing to real-time stream at $collectionPath...');

    _tasksSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .snapshots()
        .listen(
      (snapshot) async {
        debugPrint('[TASK CLOUD STREAM] Received ${snapshot.docs.length} tasks from Firestore');
        final List<TaskItem> remoteTasks = [];
        for (final doc in snapshot.docs) {
          try {
            final task = TaskItem.fromFirestore(doc.data(), doc.id);
            remoteTasks.add(task);
          } catch (e) {
            debugPrint('[TASK CLOUD PARSE ERROR] Error parsing task ${doc.id}: $e');
          }
        }

        if (remoteTasks.isNotEmpty || snapshot.docs.isEmpty) {
          _tasks = remoteTasks;
          _sort();
          await _save();
          _updateNotificationSchedules();
        }
      },
      onError: (error) {
        debugPrint('[TASK CLOUD STREAM ERROR] Error listening to tasks stream: $error');
      },
    );
  }

  /// Stop active Cloud Firestore real-time stream listener
  void stopCloudSync() {
    _tasksSubscription?.cancel();
    _tasksSubscription = null;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }

  void _updateNotificationSchedules() {
    for (final task in _tasks) {
      if (task.isCompleted || !task.reminderEnabled || task.isOverdue) {
        NotificationService.instance.cancelTaskReminder(task.notificationId);
      } else {
        NotificationService.instance.scheduleTaskReminder(task);
      }
    }
  }

  /// Add a new task item, schedule local notification, and upload to Cloud Firestore.
  Future<void> add(TaskItem task) async {
    _tasks.insert(0, task);
    _sort();
    await _save();

    if (task.reminderEnabled && !task.isCompleted) {
      await NotificationService.instance.scheduleTaskReminder(task);
    }

    // Cloud Firestore Upload
    await _uploadTaskToCloud(task);
  }

  /// Update an existing task item, update notification schedule, and sync to Cloud Firestore.
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

      // Cloud Firestore Update
      await _uploadTaskToCloud(task);
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
      await update(updated);
    }
  }

  /// Delete a task item, cancel its notification, and remove from Cloud Firestore.
  Future<void> delete(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      await NotificationService.instance.cancelTaskReminder(task.notificationId);
      _tasks.removeAt(index);
      await _save();

      // Cloud Firestore Deletion
      await _deleteTaskFromCloud(id);
    }
  }

  /// Toggle task completion state.
  Future<void> toggleComplete(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      final newCompleted = !task.isCompleted;

      if (newCompleted && task.repeat != TaskRepeat.never) {
        _handleRepeatOnCompletion(task);
      }

      final updated = task.copyWith(
        isCompleted: newCompleted,
        modifiedAt: DateTime.now(),
      );

      await update(updated);
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

  //  Cloud Firestore Operations 

  Future<void> _uploadTaskToCloud(TaskItem task) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || AuthService.instance.isGuestMode) return;

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(task.id);

      debugPrint('[TASK CLOUD] Uploading task ${task.id} to users/${user.uid}/tasks...');
      await docRef
          .set(task.toFirestore(), SetOptions(merge: true))
          .timeout(const Duration(seconds: 12));
      debugPrint('[TASK CLOUD SUCCESS] Task ${task.id} saved in Firestore users/${user.uid}/tasks');
    } on FirebaseException catch (e) {
      debugPrint('[TASK CLOUD ERROR] FirebaseException uploading task: ${e.code} - ${e.message}');
    } catch (e) {
      debugPrint('[TASK CLOUD ERROR] Error uploading task: $e');
    }
  }

  Future<void> _deleteTaskFromCloud(String taskId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || AuthService.instance.isGuestMode) return;

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(taskId);

      debugPrint('[TASK CLOUD] Deleting task $taskId from users/${user.uid}/tasks...');
      await docRef.delete().timeout(const Duration(seconds: 12));
      debugPrint('[TASK CLOUD SUCCESS] Deleted task $taskId from Firestore');
    } on FirebaseException catch (e) {
      debugPrint('[TASK CLOUD ERROR] FirebaseException deleting task: ${e.code} - ${e.message}');
    } catch (e) {
      debugPrint('[TASK CLOUD ERROR] Error deleting task from Firestore: $e');
    }
  }

  //  Filters 

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
