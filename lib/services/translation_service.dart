import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

/// Supported languages for Phase 1 On-Device Translation.
enum AppLanguage {
  english('English', TranslateLanguage.english, 'en-IN', 'en-IN', 'en'),
  telugu('Telugu', TranslateLanguage.telugu, 'te-IN', 'te-IN', 'te'),
  kannada('Kannada', TranslateLanguage.kannada, 'kn-IN', 'kn-IN', 'kn'),
  hindi('Hindi', TranslateLanguage.hindi, 'hi-IN', 'hi-IN', 'hi'),
  tamil('Tamil', TranslateLanguage.tamil, 'ta-IN', 'ta-IN', 'ta');

  final String label;
  final TranslateLanguage mlKitLanguage;
  final String speechLocale;
  final String ttsLocale;
  final String code;

  const AppLanguage(
    this.label,
    this.mlKitLanguage,
    this.speechLocale,
    this.ttsLocale,
    this.code,
  );
}

/// Service managing on-device ML Kit translation and model downloads.
class TranslationService {
  static final TranslationService instance = TranslationService._();
  TranslationService._();

  final OnDeviceTranslatorModelManager _modelManager =
      OnDeviceTranslatorModelManager();

  /// Returns the per-language diagnostic tag for logcat filtering.
  String _tag(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return 'HINDI DIAGNOSTIC';
      case AppLanguage.tamil:
        return 'TAMIL DIAGNOSTIC';
      case AppLanguage.kannada:
        return 'KANNADA DIAGNOSTIC';
      case AppLanguage.telugu:
        return 'TELUGU DIAGNOSTIC';
      case AppLanguage.english:
        return 'ENGLISH DIAGNOSTIC';
    }
  }

  /// Check if an ML Kit language model is already downloaded on the device.
  Future<bool> isModelDownloaded(AppLanguage lang) async {
    // English is the built-in base language in ML Kit — never needs a download.
    if (lang == AppLanguage.english) {
      debugPrint('[ENGLISH DIAGNOSTIC] English is built-in base language. isModelDownloaded → true');
      return true;
    }

    final tag = _tag(lang);
    final bcp = lang.mlKitLanguage.bcpCode;

    try {
      debugPrint('[$tag] MODEL CHECK — language: ${lang.label}, bcpCode: "$bcp"');
      final isDownloaded = await _modelManager.isModelDownloaded(bcp);
      debugPrint('[$tag] MODEL INSTALLED: $isDownloaded');
      return isDownloaded;
    } catch (e, st) {
      debugPrint('[$tag] MODEL CHECK ERROR: $e\n$st');
      return false;
    }
  }

  /// Download an ML Kit language model on-demand (allows mobile data or Wi-Fi).
  ///
  /// IMPORTANT: ML Kit native Android download continues in the background even
  /// if the Dart future times out. After a timeout, we poll isModelDownloaded()
  /// for up to 90 additional seconds to detect when the native download finishes.
  Future<bool> downloadModel(AppLanguage lang) async {
    if (lang == AppLanguage.english) return true;

    final tag = _tag(lang);
    final bcp = lang.mlKitLanguage.bcpCode;

    // If already downloaded, return immediately.
    final alreadyPresent = await _modelManager.isModelDownloaded(bcp).catchError((_) => false);
    if (alreadyPresent) {
      debugPrint('[$tag] MODEL already installed — skipping download.');
      return true;
    }

    try {
      debugPrint('[$tag] DOWNLOAD START — language: ${lang.label}, bcpCode: "$bcp", isWifiRequired: false');

      // Use 120s timeout — Hindi/Tamil models are ~30-40MB and take >45s on mobile data.
      bool success = false;
      try {
        success = await _modelManager
            .downloadModel(bcp, isWifiRequired: false)
            .timeout(
              const Duration(seconds: 120),
              onTimeout: () {
                // Native download continues in background even after Dart timeout.
                debugPrint('[$tag] DOWNLOAD Dart-future TIMEOUT after 120s — '
                    'native download may still be in progress.');
                return false;
              },
            );
      } catch (e) {
        debugPrint('[$tag] DOWNLOAD future ERROR: $e — will poll for native completion.');
        success = false;
      }

      if (success) {
        debugPrint('[$tag] DOWNLOAD SUCCESS (returned true immediately)');
        final verified = await _modelManager.isModelDownloaded(bcp).catchError((_) => false);
        debugPrint('[$tag] POST-DOWNLOAD VERIFICATION: isModelDownloaded → $verified');
        return verified;
      }

      // --- Timeout/false path: Poll for native background download completion ---
      // ML Kit Android may finish downloading even after our Dart future times out.
      // Poll every 5s for up to 90 more seconds (18 checks).
      debugPrint('[$tag] POLLING for native background download completion...');
      for (int i = 1; i <= 18; i++) {
        await Future.delayed(const Duration(seconds: 5));
        final ready = await _modelManager.isModelDownloaded(bcp).catchError((_) => false);
        debugPrint('[$tag] POLL #$i: isModelDownloaded → $ready');
        if (ready) {
          debugPrint('[$tag] DOWNLOAD COMPLETE (detected via polling at attempt $i)');
          return true;
        }
      }

      debugPrint('[$tag] DOWNLOAD FAILED — model not available after polling.');
      return false;
    } catch (e, st) {
      debugPrint('[$tag] DOWNLOAD ERROR: $e\n$st');
      return false;
    }
  }

  /// Perform on-device translation from source to target language.
  Future<String> translate({
    required String text,
    required AppLanguage source,
    required AppLanguage target,
  }) async {
    if (text.trim().isEmpty) return '';
    if (source == target) return text;

    final tag = '${target.label.toUpperCase()} DIAGNOSTIC';

    debugPrint(
      '[$tag] TRANSLATE START — '
      'source: ${source.label} (bcpCode: "${source.mlKitLanguage.bcpCode}"), '
      'target: ${target.label} (bcpCode: "${target.mlKitLanguage.bcpCode}"), '
      'text: "$text"',
    );

    // Pre-translate model guard. English is built-in (always available).
    if (source != AppLanguage.english) {
      final srcTag = _tag(source);
      final srcReady = await _modelManager
          .isModelDownloaded(source.mlKitLanguage.bcpCode)
          .catchError((_) => false);
      debugPrint('[$srcTag] PRE-TRANSLATE SOURCE MODEL CHECK: $srcReady');
      if (!srcReady) {
        throw Exception(
          '${source.label} translation model is not downloaded. Please download it first.',
        );
      }
    }

    if (target != AppLanguage.english) {
      final tgtReady = await _modelManager
          .isModelDownloaded(target.mlKitLanguage.bcpCode)
          .catchError((_) => false);
      debugPrint('[$tag] PRE-TRANSLATE TARGET MODEL CHECK: $tgtReady');
      if (!tgtReady) {
        throw Exception(
          '${target.label} translation model is not downloaded. Please download it first.',
        );
      }
    }

    OnDeviceTranslator? translator;
    try {
      debugPrint('[$tag] CREATING OnDeviceTranslator...');
      translator = OnDeviceTranslator(
        sourceLanguage: source.mlKitLanguage,
        targetLanguage: target.mlKitLanguage,
      );
      debugPrint('[$tag] OnDeviceTranslator CREATED — calling translateText()...');

      final result = await translator.translateText(text);
      debugPrint('[$tag] TRANSLATE SUCCESS: "$result"');
      return result;
    } catch (e, st) {
      debugPrint('[$tag] TRANSLATE ERROR: $e\n$st');
      rethrow;
    } finally {
      translator?.close();
      debugPrint('[$tag] Translator closed.');
    }
  }
}
