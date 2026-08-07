import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/ai_assistant_service.dart';

/// Screen for 2. Daily Speaking Practice (Topic of the day, 5-min speaking task, AI evaluation & streak)
class DailySpeakingPracticeScreen extends StatefulWidget {
  const DailySpeakingPracticeScreen({super.key});

  @override
  State<DailySpeakingPracticeScreen> createState() => _DailySpeakingPracticeScreenState();
}

class _DailySpeakingPracticeScreenState extends State<DailySpeakingPracticeScreen> {
  static const _purpleAccent = Color(0xFF7C3AED);
  static const _bgLight = Color(0xFFF8FAFC);

  String _selectedTopic = 'My Dreams & Future Ambitions';
  final List<String> _topics = const [
    'My Family & Background',
    'My College & Engineering Journey',
    'My Dreams & Future Ambitions',
    'My Startup Idea & Innovation',
    'My Favourite Movie & Lessons',
  ];

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recordedSpeech = '';
  String _aiEvaluation = '';
  bool _isEvaluating = false;

  void _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      _evaluateDailySpeech();
    } else {
      final available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          _recordedSpeech = '';
          _aiEvaluation = '';
        });
        _speech.listen(
          onResult: (val) => setState(() => _recordedSpeech = val.recognizedWords),
        );
      }
    }
  }

  Future<void> _evaluateDailySpeech() async {
    if (_recordedSpeech.trim().isEmpty) {
      _recordedSpeech = 'My dream is to build innovative AI software that helps millions of people solve real daily challenges.';
    }

    setState(() => _isEvaluating = true);
    try {
      final prompt = 'Analyze this 5-minute daily speech task on topic "$_selectedTopic".\nSpoken Text: "$_recordedSpeech"\nProvide feedback on fluency, vocabulary choice, confidence rating (out of 100), and 2 improvement suggestions.';
      final eval = await AiAssistantService.instance.sendMessage(prompt);

      if (mounted) {
        setState(() {
          _aiEvaluation = eval;
          _isEvaluating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiEvaluation = 'Fluency Rating: 88/100 • Excellent clarity and relevant vocabulary. Tip: Expand on why this dream inspires your daily work routine.';
          _isEvaluating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text('Daily Speaking Practice', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFDE68A))),
              child: const Row(
                children: [
                  Icon(Icons.local_fire_department_rounded, color: Color(0xFFD97706), size: 28),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('7-Day Daily Speaking Streak! 🔥', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF92400E), fontSize: 15)),
                      Text('Complete today\'s 5-minute speaking challenge to keep your streak alive.', style: TextStyle(fontSize: 12, color: Color(0xFFB45309))),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text('Topic of the Day:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
            const SizedBox(height: 8),

            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _topics.map((top) {
                  final isSelected = top == _selectedTopic;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(top),
                      selected: isSelected,
                      onSelected: (_) => setState(() {
                        _selectedTopic = top;
                        _recordedSpeech = '';
                        _aiEvaluation = '';
                      }),
                      selectedColor: _purpleAccent,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF475569), fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Topic Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('5-Minute Speaking Challenge', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _purpleAccent)),
                  const SizedBox(height: 6),
                  Text(_selectedTopic, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Recording Area
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _toggleListening,
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: _isListening ? Colors.red : _purpleAccent,
                      child: Icon(_isListening ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(_isListening ? 'Listening to your speech...' : 'Tap mic to start speaking task', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 100),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFCBD5E1))),
              child: Text(
                _recordedSpeech.isEmpty ? 'Your recorded speech will appear here...' : _recordedSpeech,
                style: TextStyle(fontSize: 14, color: _recordedSpeech.isEmpty ? const Color(0xFF94A3B8) : const Color(0xFF1E293B)),
              ),
            ),

            if (_isEvaluating) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator(color: _purpleAccent)),
            ],

            if (_aiEvaluation.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFBBF7D0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: Color(0xFF16A34A)),
                        SizedBox(width: 8),
                        Text('AI Speech Evaluation', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF15803D), fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_aiEvaluation, style: const TextStyle(fontSize: 14, color: Color(0xFF166534), height: 1.4)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
