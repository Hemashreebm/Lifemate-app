/// Model representing a daily habit goal in Lifemate v2.0.
class Habit {
  final String id;
  final String title;
  final String description;
  final String iconName; // e.g. 'water', 'exercise', 'book', 'mic'
  final int streakDays;
  final bool isCompletedToday;
  final DateTime? lastCompletedDate;
  final DateTime createdAt;

  const Habit({
    required this.id,
    required this.title,
    required this.description,
    this.iconName = 'star',
    this.streakDays = 0,
    this.isCompletedToday = false,
    this.lastCompletedDate,
    required this.createdAt,
  });

  Habit copyWith({
    String? title,
    String? description,
    String? iconName,
    int? streakDays,
    bool? isCompletedToday,
    DateTime? lastCompletedDate,
  }) {
    return Habit(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      streakDays: streakDays ?? this.streakDays,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'iconName': iconName,
        'streakDays': streakDays,
        'isCompletedToday': isCompletedToday,
        'lastCompletedDate': lastCompletedDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] as String? ?? 'Daily Habit',
        description: json['description'] as String? ?? '',
        iconName: json['iconName'] as String? ?? 'star',
        streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
        isCompletedToday: json['isCompletedToday'] as bool? ?? false,
        lastCompletedDate: json['lastCompletedDate'] != null
            ? DateTime.tryParse(json['lastCompletedDate'] as String)
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
      );

  static String generateId() => 'habit_${DateTime.now().millisecondsSinceEpoch}';
}
