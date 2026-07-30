import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';

/// Singleton service for managing My Life Book entries locally on-device.
class DiaryService {
  static const String _storageKey = 'lifemate_diary_entries_v1';

  static final DiaryService instance = DiaryService._();
  DiaryService._();

  List<DiaryEntry> _entries = [];

  /// Get all diary entries, newest created date first.
  List<DiaryEntry> get all => List.unmodifiable(_entries);

  /// Get favorite entries.
  List<DiaryEntry> get favorites =>
      _entries.where((e) => e.favorite).toList();

  /// Get entries for a specific calendar date (year, month, day match).
  List<DiaryEntry> getForDate(DateTime date) {
    return _entries.where((e) =>
        e.createdAt.year == date.year &&
        e.createdAt.month == date.month &&
        e.createdAt.day == date.day).toList();
  }

  /// Get mood counts for a given month.
  Map<String, int> getMoodStats(DateTime month) {
    final Map<String, int> counts = {};
    for (final e in _entries) {
      if (e.createdAt.year == month.year && e.createdAt.month == month.month) {
        counts[e.mood] = (counts[e.mood] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// Load entries from SharedPreferences.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr == null) {
        _entries = [];
        return;
      }
      final List<dynamic> raw = jsonDecode(jsonStr) as List<dynamic>;
      _entries = raw
          .map((j) => DiaryEntry.fromJson(j as Map<String, dynamic>))
          .toList();
      _sort();
    } catch (_) {
      _entries = [];
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }

  /// Add a new diary entry.
  Future<void> add(DiaryEntry entry) async {
    _entries.insert(0, entry);
    _sort();
    await _save();
  }

  /// Update an existing diary entry.
  Future<void> update(DiaryEntry entry) async {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      final oldAudioPath = _entries[index].audioPath;
      if (oldAudioPath != null && oldAudioPath != entry.audioPath) {
        _deleteAudioFile(oldAudioPath);
      }
      _entries[index] = entry;
      _sort();
      await _save();
    }
  }

  /// Toggle favorite status of an entry.
  Future<void> toggleFavorite(String id) async {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index != -1) {
      _entries[index] = _entries[index].copyWith(
        favorite: !_entries[index].favorite,
      );
      await _save();
    }
  }

  /// Delete a diary entry and its associated local audio file.
  Future<void> delete(String id) async {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index != -1) {
      final entry = _entries[index];
      if (entry.audioPath != null) {
        _deleteAudioFile(entry.audioPath!);
      }
      _entries.removeAt(index);
      await _save();
    }
  }

  /// Helper to safely delete an audio file from disk without throwing.
  void _deleteAudioFile(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (_) {}
  }

  /// Filter entries by query (title, content, or tags, case-insensitive).
  List<DiaryEntry> search(String query) {
    if (query.trim().isEmpty) return all;
    final q = query.trim().toLowerCase();
    return _entries.where((e) {
      final tMatches = e.title.toLowerCase().contains(q);
      final cMatches = e.content.toLowerCase().contains(q);
      final tagMatches = e.tags.any((tag) => tag.toLowerCase().contains(q));
      return tMatches || cMatches || tagMatches;
    }).toList();
  }

  void _sort() {
    _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static String formatDate(DateTime d) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day} ${months[d.month - 1]} ${d.year}, $hour:$minute $ampm';
  }

  static String formatShortDate(DateTime d) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  static String formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
