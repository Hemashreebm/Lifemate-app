import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'translation_service.dart';

/// Centralized Text-to-Speech (TTS) Service for Lifemate.
/// Manages engine selection, voice discovery, locale normalization, and speech playback.
class TtsService {
  static final TtsService instance = TtsService._();
  TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  String? _defaultEngine;
  List<String> _availableEngines = [];
  List<String> _availableLanguages = [];
  List<Map<String, String>> _availableVoices = [];

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  // Getters for diagnostic logging
  String? get defaultEngine => _defaultEngine;
  List<String> get availableEngines => List.unmodifiable(_availableEngines);
  List<String> get availableLanguages => List.unmodifiable(_availableLanguages);
  List<Map<String, String>> get availableVoices => List.unmodifiable(_availableVoices);

  /// Initialize TTS once: select preferred Google engine, discover voices/languages, attach handlers.
  Future<void> init() async {
    if (_initialized) return;

    try {
      debugPrint('[TTS DIAGNOSTIC] === INITIALIZING TTS SERVICE ===');

      // 1. Get engines
      try {
        final enginesRaw = await _tts.getEngines;
        if (enginesRaw is List) {
          _availableEngines = enginesRaw.map((e) => e.toString()).toList();
        }
        debugPrint('[TTS DIAGNOSTIC] Available engines: $_availableEngines');
      } catch (e) {
        debugPrint('[TTS DIAGNOSTIC] getEngines error: $e');
      }

      try {
        final defaultEng = await _tts.getDefaultEngine;
        _defaultEngine = defaultEng?.toString();
        debugPrint('[TTS DIAGNOSTIC] Default engine: $_defaultEngine');
      } catch (e) {
        debugPrint('[TTS DIAGNOSTIC] getDefaultEngine error: $e');
      }

      // Prefer Google TTS engine if available (com.google.android.tts)
      if (_availableEngines.contains('com.google.android.tts')) {
        try {
          debugPrint('[TTS DIAGNOSTIC] Setting engine to com.google.android.tts...');
          await _tts.setEngine('com.google.android.tts');
        } catch (e) {
          debugPrint('[TTS DIAGNOSTIC] setEngine error: $e');
        }
      }

      // 2. Set default speech rate & pitch
      try {
        await _tts.setSpeechRate(0.45);
        await _tts.setVolume(1.0);
        await _tts.setPitch(1.0);
      } catch (e) {
        debugPrint('[TTS DIAGNOSTIC] setSpeechRate/setPitch error: $e');
      }

      // 3. Attach handlers
      _tts.setStartHandler(() {
        debugPrint('[TTS] START');
        _isPlaying = true;
      });

      _tts.setCompletionHandler(() {
        debugPrint('[TTS] COMPLETE');
        _isPlaying = false;
      });

      _tts.setCancelHandler(() {
        debugPrint('[TTS] CANCELLED');
        _isPlaying = false;
      });

      _tts.setErrorHandler((msg) {
        debugPrint('[TTS] ERROR: $msg');
        _isPlaying = false;
      });

      // 4. Discover available languages & voices
      await refreshCapabilities();
      _initialized = true;
    } catch (e) {
      debugPrint('[TTS DIAGNOSTIC] Init error: $e');
    }
  }

  /// Query Android TTS engine for available languages and voices.
  Future<void> refreshCapabilities() async {
    try {
      final langsRaw = await _tts.getLanguages;
      if (langsRaw is List) {
        _availableLanguages = langsRaw.map((l) => l.toString()).toList();
      }
      debugPrint('[TTS DIAGNOSTIC] Locales returned by getLanguages (${_availableLanguages.length}): $_availableLanguages');

      final voicesRaw = await _tts.getVoices;
      _availableVoices.clear();
      if (voicesRaw is List) {
        for (final v in voicesRaw) {
          if (v is Map) {
            final name = v['name']?.toString() ?? '';
            final locale = v['locale']?.toString() ?? '';
            if (name.isNotEmpty || locale.isNotEmpty) {
              _availableVoices.add({'name': name, 'locale': locale});
            }
          }
        }
      }
      debugPrint('[TTS DIAGNOSTIC] Total voices returned by getVoices: ${_availableVoices.length}');

      // Log matching voices for each of the 5 AppLanguages
      for (final lang in AppLanguage.values) {
        final matches = _findVoicesForLang(lang);
        debugPrint('[TTS DIAGNOSTIC] ${lang.label} voices found (${matches.length}): $matches');
      }
    } catch (e) {
      debugPrint('[TTS DIAGNOSTIC] refreshCapabilities error: $e');
    }
  }

  /// Find matching voices from `getVoices` for a given AppLanguage.
  /// Normalizes '-' and '_' and matches primarily by language code (en, te, kn, hi, ta).
  List<Map<String, String>> _findVoicesForLang(AppLanguage lang) {
    final code = lang.code.toLowerCase(); // 'en', 'te', 'kn', 'hi', 'ta'
    return _availableVoices.where((v) {
      final loc = v['locale']?.toLowerCase().replaceAll('_', '-') ?? '';
      final name = v['name']?.toLowerCase().replaceAll('_', '-') ?? '';
      return loc == code || loc.startsWith('$code-') || loc.contains('-$code') || name.contains(code);
    }).toList();
  }

  /// Stop any currently playing audio immediately.
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('[TTS DIAGNOSTIC] Stop error: $e');
    } finally {
      _isPlaying = false;
    }
  }

  /// Speak `text` using the best matching voice for `targetLang`.
  Future<bool> speak({
    required String text,
    required AppLanguage targetLang,
  }) async {
    if (text.trim().isEmpty) return false;
    await init();
    await stop();

    final reqLangLabel = targetLang.label;
    final code = targetLang.code.toLowerCase(); // 'en', 'te', 'kn', 'hi', 'ta'
    
    debugPrint('[TTS] Requested language: $reqLangLabel (code: $code)');

    // 1. Find matching voices from getVoices
    final matchingVoices = _findVoicesForLang(targetLang);
    debugPrint('[TTS] Available matching voices: $matchingVoices');

    Map<String, String>? selectedVoice;
    String selectedLocale = targetLang.ttsLocale; // Default fallback e.g. 'te-IN'

    if (matchingVoices.isNotEmpty) {
      // Prefer an IN (India) voice if available
      selectedVoice = matchingVoices.firstWhere(
        (v) => (v['locale']?.toLowerCase().contains('in') ?? false) ||
               (v['name']?.toLowerCase().contains('in') ?? false),
        orElse: () => matchingVoices.first,
      );
      selectedLocale = selectedVoice['locale'] ?? targetLang.ttsLocale;
    } else {
      // Match from getLanguages list
      final matchingLangStr = _availableLanguages.firstWhere(
        (l) {
          final normalized = l.toLowerCase().replaceAll('_', '-');
          return normalized == code || normalized.startsWith('$code-') || normalized.contains('-$code');
        },
        orElse: () => targetLang.ttsLocale,
      );
      selectedLocale = matchingLangStr;
    }

    debugPrint('[TTS] Selected voice: $selectedVoice');
    debugPrint('[TTS] Selected locale: $selectedLocale');

    // 2. Set Voice if voice object available
    dynamic setVoiceResult = 'N/A';
    if (selectedVoice != null && selectedVoice['name']!.isNotEmpty) {
      try {
        setVoiceResult = await _tts.setVoice({
          'name': selectedVoice['name']!,
          'locale': selectedVoice['locale']!,
        });
        debugPrint('[TTS] setVoice result: $setVoiceResult');
      } catch (e) {
        debugPrint('[TTS] setVoice error: $e');
        setVoiceResult = 'ERROR: $e';
      }
    }

    // 3. Set Language locale
    dynamic setLangResult = 'N/A';
    try {
      setLangResult = await _tts.setLanguage(selectedLocale);
      debugPrint('[TTS] setLanguage result: $setLangResult');
    } catch (e) {
      debugPrint('[TTS] setLanguage error: $e');
      setLangResult = 'ERROR: $e';
      // Fallback: try raw BCP-47 language code e.g. "te"
      try {
        setLangResult = await _tts.setLanguage(code);
        debugPrint('[TTS] setLanguage fallback ($code) result: $setLangResult');
      } catch (e2) {
        debugPrint('[TTS] setLanguage fallback error: $e2');
      }
    }

    // 4. Configure speech rate & pitch
    try {
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
    } catch (_) {}

    // 5. Speak text
    debugPrint('[TTS] Text: "$text"');
    dynamic speakResult = 'N/A';
    try {
      speakResult = await _tts.speak(text);
      debugPrint('[TTS] speak result: $speakResult');
      return (speakResult == 1 || speakResult == true);
    } catch (e) {
      debugPrint('[TTS] ERROR: $e');
      return false;
    }
  }

  /// Run direct TTS diagnostic tests for all 5 languages without ML Kit translation.
  Future<Map<AppLanguage, bool>> runDirectDiagnosticTest() async {
    await init();
    final Map<AppLanguage, bool> results = {};
    final testPhrases = {
      AppLanguage.english: 'Hello',
      AppLanguage.telugu: 'నమస్కారం',
      AppLanguage.kannada: 'ನಮಸ್ಕಾರ',
      AppLanguage.hindi: 'नमस्ते',
      AppLanguage.tamil: 'வணக்கம்',
    };

    debugPrint('[TTS DIAGNOSTIC] === RUNNING DIRECT TTS DIAGNOSTIC TEST FOR ALL 5 LANGUAGES ===');
    for (final entry in testPhrases.entries) {
      final lang = entry.key;
      final text = entry.value;
      debugPrint('[TTS DIAGNOSTIC] Testing direct TTS for ${lang.label} ("$text")...');
      final ok = await speak(text: text, targetLang: lang);
      results[lang] = ok;
      debugPrint('[TTS DIAGNOSTIC] Direct TTS result for ${lang.label}: ${ok ? "PASS" : "FAIL"}');
      await Future.delayed(const Duration(milliseconds: 1200));
    }

    return results;
  }
}
