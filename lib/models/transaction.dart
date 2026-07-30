import 'dart:math';

/// Whether this transaction is money coming in or going out.
enum TransactionType { income, expense }

/// A single financial transaction recorded by the user.
///
/// Amounts are always stored as positive [double] values.
/// The [type] field determines whether it adds to or subtracts from the balance.
class Transaction {
  final String id;
  final TransactionType type;
  final double amount;      // Always positive
  final String category;
  final String note;
  final DateTime date;      // Date the user assigns to this transaction
  final DateTime createdAt; // When the record was first created

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
    required this.createdAt,
  });

  // ── Factory helpers ───────────────────────────────────────────────────────

  /// Generate a collision-resistant unique ID without external packages.
  static String generateId() {
    final ts   = DateTime.now().millisecondsSinceEpoch;
    final rand = Random().nextInt(99999);
    return '${ts}_$rand';
  }

  // ── Copy with ─────────────────────────────────────────────────────────────

  /// Return a new [Transaction] with selected fields replaced.
  Transaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? category,
    String? note,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Transaction(
      id:        id        ?? this.id,
      type:      type      ?? this.type,
      amount:    amount    ?? this.amount,
      category:  category  ?? this.category,
      note:      note      ?? this.note,
      date:      date      ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ── JSON serialization ────────────────────────────────────────────────────

  /// Encode to a JSON-compatible map for SharedPreferences storage.
  Map<String, dynamic> toJson() => {
    'id':        id,
    'type':      type.name,
    'amount':    amount,
    'category':  category,
    'note':      note,
    'date':      date.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  /// Decode from a JSON map read from SharedPreferences.
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id:       json['id'] as String,
      type:     TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      amount:    (json['amount'] as num).toDouble(),
      category:  json['category'] as String,
      note:     (json['note'] as String?) ?? '',
      date:      DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
