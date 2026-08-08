import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Managed Supabase Authentication Service for Lifemate v2.0.
///
/// Features:
/// 1. Google OAuth & Email/Password login/signup/reset abstraction.
/// 2. Session state restoration & user identity mapping.
/// 3. Identity bridge handling coexistence between Firebase Auth and Supabase Auth.
/// 4. Zero hardcoded client secrets.
class SupabaseAuthService {
  static final SupabaseAuthService instance = SupabaseAuthService._internal();
  SupabaseAuthService._internal();

  /// Current authenticated Supabase user (if initialized and logged in)
  User? get currentUser => SupabaseService.instance.client?.auth.currentUser;

  /// Current authenticated Supabase user ID (or null if unauthenticated / offline fallback)
  String? get currentUserId => currentUser?.id;

  /// Returns true if a valid Supabase user session exists
  bool get isAuthenticated => currentUser != null;

  /// Stream of Supabase Auth state changes
  Stream<AuthState>? get authStateChanges =>
      SupabaseService.instance.client?.auth.onAuthStateChange;

  /// Sign up with Email and Password
  Future<AuthResponse?> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    final supabase = SupabaseService.instance;
    if (!supabase.isInitialized || supabase.client == null) {
      debugPrint('[SUPABASE AUTH WARNING] Supabase not initialized. Offline fallback mode active.');
      return null;
    }

    try {
      final response = await supabase.client!.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: data,
      );
      debugPrint('[SUPABASE AUTH SUCCESS] Signed up email user: ${response.user?.id}');
      return response;
    } catch (e) {
      debugPrint('[SUPABASE AUTH ERROR] Email sign up error: $e');
      rethrow;
    }
  }

  /// Sign in with Email and Password
  Future<AuthResponse?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final supabase = SupabaseService.instance;
    if (!supabase.isInitialized || supabase.client == null) {
      debugPrint('[SUPABASE AUTH WARNING] Supabase not initialized. Offline fallback mode active.');
      return null;
    }

    try {
      final response = await supabase.client!.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      debugPrint('[SUPABASE AUTH SUCCESS] Signed in email user: ${response.user?.id}');
      return response;
    } catch (e) {
      debugPrint('[SUPABASE AUTH ERROR] Email sign in error: $e');
      rethrow;
    }
  }

  /// Trigger Google OAuth Sign-In via Supabase Auth
  Future<bool> signInWithGoogle() async {
    final supabase = SupabaseService.instance;
    if (!supabase.isInitialized || supabase.client == null) {
      debugPrint('[SUPABASE AUTH WARNING] Supabase not initialized. Offline fallback mode active.');
      return false;
    }

    try {
      return await supabase.client!.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.lifemate://login-callback/',
      );
    } catch (e) {
      debugPrint('[SUPABASE AUTH ERROR] Google OAuth sign in error: $e');
      rethrow;
    }
  }

  /// Send Password Reset Email
  Future<void> resetPassword(String email) async {
    final supabase = SupabaseService.instance;
    if (!supabase.isInitialized || supabase.client == null) return;

    try {
      await supabase.client!.auth.resetPasswordForEmail(email.trim());
      debugPrint('[SUPABASE AUTH SUCCESS] Sent password reset to $email');
    } catch (e) {
      debugPrint('[SUPABASE AUTH ERROR] Reset password error: $e');
      rethrow;
    }
  }

  /// Sign Out current Supabase session
  Future<void> signOut() async {
    final supabase = SupabaseService.instance;
    if (!supabase.isInitialized || supabase.client == null) return;

    try {
      await supabase.client!.auth.signOut();
      debugPrint('[SUPABASE AUTH SUCCESS] Signed out Supabase session.');
    } catch (e) {
      debugPrint('[SUPABASE AUTH ERROR] Sign out error: $e');
    }
  }
}
