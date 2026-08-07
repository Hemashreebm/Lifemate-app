import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';

/// Centralized Habit Tracker Service for Lifemate v2.0.
class HabitService {
  static const String _storageKey = 'lifemate_habits_v2';
  static final HabitService instance = HabitService._();
  HabitService._();

  List<Habit> _habits = [];

  /// Read unmodifiable list of all user habits.
  List<Habit> get all => List.unmodifiable(_habits);

  /// Load habits from local storage & initialize default habits if empty.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> raw = jsonDecode(jsonStr) as List<dynamic>;
        _habits = raw.map((j) => Habit.fromJson(j as Map<String, dynamic>)).toList();
      } else {
        // Seed default habits
        _habits = [
          Habit(
            id: 'h_water',
            title: 'Drink Water',
            description: 'Stay hydrated with 8 glasses of water daily.',
            iconName: 'water',
            createdAt: DateTime.now(),
          ),
          Habit(
            id: 'h_exercise',
            title: '30 Min Workout',
            description: 'Keep active with running, yoga, or gym.',
            iconName: 'exercise',
            createdAt: DateTime.now(),
          ),
          Habit(
            id: 'h_reading',
            title: 'Read 15 Mins',
            description: 'Read a chapter of a book or informative article.',
            iconName: 'book',
            createdAt: DateTime.now(),
          ),
          Habit(
            id: 'h_spoken',
            title: 'English Speaking Practice',
            description: 'Practice speaking aloud for 10 minutes.',
            iconName: 'mic',
            createdAt: DateTime.now(),
          ),
        ];
        await _saveLocal();
      }
      _checkDailyReset();
      debugPrint('[HABITS] Loaded ${_habits.length} daily habits.');
      _syncFromCloud();
    } catch (e) {
      debugPrint('[HABITS] Init error: $e');
    }
  }

  /// Toggle habit completion state for today.
  Future<void> toggleHabit(String id) async {
    final idx = _habits.indexWhere((h) => h.id == id);
    if (idx == -1) return;

    final habit = _habits[idx];
    final now = DateTime.now();
    final isDone = !habit.isCompletedToday;
    final newStreak = isDone ? habit.streakDays + 1 : (habit.streakDays > 0 ? habit.streakDays - 1 : 0);

    final updated = habit.copyWith(
      isCompletedToday: isDone,
      streakDays: newStreak,
      lastCompletedDate: isDone ? now : habit.lastCompletedDate,
    );

    _habits[idx] = updated;
    await _saveLocal();
    await _syncToCloud(updated);
    debugPrint('[HABITS] Toggled habit ${updated.title}: completed=$isDone, streak=$newStreak');
  }

  /// Add a new custom habit.
  Future<void> addHabit(String title, String description, {String iconName = 'star'}) async {
    final h = Habit(
      id: Habit.generateId(),
      title: title.trim(),
      description: description.trim(),
      iconName: iconName,
      createdAt: DateTime.now(),
    );
    _habits.add(h);
    await _saveLocal();
    await _syncToCloud(h);
    debugPrint('[HABITS] Added new habit: ${h.title}');
  }

  /// Delete a habit.
  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    await _saveLocal();
    await _deleteFromCloud(id);
    debugPrint('[HABITS] Deleted habit: $id');
  }

  void _checkDailyReset() {
    final now = DateTime.now();
    bool changed = false;
    for (int i = 0; i < _habits.length; i++) {
      final h = _habits[i];
      if (h.lastCompletedDate != null) {
        final last = h.lastCompletedDate!;
        final diffDays = now.difference(DateTime(last.year, last.month, last.day)).inDays;
        if (diffDays >= 1 && h.isCompletedToday) {
          _habits[i] = h.copyWith(isCompletedToday: false);
          changed = true;
        } else if (diffDays > 1) {
          // Missed a day -> reset streak
          _habits[i] = h.copyWith(isCompletedToday: false, streakDays: 0);
          changed = true;
        }
      }
    }
    if (changed) _saveLocal();
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _habits.map((h) => h.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  Future<void> _syncToCloud(Habit habit) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('habits')
            .doc(habit.id)
            .set(habit.toJson());
      }
    } catch (e) {
      debugPrint('[HABITS] Cloud write error: $e');
    }
  }

  Future<void> _deleteFromCloud(String id) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('habits')
            .doc(id)
            .delete();
      }
    } catch (e) {
      debugPrint('[HABITS] Cloud delete error: $e');
    }
  }

  Future<void> _syncFromCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('habits')
            .get();

        if (snapshot.docs.isNotEmpty) {
          _habits = snapshot.docs.map((doc) => Habit.fromJson(doc.data())).toList();
          await _saveLocal();
          debugPrint('[HABITS] Synced ${_habits.length} habits from Firestore.');
        }
      }
    } catch (e) {
      debugPrint('[HABITS] Cloud read error: $e');
    }
  }
}
