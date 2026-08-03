import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Whether this transaction is money coming in or going out.
enum TransactionType { income, expense }

/// A single financial transaction recorded by the user.
///
/// Amounts are always stored as positive [double] values.
/// The [type] field determines whether it adds to or subtracts from the balance.
class Transaction {
  final String id;
  final TransactionType type;
  final double amount; // Always positive
  final String category;
  final String note;
  final String merchant;
  final String paymentMethod;
  final String? receiptImageUrl;
  final String? ocrText;
  final String source; // manual, ocr, sms
  final String? smsReference;
  final DateTime date; // Date assigned to this transaction
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.note,
    this.merchant = '',
    this.paymentMethod = 'Cash',
    this.receiptImageUrl,
    this.ocrText,
    this.source = 'manual',
    this.smsReference,
    required this.date,
    required this.createdAt,
  });

  /// Generate a collision-resistant unique ID.
  static String generateId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rand = Random().nextInt(99999);
    return '${ts}_$rand';
  }

  /// Return a new [Transaction] with selected fields replaced.
  Transaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? category,
    String? note,
    String? merchant,
    String? paymentMethod,
    String? receiptImageUrl,
    String? ocrText,
    String? source,
    String? smsReference,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      merchant: merchant ?? this.merchant,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      ocrText: ocrText ?? this.ocrText,
      source: source ?? this.source,
      smsReference: smsReference ?? this.smsReference,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Encode to JSON map for local SharedPreferences storage.
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'amount': amount,
        'category': category,
        'note': note,
        'merchant': merchant,
        'paymentMethod': paymentMethod,
        'receiptImageUrl': receiptImageUrl,
        'ocrText': ocrText,
        'source': source,
        'smsReference': smsReference,
        'date': date.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  /// Map for Cloud Firestore collection users/{uid}/expenses/{expenseId}.
  Map<String, dynamic> toFirestore() => {
        'amount': amount,
        'type': type.name,
        'category': category,
        'merchant': merchant,
        'paymentMethod': paymentMethod,
        'description': note,
        'receiptImageUrl': receiptImageUrl,
        'ocrText': ocrText,
        'transactionDate': date.toIso8601String(),
        'source': source,
        'smsReference': smsReference,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  /// Decode from local JSON map.
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      note: (json['note'] as String?) ?? '',
      merchant: (json['merchant'] as String?) ?? '',
      paymentMethod: (json['paymentMethod'] as String?) ?? 'Cash',
      receiptImageUrl: json['receiptImageUrl'] as String?,
      ocrText: json['ocrText'] as String?,
      source: (json['source'] as String?) ?? 'manual',
      smsReference: json['smsReference'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Decode from Cloud Firestore document snapshot.
  factory Transaction.fromFirestore(Map<String, dynamic> data, String docId) {
    DateTime parsedDate;
    if (data['transactionDate'] is String) {
      parsedDate = DateTime.parse(data['transactionDate'] as String);
    } else if (data['transactionDate'] is Timestamp) {
      parsedDate = (data['transactionDate'] as Timestamp).toDate();
    } else if (data['date'] is String) {
      parsedDate = DateTime.parse(data['date'] as String);
    } else {
      parsedDate = DateTime.now();
    }

    DateTime parsedCreatedAt;
    if (data['createdAt'] is Timestamp) {
      parsedCreatedAt = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      parsedCreatedAt =
          DateTime.tryParse(data['createdAt'] as String) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return Transaction(
      id: docId,
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TransactionType.expense,
      ),
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      category: (data['category'] as String?) ?? 'Other',
      note: (data['description'] as String?) ?? (data['note'] as String?) ?? '',
      merchant: (data['merchant'] as String?) ?? '',
      paymentMethod: (data['paymentMethod'] as String?) ?? 'Cash',
      receiptImageUrl: data['receiptImageUrl'] as String?,
      ocrText: data['ocrText'] as String?,
      source: (data['source'] as String?) ?? 'manual',
      smsReference: data['smsReference'] as String?,
      date: parsedDate,
      createdAt: parsedCreatedAt,
    );
  }
}
