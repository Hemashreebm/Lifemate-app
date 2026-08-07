import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single Vocabulary Item with pronunciation, meaning, and example.
class VocabularyWord {
  final String word;
  final String phonetic;
  final String partOfSpeech;
  final String meaning;
  final String example;
  final String category;
  final bool isFavorite;

  const VocabularyWord({
    required this.word,
    required this.phonetic,
    required this.partOfSpeech,
    required this.meaning,
    required this.example,
    required this.category,
    this.isFavorite = false,
  });

  VocabularyWord copyWith({bool? isFavorite}) {
    return VocabularyWord(
      word: word,
      phonetic: phonetic,
      partOfSpeech: partOfSpeech,
      meaning: meaning,
      example: example,
      category: category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'word': word,
        'phonetic': phonetic,
        'partOfSpeech': partOfSpeech,
        'meaning': meaning,
        'example': example,
        'category': category,
        'isFavorite': isFavorite,
      };

  factory VocabularyWord.fromJson(Map<String, dynamic> json) => VocabularyWord(
        word: json['word'] as String,
        phonetic: (json['phonetic'] as String?) ?? '',
        partOfSpeech: (json['partOfSpeech'] as String?) ?? 'noun',
        meaning: json['meaning'] as String,
        example: json['example'] as String,
        category: (json['category'] as String?) ?? 'Daily Life',
        isFavorite: (json['isFavorite'] as bool?) ?? false,
      );
}

/// Grammar Lesson Topic Model
class GrammarTopic {
  final String id;
  final String title;
  final String description;
  final List<String> keyRules;
  final List<GrammarQuestion> questions;
  final bool isCompleted;

  const GrammarTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.keyRules,
    required this.questions,
    this.isCompleted = false,
  });

  GrammarTopic copyWith({bool? isCompleted}) => GrammarTopic(
        id: id,
        title: title,
        description: description,
        keyRules: keyRules,
        questions: questions,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}

class GrammarQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const GrammarQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

/// Achievement Badge Model
class AchievementBadge {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final bool isUnlocked;
  final String unlockedDate;

  const AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.isUnlocked,
    required this.unlockedDate,
  });

  AchievementBadge copyWith({bool? isUnlocked, String? unlockedDate}) => AchievementBadge(
        id: id,
        title: title,
        description: description,
        iconName: iconName,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        unlockedDate: unlockedDate ?? this.unlockedDate,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'iconName': iconName,
        'isUnlocked': isUnlocked,
        'unlockedDate': unlockedDate,
      };

  factory AchievementBadge.fromJson(Map<String, dynamic> json) => AchievementBadge(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        iconName: json['iconName'] as String,
        isUnlocked: (json['isUnlocked'] as bool?) ?? false,
        unlockedDate: (json['unlockedDate'] as String?) ?? '',
      );
}

/// Core Platform Manager for Communication Coach Expansion.
class CommunicationPlatformService {
  static const String _prefFavWordsKey = 'lifemate_coach_fav_words_v2';
  static const String _prefGrammarProgressKey = 'lifemate_coach_grammar_v2';
  static const String _prefOverallScoreKey = 'lifemate_coach_score_v2';
  static const String _prefAchievementsKey = 'lifemate_coach_achieve_v2';

  static final CommunicationPlatformService instance = CommunicationPlatformService._();
  CommunicationPlatformService._();

  Set<String> _favoriteWords = {};
  Set<String> _completedGrammarTopics = {};
  int _grammarScore = 82;
  int _vocabScore = 85;
  int _pronunciationScore = 78;
  int _speakingScore = 80;
  int _listeningScore = 88;
  int _writingScore = 84;

  List<AchievementBadge> _achievements = [];

  Set<String> get favoriteWords => Set.unmodifiable(_favoriteWords);
  Set<String> get completedGrammarTopics => Set.unmodifiable(_completedGrammarTopics);
  List<AchievementBadge> get achievements => List.unmodifiable(_achievements);

  int get overallScore =>
      ((_grammarScore + _vocabScore + _pronunciationScore + _speakingScore + _listeningScore + _writingScore) / 6)
          .round();

  int get grammarScore => _grammarScore;
  int get vocabScore => _vocabScore;
  int get pronunciationScore => _pronunciationScore;
  int get speakingScore => _speakingScore;
  int get listeningScore => _listeningScore;
  int get writingScore => _writingScore;

  /// Load state from SharedPreferences and sync from Firestore.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _favoriteWords = (prefs.getStringList(_prefFavWordsKey) ?? []).toSet();
      _completedGrammarTopics = (prefs.getStringList(_prefGrammarProgressKey) ?? []).toSet();

      final savedScore = prefs.getInt(_prefOverallScoreKey);
      if (savedScore != null && savedScore > 0) {
        _grammarScore = prefs.getInt('score_grammar') ?? 82;
        _vocabScore = prefs.getInt('score_vocab') ?? 85;
        _pronunciationScore = prefs.getInt('score_pron') ?? 78;
        _speakingScore = prefs.getInt('score_speak') ?? 80;
        _listeningScore = prefs.getInt('score_listen') ?? 88;
        _writingScore = prefs.getInt('score_write') ?? 84;
      }

      _loadDefaultAchievements();
      final savedAchieveJson = prefs.getString(_prefAchievementsKey);
      if (savedAchieveJson != null) {
        final List<dynamic> raw = jsonDecode(savedAchieveJson) as List<dynamic>;
        final Map<String, AchievementBadge> map = {
          for (var item in raw) (item['id'] as String): AchievementBadge.fromJson(item as Map<String, dynamic>)
        };
        _achievements = _achievements.map((a) {
          final saved = map[a.id];
          return saved ?? a;
        }).toList();
      }

      await fetchFromCloud();
    } catch (e) {
      debugPrint('[COMMUNICATION PLATFORM] Error initializing: $e');
    }
  }

  void _loadDefaultAchievements() {
    _achievements = [
      const AchievementBadge(
        id: 'streak_7',
        title: '7-Day Orator Streak',
        description: 'Practice communication every day for 7 consecutive days.',
        iconName: 'local_fire_department_rounded',
        isUnlocked: true,
        unlockedDate: 'Recent',
      ),
      const AchievementBadge(
        id: 'streak_30',
        title: '30-Day Master Communicator',
        description: 'Complete daily practice for 30 full days.',
        iconName: 'workspace_premium_rounded',
        isUnlocked: false,
        unlockedDate: '',
      ),
      const AchievementBadge(
        id: 'vocab_50',
        title: 'Vocabulary Builder 50',
        description: 'Master 50 high-impact vocabulary words across categories.',
        iconName: 'menu_book_rounded',
        isUnlocked: true,
        unlockedDate: 'Recent',
      ),
      const AchievementBadge(
        id: 'grammar_pro',
        title: 'Grammar Perfectionist',
        description: 'Complete all 6 Grammar Coach modules with 80%+ quiz score.',
        iconName: 'spellcheck_rounded',
        isUnlocked: false,
        unlockedDate: '',
      ),
      const AchievementBadge(
        id: 'interview_champ',
        title: 'AI Interview Champion',
        description: 'Successfully complete 5 HR and Technical mock interviews.',
        iconName: 'business_center_rounded',
        isUnlocked: false,
        unlockedDate: '',
      ),
    ];
  }

  /// Toggle word bookmarking.
  Future<void> toggleFavoriteWord(String word) async {
    if (_favoriteWords.contains(word)) {
      _favoriteWords.remove(word);
    } else {
      _favoriteWords.add(word);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefFavWordsKey, _favoriteWords.toList());
    await syncToCloud();
  }

  /// Complete a Grammar module.
  Future<void> markGrammarTopicCompleted(String topicId, int score) async {
    _completedGrammarTopics.add(topicId);
    _grammarScore = ((_grammarScore * 0.7) + (score * 0.3)).round().clamp(50, 100);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefGrammarProgressKey, _completedGrammarTopics.toList());
    await prefs.setInt('score_grammar', _grammarScore);
    await prefs.setInt(_prefOverallScoreKey, overallScore);

    if (_completedGrammarTopics.length >= 6) {
      _unlockAchievement('grammar_pro');
    }

    await syncToCloud();
  }

  void _unlockAchievement(String id) {
    final idx = _achievements.indexWhere((a) => a.id == id);
    if (idx != -1 && !_achievements[idx].isUnlocked) {
      _achievements[idx] = _achievements[idx].copyWith(
        isUnlocked: true,
        unlockedDate: DateTime.now().toString().substring(0, 10),
      );
      _saveAchievements();
    }
  }

  Future<void> _saveAchievements() async {
    final prefs = meAsync();
    final p = await prefs;
    final jsonList = _achievements.map((a) => a.toJson()).toList();
    await p.setString(_prefAchievementsKey, jsonEncode(jsonList));
  }

  Future<SharedPreferences> meAsync() => SharedPreferences.getInstance();

  /// Cloud Sync under users/{uid}/communication_coach
  Future<void> syncToCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final data = {
        'favoriteWords': _favoriteWords.toList(),
        'completedGrammar': _completedGrammarTopics.toList(),
        'overallScore': overallScore,
        'scores': {
          'grammar': _grammarScore,
          'vocab': _vocabScore,
          'pronunciation': _pronunciationScore,
          'speaking': _speakingScore,
          'listening': _listeningScore,
          'writing': _writingScore,
        },
        'achievements': _achievements.map((a) => a.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('communication')
          .doc('progress')
          .set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[COMMUNICATION CLOUD] Error syncing: $e');
    }
  }

  Future<void> fetchFromCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('communication')
          .doc('progress')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['favoriteWords'] != null) {
          _favoriteWords = Set<String>.from(data['favoriteWords'] as List);
        }
        if (data['completedGrammar'] != null) {
          _completedGrammarTopics = Set<String>.from(data['completedGrammar'] as List);
        }
        if (data['scores'] != null) {
          final s = data['scores'] as Map<String, dynamic>;
          _grammarScore = (s['grammar'] as int?) ?? _grammarScore;
          _vocabScore = (s['vocab'] as int?) ?? _vocabScore;
          _pronunciationScore = (s['pronunciation'] as int?) ?? _pronunciationScore;
          _speakingScore = (s['speaking'] as int?) ?? _speakingScore;
          _listeningScore = (s['listening'] as int?) ?? _listeningScore;
          _writingScore = (s['writing'] as int?) ?? _writingScore;
        }
      }
    } catch (e) {
      debugPrint('[COMMUNICATION CLOUD] Error fetching: $e');
    }
  }

  /// Get Daily 5 Vocabulary Challenge Words
  List<VocabularyWord> getDailyChallengeWords() {
    return const [
      VocabularyWord(
        word: 'Eloquent',
        phonetic: '/ˈel.ə.kwənt/',
        partOfSpeech: 'adjective',
        meaning: 'Fluent, persuasive, and expressive in speaking or writing.',
        example: 'She gave an eloquent speech that moved the entire audience.',
        category: 'Daily Life',
      ),
      VocabularyWord(
        word: 'Meticulous',
        phonetic: '/məˈtɪk.jə.ləs/',
        partOfSpeech: 'adjective',
        meaning: 'Showing great attention to detail; very careful and precise.',
        example: 'He was meticulous about keeping his financial records organized.',
        category: 'Office',
      ),
      VocabularyWord(
        word: 'Resilient',
        phonetic: '/rɪˈzɪl.jənt/',
        partOfSpeech: 'adjective',
        meaning: 'Able to withstand or recover quickly from difficult conditions.',
        example: 'Successful entrepreneurs remain resilient during setbacks.',
        category: 'Business',
      ),
      VocabularyWord(
        word: 'Pragmatic',
        phonetic: '/præɡˈmæt.ɪk/',
        partOfSpeech: 'adjective',
        meaning: 'Dealing with things sensibly and realistically based on practical considerations.',
        example: 'We need a pragmatic approach to solving this technical problem.',
        category: 'Technology',
      ),
      VocabularyWord(
        word: 'Articulate',
        phonetic: '/ɑːˈtɪk.jə.lət/',
        partOfSpeech: 'verb / adj',
        meaning: 'Expressing ideas clearly and effectively in speech.',
        example: 'Candidates who articulate their thoughts clearly perform better in interviews.',
        category: 'Interview',
      ),
    ];
  }

  /// Get Vocabulary List by Category
  List<VocabularyWord> getVocabularyByCategory(String category) {
    final allWords = [
      ...getDailyChallengeWords(),
      const VocabularyWord(
        word: 'Collaborate',
        phonetic: '/kəˈlæb.ə.reɪt/',
        partOfSpeech: 'verb',
        meaning: 'Work jointly on an activity or project.',
        example: 'Our engineering team will collaborate with the design department.',
        category: 'Office',
      ),
      const VocabularyWord(
        word: 'Innovative',
        phonetic: '/ˈɪn.ə.və.tɪv/',
        partOfSpeech: 'adjective',
        meaning: 'Featuring new methods; advanced and original.',
        example: 'The startup introduced an innovative solution for mobile payments.',
        category: 'Technology',
      ),
      const VocabularyWord(
        word: 'Itinerary',
        phonetic: '/aɪˈtɪn.ər.ər.i/',
        partOfSpeech: 'noun',
        meaning: 'A planned route or journey schedule.',
        example: 'Check your flight itinerary before heading to the airport.',
        category: 'Travel',
      ),
      const VocabularyWord(
        word: 'Competency',
        phonetic: '/ˈkɒm.pɪ.tən.si/',
        partOfSpeech: 'noun',
        meaning: 'The ability to do something successfully or efficiently.',
        example: 'Demonstrating core competency is key to landing senior roles.',
        category: 'Interview',
      ),
      const VocabularyWord(
        word: 'Curriculum',
        phonetic: '/kəˈrɪk.jə.ləm/',
        partOfSpeech: 'noun',
        meaning: 'The subjects comprising a course of study in a school or college.',
        example: 'The updated university curriculum includes artificial intelligence.',
        category: 'Education',
      ),
    ];

    if (category == 'Favorites') {
      return allWords.where((w) => _favoriteWords.contains(w.word)).toList();
    }

    if (category == 'All') return allWords;
    return allWords.where((w) => w.category == category).toList();
  }

  /// Get Grammar Topics
  List<GrammarTopic> getGrammarTopics() {
    return [
      GrammarTopic(
        id: 'tenses_101',
        title: 'Mastering Tenses (Present, Past, Future)',
        description: 'Learn when to use Simple, Continuous, and Perfect tenses with confidence.',
        keyRules: [
          'Present Perfect: Action started in past with relevance now (e.g. "I have finished my work").',
          'Past Continuous: Ongoing past action interrupted by simple past (e.g. "I was studying when he called").',
          'Future Perfect: Action that will be completed before a future time (e.g. "I will have completed the report by 5 PM").',
        ],
        questions: const [
          GrammarQuestion(
            question: 'Select the correct tense: "By next month, she _____ at this company for 5 years."',
            options: ['will work', 'worked', 'will have worked', 'is working'],
            correctIndex: 2,
            explanation: '"Will have worked" (Future Perfect) is used for actions completed before a future time.',
          ),
          GrammarQuestion(
            question: 'Identify the sentence with correct past continuous tense:',
            options: [
              'I am writing code yesterday.',
              'I was writing code when the power went out.',
              'I written code yesterday night.',
              'I will be write code.'
            ],
            correctIndex: 1,
            explanation: '"Was writing" correctly expresses an interrupted past action.',
          ),
        ],
        isCompleted: _completedGrammarTopics.contains('tenses_101'),
      ),
      GrammarTopic(
        id: 'articles_101',
        title: 'Articles (A, An, The)',
        description: 'Avoid common mistakes with indefinite (a/an) and definite (the) articles.',
        keyRules: [
          'Use "An" before vowel SOUNDS (e.g. "an hour", "an MBA", "an apple").',
          'Use "A" before consonant SOUNDS (e.g. "a university", "a European", "a book").',
          'Use "The" for specific items or unique entities (e.g. "the sun", "the CEO").',
        ],
        questions: const [
          GrammarQuestion(
            question: 'Choose the correct article: "He holds _____ Master\'s degree in Computer Science."',
            options: ['a', 'an', 'the', 'no article needed'],
            correctIndex: 0,
            explanation: '"Master\'s" starts with a consonant sound /m/, so use "a".',
          ),
        ],
        isCompleted: _completedGrammarTopics.contains('articles_101'),
      ),
      GrammarTopic(
        id: 'prepositions_101',
        title: 'Prepositions of Time & Place (In, On, At)',
        description: 'Master prepositions for time, dates, locations, and directions.',
        keyRules: [
          'AT: Specific times and exact places (e.g. "at 9 AM", "at the entrance").',
          'ON: Days, dates, and surfaces (e.g. "on Monday", "on July 4th", "on the table").',
          'IN: Months, years, centuries, and enclosed spaces (e.g. "in August", "in 2026", "in India").',
        ],
        questions: const [
          GrammarQuestion(
            question: 'Fill in the blank: "The project meeting starts _____ Monday _____ 10:00 AM."',
            options: ['in, at', 'on, at', 'at, on', 'on, in'],
            correctIndex: 1,
            explanation: 'Use "on" for days of the week and "at" for specific clock times.',
          ),
        ],
        isCompleted: _completedGrammarTopics.contains('prepositions_101'),
      ),
      GrammarTopic(
        id: 'active_passive',
        title: 'Active & Passive Voice',
        description: 'Transform sentences between Active (doer first) and Passive (action focused).',
        keyRules: [
          'Active: Subject performs action (e.g. "The developer wrote the code").',
          'Passive: Action is received by subject (e.g. "The code was written by the developer").',
          'Use passive voice in official reports and formal announcements.',
        ],
        questions: const [
          GrammarQuestion(
            question: 'Convert to Passive Voice: "The manager approved the budget."',
            options: [
              'The budget was approved by the manager.',
              'The budget approved the manager.',
              'The manager is approving the budget.',
              'The budget has been approve.'
            ],
            correctIndex: 0,
            explanation: 'Passive voice places the recipient ("The budget") first followed by "was approved".',
          ),
        ],
        isCompleted: _completedGrammarTopics.contains('active_passive'),
      ),
      GrammarTopic(
        id: 'direct_indirect',
        title: 'Direct & Indirect Speech',
        description: 'Report spoken statements accurately without changing the core meaning.',
        keyRules: [
          'Direct Speech: Uses exact quotes (e.g. He said, "I am ready").',
          'Indirect Speech: Shifts tense back (e.g. He said that he was ready).',
          'Pronouns and time references shift (e.g. "now" -> "then", "today" -> "that day").',
        ],
        questions: const [
          GrammarQuestion(
            question: 'Convert to Reported Speech: She said, "I am working on the project."',
            options: [
              'She said that she was working on the project.',
              'She said that I am working on the project.',
              'She told she is working on the project.',
              'She says that she worked on project.'
            ],
            correctIndex: 0,
            explanation: '"I am working" shifts to past continuous "she was working" in indirect speech.',
          ),
        ],
        isCompleted: _completedGrammarTopics.contains('direct_indirect'),
      ),
      GrammarTopic(
        id: 'sentence_formation',
        title: 'Sentence Formation & Structure',
        description: 'Construct clear, complex, and impactful sentences without run-on errors.',
        keyRules: [
          'Subject + Verb + Object is the foundation of English sentence structure.',
          'Avoid dangling modifiers (e.g. "Walking down the street, the building was tall").',
          'Use conjunctions (and, but, although, because) to connect clauses cleanly.',
        ],
        questions: const [
          GrammarQuestion(
            question: 'Choose the grammatically correct sentence:',
            options: [
              'Although it was raining, but we went for a walk.',
              'Although it was raining, we went for a walk.',
              'Because it was raining so we stayed home.',
              'While studying, the lights turned off.'
            ],
            correctIndex: 1,
            explanation: 'Do not pair "Although" with "but" in the same sentence.',
          ),
        ],
        isCompleted: _completedGrammarTopics.contains('sentence_formation'),
      ),
    ];
  }

  /// Analyze Public Speaking Recording (Speed WPM, Fillers, Clarity, Confidence Score)
  Map<String, dynamic> analyzePublicSpeakingSpeech(String spokenText, int durationSeconds) {
    if (spokenText.trim().isEmpty) {
      return {
        'wpm': 0,
        'fillerCount': 0,
        'fillersFound': <String>[],
        'clarityScore': 0,
        'confidenceScore': 0,
        'tips': ['Press the microphone and speak for at least 15 seconds to receive detailed feedback.'],
      };
    }

    final words = spokenText.trim().split(RegExp(r'\s+'));
    final wordCount = words.length;
    final minutes = durationSeconds > 0 ? durationSeconds / 60.0 : 0.5;
    final wpm = (wordCount / minutes).round();

    final fillerRegex = RegExp(r'\b(um|uh|like|you know|basically|actually|literally|so yeah)\b', caseSensitive: false);
    final fillerMatches = fillerRegex.allMatches(spokenText).map((m) => m.group(0)!.toLowerCase()).toList();

    int clarityScore = 90 - (fillerMatches.length * 4);
    if (wpm < 110) clarityScore -= 10; // Too slow
    if (wpm > 175) clarityScore -= 12; // Too fast
    clarityScore = clarityScore.clamp(45, 98);

    int confidenceScore = 88;
    if (fillerMatches.length > 3) confidenceScore -= 15;
    if (wordCount > 30) confidenceScore += 5;
    confidenceScore = confidenceScore.clamp(40, 99);

    final tips = <String>[];
    if (wpm < 120) tips.add('Speed up slightly. Ideal speaking pace is 130–150 words per minute.');
    else if (wpm > 160) tips.add('Slow down your pace to let key points resonate with your audience.');
    else tips.add('Great speaking pace! Your speed falls perfectly within professional speaking standards.');

    if (fillerMatches.isNotEmpty) {
      tips.add('Detected ${fillerMatches.length} filler words (${fillerMatches.join(', ')}). Pause silently instead of using fillers.');
    } else {
      tips.add('Excellent fluency! Zero filler words detected in your speech.');
    }

    return {
      'wpm': wpm,
      'fillerCount': fillerMatches.length,
      'fillersFound': fillerMatches,
      'clarityScore': clarityScore,
      'confidenceScore': confidenceScore,
      'tips': tips,
    };
  }

  /// Analyze Writing Assistant Input (Grammar & Sentence Proofreader)
  Map<String, dynamic> analyzeWritingText(String text) {
    if (text.trim().isEmpty) {
      return {
        'correctedText': '',
        'score': 100,
        'corrections': <Map<String, String>>[],
      };
    }

    String corrected = text;
    final corrections = <Map<String, String>>[];

    // Common Indian English & Grammar Corrections
    final rules = [
      {
        'pattern': r'\bi am having a doubt\b',
        'replacement': 'I have a question',
        'explanation': 'In formal English, use "I have a question" instead of "having a doubt".'
      },
      {
        'pattern': r'\bdo one thing\b',
        'replacement': 'here is a suggestion',
        'explanation': '"Do one thing" is a literal translation. Prefer "here is what we can do".'
      },
      {
        'pattern': r'\brevert back\b',
        'replacement': 'reply',
        'explanation': '"Revert" already means go back or reply. "Revert back" is redundant.'
      },
      {
        'pattern': r'\bdiscuss about\b',
        'replacement': 'discuss',
        'explanation': '"Discuss" takes a direct object without the preposition "about".'
      },
      {
        'pattern': r'\bi am agree\b',
        'replacement': 'I agree',
        'explanation': '"Agree" is a verb itself. Say "I agree" instead of "I am agree".'
      },
    ];

    for (final rule in rules) {
      final reg = RegExp(rule['pattern']!, caseSensitive: false);
      if (reg.hasMatch(corrected)) {
        corrections.add({
          'original': reg.firstMatch(corrected)!.group(0)!,
          'suggestion': rule['replacement']!,
          'explanation': rule['explanation']!,
        });
        corrected = corrected.replaceAll(reg, rule['replacement']!);
      }
    }

    final score = (100 - (corrections.length * 15)).clamp(50, 100);

    return {
      'correctedText': corrected,
      'score': score,
      'corrections': corrections,
    };
  }
}
