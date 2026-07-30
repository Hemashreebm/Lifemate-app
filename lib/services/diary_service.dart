import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';
import 'auth_service.dart';

/// Singleton service for managing My Life Book entries with local storage and Cloud Firestore sync.
class DiaryService {
  static const String _storageKey = 'lifemate_diary_entries_v1';

  static final DiaryService instance = DiaryService._();
  DiaryService._();

  List<DiaryEntry> _entries = [];
  StreamSubscription<QuerySnapshot>? _diarySubscription;

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

  /// Load entries from SharedPreferences and subscribe to Firestore real-time updates.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null) {
        final List<dynamic> raw = jsonDecode(jsonStr) as List<dynamic>;
        _entries = raw
            .map((j) => DiaryEntry.fromJson(j as Map<String, dynamic>))
            .toList();
        _sort();
      } else {
        _entries = [];
      }

      // Initialize real-time Cloud Firestore sync
      initCloudSync();
    } catch (e) {
      debugPrint('[DIARY SERVICE] Error loading local entries: $e');
      _entries = [];
    }
  }

  /// Initialize real-time Cloud Firestore listener for users/{uid}/diary
  void initCloudSync() {
    _diarySubscription?.cancel();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || AuthService.instance.isGuestMode) {
      debugPrint('[DIARY CLOUD] Guest mode or unauthenticated. Using local storage only.');
      return;
    }

    final collectionPath = 'users/${user.uid}/diary';
    debugPrint('[DIARY CLOUD] Subscribing to real-time stream at $collectionPath...');

    _diarySubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('diary')
        .snapshots()
        .listen(
      (snapshot) async {
        debugPrint('[DIARY CLOUD STREAM] Received ${snapshot.docs.length} entries from Firestore');
        final List<DiaryEntry> remoteEntries = [];
        for (final doc in snapshot.docs) {
          try {
            final entry = DiaryEntry.fromFirestore(doc.data(), doc.id);
            remoteEntries.add(entry);
          } catch (e) {
            debugPrint('[DIARY CLOUD PARSE ERROR] Error parsing entry ${doc.id}: $e');
          }
        }

        if (remoteEntries.isNotEmpty || snapshot.docs.isEmpty) {
          _entries = remoteEntries;
          _sort();
          await _save();
        }
      },
      onError: (error) {
        debugPrint('[DIARY CLOUD STREAM ERROR] Error listening to diary stream: $error');
      },
    );
  }

  /// Stop active Cloud Firestore real-time stream listener
  void stopCloudSync() {
    _diarySubscription?.cancel();
    _diarySubscription = null;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }

  /// Add a new diary entry and upload to Cloud Firestore.
  Future<void> add(DiaryEntry entry) async {
    _entries.insert(0, entry);
    _sort();
    await _save();

    // Cloud Firestore Upload
    await _uploadEntryToCloud(entry);
  }

  /// Update an existing diary entry and sync to Cloud Firestore.
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

      // Cloud Firestore Update
      await _uploadEntryToCloud(entry);
    }
  }

  /// Toggle favorite status of an entry and sync to Cloud Firestore.
  Future<void> toggleFavorite(String id) async {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index != -1) {
      final updated = _entries[index].copyWith(
        favorite: !_entries[index].favorite,
      );
      _entries[index] = updated;
      await _save();

      // Cloud Firestore Update
      await _uploadEntryToCloud(updated);
    }
  }

  /// Delete a diary entry and remove from Cloud Firestore.
  Future<void> delete(String id) async {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index != -1) {
      final entry = _entries[index];
      if (entry.audioPath != null) {
        _deleteAudioFile(entry.audioPath!);
      }
      _entries.removeAt(index);
      await _save();

      // Cloud Firestore Deletion
      await _deleteEntryFromCloud(id);
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

  // ── Cloud Firestore Operations ───────────────────────────────────────────

  Future<void> _uploadEntryToCloud(DiaryEntry entry) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || AuthService.instance.isGuestMode) return;

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('diary')
          .doc(entry.id);

      debugPrint('[DIARY CLOUD] Uploading diary entry ${entry.id} to users/${user.uid}/diary...');
      await docRef
          .set(entry.toFirestore(), SetOptions(merge: true))
          .timeout(const Duration(seconds: 12));
      debugPrint('[DIARY CLOUD SUCCESS] Entry ${entry.id} saved in Firestore users/${user.uid}/diary');
    } on FirebaseException catch (e) {
      debugPrint('[DIARY CLOUD ERROR] FirebaseException uploading entry: ${e.code} - ${e.message}');
    } catch (e) {
      debugPrint('[DIARY CLOUD ERROR] Error uploading entry: $e');
    }
  }

  Future<void> _deleteEntryFromCloud(String entryId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || AuthService.instance.isGuestMode) return;

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('diary')
          .doc(entryId);

      debugPrint('[DIARY CLOUD] Deleting entry $entryId from users/${user.uid}/diary...');
      await docRef.delete().timeout(const Duration(seconds: 12));
      debugPrint('[DIARY CLOUD SUCCESS] Deleted entry $entryId from Firestore');
    } on FirebaseException catch (e) {
      debugPrint('[DIARY CLOUD ERROR] FirebaseException deleting entry: ${e.code} - ${e.message}');
    } catch (e) {
      debugPrint('[DIARY CLOUD ERROR] Error deleting entry from Firestore: $e');
    }
  }

  // ── Search & Filter ───────────────────────────────────────────────────────

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
