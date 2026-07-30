import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/translation_service.dart';
import '../services/tts_service.dart';

/// Spoken English Practice Screen (Phase 1)
///
/// Features:
/// 1. Simple, beginner-friendly instructions.
/// 2. Large Start Speaking / Stop microphone button.
/// 3. Direct speech.listen(localeId: 'en_US') without speech.locales() blocking check.
/// 4. Recognized speech display card with ðŸ”Š Listen, ðŸ”„ Try Again, and ðŸ—‘ Clear buttons.
class SpokenEnglishPracticeScreen extends StatefulWidget {
  const SpokenEnglishPracticeScreen({super.key});

  @override
  State<SpokenEnglishPracticeScreen> createState() =>
      _SpokenEnglishPracticeScreenState();
}

class _SpokenEnglishPracticeScreenState
    extends State<SpokenEnglishPracticeScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechInitialized = false;
  bool _isListening = false;
  bool _isSpeakingTts = false;
  String _recognizedText = '';
  String _statusMessage = '';

  static const _purpleAccent = Color(0xFF7C3AED);

  @override
  void dispose() {
    _speech.stop();
    TtsService.instance.stop();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    // If TTS is playing, stop it first
    await TtsService.instance.stop();
    if (mounted) setState(() => _isSpeakingTts = false);

    if (_isListening) {
      await _speech.stop();
      if (mounted) {
        setState(() {
          _isListening = false;
          _statusMessage = '';
        });
      }
      return;
    }

    // Initialize speech if not initialized
    if (!_speechInitialized) {
      final ok = await _speech.initialize(
        onError: (err) {
          debugPrint('[PRACTICE STT] ERROR: ${err.errorMsg}');
          if (mounted) {
            setState(() {
              _isListening = false;
              _statusMessage = 'Speech error: ${err.errorMsg}';
            });
          }
        },
        onStatus: (status) {
          debugPrint('[PRACTICE STT] STATUS: $status');
          if (mounted && (status == 'done' || status == 'notListening')) {
            setState(() => _isListening = false);
          }
        },
      );

      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone or Speech Recognition service not ready.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      _speechInitialized = true;
    }

    // Directly attempt speech.listen(localeId: 'en_US')
    debugPrint('[PRACTICE STT] CALLING speech.listen(localeId: "en_US")');

    setState(() {
      _isListening = true;
      _statusMessage = 'Listening... Speak now!';
    });

    await _speech.listen(
      localeId: 'en_US',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        debugPrint(
            '[PRACTICE STT] RESULT: "${result.recognizedWords}" (final: ${result.finalResult})');
        if (mounted) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });
        }
      },
    );
  }

  Future<void> _listenToSentence() async {
    if (_recognizedText.trim().isEmpty) return;

    if (_isSpeakingTts) {
      await TtsService.instance.stop();
      if (mounted) setState(() => _isSpeakingTts = false);
      return;
    }

    setState(() => _isSpeakingTts = true);

    final ok = await TtsService.instance.speak(
      text: _recognizedText,
      targetLang: AppLanguage.english,
    );

    if (mounted) {
      setState(() => _isSpeakingTts = false);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('English spoken playback is not available on this device.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _clearText() {
    _speech.stop();
    TtsService.instance.stop();
    setState(() {
      _recognizedText = '';
      _isListening = false;
      _isSpeakingTts = false;
      _statusMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Spoken English Practice',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // â”€â”€ Instruction Banner â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildInstructionCard(),

            const SizedBox(height: 24),

            // â”€â”€ Large Mic Button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildMicButton(),

            const SizedBox(height: 12),

            // Status message
            if (_statusMessage.isNotEmpty)
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _isListening ? _purpleAccent : const Color(0xFF64748B),
                ),
              ),

            const SizedBox(height: 28),

            // â”€â”€ Recognized Speech Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildResultCard(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFDDD6FE),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline_rounded, color: _purpleAccent, size: 24),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Speak naturally in English.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Lifemate will show what it heard.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _toggleListening,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          gradient: _isListening
              ? const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [_purpleAccent, Color(0xFF6D28D9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: (_isListening ? const Color(0xFFEF4444) : _purpleAccent)
                  .withAlpha(76),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isListening ? Icons.stop_rounded : Icons.mic_rounded,
              size: 36,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              _isListening ? 'â¹ Stop' : 'ðŸŽ¤ Start Speaking',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final hasText = _recognizedText.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: hasText ? _purpleAccent.withAlpha(76) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'You said:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.2,
            ),
          ),

          const SizedBox(height: 12),

          // Recognized Text Display
          Text(
            hasText
                ? '"$_recognizedText"'
                : 'Tap "Start Speaking" and speak an English sentence.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: hasText ? FontWeight.w700 : FontWeight.w500,
              color: hasText ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
              height: 1.4,
              fontStyle: hasText ? FontStyle.normal : FontStyle.italic,
            ),
          ),

          if (hasText) ...[
            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 16),

            // Action Buttons Row
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                // ðŸ”Š Listen Button
                ElevatedButton.icon(
                  onPressed: _listenToSentence,
                  icon: Icon(
                    _isSpeakingTts ? Icons.stop_rounded : Icons.volume_up_rounded,
                    size: 18,
                  ),
                  label: Text(_isSpeakingTts ? 'â¹ Stop' : 'ðŸ”Š Listen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purpleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),

                // ðŸ”„ Try Again Button
                OutlinedButton.icon(
                  onPressed: () {
                    _clearText();
                    _toggleListening();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('ðŸ”„ Try Again'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _purpleAccent,
                    side: const BorderSide(color: _purpleAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),

                // ðŸ—‘ Clear Button
                IconButton(
                  onPressed: _clearText,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: const Color(0xFFEF4444),
                  tooltip: 'Clear text',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

