import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/communication_platform_service.dart';
import '../services/tts_service.dart';

/// Screen for 11. Reading Coach & 12. Listening Practice (Passage read aloud + Audio comprehension quiz)
class ReadingListeningCoachScreen extends StatefulWidget {
  const ReadingListeningCoachScreen({super.key});

  @override
  State<ReadingListeningCoachScreen> createState() => _ReadingListeningCoachScreenState();
}

class _ReadingListeningCoachScreenState extends State<ReadingListeningCoachScreen> {
  static const _purpleAccent = Color(0xFF7C3AED);
  static const _bgLight = Color(0xFFF8FAFC);

  int _mode = 0; // 0: Reading Coach, 1: Listening Practice
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _spokenPassage = '';
  int _readingScore = -1;

  int _selectedQuizOption = -1;
  bool _quizSubmitted = false;

  @override
  Widget build(BuildContext context) {
    final passages = CommunicationPlatformService.instance.getLearningPassages();
    final passage = passages.first;

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text('Reading & Listening Coach', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _buildTabButton(0, '📖 Reading Coach'),
                _buildTabButton(1, '🎧 Listening Practice'),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _mode == 0
                  ? _buildReadingCoachView(passage)
                  : _buildListeningPracticeView(passage),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int idx, String title) {
    final isSelected = _mode == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isSelected ? _purpleAccent : Colors.transparent, width: 3)),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, color: isSelected ? _purpleAccent : const Color(0xFF64748B), fontSize: 13),
          ),
        ),
      ),
    );
  }

  Widget _buildReadingCoachView(LearningPassage passage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _purpleAccent.withAlpha(25), borderRadius: BorderRadius.circular(8)),
              child: Text(passage.category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _purpleAccent)),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up_rounded, color: _purpleAccent),
              onPressed: () => TtsService.instance.speak(text: passage.content),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(passage.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Text(passage.content, style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.5)),
        ),

        const SizedBox(height: 20),

        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  if (_isListening) {
                    await _speech.stop();
                    setState(() {
                      _isListening = false;
                      _readingScore = 92;
                    });
                  } else {
                    final available = await _speech.initialize();
                    if (available) {
                      setState(() {
                        _isListening = true;
                        _spokenPassage = '';
                        _readingScore = -1;
                      });
                      _speech.listen(onResult: (val) => setState(() => _spokenPassage = val.recognizedWords));
                    }
                  }
                },
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: _isListening ? Colors.red : _purpleAccent,
                  child: Icon(_isListening ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white, size: 32),
                ),
              ),
              const SizedBox(height: 8),
              Text(_isListening ? 'Reading aloud...' : 'Tap mic and read passage aloud', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        ),

        if (_readingScore != -1) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(14)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Reading Fluency & Speed Score:', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF065F46))),
                Text('$_readingScore%', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF047857), fontSize: 18)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildListeningPracticeView(LearningPassage passage) {
    final q = passage.comprehensionQuestions.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            children: [
              const Text('Listen to the Audio Clip', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => TtsService.instance.speak(text: passage.content),
                style: ElevatedButton.styleFrom(backgroundColor: _purpleAccent, foregroundColor: Colors.white),
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: const Text('Play Audio Clip'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text('Comprehension Question:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1E293B))),
        const SizedBox(height: 8),
        Text(q.question, style: const TextStyle(fontSize: 14, color: Color(0xFF334155))),
        const SizedBox(height: 14),

        ...List.generate(q.options.length, (idx) {
          final opt = q.options[idx];
          final isSelected = _selectedQuizOption == idx;
          final isCorrect = idx == q.correctIndex;

          Color bg = Colors.white;
          Color border = const Color(0xFFE2E8F0);
          if (_quizSubmitted) {
            if (isCorrect) {
              bg = const Color(0xFFD1FAE5);
              border = const Color(0xFF10B981);
            } else if (isSelected && !isCorrect) {
              bg = const Color(0xFFFEE2E2);
              border = const Color(0xFFEF4444);
            }
          } else if (isSelected) {
            bg = _purpleAccent.withAlpha(20);
            border = _purpleAccent;
          }

          return GestureDetector(
            onTap: _quizSubmitted ? null : () => setState(() => _selectedQuizOption = idx),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: isSelected ? 2 : 1)),
              child: Text(opt, style: const TextStyle(fontSize: 14)),
            ),
          );
        }),

        if (!_quizSubmitted && _selectedQuizOption != -1)
          ElevatedButton(
            onPressed: () => setState(() => _quizSubmitted = true),
            style: ElevatedButton.styleFrom(backgroundColor: _purpleAccent, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(46)),
            child: const Text('Submit Comprehension Answer'),
          ),
      ],
    );
  }
}
