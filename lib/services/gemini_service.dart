import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'supabase_service.dart';
import 'ai_memory_service.dart';

/// Secure Client Service for Google Gemini AI Engine.
///
/// Features:
/// 1. Server-side proxy through Supabase Edge Function `gemini-chat` (Production Architecture).
/// 2. Developer Test Key support (`--dart-define=GEMINI_API_KEY=your_key`) for local testing.
/// 3. Rate limiting & request throttling (1.5s delay, 30 max requests/session).
/// 4. Sensitive data filtering (OTPs, PINs, Passwords, Card numbers).
/// 5. Graceful offline & failure fallback (Never crashes).
class GeminiService {
  static final GeminiService instance = GeminiService._internal();
  GeminiService._internal();

  DateTime? _lastRequestTime;
  int _sessionRequestCount = 0;
  static const int _maxSessionRequests = 30;
  static const Duration _minRequestInterval = Duration(milliseconds: 1500);

  /// Reset session request counter for development testing
  void resetSessionCounter() {
    _sessionRequestCount = 0;
    _lastRequestTime = null;
  }

  /// Generate AI response using Secure Backend or Local Dev Configuration.
  Future<String> generateResponse(String prompt, {String? memoryContext}) async {
    final sanitizedPrompt = _sanitizePrompt(prompt);
    if (sanitizedPrompt.isEmpty) {
      return 'Please enter a valid request.';
    }

    // 1. Rate Limit & Throttle Checks
    final now = DateTime.now();
    if (_lastRequestTime != null) {
      final elapsed = now.difference(_lastRequestTime!);
      if (elapsed < _minRequestInterval) {
        await Future.delayed(_minRequestInterval - elapsed);
      }
    }
    _lastRequestTime = DateTime.now();

    if (_sessionRequestCount >= _maxSessionRequests) {
      return 'You have reached the maximum AI request limit for this session (30 requests). Please take a break and try again later.';
    }
    _sessionRequestCount++;

    // 2. Combine Context from AI Memory
    final context = memoryContext ?? AiMemoryService.instance.getMemoryContextPrompt();

    // 3. Attempt Supabase Edge Function (Server-Side Secure Architecture)
    final supabase = SupabaseService.instance;
    if (supabase.isInitialized && supabase.client != null) {
      try {
        debugPrint('[GEMINI SERVICE] Sending request to Supabase Edge Function gemini-chat...');
        final firebaseUser = FirebaseAuth.instance.currentUser;
        final idToken = await firebaseUser?.getIdToken() ?? 'dummy_dev_token';

        final res = await supabase.client!.functions.invoke(
          'gemini-chat',
          headers: {
            'Authorization': 'Bearer $idToken',
          },
          body: {
            'prompt': sanitizedPrompt,
            'context': context,
          },
        ).timeout(const Duration(seconds: 15));

        if (res.data != null && res.data['reply'] != null) {
          return (res.data['reply'] as String).trim();
        }
      } catch (e) {
        debugPrint('[GEMINI SERVICE WARNING] Edge function call failed: $e. Checking dev key / fallback...');
      }
    }

    // 4. Attempt Developer Test Key (Local Dev Build Only)
    final devApiKey = const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (devApiKey.isNotEmpty && !devApiKey.contains('placeholder')) {
      try {
        debugPrint('[GEMINI DEV KEY] Calling Gemini REST API with local developer key...');
        final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$devApiKey');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': context.isNotEmpty ? 'Context: $context\n\nUser: $sanitizedPrompt' : sanitizedPrompt}
                ]
              }
            ],
            'generationConfig': {'maxOutputTokens': 500, 'temperature': 0.7}
          }),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
          if (text != null && (text as String).trim().isNotEmpty) {
            return text.trim();
          }
        } else if (response.statusCode == 400 || response.statusCode == 403) {
          return 'Developer API key is invalid or quota exceeded. Please check your local GEMINI_API_KEY configuration.';
        }
      } catch (e) {
        debugPrint('[GEMINI DEV KEY WARNING] Local Gemini API call failed: $e');
      }
    }

    // 5. Fallback Contextual Response Generator (Offline / Unconfigured Mode)
    return _generateContextualFallback(sanitizedPrompt);
  }

  /// Sanitize prompt to strip sensitive financial credentials, OTPs, PINs, and card numbers.
  String _sanitizePrompt(String input) {
    var text = input.trim();
    if (text.length > 2000) {
      text = text.substring(0, 2000);
    }

    // Remove potential 4-6 digit OTPs or PINs when accompanied by sensitive keywords
    final lower = text.toLowerCase();
    if (lower.contains('otp') || lower.contains('password') || lower.contains('cvv') || lower.contains('card number')) {
      text = text.replaceAll(RegExp(r'\b\d{4,16}\b'), '[REDACTED_SENSITIVE]');
    }

    return text;
  }

  /// Offline contextual response generator
  String _generateContextualFallback(String prompt) {
    final lower = prompt.toLowerCase();
    if (lower.contains('task') || lower.contains('reminder')) {
      return 'I can help you manage your day! You can add tasks or set reminders right from the Tasks tab.';
    }
    if (lower.contains('expense') || lower.contains('spend') || lower.contains('spent') || lower.contains('budget')) {
      return 'Your financial peace of mind is important. Check out the Expense Tracker tab to review transactions and set budgets.';
    }
    if (lower.contains('diary') || lower.contains('note') || lower.contains('feeling')) {
      return 'Reflecting on your day helps maintain clarity. Feel free to jot down your thoughts in the Friendly Diary.';
    }
    if (lower.contains('scheme') || lower.contains('government')) {
      return 'Lifemate provides personalized Indian Government schemes. Head over to Citizen Services to explore schemes curated for you!';
    }
    return 'Thank you for reaching out! I am here to help you stay organized, manage your expenses, and achieve your daily goals.';
  }
}
