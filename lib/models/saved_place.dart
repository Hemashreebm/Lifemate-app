import 'dart:math';

/// Represents an important place saved locally by the user.
class SavedPlace {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final String note;
  final DateTime createdAt;

  const SavedPlace({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.note,
    required this.createdAt,
  });

  /// Generate a unique ID for a saved place
  static String generateId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rand = Random().nextInt(99999);
    return 'place_${ts}_$rand';
  }

  SavedPlace copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    String? address,
    String? note,
    DateTime? createdAt,
  }) {
    return SavedPlace(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SavedPlace.fromJson(Map<String, dynamic> json) {
    return SavedPlace(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: (json['address'] as String?) ?? '',
      note: (json['note'] as String?) ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
