import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import 'auth_service.dart';

/// Manages all Lifemate transaction and expense data with local persistence and Cloud Firestore sync.
class TransactionService {
  static const String _storageKey = 'lifemate_transactions_v1';

  static final TransactionService instance = TransactionService._();
  TransactionService._();

  List<Transaction> _transactions = [];
  StreamSubscription<QuerySnapshot>? _expensesSubscription;

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

  // ── Persistence & Cloud Sync ───────────────────────────────────────────────

  /// Load all transactions from device storage and initialize real-time Firestore stream listener.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null) {
        final List<dynamic> raw = jsonDecode(jsonStr) as List<dynamic>;
        _transactions = raw
            .map((j) => Transaction.fromJson(j as Map<String, dynamic>))
            .toList();
        _sort();
      } else {
        _transactions = [];
      }

      // Initialize real-time Cloud Firestore sync
      initCloudSync();
    } catch (e) {
      debugPrint('[TRANSACTION SERVICE] Error loading local transactions: $e');
      _transactions = [];
    }
  }

  /// Initialize real-time Cloud Firestore listener for users/{uid}/expenses
  void initCloudSync() {
    _expensesSubscription?.cancel();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || AuthService.instance.isGuestMode) {
      debugPrint('[EXPENSE CLOUD] Guest mode or unauthenticated. Using local storage only.');
      return;
    }

    final collectionPath = 'users/${user.uid}/expenses';
    debugPrint('[EXPENSE CLOUD] Subscribing to real-time stream at $collectionPath...');

    _expensesSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .snapshots()
        .listen(
      (snapshot) async {
        debugPrint('[EXPENSE CLOUD STREAM] Received ${snapshot.docs.length} expenses from Firestore');
        final List<Transaction> remoteTransactions = [];
        for (final doc in snapshot.docs) {
          try {
            final tx = Transaction.fromFirestore(doc.data(), doc.id);
            remoteTransactions.add(tx);
          } catch (e) {
            debugPrint('[EXPENSE CLOUD PARSE ERROR] Error parsing expense ${doc.id}: $e');
          }
        }

        if (remoteTransactions.isNotEmpty || snapshot.docs.isEmpty) {
          _transactions = remoteTransactions;
          _sort();
          await _save();
        }
      },
      onError: (error) {
        debugPrint('[EXPENSE CLOUD STREAM ERROR] Error listening to expenses stream: $error');
      },
    );
  }

  /// Stop active Cloud Firestore real-time stream listener
  void stopCloudSync() {
    _expensesSubscription?.cancel();
    _expensesSubscription = null;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr =
        jsonEncode(_transactions.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  /// Persist a new [transaction] locally and sync to Cloud Firestore.
  Future<void> add(Transaction transaction) async {
    _transactions.insert(0, transaction);
    _sort();
    await _save();

    // Cloud Firestore Upload
    await _uploadExpenseToCloud(transaction);
  }

  /// Replace an existing transaction (matched by [id]) locally and sync to Cloud Firestore.
  Future<void> update(Transaction transaction) async {
    final i = _transactions.indexWhere((t) => t.id == transaction.id);
    if (i != -1) {
      _transactions[i] = transaction;
      _sort();
      await _save();

      // Cloud Firestore Update
      await _uploadExpenseToCloud(transaction);
    }
  }

  /// Remove a transaction by [id] locally and delete from Cloud Firestore.
  Future<void> delete(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _save();

    // Cloud Firestore Deletion
    await _deleteExpenseFromCloud(id);
  }

  // ── Cloud Firestore Operations ───────────────────────────────────────────

  Future<void> _uploadExpenseToCloud(Transaction transaction) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || AuthService.instance.isGuestMode) return;

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .doc(transaction.id);

      debugPrint('[EXPENSE CLOUD] Uploading expense ${transaction.id} to users/${user.uid}/expenses...');
      await docRef
          .set(transaction.toFirestore(), SetOptions(merge: true))
          .timeout(const Duration(seconds: 12));
      debugPrint('[EXPENSE CLOUD SUCCESS] Expense ${transaction.id} saved in Firestore users/${user.uid}/expenses');
    } on FirebaseException catch (e) {
      debugPrint('[EXPENSE CLOUD ERROR] FirebaseException uploading expense: ${e.code} - ${e.message}');
    } catch (e) {
      debugPrint('[EXPENSE CLOUD ERROR] Error uploading expense: $e');
    }
  }

  Future<void> _deleteExpenseFromCloud(String expenseId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || AuthService.instance.isGuestMode) return;

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .doc(expenseId);

      debugPrint('[EXPENSE CLOUD] Deleting expense $expenseId from users/${user.uid}/expenses...');
      await docRef.delete().timeout(const Duration(seconds: 12));
      debugPrint('[EXPENSE CLOUD SUCCESS] Deleted expense $expenseId from Firestore');
    } on FirebaseException catch (e) {
      debugPrint('[EXPENSE CLOUD ERROR] FirebaseException deleting expense: ${e.code} - ${e.message}');
    } catch (e) {
      debugPrint('[EXPENSE CLOUD ERROR] Error deleting expense from Firestore: $e');
    }
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
    final seen = <String>{};
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
