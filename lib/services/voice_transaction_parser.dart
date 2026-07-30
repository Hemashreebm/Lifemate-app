import '../models/transaction.dart';

/// Result of locally parsing a voice/text sentence into transaction fields.
class ParsedTransaction {
  final TransactionType type;
  final double? amount;     // null if no number was detected
  final String? category;   // null if no category matched
  final DateTime date;
  final String note;
  final String rawText;

  const ParsedTransaction({
    required this.type,
    this.amount,
    this.category,
    required this.date,
    required this.note,
    required this.rawText,
  });

  /// True when the minimum required fields (amount) were detected.
  bool get isComplete => amount != null && amount! > 0;
}

/// Deterministic, on-device parser that converts a natural-language sentence
/// into a [ParsedTransaction]. No network or AI calls are made.
///
/// Designed to be extended: add new keyword lists without changing the parsing logic.
class VoiceTransactionParser {
  VoiceTransactionParser._();

  /// Parse [text] and return the best-guess [ParsedTransaction].
  static ParsedTransaction parse(String text) {
    final lower = text.toLowerCase().trim();
    final type   = _detectType(lower);
    return ParsedTransaction(
      rawText:  text,
      type:     type,
      amount:   _extractAmount(lower),
      category: _detectCategory(lower, type),
      date:     _extractDate(lower),
      note:     text,
    );
  }

  // ── Transaction type detection ─────────────────────────────────────────────

  static const _incomeKeywords = [
    'received', 'receive', 'got', 'get', 'earned', 'earn',
    'salary', 'scholarship', 'income', 'pocket money', 'allowance',
    'refund', 'gift', 'freelance', 'added', 'deposited', 'credited',
    'bonus', 'stipend', 'reward',
  ];

  static const _expenseKeywords = [
    'spent', 'spend', 'paid', 'pay', 'bought', 'buy', 'purchased',
    'purchase', 'cost', 'costs', 'expense', 'charged', 'used for',
    'gave', 'given',
  ];

  static TransactionType _detectType(String lower) {
    // Income keywords take priority so "received refund" → income
    for (final kw in _incomeKeywords) {
      if (lower.contains(kw)) return TransactionType.income;
    }
    // Expense keywords second
    for (final kw in _expenseKeywords) {
      if (lower.contains(kw)) return TransactionType.expense;
    }
    // Default: expense (most common entry)
    return TransactionType.expense;
  }

  // ── Amount extraction ──────────────────────────────────────────────────────

  // Matches patterns like: 250, ₹250, Rs 250, 5,000, 5000.50
  static final _amountRe = RegExp(
    r'(?:₹|rs\.?\s*|rupees?\s*|inr\s*)?(\d[\d,]*(?:\.\d{1,2})?)\s*(?:rupees?|rs\.?|inr|₹)?',
    caseSensitive: false,
  );

  static double? _extractAmount(String lower) {
    final match = _amountRe.firstMatch(lower);
    if (match == null) return null;
    final raw = match.group(1)!.replaceAll(',', '');
    return double.tryParse(raw);
  }

  // ── Date extraction ────────────────────────────────────────────────────────

  static DateTime _extractDate(String lower) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lower.contains('day before yesterday')) {
      return today.subtract(const Duration(days: 2));
    }
    if (lower.contains('yesterday')) {
      return today.subtract(const Duration(days: 1));
    }
    return today; // default: today
  }

  // ── Category detection ─────────────────────────────────────────────────────

  // Maps exact category names (from TransactionCategories) to trigger keywords.
  static const Map<String, List<String>> _expenseCatKeywords = {
    'Food': [
      'food', 'lunch', 'dinner', 'breakfast', 'groceries', 'grocery',
      'restaurant', 'cafe', 'snack', 'eating', 'meal', 'coffee', 'tea',
      'sweets', 'tiffin', 'biryani', 'pizza', 'burger', 'vegetable',
      'fruit', 'milk', 'bread', 'rice',
    ],
    'Transport': [
      'bus', 'auto', 'taxi', 'petrol', 'fuel', 'train', 'uber', 'ola',
      'metro', 'travel', 'transport', 'cab', 'rickshaw', 'bike ride',
      'commute', 'ticket', 'fare', 'rapido',
    ],
    'Shopping': [
      'shirt', 'dress', 'shoes', 'shopping', 'mall', 'clothes', 'fashion',
      'bag', 'online shopping', 'amazon', 'flipkart', 'shop', 'store',
      'apparel', 'clothing', 'jeans', 'saree', 'kurta',
    ],
    'Bills': [
      'bill', 'electricity', 'water', 'rent', 'internet', 'wifi', 'cable',
      'gas', 'maintenance', 'subscription', 'emi', 'loan', 'insurance',
    ],
    'Education': [
      'college', 'book', 'course', 'fees', 'fee', 'school', 'tuition',
      'education', 'study', 'class', 'coaching', 'exam', 'stationery',
      'university', 'notes',
    ],
    'Health': [
      'medicine', 'doctor', 'hospital', 'pharmacy', 'health', 'clinic',
      'medical', 'tablet', 'pills', 'injection', 'checkup', 'dental',
      'eye', 'test',
    ],
    'Entertainment': [
      'movie', 'cinema', 'netflix', 'entertainment', 'game', 'concert',
      'show', 'park', 'outing', 'party', 'hangout', 'fun', 'theatre',
      'youtube', 'prime', 'hotstar',
    ],
    'Home': [
      'home', 'house', 'furniture', 'appliance', 'repair', 'cleaning',
      'kitchen', 'household', 'decor', 'tools', 'paint',
    ],
  };

  static const Map<String, List<String>> _incomeCatKeywords = {
    'Salary': [
      'salary', 'wage', 'paycheck', 'stipend', 'job', 'office work', 'monthly salary',
    ],
    'Freelance': [
      'freelance', 'project', 'client', 'contract', 'gig', 'freelancing',
    ],
    'Scholarship': [
      'scholarship', 'fellowship', 'grant', 'merit',
    ],
    'Refund': [
      'refund', 'cashback', 'cash back', 'return', 'reimbursement', 'money back',
    ],
    'Gift': [
      'gift', 'present', 'birthday', 'festival', 'diwali', 'eid',
    ],
    'Allowance': [
      'pocket money', 'allowance', 'parents gave', 'from parents',
      'from family', 'family sent',
    ],
    'Investment': [
      'investment', 'dividend', 'interest', 'returns', 'profit',
    ],
  };

  static String? _detectCategory(String lower, TransactionType type) {
    final map = type == TransactionType.expense
        ? _expenseCatKeywords
        : _incomeCatKeywords;

    for (final entry in map.entries) {
      for (final kw in entry.value) {
        if (lower.contains(kw)) return entry.key;
      }
    }
    return null; // unknown — user will select in confirmation screen
  }
}
