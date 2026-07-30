import 'package:flutter/material.dart';

/// Central theme configuration for Lifemate.
///
/// Design philosophy: warm, calm, modern, friendly â€” like a personal companion.
/// Uses Material 3 with a soft violet brand color.
class AppTheme {
  AppTheme._(); // Prevent instantiation â€” static use only

  // â”€â”€ Brand Colors â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Primary brand color â€” soft violet, warm and inviting
  static const Color brandSeed = Color(0xFF6C5CE7);

  /// Accent used for feature icon: diary
  static const Color accentDiary = Color(0xFF8B5CF6);

  /// Accent used for feature icon: translation
  static const Color accentTranslation = Color(0xFF3B82F6);

  /// Accent used for feature icon: location
  static const Color accentLocation = Color(0xFF10B981);

  /// Accent used for feature icon: tasks
  static const Color accentTasks = Color(0xFFF59E0B);

  /// Accent used for the Expense Tracker feature
  static const Color accentExpense = Color(0xFF0EA5E9);

  // â”€â”€ Light Theme â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brandSeed,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // Slightly warm off-white page background
      scaffoldBackgroundColor: const Color(0xFFF7F8FF),

      // App bar: transparent, zero elevation â€” we style headers manually
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
      ),

      // Cards: white, rounded, no shadow (shadows added per card as needed)
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Material 3 bottom navigation bar
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        height: 68,
        indicatorColor: brandSeed.withAlpha(31),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary, size: 24);
          }
          return const IconThemeData(color: Color(0xFF9E9E9E), size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            );
          }
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Color(0xFF9E9E9E),
          );
        }),
      ),

      // Snack bars: rounded floating style
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

