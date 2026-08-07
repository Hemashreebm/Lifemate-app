import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/translation_service.dart';
import '../services/tts_service.dart';

/// Pronunciation Practice Screen (Phase 2)
///
/// Features:
/// 1. Built-in practice sentences with Previous / Next navigation.
/// 2.  Listen button to hear native/correct English TTS pronunciation.
/// 3.  Repeat Sentence button (speech_to_text with direct localeId: 'en_US').
/// 4. Normalized word-by-word text comparison & match percentage feedback.
/// 5. Visual word difference breakdown and simple, encouraging guidance.
class PronunciationPracticeScreen extends StatefulWidget {
  const PronunciationPracticeScreen({super.key});

  @override
  State<PronunciationPracticeScreen> createState() =>
      _PronunciationPracticeScreenState();
}

class _PronunciationPracticeScreenState
    extends State<PronunciationPracticeScreen> {
  static const List<String> _sentences = [
    'Good morning.',
    'How are you today?',
    'My name is Hema.',
    'Nice to meet you.',
    'Thank you very much.',
    'I am learning English.',
    'I would like some water.',
    'Can you help me?',
    'Where are you going?',
    'I want to improve my English.',
  ];

  int _currentIndex = 0;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechInitialized = false;
  bool _isListening = false;
  bool _isSpeakingTts = false;
  String _recognizedText = '';
  String _statusMessage = '';

  static const _purpleAccent = Color(0xFF7C3AED);

  String get _currentSentence => _sentences[_currentIndex];

  @override
  void dispose() {
    _speech.stop();
    TtsService.instance.stop();
    super.dispose();
  }

  void _nextSentence() {
    _stopAll();
    if (_currentIndex < _sentences.length - 1) {
      setState(() {
        _currentIndex++;
        _recognizedText = '';
        _statusMessage = '';
      });
    }
  }

  void _previousSentence() {
    _stopAll();
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _recognizedText = '';
        _statusMessage = '';
      });
    }
  }

  void _stopAll() {
    _speech.stop();
    TtsService.instance.stop();
    setState(() {
      _isListening = false;
      _isSpeakingTts = false;
    });
  }

  Future<void> _listenToCorrectPronunciation() async {
    if (_isSpeakingTts) {
      await TtsService.instance.stop();
      if (mounted) setState(() => _isSpeakingTts = false);
      return;
    }

    _speech.stop();
    setState(() {
      _isListening = false;
      _isSpeakingTts = true;
    });

    final ok = await TtsService.instance.speak(
      text: _currentSentence,
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

  Future<void> _startRepeating() async {
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

    if (!_speechInitialized) {
      final ok = await _speech.initialize(
        onError: (err) {
          debugPrint('[PRONUNCIATION STT] ERROR: ${err.errorMsg}');
          if (mounted) {
            setState(() {
              _isListening = false;
              _statusMessage = 'Speech error: ${err.errorMsg}';
            });
          }
        },
        onStatus: (status) {
          debugPrint('[PRONUNCIATION STT] STATUS: $status');
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

    debugPrint('[PRONUNCIATION STT] CALLING speech.listen(localeId: "en_US")');

    setState(() {
      _isListening = true;
      _recognizedText = '';
      _statusMessage = 'Listening... Speak now!';
    });

    await _speech.listen(
      localeId: 'en_US',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        debugPrint(
            '[PRONUNCIATION STT] RESULT: "${result.recognizedWords}" (final: ${result.finalResult})');
        if (mounted) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });
        }
      },
    );
  }

  //  Word Match Calculation & Comparison Logic 

  List<String> _normalizeToWords(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // remove punctuation
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  int _calculateWordMatchPercentage(String expected, String actual) {
    final expWords = _normalizeToWords(expected);
    final actWords = _normalizeToWords(actual);

    if (expWords.isEmpty) return 0;
    if (actWords.isEmpty) return 0;

    int matchCount = 0;
    List<String> remainingActual = List.from(actWords);

    for (final expW in expWords) {
      final index = remainingActual.indexOf(expW);
      if (index != -1) {
        matchCount++;
        remainingActual.removeAt(index);
      }
    }

    final percentage = (matchCount / expWords.length * 100).round();
    return percentage > 100 ? 100 : percentage;
  }

  @override
  Widget build(BuildContext context) {
    final hasRecognized = _recognizedText.trim().isNotEmpty;
    final matchPercentage =
        hasRecognized ? _calculateWordMatchPercentage(_currentSentence, _recognizedText) : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Pronunciation Practice',
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
            //  Top Header Instructions 
            _buildInstructionHeader(),

            const SizedBox(height: 20),

            //  Target Sentence Card & Nav 
            _buildSentenceCard(),

            const SizedBox(height: 20),

            //   Listen to Pronunciation Button 
            _buildListenButton(),

            const SizedBox(height: 16),

            //   Repeat Sentence Button 
            _buildRepeatButton(),

            if (_statusMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _isListening ? _purpleAccent : const Color(0xFF64748B),
                ),
              ),
            ],

            const SizedBox(height: 28),

            //  Recognized Speech & Feedback Card 
            if (hasRecognized) _buildFeedbackCard(matchPercentage),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.volume_up_outlined, color: _purpleAccent, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Listen to the sentence, then repeat it.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Index Badge & Nav Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _purpleAccent.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Sentence ${_currentIndex + 1} of ${_sentences.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _purpleAccent,
                  ),
                ),
              ),

              Row(
                children: [
                  IconButton(
                    onPressed: _currentIndex > 0 ? _previousSentence : null,
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                    color: _purpleAccent,
                    tooltip: 'Previous Sentence',
                  ),
                  IconButton(
                    onPressed:
                        _currentIndex < _sentences.length - 1 ? _nextSentence : null,
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                    color: _purpleAccent,
                    tooltip: 'Next Sentence',
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Main Sentence Display
          Text(
            '"$_currentSentence"',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              height: 1.35,
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildListenButton() {
    return OutlinedButton.icon(
      onPressed: _listenToCorrectPronunciation,
      icon: Icon(
        _isSpeakingTts ? Icons.stop_rounded : Icons.volume_up_rounded,
        size: 22,
      ),
      label: Text(
        _isSpeakingTts ? 'Stop Listening' : 'Listen to Pronunciation',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: _purpleAccent,
        side: const BorderSide(color: _purpleAccent, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }

  Widget _buildRepeatButton() {
    return ElevatedButton.icon(
      onPressed: _startRepeating,
      icon: Icon(
        _isListening ? Icons.stop_rounded : Icons.mic_rounded,
        size: 26,
      ),
      label: Text(
        _isListening ? 'Stop' : 'Repeat Sentence',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isListening ? const Color(0xFFEF4444) : _purpleAccent,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }

  Widget _buildFeedbackCard(int percentage) {
    String feedbackTitle;
    String feedbackSubtitle;
    Color statusColor;

    if (percentage >= 90) {
      feedbackTitle = 'Excellent match!';
      feedbackSubtitle = 'Great pronunciation! Move to the next sentence.';
      statusColor = const Color(0xFF10B981);
    } else if (percentage >= 70) {
      feedbackTitle = 'Good attempt!';
      feedbackSubtitle = 'Try once more for an even closer match.';
      statusColor = const Color(0xFFD97706);
    } else {
      feedbackTitle = 'Keep practicing';
      feedbackSubtitle = 'Listen again and repeat slowly.';
      statusColor = const Color(0xFFE11D48);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withAlpha(76), width: 1.5),
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  feedbackTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Word match: $percentage%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            feedbackSubtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 14),

          // Recognized Text
          const Text(
            'You said:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),

          _buildWordComparisonView(_currentSentence, _recognizedText),

          const SizedBox(height: 20),

          // Action Buttons
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              //  Listen Again
              ElevatedButton.icon(
                onPressed: _listenToCorrectPronunciation,
                icon: const Icon(Icons.volume_up_rounded, size: 16),
                label: const Text('Listen Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purpleAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),

              // Try Again
              OutlinedButton.icon(
                onPressed: _startRepeating,
                icon: const Icon(Icons.mic_rounded, size: 16),
                label: const Text('Try Again'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _purpleAccent,
                  side: const BorderSide(color: _purpleAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),

              // Â¡ Next Sentence
              if (_currentIndex < _sentences.length - 1)
                ElevatedButton.icon(
                  onPressed: _nextSentence,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text('Â¡ Next Sentence'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWordComparisonView(String expected, String actual) {
    final expWords = _normalizeToWords(expected);
    final actWords = _normalizeToWords(actual);

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: actWords.map((w) {
        final isMatched = expWords.contains(w);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isMatched
                ? const Color(0xFFDCFCE7)
                : const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isMatched
                  ? const Color(0xFF86EFAC)
                  : const Color(0xFFFCA5A5),
            ),
          ),
          child: Text(
            w,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isMatched
                  ? const Color(0xFF166534)
                  : const Color(0xFF991B1B),
            ),
          ),
        );
      }).toList(),
    );
  }
}

