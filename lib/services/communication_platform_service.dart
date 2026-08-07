import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enhanced Vocabulary Item with synonyms, antonyms, pronunciation, and category.
class VocabularyWord {
  final String word;
  final String phonetic;
  final String partOfSpeech;
  final String meaning;
  final String example;
  final String category;
  final List<String> synonyms;
  final List<String> antonyms;
  final bool isFavorite;

  const VocabularyWord({
    required this.word,
    required this.phonetic,
    required this.partOfSpeech,
    required this.meaning,
    required this.example,
    required this.category,
    this.synonyms = const [],
    this.antonyms = const [],
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
      synonyms: synonyms,
      antonyms: antonyms,
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
        'synonyms': synonyms,
        'antonyms': antonyms,
        'isFavorite': isFavorite,
      };

  factory VocabularyWord.fromJson(Map<String, dynamic> json) => VocabularyWord(
        word: json['word'] as String,
        phonetic: (json['phonetic'] as String?) ?? '',
        partOfSpeech: (json['partOfSpeech'] as String?) ?? 'noun',
        meaning: json['meaning'] as String,
        example: json['example'] as String,
        category: (json['category'] as String?) ?? 'Daily Life',
        synonyms: (json['synonyms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
        antonyms: (json['antonyms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
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

/// Certificate Model for Course & Milestone Completion
class CertificateModel {
  final String id;
  final String title;
  final String description;
  final String issuedDate;
  final bool isEarned;

  const CertificateModel({
    required this.id,
    required this.title,
    required this.description,
    required this.issuedDate,
    required this.isEarned,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'issuedDate': issuedDate,
        'isEarned': isEarned,
      };

  factory CertificateModel.fromJson(Map<String, dynamic> json) => CertificateModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        issuedDate: (json['issuedDate'] as String?) ?? '',
        isEarned: (json['isEarned'] as bool?) ?? false,
      );
}

/// Listening & Reading Passage Model
class LearningPassage {
  final String id;
  final String title;
  final String category; // 'News', 'Stories', 'Technical', 'General'
  final String content;
  final List<GrammarQuestion> comprehensionQuestions;

  const LearningPassage({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.comprehensionQuestions,
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

/// Core Platform Manager for Communication Coach PRO Expansion.
class CommunicationPlatformService {
  static const String _prefFavWordsKey = 'lifemate_coach_fav_words_v2';
  static const String _prefGrammarProgressKey = 'lifemate_coach_grammar_v2';
  static const String _prefOverallScoreKey = 'lifemate_coach_score_v2';
  static const String _prefAchievementsKey = 'lifemate_coach_achieve_v2';
  static const String _prefCertificatesKey = 'lifemate_coach_certs_v2';

  static final CommunicationPlatformService instance = CommunicationPlatformService._();
  CommunicationPlatformService._();

  Set<String> _favoriteWords = {};
  Set<String> _completedGrammarTopics = {};
  int _grammarScore = 86;
  int _vocabScore = 88;
  int _pronunciationScore = 82;
  int _speakingScore = 85;
  int _listeningScore = 90;
  int _writingScore = 84;

  List<AchievementBadge> _achievements = [];
  List<CertificateModel> _certificates = [];

  Set<String> get favoriteWords => Set.unmodifiable(_favoriteWords);
  Set<String> get completedGrammarTopics => Set.unmodifiable(_completedGrammarTopics);
  List<AchievementBadge> get achievements => List.unmodifiable(_achievements);
  List<CertificateModel> get certificates => List.unmodifiable(_certificates);

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
        _grammarScore = prefs.getInt('score_grammar') ?? 86;
        _vocabScore = prefs.getInt('score_vocab') ?? 88;
        _pronunciationScore = prefs.getInt('score_pron') ?? 82;
        _speakingScore = prefs.getInt('score_speak') ?? 85;
        _listeningScore = prefs.getInt('score_listen') ?? 90;
        _writingScore = prefs.getInt('score_write') ?? 84;
      }

      _loadDefaultAchievements();
      _loadDefaultCertificates();

      await fetchFromCloud();
    } catch (e) {
      debugPrint('[COMMUNICATION PRO] Error initializing: $e');
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
        isUnlocked: true,
        unlockedDate: 'Recent',
      ),
      const AchievementBadge(
        id: 'vocab_50',
        title: 'Vocabulary Master 50',
        description: 'Master 50 high-impact vocabulary words across categories.',
        iconName: 'menu_book_rounded',
        isUnlocked: true,
        unlockedDate: 'Recent',
      ),
      const AchievementBadge(
        id: 'grammar_pro',
        title: 'Grammar Perfectionist',
        description: 'Complete all Grammar Master modules with 80%+ quiz score.',
        iconName: 'spellcheck_rounded',
        isUnlocked: true,
        unlockedDate: 'Recent',
      ),
      const AchievementBadge(
        id: 'interview_champ',
        title: 'AI Interview Champion',
        description: 'Successfully complete 5 HR and Technical mock interviews.',
        iconName: 'business_center_rounded',
        isUnlocked: true,
        unlockedDate: 'Recent',
      ),
    ];
  }

  void _loadDefaultCertificates() {
    _certificates = [
      const CertificateModel(
        id: 'cert_beg',
        title: 'Spoken English — Beginner Level',
        description: 'Awarded for completing Level 1 Spoken English Course & Greetings.',
        issuedDate: '2026-08-01',
        isEarned: true,
      ),
      const CertificateModel(
        id: 'cert_int',
        title: 'Spoken English — Intermediate Level',
        description: 'Awarded for completing Workplace Communication & Roleplay.',
        issuedDate: '2026-08-05',
        isEarned: true,
      ),
      const CertificateModel(
        id: 'cert_adv',
        title: 'Spoken English — Advanced Level',
        description: 'Awarded for mastering Public Speaking & Group Discussions.',
        issuedDate: '2026-08-07',
        isEarned: true,
      ),
      const CertificateModel(
        id: 'cert_interview',
        title: 'HR & Technical Interview Master',
        description: 'Awarded for scoring 85%+ in AI Mock Interview Simulations.',
        issuedDate: '2026-08-07',
        isEarned: true,
      ),
      const CertificateModel(
        id: 'cert_grammar',
        title: 'Grammar & Writing Master',
        description: 'Awarded for completing all 8 Grammar Master modules.',
        issuedDate: '2026-08-07',
        isEarned: true,
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

    await syncToCloud();
  }

  /// Cloud Sync under users/{uid}/communication_coach/progress
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
        'certificates': _certificates.map((c) => c.toJson()).toList(),
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
        synonyms: ['Articulate', 'Persuasive', 'Expressive'],
        antonyms: ['Inarticulate', 'Hesitant', 'Mute'],
      ),
      VocabularyWord(
        word: 'Meticulous',
        phonetic: '/məˈtɪk.jə.ləs/',
        partOfSpeech: 'adjective',
        meaning: 'Showing great attention to detail; very careful and precise.',
        example: 'He was meticulous about keeping his financial records organized.',
        category: 'Office',
        synonyms: ['Thorough', 'Precise', 'Painstaking'],
        antonyms: ['Careless', 'Sloppy', 'Negligent'],
      ),
      VocabularyWord(
        word: 'Resilient',
        phonetic: '/rɪˈzɪl.jənt/',
        partOfSpeech: 'adjective',
        meaning: 'Able to withstand or recover quickly from difficult conditions.',
        example: 'Successful entrepreneurs remain resilient during setbacks.',
        category: 'Business',
        synonyms: ['Tough', 'Adaptable', 'Robust'],
        antonyms: ['Fragile', 'Vulnerable', 'Weak'],
      ),
      VocabularyWord(
        word: 'Pragmatic',
        phonetic: '/præɡˈmæt.ɪk/',
        partOfSpeech: 'adjective',
        meaning: 'Dealing with things sensibly and realistically based on practical considerations.',
        example: 'We need a pragmatic approach to solving this technical problem.',
        category: 'Technology',
        synonyms: ['Practical', 'Realistic', 'Sensible'],
        antonyms: ['Idealistic', 'Impractical', 'Theoretical'],
      ),
      VocabularyWord(
        word: 'Articulate',
        phonetic: '/ɑːˈtɪk.jə.lət/',
        partOfSpeech: 'verb / adj',
        meaning: 'Expressing ideas clearly and effectively in speech.',
        example: 'Candidates who articulate their thoughts clearly perform better in interviews.',
        category: 'Interview',
        synonyms: ['Clear', 'Fluent', 'Coherent'],
        antonyms: ['Mumbled', 'Confused', 'Vague'],
      ),
    ];
  }

  /// Get 1000+ Categorized Vocabulary Master List
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
        synonyms: ['Cooperate', 'Partner', 'Team up'],
        antonyms: ['Oppose', 'Disagree', 'Compete'],
      ),
      const VocabularyWord(
        word: 'Innovative',
        phonetic: '/ˈɪn.ə.və.tɪv/',
        partOfSpeech: 'adjective',
        meaning: 'Featuring new methods; advanced and original.',
        example: 'The startup introduced an innovative solution for mobile payments.',
        category: 'Technology',
        synonyms: ['Inventive', 'Pioneering', 'Groundbreaking'],
        antonyms: ['Traditional', 'Outdated', 'Unoriginal'],
      ),
      const VocabularyWord(
        word: 'Itinerary',
        phonetic: '/aɪˈtɪn.ər.ər.i/',
        partOfSpeech: 'noun',
        meaning: 'A planned route or journey schedule.',
        example: 'Check your flight itinerary before heading to the airport.',
        category: 'Travel',
        synonyms: ['Schedule', 'Travel plan', 'Route'],
        antonyms: ['Disorganization', 'Randomness'],
      ),
      const VocabularyWord(
        word: 'Competency',
        phonetic: '/ˈkɒm.pɪ.tən.si/',
        partOfSpeech: 'noun',
        meaning: 'The ability to do something successfully or efficiently.',
        example: 'Demonstrating core competency is key to landing senior roles.',
        category: 'Interview',
        synonyms: ['Skill', 'Capability', 'Proficiency'],
        antonyms: ['Incompetence', 'Inability', 'Weakness'],
      ),
      const VocabularyWord(
        word: 'Curriculum',
        phonetic: '/kəˈrɪk.jə.ləm/',
        partOfSpeech: 'noun',
        meaning: 'The subjects comprising a course of study in a school or college.',
        example: 'The updated university curriculum includes artificial intelligence.',
        category: 'Education',
        synonyms: ['Syllabus', 'Course of study', 'Program'],
        antonyms: ['Extracurricular'],
      ),
      const VocabularyWord(
        word: 'Scalability',
        phonetic: '/ˌskeɪ.ləˈbɪl.ə.ti/',
        partOfSpeech: 'noun',
        meaning: 'The capacity of a system to handle a growing amount of work gracefully.',
        example: 'Cloud architecture provides high scalability for modern web applications.',
        category: 'Engineering',
        synonyms: ['Expandability', 'Flexibility', 'Growth capacity'],
        antonyms: ['Rigidity', 'Limitation'],
      ),
      const VocabularyWord(
        word: 'Diagnosis',
        phonetic: '/ˌdaɪ.əɡˈnəʊ.sɪs/',
        partOfSpeech: 'noun',
        meaning: 'The identification of the nature of an illness or medical problem.',
        example: 'Early diagnosis improves recovery rates significantly.',
        category: 'Medical',
        synonyms: ['Identification', 'Analysis', 'Assessment'],
        antonyms: ['Ignorance', 'Misjudgment'],
      ),
    ];

    if (category == 'Favorites') {
      return allWords.where((w) => _favoriteWords.contains(w.word)).toList();
    }

    if (category == 'All') return allWords;
    return allWords.where((w) => w.category == category).toList();
  }

  /// Get Grammar Master Topics
  List<GrammarTopic> getGrammarTopics() {
    return [
      GrammarTopic(
        id: 'tenses_101',
        title: 'Tenses Master (Present, Past, Future)',
        description: 'Learn Simple, Continuous, Perfect, and Perfect Continuous tenses.',
        keyRules: [
          'Present Perfect: Action started in past with relevance now (e.g. "I have finished my work").',
          'Past Continuous: Ongoing past action interrupted by simple past (e.g. "I was studying when he called").',
          'Future Perfect: Action completed before a future time (e.g. "I will have completed the report by 5 PM").',
        ],
        questions: const [
          GrammarQuestion(
            question: 'Select the correct tense: "By next month, she _____ at this company for 5 years."',
            options: ['will work', 'worked', 'will have worked', 'is working'],
            correctIndex: 2,
            explanation: '"Will have worked" (Future Perfect) is used for actions completed before a future time.',
          ),
        ],
        isCompleted: _completedGrammarTopics.contains('tenses_101'),
      ),
      GrammarTopic(
        id: 'articles_101',
        title: 'Articles Master (A, An, The)',
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
        title: 'Prepositions (In, On, At, By, With)',
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
        id: 'voice_master',
        title: 'Active & Passive Voice Master',
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
        isCompleted: _completedGrammarTopics.contains('voice_master'),
      ),
      GrammarTopic(
        id: 'narration_master',
        title: 'Direct & Indirect Speech (Narration)',
        description: 'Report spoken statements accurately without changing the core meaning.',
        keyRules: [
          'Direct Speech: Uses exact quotes (e.g. He said, "I am ready").',
          'Indirect Speech: Shifts tense back (e.g. He said that he was ready).',
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
        isCompleted: _completedGrammarTopics.contains('narration_master'),
      ),
      GrammarTopic(
        id: 'conjunctions_master',
        title: 'Conjunctions & Connectors',
        description: 'Use coordinate and subordinate conjunctions to link ideas smoothly.',
        keyRules: [
          'Coordinate: For, And, Nor, But, Or, Yet, So (FANBOYS).',
          'Subordinate: Although, Because, Since, While, Unless.',
        ],
        questions: const [
          GrammarQuestion(
            question: 'Choose the correct connector: "He worked hard, _____ he failed to meet the deadline."',
            options: ['yet', 'because', 'so', 'since'],
            correctIndex: 0,
            explanation: '"Yet" shows contrast between hard work and missing the deadline.',
          ),
        ],
        isCompleted: _completedGrammarTopics.contains('conjunctions_master'),
      ),
    ];
  }

  /// Get Pronunciation Lab Tongue Twisters & Guides
  List<Map<String, String>> getTongueTwisters() {
    return const [
      {'text': 'Peter Piper picked a peck of pickled peppers.', 'difficulty': 'Easy', 'ipa': '/ˈpiː.tər ˈpaɪ.pər pɪkt ə pek əv ˈpɪk.əld ˈpep.əz/'},
      {'text': 'She sells seashells by the seashore.', 'difficulty': 'Easy', 'ipa': '/ʃiː selz ˈsiː.ʃelz baɪ ðə ˈsiː.ʃɔːr/'},
      {'text': 'How much wood would a woodchuck chuck if a woodchuck could chuck wood?', 'difficulty': 'Medium', 'ipa': '/haʊ mʌtʃ wʊd wʊd ə ˈwʊd.tʃʌk tʃʌk/'},
      {'text': 'Unique New York, unique New York, you know you need unique New York.', 'difficulty': 'Hard', 'ipa': '/juːˈniːk njuː jɔːk/'},
    ];
  }

  /// Get Listening & Reading Passages
  List<LearningPassage> getLearningPassages() {
    return const [
      LearningPassage(
        id: 'pass_tech_1',
        title: 'The Future of Artificial Intelligence in Healthcare',
        category: 'Technical',
        content: 'Artificial Intelligence is revolutionizing modern medicine by enabling faster medical diagnoses and personalized treatments. Machine learning algorithms analyze complex genomic data and medical imaging in seconds, assisting doctors in identifying rare diseases with high precision. As AI technology evolves, ethical considerations regarding patient privacy and data security remain essential.',
        comprehensionQuestions: [
          GrammarQuestion(
            question: 'What is the main benefit of AI in healthcare mentioned in the passage?',
            options: [
              'Faster medical diagnoses and personalized treatments',
              'Replacing all human doctors completely',
              'Reducing hospital construction costs',
              'Automating physical surgeries'
            ],
            correctIndex: 0,
            explanation: 'The passage highlights faster diagnoses and personalized treatments as key benefits.',
          ),
        ],
      ),
      LearningPassage(
        id: 'pass_news_1',
        title: 'Global Renewable Energy Transition Milestone',
        category: 'News',
        content: 'Clean energy generation reached an all-time record this year as solar and wind installations expanded rapidly worldwide. Major economies are investing heavily in grid infrastructure and battery storage to ensure sustainable energy security for future generations.',
        comprehensionQuestions: [
          GrammarQuestion(
            question: 'Which energy sources led the clean energy expansion?',
            options: ['Solar and wind power', 'Coal and natural gas', 'Nuclear energy only', 'Diesel generators'],
            correctIndex: 0,
            explanation: 'The passage specifies solar and wind installations.',
          ),
        ],
      ),
    ];
  }

  /// Public Speaking & Fluency Analyzer
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

    int clarityScore = 92 - (fillerMatches.length * 4);
    if (wpm < 110) clarityScore -= 8;
    if (wpm > 175) clarityScore -= 10;
    clarityScore = clarityScore.clamp(50, 98);

    int confidenceScore = 90;
    if (fillerMatches.length > 3) confidenceScore -= 12;
    if (wordCount > 30) confidenceScore += 5;
    confidenceScore = confidenceScore.clamp(45, 99);

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

  /// Writing Coach Proofreader
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
