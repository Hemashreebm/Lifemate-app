import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single lesson item model in the Communication Coach curriculum.
class CoachLesson {
  final String id;
  final String level; // 'Beginner', 'Intermediate', 'Advanced'
  final int levelNumber;
  final int lessonNumber;
  final String title;
  final String description;
  final String type; // 'speaking', 'listening', 'interview', 'discussion', 'quiz'
  final int xpReward;
  final bool isUnlocked;
  final bool isCompleted;
  final int highestScore;

  const CoachLesson({
    required this.id,
    required this.level,
    required this.levelNumber,
    required this.lessonNumber,
    required this.title,
    required this.description,
    required this.type,
    required this.xpReward,
    required this.isUnlocked,
    required this.isCompleted,
    required this.highestScore,
  });

  CoachLesson copyWith({
    bool? isUnlocked,
    bool? isCompleted,
    int? highestScore,
  }) {
    return CoachLesson(
      id: id,
      level: level,
      levelNumber: levelNumber,
      lessonNumber: lessonNumber,
      title: title,
      description: description,
      type: type,
      xpReward: xpReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      highestScore: highestScore ?? this.highestScore,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'isUnlocked': isUnlocked,
        'isCompleted': isCompleted,
        'highestScore': highestScore,
      };
}

/// Service managing Communication Coach curriculum, XP, Streaks, and Badges.
class CommunicationCurriculumService {
  static const String _prefCurriculumKey = 'lifemate_coach_curriculum_v1';
  static const String _prefXpKey = 'lifemate_coach_xp_v1';
  static const String _prefStreakKey = 'lifemate_coach_streak_v1';
  static const String _prefLastDateKey = 'lifemate_coach_last_date_v1';

  static final CommunicationCurriculumService instance =
      CommunicationCurriculumService._();
  CommunicationCurriculumService._();

  int _totalXp = 0;
  int _streakDays = 1;
  List<String> _earnedBadges = ['First Step'];

  int get totalXp => _totalXp;
  int get streakDays => _streakDays;
  List<String> get earnedBadges => List.unmodifiable(_earnedBadges);

  List<CoachLesson> _lessons = [];
  List<CoachLesson> get lessons => List.unmodifiable(_lessons);

  /// Default predefined structured curriculum (Level 1 -> Level 3).
  static final List<CoachLesson> _defaultCurriculum = [
    //  Beginner (Level 1) 
    const CoachLesson(
      id: 'beg_l1_1',
      level: 'Beginner',
      levelNumber: 1,
      lessonNumber: 1,
      title: 'Greetings & Introductions',
      description: 'Master warm greetings, self-introductions, and friendly small talk.',
      type: 'speaking',
      xpReward: 50,
      isUnlocked: true, // Always unlocked
      isCompleted: false,
      highestScore: 0,
    ),
    const CoachLesson(
      id: 'beg_l1_2',
      level: 'Beginner',
      levelNumber: 1,
      lessonNumber: 2,
      title: 'Expressing Preferences & Requests',
      description: 'Learn polite phrasing for asking favors, ordering, and seeking help.',
      type: 'listening',
      xpReward: 60,
      isUnlocked: false,
      isCompleted: false,
      highestScore: 0,
    ),
    const CoachLesson(
      id: 'beg_l1_3',
      level: 'Beginner',
      levelNumber: 1,
      lessonNumber: 3,
      title: 'Daily Conversations & Shopping',
      description: 'Practice real-life dialogue at stores, cafes, and local markets.',
      type: 'quiz',
      xpReward: 75,
      isUnlocked: false,
      isCompleted: false,
      highestScore: 0,
    ),

    //  Intermediate (Level 2) 
    const CoachLesson(
      id: 'int_l2_1',
      level: 'Intermediate',
      levelNumber: 2,
      lessonNumber: 1,
      title: 'Workplace & Meeting Etiquette',
      description: 'Professional vocabulary, team updates, and active listening skills.',
      type: 'speaking',
      xpReward: 100,
      isUnlocked: false,
      isCompleted: false,
      highestScore: 0,
    ),
    const CoachLesson(
      id: 'int_l2_2',
      level: 'Intermediate',
      levelNumber: 2,
      lessonNumber: 2,
      title: 'AI Job Interview Practice',
      description: 'Simulate common job interview questions with tone & clarity feedback.',
      type: 'interview',
      xpReward: 120,
      isUnlocked: false,
      isCompleted: false,
      highestScore: 0,
    ),
    const CoachLesson(
      id: 'int_l2_3',
      level: 'Intermediate',
      levelNumber: 2,
      lessonNumber: 3,
      title: 'Handling Opinions & Discussions',
      description: 'Diplomatically agree, disagree, and justify your viewpoints.',
      type: 'speaking',
      xpReward: 140,
      isUnlocked: false,
      isCompleted: false,
      highestScore: 0,
    ),

    //  Advanced (Level 3) 
    const CoachLesson(
      id: 'adv_l3_1',
      level: 'Advanced',
      levelNumber: 3,
      lessonNumber: 1,
      title: 'Public Speaking & Presentations',
      description: 'Structure speeches with impact, vocal modulation, and confidence.',
      type: 'speaking',
      xpReward: 180,
      isUnlocked: false,
      isCompleted: false,
      highestScore: 0,
    ),
    const CoachLesson(
      id: 'adv_l3_2',
      level: 'Advanced',
      levelNumber: 3,
      lessonNumber: 2,
      title: 'AI Group Discussion Simulator',
      description: 'Participate in a multi-speaker group discussion on modern topics.',
      type: 'discussion',
      xpReward: 200,
      isUnlocked: false,
      isCompleted: false,
      highestScore: 0,
    ),
    const CoachLesson(
      id: 'adv_l3_3',
      level: 'Advanced',
      levelNumber: 3,
      lessonNumber: 3,
      title: 'Empathy & Persuasive Negotiation',
      description: 'Advanced communication strategies for high-stakes leadership.',
      type: 'interview',
      xpReward: 250,
      isUnlocked: false,
      isCompleted: false,
      highestScore: 0,
    ),
  ];

  /// Initialize and load saved curriculum progress from SharedPreferences.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _totalXp = prefs.getInt(_prefXpKey) ?? 0;
      _streakDays = prefs.getInt(_prefStreakKey) ?? 1;

      // Update streak
      final lastDateStr = prefs.getString(_prefLastDateKey);
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      if (lastDateStr != null && lastDateStr != todayStr) {
        final lastDate = DateTime.tryParse(lastDateStr);
        if (lastDate != null && DateTime.now().difference(lastDate).inDays == 1) {
          _streakDays++;
          await prefs.setInt(_prefStreakKey, _streakDays);
        }
      }
      await prefs.setString(_prefLastDateKey, todayStr);

      final jsonStr = prefs.getString(_prefCurriculumKey);
      if (jsonStr == null) {
        _lessons = List.from(_defaultCurriculum);
        return;
      }

      final List<dynamic> raw = jsonDecode(jsonStr) as List<dynamic>;
      final Map<String, Map<String, dynamic>> savedMap = {};
      for (final item in raw) {
        final map = item as Map<String, dynamic>;
        savedMap[map['id'] as String] = map;
      }

      _lessons = _defaultCurriculum.map((d) {
        final saved = savedMap[d.id];
        if (saved != null) {
          return d.copyWith(
            isUnlocked: (saved['isUnlocked'] as bool?) ?? d.isUnlocked,
            isCompleted: (saved['isCompleted'] as bool?) ?? d.isCompleted,
            highestScore: (saved['highestScore'] as int?) ?? d.highestScore,
          );
        }
        return d;
      }).toList();

      _evaluateBadges();
    } catch (e) {
      debugPrint('Error loading curriculum: $e');
      _lessons = List.from(_defaultCurriculum);
    }
  }

  /// Complete a lesson, award XP, unlock the next lesson, and save state.
  Future<void> completeLesson(String lessonId, int score) async {
    final index = _lessons.indexWhere((l) => l.id == lessonId);
    if (index == -1) return;

    final lesson = _lessons[index];
    final isFirstCompletion = !lesson.isCompleted;

    final updated = lesson.copyWith(
      isCompleted: true,
      highestScore: score > lesson.highestScore ? score : lesson.highestScore,
    );

    _lessons[index] = updated;

    // Unlock next lesson in line
    if (index + 1 < _lessons.length) {
      _lessons[index + 1] = _lessons[index + 1].copyWith(isUnlocked: true);
    }

    if (isFirstCompletion) {
      _totalXp += lesson.xpReward;
    }

    _evaluateBadges();

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefXpKey, _totalXp);
    final jsonList = _lessons.map((l) => l.toJson()).toList();
    await prefs.setString(_prefCurriculumKey, jsonEncode(jsonList));
  }

  void _evaluateBadges() {
    final badges = <String>['First Step'];
    final completedCount = _lessons.where((l) => l.isCompleted).length;

    if (completedCount >= 1) badges.add('Word Starter');
    if (completedCount >= 3) badges.add('Level 1 Champion');
    if (completedCount >= 6) badges.add('Interview Pro');
    if (completedCount >= 9) badges.add('Master Orator');
    if (_totalXp >= 500) badges.add('XP Legend');

    _earnedBadges = badges;
  }
}
