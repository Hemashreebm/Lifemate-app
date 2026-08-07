import 'package:flutter/material.dart';
import '../services/communication_platform_service.dart';
import '../services/tts_service.dart';

/// Screen for 1. Daily English Challenge (5 words, audio, meaning, example, quiz & streak)
class DailyEnglishChallengeScreen extends StatefulWidget {
  const DailyEnglishChallengeScreen({super.key});

  @override
  State<DailyEnglishChallengeScreen> createState() => _DailyEnglishChallengeScreenState();
}

class _DailyEnglishChallengeScreenState extends State<DailyEnglishChallengeScreen> {
  static const _purpleAccent = Color(0xFF7C3AED);
  static const _bgLight = Color(0xFFF8FAFC);

  int _currentIndex = 0;
  bool _quizMode = false;
  int _selectedQuizOption = -1;
  bool _quizSubmitted = false;
  int _quizScore = 0;

  @override
  Widget build(BuildContext context) {
    final words = CommunicationPlatformService.instance.getDailyChallengeWords();
    final word = words[_currentIndex];

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text('Daily English Challenge', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Word ${_currentIndex + 1} of ${words.length}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded, color: Color(0xFFD97706), size: 16),
                      SizedBox(width: 4),
                      Text('7-Day Streak', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF92400E))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_currentIndex + 1) / words.length,
              backgroundColor: const Color(0xFFE2E8F0),
              color: _purpleAccent,
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
            ),

            const SizedBox(height: 24),

            !_quizMode
                ? _buildWordCard(word)
                : _buildQuizCard(word),

            const SizedBox(height: 24),

            // Bottom Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentIndex > 0 && !_quizMode)
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _currentIndex--),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Previous'),
                  )
                else
                  const SizedBox.shrink(),
                ElevatedButton.icon(
                  onPressed: () {
                    if (!_quizMode) {
                      setState(() {
                        _quizMode = true;
                        _selectedQuizOption = -1;
                        _quizSubmitted = false;
                      });
                    } else {
                      if (_currentIndex < words.length - 1) {
                        setState(() {
                          _currentIndex++;
                          _quizMode = false;
                        });
                      } else {
                        _showChallengeCompleteDialog();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purpleAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: Icon(_quizMode ? Icons.arrow_forward_rounded : Icons.quiz_rounded, size: 18),
                  label: Text(_quizMode ? (_currentIndex == words.length - 1 ? 'Finish Challenge' : 'Next Word') : 'Take Practice Quiz'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordCard(VocabularyWord word) {
    final isFav = CommunicationPlatformService.instance.favoriteWords.contains(word.word);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _purpleAccent.withAlpha(25), borderRadius: BorderRadius.circular(8)),
                child: Text(word.category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _purpleAccent)),
              ),
              IconButton(
                icon: Icon(isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: _purpleAccent),
                onPressed: () async {
                  await CommunicationPlatformService.instance.toggleFavoriteWord(word.word);
                  setState(() {});
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(word.word, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, color: _purpleAccent, size: 28),
                onPressed: () => TtsService.instance.speak(word.word, language: 'en-US'),
                tooltip: 'Pronounce Word',
              ),
            ],
          ),
          Text('${word.phonetic} • ${word.partOfSpeech}', style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
          const SizedBox(height: 16),
          const Text('Meaning', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
          const SizedBox(height: 4),
          Text(word.meaning, style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B), height: 1.4)),
          const SizedBox(height: 16),
          const Text('Example Sentence', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
            child: Text('"${word.example}"', style: const TextStyle(fontSize: 14, color: Color(0xFF475569), fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(VocabularyWord word) {
    final options = [
      word.meaning,
      'Extremely quiet or reserved in public spaces.',
      'Occurring without any previous planning or preparation.',
      'Relating to ancient architecture or historical buildings.',
    ]..shuffle();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline_rounded, color: _purpleAccent, size: 22),
              const SizedBox(width: 8),
              Text('Quiz: What is the meaning of "${word.word}"?', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(options.length, (idx) {
            final opt = options[idx];
            final isSelected = _selectedQuizOption == idx;
            final isCorrect = opt == word.meaning;

            Color bgColor = Colors.white;
            Color borderColor = const Color(0xFFE2E8F0);
            if (_quizSubmitted) {
              if (isCorrect) {
                bgColor = const Color(0xFFD1FAE5);
                borderColor = const Color(0xFF10B981);
              } else if (isSelected && !isCorrect) {
                bgColor = const Color(0xFFFEE2E2);
                borderColor = const Color(0xFFEF4444);
              }
            } else if (isSelected) {
              bgColor = _purpleAccent.withAlpha(20);
              borderColor = _purpleAccent;
            }

            return GestureDetector(
              onTap: _quizSubmitted ? null : () => setState(() => _selectedQuizOption = idx),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor, width: isSelected ? 2 : 1)),
                child: Text(opt, style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B))),
              ),
            );
          }),
          const SizedBox(height: 12),
          if (!_quizSubmitted && _selectedQuizOption != -1)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _quizSubmitted = true;
                  if (options[_selectedQuizOption] == word.meaning) {
                    _quizScore += 20;
                  }
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: _purpleAccent, foregroundColor: Colors.white),
              child: const Text('Submit Answer'),
            ),
        ],
      ),
    );
  }

  void _showChallengeCompleteDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: Color(0xFFF59E0B)),
            SizedBox(width: 8),
            Text('Challenge Complete! 🎉'),
          ],
        ),
        content: Text('Awesome job! You mastered 5 new vocabulary words today and earned +100 XP!\n\nDaily Streak: 7 Days 🔥'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }
}
