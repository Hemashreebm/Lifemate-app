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
  final List<Map<String, String>> _availableVoices = [];

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  // Getters for diagnostic logging
  String? get defaultEngine => _defaultEngine;
  List<String> get availableEngines => List.unmodifiable(_availableEngines);
  List<String> get availableLanguages => List.unmodifiable(_availableLanguages);
  List<Map<String, String>> get availableVoices => List.unmodifiable(_availableVoices);

  /// Initialize TTS once: discover voices/languages and attach handlers.
  Future<void> init() async {
    if (_initialized) return;

    try {
      debugPrint('[TTS] Initializing TtsService...');

      // 1. Get available engines
      try {
        final enginesRaw = await _tts.getEngines;
        if (enginesRaw is List) {
          _availableEngines = enginesRaw.map((e) => e.toString()).toList();
        }
        debugPrint('[TTS] Engines: $_availableEngines');
      } catch (e) {
        debugPrint('[TTS] getEngines error: $e');
      }

      try {
        final defaultEng = await _tts.getDefaultEngine;
        _defaultEngine = defaultEng?.toString();
        debugPrint('[TTS] Default engine: $_defaultEngine');
      } catch (e) {
        debugPrint('[TTS] getDefaultEngine error: $e');
      }

      // 2. Set default speech parameters
      try {
        await _tts.setVolume(1.0);
        await _tts.setSpeechRate(0.45);
        await _tts.setPitch(1.0);
        await _tts.setQueueMode(1); // Flush queue mode on Android
      } catch (e) {
        debugPrint('[TTS] Speech rate/pitch/queue error: $e');
      }

      // 3. Attach handlers
      _tts.setStartHandler(() {
        debugPrint('[TTS] START PLAYBACK');
        _isPlaying = true;
      });

      _tts.setCompletionHandler(() {
        debugPrint('[TTS] PLAYBACK COMPLETED');
        _isPlaying = false;
      });

      _tts.setCancelHandler(() {
        debugPrint('[TTS] PLAYBACK CANCELLED');
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
      debugPrint('[TTS] Init error: $e');
    }
  }

  /// Query Android TTS engine for available languages and voices.
  Future<void> refreshCapabilities() async {
    try {
      final langsRaw = await _tts.getLanguages;
      if (langsRaw is List) {
        _availableLanguages = langsRaw.map((l) => l.toString()).toList();
      }
      debugPrint('[TTS] Languages count: ${_availableLanguages.length}');

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
      debugPrint('[TTS] Voices count: ${_availableVoices.length}');
    } catch (e) {
      debugPrint('[TTS] refreshCapabilities error: $e');
    }
  }

  /// Stop any currently playing audio immediately.
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('[TTS] Stop error: $e');
    } finally {
      _isPlaying = false;
    }
  }

  /// Speak `text` using target language locale.
  Future<bool> speak({
    required String text,
    required AppLanguage targetLang,
  }) async {
    if (text.trim().isEmpty) return false;
    await init();
    await stop();

    // 100ms delay to allow native TTS engine queue to settle after stop()
    await Future.delayed(const Duration(milliseconds: 100));

    final code = targetLang.code.toLowerCase(); // 'en', 'te', 'kn', 'hi', 'ta'
    final rawLocale = targetLang.ttsLocale; // 'te-IN', 'kn-IN', 'hi-IN', 'ta-IN', 'en-US'
    final normalizedLocale = rawLocale.replaceAll('-', '_'); // 'te_IN', 'kn_IN', 'hi_IN', 'ta_IN', 'en_US'

    debugPrint('[TTS] Requesting speak for ${targetLang.label} (locale: $rawLocale / $normalizedLocale)');

    // 1. Set Language Locale
    bool langSupported = false;
    try {
      final res = await _tts.setLanguage(rawLocale);
      debugPrint('[TTS] setLanguage ($rawLocale) result: $res (type: ${res.runtimeType})');
      if (res == true || (res is int && res >= 0)) {
        langSupported = true;
      }
    } catch (e) {
      debugPrint('[TTS] setLanguage ($rawLocale) error: $e');
    }

    if (!langSupported) {
      try {
        final res = await _tts.setLanguage(normalizedLocale);
        debugPrint('[TTS] setLanguage ($normalizedLocale) result: $res (type: ${res.runtimeType})');
        if (res == true || (res is int && res >= 0)) {
          langSupported = true;
        }
      } catch (e) {
        debugPrint('[TTS] setLanguage ($normalizedLocale) error: $e');
      }
    }

    if (!langSupported) {
      try {
        final res = await _tts.setLanguage(code);
        debugPrint('[TTS] setLanguage fallback ($code) result: $res (type: ${res.runtimeType})');
        if (res == true || (res is int && res >= 0)) {
          langSupported = true;
        }
      } catch (e) {
        debugPrint('[TTS] setLanguage fallback error: $e');
      }
    }

    // 2. Configure audio parameters
    try {
      await _tts.setVolume(1.0);
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
    } catch (_) {}

    // 3. Trigger Speech
    debugPrint('[TTS] Speaking text: "$text"');
    try {
      _isPlaying = true;
      final speakResult = await _tts.speak(text);
      debugPrint('[TTS] speak() returned: $speakResult (type: ${speakResult.runtimeType})');

      if (speakResult == true || (speakResult is int && speakResult >= 0)) {
        return true;
      } else {
        _isPlaying = false;
        return false;
      }
    } catch (e) {
      debugPrint('[TTS] speak() error: $e');
      _isPlaying = false;
      return false;
    }
  }

  /// Run direct TTS diagnostic tests for all 5 languages.
  Future<Map<AppLanguage, bool>> runDirectDiagnosticTest() async {
    await init();
    final Map<AppLanguage, bool> results = {};
    final testPhrases = {
      AppLanguage.english: 'Hello, welcome to Lifemate.',
      AppLanguage.telugu: 'నమస్కారం',
      AppLanguage.kannada: 'ನಮಸ್ಕಾರ',
      AppLanguage.hindi: 'नमस्ते',
      AppLanguage.tamil: 'வணக்கம்',
    };

    debugPrint('[TTS DIAGNOSTIC] === RUNNING DIRECT TTS DIAGNOSTIC TEST ===');
    for (final entry in testPhrases.entries) {
      final lang = entry.key;
      final text = entry.value;
      debugPrint('[TTS DIAGNOSTIC] Testing direct TTS for ${lang.label}...');
      final ok = await speak(text: text, targetLang: lang);
      results[lang] = ok;
      debugPrint('[TTS DIAGNOSTIC] Direct TTS result for ${lang.label}: ${ok ? "PASS" : "FAIL"}');
      await Future.delayed(const Duration(milliseconds: 1500));
    }

    return results;
  }
}
