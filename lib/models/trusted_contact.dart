import 'dart:math';

/// Represents a user-added trusted contact for emergency situations.
class TrustedContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String relationship; // e.g. Mother, Father, Spouse, Friend, Guardian
  final DateTime createdAt;

  const TrustedContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    required this.createdAt,
  });

  /// Unique ID generator for trusted contact
  static String generateId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rand = Random().nextInt(99999);
    return 'contact_${ts}_$rand';
  }

  TrustedContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? relationship,
    DateTime? createdAt,
  }) {
    return TrustedContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'relationship': relationship,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TrustedContact.fromJson(Map<String, dynamic> json) {
    return TrustedContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      relationship: (json['relationship'] as String?) ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
