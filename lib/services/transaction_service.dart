import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

/// Manages all Lifemate transaction data.
///
/// Provides in-memory access with automatic JSON persistence via SharedPreferences.
/// All financial data stays on the user's device — no network calls are made.
///
/// Usage:
/// ```dart
/// await TransactionService.instance.load();  // once per screen open
/// await TransactionService.instance.add(tx);
/// ```
class TransactionService {
  // Storage key — versioned so future migrations are possible
  static const String _storageKey = 'lifemate_transactions_v1';

  /// Global singleton — access everywhere without passing instances around.
  static final TransactionService instance = TransactionService._();
  TransactionService._();

  List<Transaction> _transactions = [];

  // ── Read ──────────────────────────────────────────────────────────────────

  /// All saved transactions, newest date first.
  List<Transaction> get all => List.unmodifiable(_transactions);

  /// Transactions whose user-assigned [date] falls in [month] (year+month match).
  List<Transaction> getForMonth(DateTime month) {
    return _transactions
        .where((t) =>
            t.date.year == month.year && t.date.month == month.month)
        .toList();
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  /// Load all transactions from device storage into memory.
  /// Call this before reading data (e.g. in [initState] of each screen).
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr == null) {
        _transactions = [];
        return;
      }
      final List<dynamic> raw = jsonDecode(jsonStr) as List<dynamic>;
      _transactions = raw
          .map((j) => Transaction.fromJson(j as Map<String, dynamic>))
          .toList();
      _sort();
    } catch (_) {
      // Corrupted data — start fresh rather than crash
      _transactions = [];
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr =
        jsonEncode(_transactions.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  /// Persist a new [transaction].
  Future<void> add(Transaction transaction) async {
    _transactions.insert(0, transaction);
    _sort();
    await _save();
  }

  /// Replace an existing transaction (matched by [id]).
  Future<void> update(Transaction transaction) async {
    final i = _transactions.indexWhere((t) => t.id == transaction.id);
    if (i != -1) {
      _transactions[i] = transaction;
      _sort();
      await _save();
    }
  }

  /// Remove a transaction by [id].
  Future<void> delete(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _save();
  }

  // ── Calculations (all pure — no side effects) ────────────────────────────

  /// Sum of all income amounts in [txs].
  double totalIncome(List<Transaction> txs) => txs
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  /// Sum of all expense amounts in [txs].
  double totalExpense(List<Transaction> txs) => txs
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  /// Category → total expense amount, sorted descending.
  Map<String, double> expenseByCategory(List<Transaction> txs) {
    final Map<String, double> map = {};
    for (final t in txs.where((t) => t.type == TransactionType.expense)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    final entries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries);
  }

  // ── Formatting helpers ────────────────────────────────────────────────────

  /// Format a double as a ₹ currency string with thousands separators.
  /// e.g. 12345.0 → '₹12,345'
  static String formatCurrency(double amount) {
    final whole = amount.abs().toInt().toString();
    final buf = StringBuffer();
    final len = whole.length;
    for (var i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buf.write(',');
      buf.write(whole[i]);
    }
    return '₹${buf.toString()}';
  }

  static final List<String> _shortMonths = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec',
  ];
  static final List<String> _fullMonths = [
    'January','February','March','April','May','June',
    'July','August','September','October','November','December',
  ];

  /// Format as "25 Jul".
  static String formatShortDate(DateTime d) =>
      '${d.day} ${_shortMonths[d.month - 1]}';

  /// Format as "July 2026".
  static String formatMonthYear(DateTime d) =>
      '${_fullMonths[d.month - 1]} ${d.year}';

  // ── Private ───────────────────────────────────────────────────────────────

  void _sort() {
    _transactions.sort((a, b) {
      final cmp = b.date.compareTo(a.date);
      return cmp != 0 ? cmp : b.createdAt.compareTo(a.createdAt);
    });
  }

  // ── Budget ────────────────────────────────────────────────────────────────

  static String _budgetKey(DateTime month) =>
      'lifemate_budget_${month.year}_${month.month}';

  /// Persist a monthly budget. Pass [amount] ≤ 0 to clear it.
  Future<void> setBudget(double amount, DateTime month) async {
    final prefs = await SharedPreferences.getInstance();
    if (amount <= 0) {
      await prefs.remove(_budgetKey(month));
    } else {
      await prefs.setDouble(_budgetKey(month), amount);
    }
  }

  /// Load the budget for [month], or null if none has been set.
  Future<double?> getBudget(DateTime month) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_budgetKey(month));
  }

  // ── Month history ─────────────────────────────────────────────────────────

  /// Returns every distinct year-month that contains at least one transaction,
  /// sorted newest-first.
  List<DateTime> getTransactionMonths() {
    final seen  = <String>{};
    final months = <DateTime>[];
    for (final t in _transactions) {
      final key = '${t.date.year}_${t.date.month}';
      if (seen.add(key)) {
        months.add(DateTime(t.date.year, t.date.month));
      }
    }
    months.sort((a, b) => b.compareTo(a));
    return months;
  }
}
