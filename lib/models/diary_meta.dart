import 'package:flutter/material.dart';

/// Language configuration for Voice Diary and multilingual entry tagging.
class DiaryLanguage {
  final String name;
  final String nativeName;
  final String flag;
  final String localeId;

  const DiaryLanguage({
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.localeId,
  });

  static const List<DiaryLanguage> supportedLanguages = [
    DiaryLanguage(
      name: 'English',
      nativeName: 'English',
      flag: '',
      localeId: 'en_IN',
    ),
    DiaryLanguage(
      name: 'Telugu',
      nativeName: 'తెలుగు',
      flag: '🇮🇳',
      localeId: 'te_IN',
    ),
    DiaryLanguage(
      name: 'Kannada',
      nativeName: 'ಕನ್ನಡ',
      flag: '🇮🇳',
      localeId: 'kn_IN',
    ),
    DiaryLanguage(
      name: 'Hindi',
      nativeName: 'हिन्दी',
      flag: '🇮🇳',
      localeId: 'hi_IN',
    ),
    DiaryLanguage(
      name: 'Tamil',
      nativeName: 'தமிழ்',
      flag: '🇮🇳',
      localeId: 'ta_IN',
    ),
  ];

  static DiaryLanguage defaultLanguage = supportedLanguages.first;

  static DiaryLanguage findByName(String name) {
    return supportedLanguages.firstWhere(
      (l) => l.name.toLowerCase() == name.toLowerCase(),
      orElse: () => defaultLanguage,
    );
  }
}

/// Mood option for a diary memory entry.
class DiaryMood {
  final String label;
  final String emoji;
  final Color color;

  const DiaryMood({
    required this.label,
    required this.emoji,
    required this.color,
  });

  static const List<DiaryMood> supportedMoods = [
    DiaryMood(label: 'Very Happy', emoji: '', color: Color(0xFF10B981)),
    DiaryMood(label: 'Happy',      emoji: '', color: Color(0xFF3B82F6)),
    DiaryMood(label: 'Excited',    emoji: '', color: Color(0xFFF59E0B)),
    DiaryMood(label: 'Loved',      emoji: '', color: Color(0xFFEC4899)),
    DiaryMood(label: 'Calm',       emoji: '', color: Color(0xFF06B6D4)),
    DiaryMood(label: 'Normal',     emoji: '', color: Color(0xFF8B5CF6)),
    DiaryMood(label: 'Sad',        emoji: '', color: Color(0xFF64748B)),
    DiaryMood(label: 'Very Sad',   emoji: '', color: Color(0xFF475569)),
    DiaryMood(label: 'Stressed',   emoji: '', color: Color(0xFFF97316)),
    DiaryMood(label: 'Angry',      emoji: '', color: Color(0xFFEF4444)),
  ];

  static DiaryMood defaultMood = supportedMoods[3]; // Normal (fallback)

  static DiaryMood findByLabel(String label) {
    return supportedMoods.firstWhere(
      (m) => m.label.toLowerCase() == label.toLowerCase(),
      orElse: () => DiaryMood(label: label, emoji: '', color: const Color(0xFF8B5CF6)),
    );
  }
}

/// Suggested Quick Tags for My Life Book entries.
class DiaryTags {
  static const List<String> quickTags = [
    'College',
    'Family',
    'Friends',
    'Travel',
    'Temple',
    'Personal',
    'Study',
    'Achievement',
    'Special Day',
  ];
}
