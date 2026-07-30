import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/translation_service.dart';
import '../services/tts_service.dart';
import 'conversation_mode_screen.dart';

/// Screen for Phase 1 On-Device Real-Time Translation & TTS.
class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final _transSvc = TranslationService.instance;
  final _inputCtrl = TextEditingController();
  final _speech = stt.SpeechToText();
  final _tts = FlutterTts();

  AppLanguage _fromLang = AppLanguage.english;
  AppLanguage _toLang = AppLanguage.telugu;

  String _translatedText = '';
  bool _isTranslating = false;
  bool _isDownloadingModel = false;
  String _downloadStatusText = '';

  // Speech-to-text state
  bool _speechInitialized = false;
  bool _isListening = false;
  String _speechStatus = '';

  // TTS state & optimizations
  bool _isPreparingTts = false;
  bool _isPlayingTts = false;
  final Set<String> _verifiedTtsLocales = {}; // Cache checked TTS voices

  @override
  void initState() {
    super.initState();
    _initSpeechAndTts();
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _inputCtrl.dispose();
    super.dispose();
  }

  Future<void> _initSpeechAndTts() async {
    try {
      _speechInitialized = await _speech.initialize(
        onError: (err) {
          if (mounted) {
            setState(() {
              _isListening = false;
              _speechStatus = 'Speech error: ${err.errorMsg}';
            });
          }
        },
        onStatus: (status) {
          if (mounted) {
            if (status == 'done' || status == 'notListening') {
              setState(() => _isListening = false);
            }
          }
        },
      );
    } catch (e) {
      debugPrint('[TranslationScreen] Speech init error: $e');
    }

    try {
      await TtsService.instance.init();
    } catch (e) {
      debugPrint('[TranslationScreen] TtsService init error: $e');
    }
  }

  // ── Language Swapping ─────────────────────────────────────────────────────

  void _swapLanguages() {
    _stopTts();
    setState(() {
      final temp = _fromLang;
      _fromLang = _toLang;
      _toLang = temp;
      _translatedText = ''; // Clear stale translation
    });
  }

  // ── Speech Recognition 🎤 ─────────────────────────────────────────────────

  Future<void> _toggleListening() async {
    _stopTts();
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    if (!_speechInitialized) {
      final initOk = await _speech.initialize(
        onError: (err) {
          debugPrint('[TRANSLATION STT] error: ${err.errorMsg}');
        },
        onStatus: (status) {
          debugPrint('[TRANSLATION STT] status: $status');
          if (mounted && (status == 'done' || status == 'notListening')) {
            setState(() => _isListening = false);
          }
        },
      );
      if (!initOk) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Speech recognition is not available on this device.')),
          );
        }
        return;
      }
      _speechInitialized = true;
    }

    // Determine target STT localeId (using discovered locale or explicit fallback ID)
    final String fallbackLocaleId;
    switch (_fromLang) {
      case AppLanguage.english:
        fallbackLocaleId = 'en_US';
        break;
      case AppLanguage.telugu:
        fallbackLocaleId = 'te_IN';
        break;
      case AppLanguage.hindi:
        fallbackLocaleId = 'hi_IN';
        break;
      case AppLanguage.tamil:
        fallbackLocaleId = 'ta_IN';
        break;
      case AppLanguage.kannada:
        fallbackLocaleId = 'kn_IN';
        break;
    }

    stt.LocaleName? matched;
    try {
      final locales = await _speech.locales();
      final prefix = _fromLang.code.toLowerCase();
      final matches = locales.where((l) {
        final id = l.localeId.toLowerCase().replaceAll('_', '-');
        return id == prefix || id.startsWith('$prefix-') || id.contains('-$prefix') || id.contains(prefix);
      }).toList();
      if (matches.isNotEmpty) {
        matched = matches.firstWhere(
          (l) => l.localeId.toLowerCase().contains('in'),
          orElse: () => matches.first,
        );
      }
    } catch (e) {
      debugPrint('[TRANSLATION STT] locales lookup error: $e');
    }

    final targetLocaleId = matched?.localeId ?? fallbackLocaleId;

    debugPrint('[TRANSLATION STT] Requested language: ${_fromLang.label}');
    debugPrint('[TRANSLATION STT] Requested locale: $targetLocaleId');
    debugPrint('[TRANSLATION STT] listen() called for ${_fromLang.label} with localeId: $targetLocaleId');

    setState(() {
      _isListening = true;
      _speechStatus = 'Listening in ${_fromLang.label}...';
    });

    await _speech.listen(
      localeId: targetLocaleId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        debugPrint('[TRANSLATION STT] result: "${result.recognizedWords}" (final: ${result.finalResult})');
        if (mounted) {
          setState(() {
            _inputCtrl.text = result.recognizedWords;
          });
        }
      },
    );
  }

  // ── Model Check & Translation ──────────────────────────────────────────────

  Future<void> _performTranslation() async {
    _stopTts();
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or speak text to translate.')),
      );
      return;
    }

    if (_fromLang == _toLang) {
      setState(() => _translatedText = text);
      return;
    }

    // 1. Check Source Language Model
    final fromDownloaded = await _transSvc.isModelDownloaded(_fromLang);
    if (!fromDownloaded) {
      final shouldDownload = await _promptModelDownload(_fromLang);
      if (shouldDownload != true) return;

      setState(() {
        _isDownloadingModel = true;
        _downloadStatusText = 'Downloading ${_fromLang.label} model...';
      });

      final success = await _transSvc.downloadModel(_fromLang);
      if (mounted) setState(() => _isDownloadingModel = false);

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not download ${_fromLang.label} translation model.'),
              backgroundColor: const Color(0xFFEF4444),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _performTranslation,
              ),
            ),
          );
        }
        return;
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_fromLang.label} model downloaded.')),
        );
      }
    }

    // 2. Check Target Language Model
    final toDownloaded = await _transSvc.isModelDownloaded(_toLang);
    if (!toDownloaded) {
      final shouldDownload = await _promptModelDownload(_toLang);
      if (shouldDownload != true) return;

      setState(() {
        _isDownloadingModel = true;
        _downloadStatusText = 'Downloading ${_toLang.label} model...';
      });

      final success = await _transSvc.downloadModel(_toLang);
      if (mounted) setState(() => _isDownloadingModel = false);

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not download ${_toLang.label} translation model.'),
              backgroundColor: const Color(0xFFEF4444),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _performTranslation,
              ),
            ),
          );
        }
        return;
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_toLang.label} model downloaded.')),
        );
      }
    }

    // 3. Perform On-Device Translation
    setState(() => _isTranslating = true);
    try {
      final result = await _transSvc.translate(
        text: text,
        source: _fromLang,
        target: _toLang,
      );
      if (mounted) {
        setState(() {
          _translatedText = result;
          _translationHistory.insert(0, {
            'from': _fromLang.label,
            'to': _toLang.label,
            'source': text,
            'target': result,
          });
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Translation failed: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTranslating = false;
          _isDownloadingModel = false;
        });
      }
    }
  }

  Future<bool?> _promptModelDownload(AppLanguage lang) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Download ${lang.label} Model?'),
        content: Text(
          '${lang.label} translation model is required (~30MB). It will be downloaded once and will work completely offline.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  // ── Text-to-Speech (TTS) 🔊 ────────────────────────────────────────────────

  Future<void> _stopTts() async {
    await TtsService.instance.stop();
    if (mounted) {
      setState(() {
        _isPreparingTts = false;
        _isPlayingTts = false;
      });
    }
  }

  Future<void> _toggleTts() async {
    if (_translatedText.trim().isEmpty) return;

    if (_isPlayingTts || _isPreparingTts) {
      await _stopTts();
      return;
    }

    // Stop any previous playback
    await _stopTts();

    setState(() {
      _isPreparingTts = true;
      _isPlayingTts = true;
    });

    final ok = await TtsService.instance.speak(
      text: _translatedText,
      targetLang: _toLang,
    );

    if (mounted) {
      setState(() {
        _isPreparingTts = false;
        _isPlayingTts = false;
      });
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_toLang.label} spoken playback is not installed on this phone.'),
            backgroundColor: const Color(0xFFE11D48),
          ),
        );
      }
    }
  }

  // ── Copy & Clear 📋 ───────────────────────────────────────────────────────

  void _copyTranslation() {
    if (_translatedText.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _translatedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Translation copied.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearAll() {
    _stopTts();
    setState(() {
      _inputCtrl.clear();
      _translatedText = '';
    });
  }

  final List<Map<String, String>> _translationHistory = [];
  final List<Map<String, String>> _favoritePhrases = [];

  void _showHistoryAndFavorites() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(height: 12),
            const TabBar(
              labelColor: Color(0xFF6C5CE7),
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(icon: Icon(Icons.history_rounded), text: 'History'),
                Tab(icon: Icon(Icons.star_rounded), text: 'Favorites'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _translationHistory.isEmpty
                      ? const Center(child: Text('No translation history yet.'))
                      : ListView.builder(
                          itemCount: _translationHistory.length,
                          itemBuilder: (ctx, i) {
                            final item = _translationHistory[i];
                            final isFav = _favoritePhrases.contains(item);
                            return ListTile(
                              title: Text(item['source'] ?? ''),
                              subtitle: Text('${item['from']} → ${item['to']}: ${item['target']}'),
                              trailing: IconButton(
                                icon: Icon(
                                  isFav ? Icons.star_rounded : Icons.star_border_rounded,
                                  color: isFav ? Colors.amber : Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (isFav) {
                                      _favoritePhrases.remove(item);
                                    } else {
                                      _favoritePhrases.add(item);
                                    }
                                  });
                                  Navigator.pop(ctx);
                                },
                              ),
                            );
                          },
                        ),
                  _favoritePhrases.isEmpty
                      ? const Center(child: Text('No favorite phrases saved.'))
                      : ListView.builder(
                          itemCount: _favoritePhrases.length,
                          itemBuilder: (ctx, i) {
                            final item = _favoritePhrases[i];
                            return ListTile(
                              title: Text(item['source'] ?? ''),
                              subtitle: Text('${item['from']} → ${item['to']}: ${item['target']}'),
                              trailing: const Icon(Icons.star_rounded, color: Colors.amber),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
      appBar: AppBar(
        title: const Text('Real-Time Translation', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Translation History & Favorites',
            onPressed: _showHistoryAndFavorites,
          ),
          IconButton(
            icon: const Icon(Icons.volume_up_outlined),
            tooltip: 'Run Direct TTS Diagnostic Test',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Testing direct TTS for all languages... Check logcat / debug console.'),
                  duration: Duration(seconds: 3),
                ),
              );
              final results = await TtsService.instance.runDirectDiagnosticTest();
              if (mounted) {
                final summary = results.entries
                    .map((e) => '${e.key.label}: ${e.value ? "PASS" : "FAIL"}')
                    .join(', ');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Direct TTS Test Results: $summary'),
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Language Selectors & Swap ⇄ ─────────────────────────────
            _buildLanguageBar(),

            const SizedBox(height: 16),

            // ── 2. Download Status Banner (If downloading) ─────────────────
            if (_isDownloadingModel) _buildDownloadStatusBanner(),

            // ── 3. Input Card (Typed or Speech) ────────────────────────────
            _buildInputCard(),

            const SizedBox(height: 20),

            // ── 4. Translation Output Card ─────────────────────────────────
            _buildTranslationOutputCard(),

            const SizedBox(height: 24),

            // ── 5. Conversation Mode Banner Card ───────────────────────────
            _buildConversationModeCard(),

            const SizedBox(height: 20),

            // ── 6. Privacy Banner ──────────────────────────────────────────
            _buildPrivacyCard(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Conversation Mode Card ──────────────────────────────────────────────────

  Widget _buildConversationModeCard() {
    return GestureDetector(
      onTap: () {
        _stopTts();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ConversationModeScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x338B5CF6),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                shape: BoxShape.circle,
              ),
              child: const Text('🗣', style: TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Conversation Mode',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Talk naturally back-and-forth with someone speaking another language.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFEDE9FE),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ── UI Builders ───────────────────────────────────────────────────────────

  Widget _buildLanguageBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // From Language Dropdown
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<AppLanguage>(
                value: _fromLang,
                isExpanded: true,
                style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E), fontSize: 14),
                items: AppLanguage.values.map((lang) {
                  return DropdownMenuItem(
                    value: lang,
                    child: Text(lang.label),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    _stopTts();
                    setState(() => _fromLang = val);
                  }
                },
              ),
            ),
          ),

          // Swap Button ⇄
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF8B5CF6), size: 26),
            onPressed: _swapLanguages,
            tooltip: 'Swap Languages',
          ),

          // To Language Dropdown
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<AppLanguage>(
                value: _toLang,
                isExpanded: true,
                style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF8B5CF6), fontSize: 14),
                items: AppLanguage.values.map((lang) {
                  return DropdownMenuItem(
                    value: lang,
                    child: Text(lang.label),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    _stopTts();
                    setState(() => _toLang = val);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadStatusBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _downloadStatusText.isNotEmpty ? _downloadStatusText : 'Downloading translation model...',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1D4ED8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'INPUT (${_fromLang.label})',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
              ),
              const Spacer(),
              if (_isListening)
                const Text(
                  '🎤 Listening...',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFEC4899)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _inputCtrl,
            maxLines: 4,
            style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A2E)),
            decoration: InputDecoration(
              hintText: 'Type or tap microphone to speak in ${_fromLang.label}...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),
          Row(
            children: [
              // 🎤 Speak Button
              IconButton(
                onPressed: _toggleListening,
                icon: Icon(
                  _isListening ? Icons.stop_circle : Icons.mic_rounded,
                  color: _isListening ? const Color(0xFFEC4899) : const Color(0xFF8B5CF6),
                  size: 26,
                ),
                tooltip: _isListening ? 'Stop Listening' : 'Speak',
              ),
              const SizedBox(width: 8),

              // Clear Text Button
              TextButton(
                onPressed: _clearAll,
                child: const Text('Clear', style: TextStyle(color: Color(0xFF94A3B8))),
              ),
              const Spacer(),

              // Translate Button
              FilledButton.icon(
                onPressed: (_isTranslating || _isDownloadingModel) ? null : _performTranslation,
                icon: _isTranslating || _isDownloadingModel
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.translate_rounded, size: 18),
                label: Text(_isDownloadingModel ? 'Downloading...' : 'Translate'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationOutputCard() {
    String getButtonLabel() {
      if (_isPlayingTts) return '⏹ Stop';
      if (_isPreparingTts) return 'Preparing audio...';
      return '🔊 Listen';
    }

    IconData getButtonIcon() {
      if (_isPlayingTts) return Icons.stop_rounded;
      if (_isPreparingTts) return Icons.hourglass_top_rounded;
      return Icons.volume_up_rounded;
    }

    Color getButtonColor() {
      if (_isPlayingTts) return const Color(0xFFEF4444);
      if (_isPreparingTts) return const Color(0xFFF59E0B);
      return const Color(0xFF10B981);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRANSLATION (${_toLang.label})',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8B5CF6)),
          ),
          const SizedBox(height: 10),
          SelectableText(
            _translatedText.isNotEmpty ? _translatedText : '(Translation will appear here)',
            style: TextStyle(
              fontSize: 17,
              fontWeight: _translatedText.isNotEmpty ? FontWeight.w700 : FontWeight.w400,
              color: _translatedText.isNotEmpty ? const Color(0xFF1A1A2E) : const Color(0xFF94A3B8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            children: [
              // 📋 Copy Button
              OutlinedButton.icon(
                onPressed: _translatedText.isNotEmpty ? _copyTranslation : null,
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8B5CF6),
                  side: const BorderSide(color: Color(0xFF8B5CF6)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 12),

              // 🔊 Listen / ⏹ Stop Speaker Button (Prominent & Large for Accessibility)
              Expanded(
                child: FilledButton.icon(
                  onPressed: _translatedText.isNotEmpty ? _toggleTts : null,
                  icon: _isPreparingTts
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(getButtonIcon(), size: 20),
                  label: Text(
                    getButtonLabel(),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: getButtonColor(),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: const [
          Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy & Security',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1A1A2E)),
                ),
                SizedBox(height: 2),
                Text(
                  'Translation runs on your device after language models are downloaded. No cloud servers, no continuous background listening.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
