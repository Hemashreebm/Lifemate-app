import 'package:flutter/material.dart';
import 'transaction.dart';

/// Visual and semantic information about a single transaction category.
class CategoryInfo {
  final String name;
  final String emoji;
  final Color color;

  const CategoryInfo({
    required this.name,
    required this.emoji,
    required this.color,
  });
}

/// Central registry of all Lifemate expense and income categories.
///
/// To add a new category: append a [CategoryInfo] to the relevant list.
/// No other code changes are needed — all screens read from these lists.
class TransactionCategories {
  TransactionCategories._(); // Static use only

  // ── Expense categories ────────────────────────────────────────────────────

  static const List<CategoryInfo> expense = [
    CategoryInfo(name: 'Food',          emoji: '🍔', color: Color(0xFFFF6B6B)),
    CategoryInfo(name: 'Transport',     emoji: '🚕', color: Color(0xFF4ECDC4)),
    CategoryInfo(name: 'Shopping',      emoji: '🛍️', color: Color(0xFFFFBE0B)),
    CategoryInfo(name: 'Bills',         emoji: '📱', color: Color(0xFF3B82F6)),
    CategoryInfo(name: 'Education',     emoji: '🎓', color: Color(0xFF8B5CF6)),
    CategoryInfo(name: 'Health',        emoji: '🏥', color: Color(0xFF10B981)),
    CategoryInfo(name: 'Entertainment', emoji: '🎬', color: Color(0xFFF97316)),
    CategoryInfo(name: 'Home',          emoji: '🏠', color: Color(0xFF6B7280)),
    CategoryInfo(name: 'Other',         emoji: '💸', color: Color(0xFF9E9E9E)),
  ];

  // ── Income categories ─────────────────────────────────────────────────────

  static const List<CategoryInfo> income = [
    CategoryInfo(name: 'Salary',      emoji: '💼', color: Color(0xFF10B981)),
    CategoryInfo(name: 'Freelance',   emoji: '💻', color: Color(0xFF3B82F6)),
    CategoryInfo(name: 'Scholarship', emoji: '🎓', color: Color(0xFF8B5CF6)),
    CategoryInfo(name: 'Gift',        emoji: '🎁', color: Color(0xFFFF6B6B)),
    CategoryInfo(name: 'Allowance',   emoji: '💰', color: Color(0xFFFFBE0B)),
    CategoryInfo(name: 'Refund',      emoji: '↩️', color: Color(0xFF4ECDC4)),
    CategoryInfo(name: 'Investment',  emoji: '📈', color: Color(0xFF6B7FD7)),
    CategoryInfo(name: 'Other',       emoji: '💵', color: Color(0xFF9E9E9E)),
  ];

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Return the category list for the given transaction type.
  static List<CategoryInfo> forType(TransactionType type) =>
      type == TransactionType.expense ? expense : income;

  /// Find a [CategoryInfo] by name. Returns null if not found.
  static CategoryInfo? find(String name, TransactionType type) {
    final list = forType(type);
    for (final c in list) {
      if (c.name == name) return c;
    }
    return null;
  }

  /// Return a safe fallback (the last 'Other' entry) when a name is unknown.
  static CategoryInfo fallback(TransactionType type) => forType(type).last;
}
