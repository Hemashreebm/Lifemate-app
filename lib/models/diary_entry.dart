import 'dart:math';

/// Represents a single personal diary memory in My Life Book.
///
/// Fully backward-compatible with existing saved entries.
class DiaryEntry {
  final String id;
  final String title;
  final String content;
  final String mood;        // e.g. "Happy", "Calm", "Normal", "Sad", "Stressed", "Very Happy", "Loved", "Excited", "Angry", "Very Sad"
  final String language;    // e.g. "English", "Telugu", "Kannada", "Hindi", "Tamil"
  final String? audioPath;  // Local device path to recorded voice audio file
  final int? audioDurationSeconds;
  final bool favorite;      // Whether entry is marked as favorite
  final List<String> tags;  // Memory tags e.g. ['Family', 'Temple']
  final List<String> photoPaths; // Local image file paths attached to memory
  final DateTime createdAt;
  final DateTime modifiedAt;

  const DiaryEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.mood,
    required this.language,
    this.audioPath,
    this.audioDurationSeconds,
    this.favorite = false,
    this.tags = const [],
    this.photoPaths = const [],
    required this.createdAt,
    required this.modifiedAt,
  });

  /// Generate a unique ID for new entries
  static String generateId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rand = Random().nextInt(99999);
    return 'diary_${ts}_$rand';
  }

  DiaryEntry copyWith({
    String? id,
    String? title,
    String? content,
    String? mood,
    String? language,
    String? audioPath,
    bool clearAudioPath = false,
    int? audioDurationSeconds,
    bool? favorite,
    List<String>? tags,
    List<String>? photoPaths,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      language: language ?? this.language,
      audioPath: clearAudioPath ? null : (audioPath ?? this.audioPath),
      audioDurationSeconds: clearAudioPath
          ? null
          : (audioDurationSeconds ?? this.audioDurationSeconds),
      favorite: favorite ?? this.favorite,
      tags: tags ?? this.tags,
      photoPaths: photoPaths ?? this.photoPaths,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'mood': mood,
        'language': language,
        'audioPath': audioPath,
        'audioDurationSeconds': audioDurationSeconds,
        'favorite': favorite,
        'tags': tags,
        'photoPaths': photoPaths,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
      };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String,
      title: (json['title'] as String?) ?? '',
      content: (json['content'] as String?) ?? '',
      mood: (json['mood'] as String?) ?? 'Normal',
      language: (json['language'] as String?) ?? 'English',
      audioPath: json['audioPath'] as String?,
      audioDurationSeconds: json['audioDurationSeconds'] as int?,
      favorite: (json['favorite'] as bool?) ?? false,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      photoPaths: (json['photoPaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
    );
  }
}
