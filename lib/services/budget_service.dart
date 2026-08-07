import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import 'transaction_service.dart';

/// Monthly Budget limit & progress snapshot.
class CategoryBudget {
  final String categoryId;
  final double limit;
  final double spent;

  const CategoryBudget({
    required this.categoryId,
    required this.limit,
    required this.spent,
  });

  double get percentage => limit > 0 ? (spent / limit) * 100 : 0.0;
  bool get isWarning => percentage >= 80.0 && percentage < 100.0;
  bool get isExceeded => percentage >= 100.0;
}

/// Service managing user monthly budgets and spending alerts for Lifemate v2.0.
class BudgetService {
  static const String _storageKey = 'lifemate_category_budgets_v2';
  static final BudgetService instance = BudgetService._();
  BudgetService._();

  final Map<String, double> _categoryLimits = {
    'total': 30000.0,
    'food': 8000.0,
    'transport': 4000.0,
    'shopping': 6000.0,
    'bills': 5000.0,
  };

  /// Read unmodifiable map of category budget limits.
  Map<String, double> get categoryLimits => Map.unmodifiable(_categoryLimits);

  /// Total monthly overall budget limit.
  double get totalMonthlyLimit => _categoryLimits['total'] ?? 30000.0;

  /// Load budget limits from local storage & Firestore.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> raw = jsonDecode(jsonStr) as Map<String, dynamic>;
        raw.forEach((k, v) {
          if (v is num) _categoryLimits[k] = v.toDouble();
        });
      }
      debugPrint('[BUDGET] Loaded budget limits for ${_categoryLimits.length} categories.');
      _syncFromCloud();
    } catch (e) {
      debugPrint('[BUDGET] Init error: $e');
    }
  }

  /// Set budget limit for a specific category.
  Future<void> setBudgetLimit(String categoryId, double limit) async {
    if (limit < 0) return;
    _categoryLimits[categoryId] = limit;
    await _saveLocal();
    await _syncToCloud();
    debugPrint('[BUDGET] Set limit for $categoryId: ₹$limit');
  }

  /// Get current budget snapshot for a specific category for current month.
  CategoryBudget getCategoryBudget(String categoryId, List<Transaction> monthTransactions) {
    final limit = _categoryLimits[categoryId] ?? 0.0;
    double spent = 0.0;
    if (categoryId == 'total') {
      spent = TransactionService.instance.totalExpense(monthTransactions);
    } else {
      spent = monthTransactions
          .where((t) => t.type == TransactionType.expense && t.category == categoryId)
          .fold(0.0, (sum, t) => sum + t.amount);
    }
    return CategoryBudget(categoryId: categoryId, limit: limit, spent: spent);
  }

  /// Get budget snapshots for all defined categories.
  List<CategoryBudget> getAllBudgets(List<Transaction> monthTransactions) {
    return _categoryLimits.keys.map((catId) => getCategoryBudget(catId, monthTransactions)).toList();
  }

  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_categoryLimits));
  }

  Future<void> _syncToCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('budgets')
            .doc('current')
            .set(_categoryLimits);
      }
    } catch (e) {
      debugPrint('[BUDGET] Cloud write error: $e');
    }
  }

  Future<void> _syncFromCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('budgets')
            .doc('current')
            .get();

        if (doc.exists && doc.data() != null) {
          doc.data()!.forEach((k, v) {
            if (v is num) _categoryLimits[k] = v.toDouble();
          });
          await _saveLocal();
          debugPrint('[BUDGET] Synced limits from Firestore.');
        }
      }
    } catch (e) {
      debugPrint('[BUDGET] Cloud read error: $e');
    }
  }
}
