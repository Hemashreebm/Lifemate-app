import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/translation_service.dart';
import '../services/tts_service.dart';

// â”€â”€â”€ Data Models â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

/// Which person is currently the active speaker.
enum _Speaker { personA, personB }

/// A single conversation turn stored in memory.
class _ConvMessage {
  final _Speaker speaker;
  final String original;
  final String translated;
  final AppLanguage fromLang;
  final AppLanguage toLang;
  final DateTime timestamp;

  const _ConvMessage({
    required this.speaker,
    required this.original,
    required this.translated,
    required this.fromLang,
    required this.toLang,
    required this.timestamp,
  });
}

// ——— Screen —————————————————————————————————————————————————————————————————

/// Phase 2 — Conversation Mode (Optimized STT/TTS & Zero-Delay Flow).
class ConversationModeScreen extends StatefulWidget {
  const ConversationModeScreen({super.key});

  @override
  State<ConversationModeScreen> createState() => _ConversationModeScreenState();
}

class _ConversationModeScreenState extends State<ConversationModeScreen> {
  // ——— Services —————————————————————————————————————————————————————————————
  final _transSvc = TranslationService.instance;
  final _speech = stt.SpeechToText();

  // ——— Language pair ————————————————————————————————————————————————————————
  AppLanguage _langA = AppLanguage.telugu;  // Person A default
  AppLanguage _langB = AppLanguage.english; // Person B default

  // ——— Conversation history (in-memory) ——————————————————————————————————————
  final List<_ConvMessage> _messages = [];

  // ——— Lifecycle & Busy state ———————————————————————————————————————————————
  _Speaker? _activeSpk;           // who is currently speaking (null = idle)
  bool _isSpeaking   = false;     // TTS is currently playing
  bool _isListening  = false;     // STT is active
  bool _isTranslating = false;    // translation in progress
  bool _isDownloading = false;    // model download in progress
  String _statusText = '';        // banner text while busy
  String _dlText = '';            // download status text

  // ——— Cached STT / TTS Capabilities (Loaded ONCE at init) ——————————————————
  bool _speechInitialized = false;
  int _sttInitDurationMs = 0;
  final Map<AppLanguage, stt.LocaleName> _cachedSttLocales = {};
  final Set<AppLanguage> _cachedTtsSupported = {};

  // Track which message is currently being replayed (index or -1)
  int _replayingIndex = -1;

  // â”€â”€ Scroll â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final _scrollCtrl = ScrollController();

  // â”€â”€ Colours â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  static const _purpleA   = Color(0xFF8B5CF6); // Person A accent
  static const _tealB     = Color(0xFF0D9488); // Person B accent
  static const _bgPage    = Color(0xFFF0F4FF);
  static const _bgCard    = Colors.white;

  // â”€â”€â”€ Init / Dispose â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  void initState() {
    super.initState();
    _initSpeechAndTts();
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _scrollCtrl.dispose();
    super.dispose();
  }

  /// Initialize STT & TTS ONCE when Conversation Mode opens.
  /// Discovers and caches all available phone STT locales and TTS voices.
  Future<void> _initSpeechAndTts() async {
    final tInitStart = DateTime.now().millisecondsSinceEpoch;
    debugPrint('[PERF DIAGNOSTIC] STT INIT START at $tInitStart');

    // 1. Initialize Speech-to-Text
    try {
      _speechInitialized = await _speech.initialize(
        onError: (err) {
          debugPrint('[STT DIAGNOSTIC] STT onError: ${err.errorMsg}');
          if (mounted) {
            setState(() {
              _isListening = false;
              _activeSpk   = null;
              _statusText  = '';
            });
          }
        },
        onStatus: (status) {
          debugPrint('[STT DIAGNOSTIC] STT onStatus: $status');
          if (mounted && (status == 'done' || status == 'notListening')) {
            setState(() => _isListening = false);
          }
        },
      );
      final tInitEnd = DateTime.now().millisecondsSinceEpoch;
      _sttInitDurationMs = tInitEnd - tInitStart;
      debugPrint('[STT DIAGNOSTIC] speech.initialize result: $_speechInitialized (took ${_sttInitDurationMs}ms)');
    } catch (e) {
      debugPrint('[STT DIAGNOSTIC] STT init exception: $e');
    }

    // 2. Discover STT Locales & System Locale ONCE
    if (_speechInitialized) {
      try {
        final sysLoc = await _speech.systemLocale();
        debugPrint('[STT DIAGNOSTIC] systemLocale: localeId="${sysLoc?.localeId}", name="${sysLoc?.name}"');
      } catch (e) {
        debugPrint('[STT DIAGNOSTIC] systemLocale error: $e');
      }

      try {
        final locales = await _speech.locales();
        debugPrint('[STT DIAGNOSTIC] AVAILABLE LOCALES COUNT from speech.locales(): ${locales.length}');
        for (final l in locales) {
          debugPrint('[STT DIAGNOSTIC]   - AVAILABLE LOCALE ID: "${l.localeId}", NAME: "${l.name}"');
        }

        // Safe locale matching for all 5 languages using language code normalization
        for (final lang in AppLanguage.values) {
          final code = lang.code.toLowerCase(); // 'en', 'te', 'kn', 'hi', 'ta'

          // Match by normalized language code ('-' and '_' treated equivalently)
          final matches = locales.where((l) {
            final id = l.localeId.toLowerCase().replaceAll('_', '-');
            return id == code || id.startsWith('$code-') || id.contains('-$code') || id.contains(code);
          }).toList();

          if (matches.isNotEmpty) {
            // Prefer xx-IN or xx_IN if available, else first match
            final inMatch = matches.firstWhere(
              (l) => l.localeId.toLowerCase().contains('in'),
              orElse: () => matches.first,
            );
            _cachedSttLocales[lang] = inMatch;
            debugPrint('[STT DIAGNOSTIC] ${lang.label} STT LOCALE FOUND: localeId="${inMatch.localeId}", name="${inMatch.name}"');
          } else {
            debugPrint('[STT DIAGNOSTIC] ${lang.label} STT LOCALE FOUND: NONE');
          }
        }
      } catch (e) {
        debugPrint('[STT DIAGNOSTIC] STT locale discovery error: $e');
      }
    }

    // 3. Initialize TtsService ONCE
    try {
      await TtsService.instance.init();
    } catch (e) {
      debugPrint('[TTS DIAGNOSTIC] TTS init error: $e');
    }
  }

  // â”€â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  bool get _isBusy =>
      _isListening || _isTranslating || _isDownloading || _isSpeaking;

  AppLanguage _targetLangFor(_Speaker spk) =>
      spk == _Speaker.personA ? _langB : _langA;

  AppLanguage _sourceLangFor(_Speaker spk) =>
      spk == _Speaker.personA ? _langA : _langB;

  String _personLabel(_Speaker spk) =>
      spk == _Speaker.personA ? 'YOU — ${_langA.label}' : 'OTHER PERSON — ${_langB.label}';

  Color _accentFor(_Speaker spk) =>
      spk == _Speaker.personA ? _purpleA : _tealB;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // â”€â”€â”€ Stop TTS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _stopTts() async {
    await TtsService.instance.stop();
    if (mounted) {
      setState(() {
        _isSpeaking     = false;
        _replayingIndex = -1;
        _statusText     = '';
      });
    }
  }

  // â”€â”€â”€ TTS Speak â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _speakText(String text, AppLanguage lang, {int replayIndex = -1}) async {
    if (text.trim().isEmpty) return;

    if (mounted) {
      setState(() {
        _isSpeaking     = true;
        _replayingIndex = replayIndex;
      });
    }

    final ok = await TtsService.instance.speak(
      text: text,
      targetLang: lang,
    );

    if (mounted) {
      setState(() {
        _isSpeaking     = false;
        _replayingIndex = -1;
      });
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${lang.label} spoken playback is not installed on this phone.'),
            backgroundColor: const Color(0xFFE11D48),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // â”€â”€â”€ Model Management â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<bool> _ensureModels(AppLanguage src, AppLanguage tgt) async {
    if (src != AppLanguage.english) {
      final srcOk = await _transSvc.isModelDownloaded(src);
      if (!srcOk) {
        final go = await _promptDownload(src);
        if (go != true) return false;
        if (mounted) {
          setState(() {
            _isDownloading = true;
            _dlText = 'Downloading ${src.label} model...';
            _statusText = _dlText;
          });
        }
        final ok = await _transSvc.downloadModel(src);
        if (mounted) setState(() => _isDownloading = false);
        if (!ok) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not download ${src.label} model.'),
                backgroundColor: const Color(0xFFEF4444),
              ),
            );
          }
          return false;
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${src.label} model downloaded.')),
          );
        }
      }
    }

    if (tgt != AppLanguage.english) {
      final tgtOk = await _transSvc.isModelDownloaded(tgt);
      if (!tgtOk) {
        final go = await _promptDownload(tgt);
        if (go != true) return false;
        if (mounted) {
          setState(() {
            _isDownloading = true;
            _dlText = 'Downloading ${tgt.label} model...';
            _statusText = _dlText;
          });
        }
        final ok = await _transSvc.downloadModel(tgt);
        if (mounted) setState(() => _isDownloading = false);
        if (!ok) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not download ${tgt.label} model.'),
                backgroundColor: const Color(0xFFEF4444),
              ),
            );
          }
          return false;
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${tgt.label} model downloaded.')),
          );
        }
      }
    }

    return true;
  }

  Future<bool?> _promptDownload(AppLanguage lang) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Download ${lang.label} Model?'),
        content: Text(
          '${lang.label} translation model is required (~30MB).\n'
          'It downloads once and works completely offline.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: _purpleA),
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  // â”€â”€â”€ Core Speak Flow (Optimized, Timed, Zero-Delay Text Display) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _onSpeakTapped(_Speaker spk) async {
    final tButton = DateTime.now().millisecondsSinceEpoch;
    debugPrint('[PERF DIAGNOSTIC] MIC BUTTON PRESSED at $tButton');

    // If TTS is playing, stop it first
    if (_isSpeaking) {
      await _stopTts();
      return;
    }

    // If listening, stop
    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
        _activeSpk   = null;
        _statusText  = '';
      });
      return;
    }

    if (_isBusy) return;

    final srcLang = _sourceLangFor(spk);
    final tgtLang = _targetLangFor(spk);

    // Direct explicit locale mapping
    final String targetLocaleId;
    switch (srcLang) {
      case AppLanguage.english:
        targetLocaleId = 'en_US';
        break;
      case AppLanguage.telugu:
        targetLocaleId = 'te_IN';
        break;
      case AppLanguage.hindi:
        targetLocaleId = 'hi_IN';
        break;
      case AppLanguage.tamil:
        targetLocaleId = 'ta_IN';
        break;
      case AppLanguage.kannada:
        targetLocaleId = 'kn_IN';
        break;
      case AppLanguage.malayalam:
        targetLocaleId = 'ml_IN';
        break;
    }

    debugPrint('[CONVERSATION STT] BUTTON = Speak ${srcLang.label}');
    debugPrint('[CONVERSATION STT] LANGUAGE = ${srcLang.label}');
    debugPrint('[CONVERSATION STT] LOCALE = $targetLocaleId');
    debugPrint('[CONVERSATION STT] CALLING speech.listen()');

    if (!_speechInitialized) {
      final ok = await _speech.initialize(
        onError: (err) {
          debugPrint('[CONVERSATION STT] ERROR = ${err.errorMsg}');
        },
        onStatus: (status) {
          debugPrint('[CONVERSATION STT] STATUS = $status');
        },
      );
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Speech recognition permissions or service not ready.')),
          );
        }
        return;
      }
      _speechInitialized = true;
    }

    String recognizedText = '';

    setState(() {
      _activeSpk  = spk;
      _isListening = true;
      _statusText  = '🎙️ Listening in ${srcLang.label}...';
    });

    await _speech.listen(
      localeId: targetLocaleId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        debugPrint('[CONVERSATION STT] RESULT = "${result.recognizedWords}" (final: ${result.finalResult})');
        if (mounted) {
          recognizedText = result.recognizedWords;
          setState(() => _statusText = '🎙️ "${result.recognizedWords}"');
        }
      },
    );

    // Wait until STT completes
    while (_speech.isListening) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final tSpeechResult = DateTime.now().millisecondsSinceEpoch;
    debugPrint('[PERF DIAGNOSTIC] SPEECH RESULT RECEIVED at $tSpeechResult: "$recognizedText"');

    if (mounted) setState(() => _isListening = false);

    if (recognizedText.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _activeSpk  = null;
          _statusText = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No speech detected in ${srcLang.label}. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // â”€â”€ Model Guard â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    if (mounted) {
      setState(() {
        _isTranslating = true;
        _statusText    = 'â³ Translating...';
      });
    }

    final modelsReady = await _ensureModels(srcLang, tgtLang);
    if (!modelsReady) {
      if (mounted) {
        setState(() {
          _isTranslating = false;
          _activeSpk     = null;
          _statusText    = '';
        });
      }
      return;
    }

    // â”€â”€ Perform Translation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    final tTrxStart = DateTime.now().millisecondsSinceEpoch;
    debugPrint('[PERF DIAGNOSTIC] TRANSLATION START at $tTrxStart');

    String translated = '';
    try {
      translated = await _transSvc.translate(
        text: recognizedText,
        source: srcLang,
        target: tgtLang,
      );
    } catch (e) {
      debugPrint('[CONV TRANSLATE] Error: $e');
      if (mounted) {
        setState(() {
          _isTranslating = false;
          _activeSpk     = null;
          _statusText    = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Translation failed: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
      return;
    }

    final tTrxEnd = DateTime.now().millisecondsSinceEpoch;
    debugPrint('[PERF DIAGNOSTIC] TRANSLATION END at $tTrxEnd (trx duration: ${tTrxEnd - tTrxStart}ms)');

    // â”€â”€ IMPORTANT OPTIMIZATION: DISPLAY TRANSLATED TEXT IMMEDIATELY! â”€â”€â”€â”€â”€â”€â”€â”€â”€
    // Do NOT wait for TTS preparation or completion before rendering the bubble!
    final msg = _ConvMessage(
      speaker:    spk,
      original:   recognizedText,
      translated: translated,
      fromLang:   srcLang,
      toLang:     tgtLang,
      timestamp:  DateTime.now(),
    );

    if (mounted) {
      setState(() {
        _messages.add(msg);
        _isTranslating = false;
        _statusText    = 'Preparing voice...';
      });
      _scrollToBottom();
    }

    // â”€â”€ Auto-speak translation (Asynchronous audio overlay) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    await _speakText(translated, tgtLang, replayIndex: _messages.length - 1);

    if (mounted) {
      setState(() {
        _activeSpk  = null;
        _statusText = '';
      });
    }
  }

  // â”€â”€â”€ Clear Conversation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _clearConversation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Clear Conversation?'),
        content: const Text(
          'This will remove all messages from this conversation session.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await _stopTts();
      setState(() => _messages.clear());
    }
  }

  // â”€â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Language selector
          _buildLanguageBar(),

          // Status banner
          if (_isBusy) _buildStatusBanner(),

          // Download banner
          if (_isDownloading) _buildDownloadBanner(),

          // Conversation history
          Expanded(child: _buildHistory()),

          // Privacy note
          _buildPrivacyNote(),

          // Mic buttons
          _buildMicRow(),
        ],
      ),
    );
  }

  // â”€â”€ AppBar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        '🗣️ Conversation Mode',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
      ),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1A1A2E),
      elevation: 0,
      actions: [
        if (_messages.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Clear Conversation',
            onPressed: _clearConversation,
          ),
      ],
    );
  }

  // â”€â”€ Language Bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildLanguageBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Person A language
          Expanded(child: _buildLangDropdown(
            value: _langA,
            accentColor: _purpleA,
            excluded: _langB,
            onChanged: _isBusy ? null : (lang) {
              if (lang != null) setState(() { _langA = lang; _messages.clear(); });
            },
          )),

          // Swap button
          GestureDetector(
            onTap: _isBusy ? null : () {
              setState(() {
                final t = _langA;
                _langA = _langB;
                _langB = t;
                _messages.clear();
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _purpleA.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.swap_horiz_rounded, color: _purpleA, size: 22),
            ),
          ),

          // Person B language
          Expanded(child: _buildLangDropdown(
            value: _langB,
            accentColor: _tealB,
            excluded: _langA,
            onChanged: _isBusy ? null : (lang) {
              if (lang != null) setState(() { _langB = lang; _messages.clear(); });
            },
          )),
        ],
      ),
    );
  }

  Widget _buildLangDropdown({
    required AppLanguage value,
    required Color accentColor,
    required AppLanguage excluded,
    required ValueChanged<AppLanguage?>? onChanged,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<AppLanguage>(
        value: value,
        isExpanded: true,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: accentColor,
          fontSize: 14,
        ),
        items: AppLanguage.values
            .where((l) => l != excluded)
            .map((l) => DropdownMenuItem(
                  value: l,
                  child: Text(l.label),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  // â”€â”€ Status Banner â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildStatusBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF3B82F6)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _statusText.isNotEmpty ? _statusText : 'Processing...',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D4ED8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF59E0B)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _dlText.isNotEmpty ? _dlText : 'Downloading translation model...',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Conversation History â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildHistory() {
    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _purpleA.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.forum_outlined, size: 48, color: _purpleA),
              ),
              const SizedBox(height: 20),
              const Text(
                'Start a conversation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap a microphone button below to speak.\n'
                'The translation will appear here automatically.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount: _messages.length,
      itemBuilder: (ctx, i) => _buildMessageBubble(_messages[i], i),
    );
  }

  Widget _buildMessageBubble(_ConvMessage msg, int index) {
    final isA = msg.speaker == _Speaker.personA;
    final accent = _accentFor(msg.speaker);
    final alignment = isA ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleRadius = isA
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          );

    final isReplaying = _replayingIndex == index && _isSpeaking;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          // Speaker label
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
            child: Text(
              _personLabel(msg.speaker),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: accent,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Bubble
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.80,
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _bgCard,
                borderRadius: bubbleRadius,
                border: Border.all(
                  color: accent.withAlpha(51),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withAlpha(15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Original text
                  Text(
                    msg.original,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Divider(color: accent.withAlpha(38), height: 1),
                  const SizedBox(height: 8),

                  // Translation label
                  Text(
                    '${msg.toLang.label}:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: accent,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Translated text
                  Text(
                    msg.translated,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: accent,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Replay / Stop button
                  Align(
                    alignment: isA ? Alignment.centerRight : Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () async {
                        if (isReplaying) {
                          await _stopTts();
                        } else {
                          await _stopTts();
                          await _speakText(
                            msg.translated,
                            msg.toLang,
                            replayIndex: index,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isReplaying
                              ? const Color(0xFFEF4444).withAlpha(26)
                              : accent.withAlpha(26),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isReplaying
                                  ? Icons.stop_rounded
                                  : Icons.volume_up_rounded,
                              size: 14,
                              color: isReplaying
                                  ? const Color(0xFFEF4444)
                                  : accent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isReplaying ? 'â¹ Stop' : '🔊 Replay',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isReplaying
                                    ? const Color(0xFFEF4444)
                                    : accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Privacy Note â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildPrivacyNote() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Microphone activates only when you tap Speak.',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF065F46),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Microphone Row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildMicRow() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, -3)),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildMicButton(_Speaker.personA)),
          const SizedBox(width: 12),
          if (_isSpeaking)
            GestureDetector(
              onTap: _stopTts,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withAlpha(26),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
                ),
                child: const Icon(Icons.stop_rounded, color: Color(0xFFEF4444), size: 22),
              ),
            )
          else
            const SizedBox(width: 12),
          const SizedBox(width: 12),
          Expanded(child: _buildMicButton(_Speaker.personB)),
        ],
      ),
    );
  }

  Widget _buildMicButton(_Speaker spk) {
    final isThisSpeaker = _activeSpk == spk;
    final isActive      = isThisSpeaker && _isListening;
    final accent        = _accentFor(spk);
    final lang          = spk == _Speaker.personA ? _langA : _langB;

    String label;
    IconData icon;
    if (isActive) {
      label = '🎙️ Listening...';
      icon  = Icons.mic_rounded;
    } else if (isThisSpeaker && _isTranslating) {
      label = 'â³ Translating...';
      icon  = Icons.translate_rounded;
    } else if (isThisSpeaker && _isSpeaking) {
      label = '🔊 Speaking...';
      icon  = Icons.volume_up_rounded;
    } else {
      label = '🎤 Speak ${lang.label}';
      icon  = Icons.mic_none_rounded;
    }

    final isDisabled = _isBusy && _activeSpk != spk;

    return GestureDetector(
      onTap: isDisabled ? null : () => _onSpeakTapped(spk),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [accent, accent.withAlpha(191)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive ? null : (isDisabled ? const Color(0xFFF1F5F9) : accent.withAlpha(26)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDisabled ? Colors.transparent : accent.withAlpha(isActive ? 255 : 102),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: isActive ? Colors.white : (isDisabled ? Colors.grey.shade400 : accent),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : (isDisabled ? Colors.grey.shade400 : accent),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

