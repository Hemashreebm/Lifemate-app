import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Structured AI Memory Fact entry storing user preferences, context, and habits.
class AiMemoryFact {
  final String id;
  final String key;
  final String value;
  final String category; // 'preference', 'habit', 'goal', 'context', 'profile'
  final DateTime createdAt;
  final DateTime updatedAt;

  const AiMemoryFact({
    required this.id,
    required this.key,
    required this.value,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'key': key,
        'value': value,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory AiMemoryFact.fromJson(Map<String, dynamic> json) => AiMemoryFact(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        key: json['key'] as String? ?? '',
        value: json['value'] as String? ?? '',
        category: json['category'] as String? ?? 'context',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}

/// Service managing persistent user AI Memory across sessions and device restarts.
class AiMemoryService {
  static const String _storageKey = 'lifemate_ai_memory_facts_v2';
  static final AiMemoryService instance = AiMemoryService._();
  AiMemoryService._();

  final Map<String, AiMemoryFact> _memoryStore = {};

  /// Read unmodifiable map of all stored memory facts.
  Map<String, AiMemoryFact> get allFacts => Map.unmodifiable(_memoryStore);

  /// Initialize AI Memory by loading facts from local storage & Firestore.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> raw = jsonDecode(jsonStr) as List<dynamic>;
        _memoryStore.clear();
        for (final item in raw) {
          if (item is Map<String, dynamic>) {
            final fact = AiMemoryFact.fromJson(item);
            if (fact.key.isNotEmpty) {
              _memoryStore[fact.key] = fact;
            }
          }
        }
      }
      debugPrint('[AI MEMORY] Loaded ${_memoryStore.length} memory facts locally.');
      _syncFromCloud();
    } catch (e) {
      debugPrint('[AI MEMORY] Init error: $e');
    }
  }

  /// Store or update a memory fact for the user.
  Future<void> remember({
    required String key,
    required String value,
    String category = 'context',
  }) async {
    if (key.trim().isEmpty || value.trim().isEmpty) return;

    final now = DateTime.now();
    final existing = _memoryStore[key];

    final fact = AiMemoryFact(
      id: existing?.id ?? 'mem_${now.millisecondsSinceEpoch}',
      key: key.trim(),
      value: value.trim(),
      category: category,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    _memoryStore[key] = fact;
    await _saveLocal();
    await _syncToCloud(fact);
    debugPrint('[AI MEMORY] Remembered: ${fact.key} = "${fact.value}"');
  }

  /// Retrieve a specific memory value by key.
  String? getFact(String key) {
    return _memoryStore[key]?.value;
  }

  /// Get formatted memory context string for AI prompts.
  String getMemoryContextPrompt() {
    if (_memoryStore.isEmpty) return 'No prior user memory facts.';
    return _memoryStore.values.map((f) => '${f.key}: ${f.value}').join('; ');
  }

  /// Forget / delete a memory fact.
  Future<void> forget(String key) async {
    if (_memoryStore.containsKey(key)) {
      final factId = _memoryStore[key]?.id;
      _memoryStore.remove(key);
      await _saveLocal();
      if (factId != null) {
        await _deleteFromCloud(factId);
      }
      debugPrint('[AI MEMORY] Forgotten key: $key');
    }
  }

  /// Clear all stored memory facts.
  Future<void> clearAll() async {
    _memoryStore.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    debugPrint('[AI MEMORY] Cleared all memory facts.');
  }

  /// Generate a concise context system prompt summarizing user memory for AI Assistant.
  String buildSystemContextPrompt() {
    if (_memoryStore.isEmpty) return '';

    final sb = StringBuffer();
    sb.writeln('\n[USER MEMORY & PREFERENCES]');
    for (final fact in _memoryStore.values) {
      sb.writeln('- ${fact.key}: ${fact.value}');
    }
    sb.writeln('Use these personal details to provide tailored, empathetic, and relevant answers.\n');
    return sb.toString();
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final listJson = _memoryStore.values.map((f) => f.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(listJson));
  }

  Future<void> _syncToCloud(AiMemoryFact fact) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('ai_memory')
            .doc(fact.id)
            .set(fact.toJson());
      }
    } catch (e) {
      debugPrint('[AI MEMORY] Cloud sync write error: $e');
    }
  }

  Future<void> _deleteFromCloud(String factId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('ai_memory')
            .doc(factId)
            .delete();
      }
    } catch (e) {
      debugPrint('[AI MEMORY] Cloud sync delete error: $e');
    }
  }

  Future<void> _syncFromCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('ai_memory')
            .get();

        for (final doc in snapshot.docs) {
          final fact = AiMemoryFact.fromJson(doc.data());
          if (fact.key.isNotEmpty) {
            _memoryStore[fact.key] = fact;
          }
        }
        await _saveLocal();
        debugPrint('[AI MEMORY] Synced ${_memoryStore.length} facts from Firestore.');
      }
    } catch (e) {
      debugPrint('[AI MEMORY] Cloud sync read error: $e');
    }
  }
}
