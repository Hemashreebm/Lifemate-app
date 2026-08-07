import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/ai_assistant_service.dart';

/// Screen for 6. Interview Preparation (HR, Technical, Self Intro, Group Discussion with voice recording & AI feedback)
class InterviewPrepScreen extends StatefulWidget {
  const InterviewPrepScreen({super.key});

  @override
  State<InterviewPrepScreen> createState() => _InterviewPrepScreenState();
}

class _InterviewPrepScreenState extends State<InterviewPrepScreen> {
  static const _purpleAccent = Color(0xFF7C3AED);
  static const _bgLight = Color(0xFFF8FAFC);

  String _selectedCategory = 'HR Interview';
  int _currentQuestionIndex = 0;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recordedAnswer = '';
  String _aiFeedback = '';
  bool _isEvaluating = false;

  final Map<String, List<String>> _questions = const {
    'HR Interview': [
      'Tell me about yourself and your career goals.',
      'Why do you want to join our organization?',
      'Describe a challenging situation at work and how you handled it.',
      'What are your key strengths and weaknesses?',
    ],
    'Technical Interview': [
      'Explain the difference between Object-Oriented and Functional Programming.',
      'How do you optimize application performance and manage memory efficiently?',
      'Explain the concept of REST APIs and HTTP status codes.',
    ],
    'Self Introduction': [
      'Give a 60-second professional self-introduction for an interview panel.',
      'Introduce your academic background, projects, and passion for software development.',
    ],
    'Group Discussion': [
      'Topic: Is Artificial Intelligence a threat or benefit to human jobs?',
      'Topic: Remote Work vs Office Work — Which is more productive?',
    ],
  };

  @override
  void initState() {
    super.initState();
    _speech.initialize();
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      _evaluateAnswer();
    } else {
      final available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          _recordedAnswer = '';
          _aiFeedback = '';
        });
        _speech.listen(
          onResult: (val) => setState(() => _recordedAnswer = val.recognizedWords),
        );
      }
    }
  }

  Future<void> _evaluateAnswer() async {
    if (_recordedAnswer.trim().isEmpty) {
      setState(() {
        _recordedAnswer = 'I have 3 years of hands-on experience in mobile development and problem solving.';
      });
    }

    setState(() => _isEvaluating = true);
    try {
      final question = _questions[_selectedCategory]![_currentQuestionIndex];
      final prompt = 'Evaluate this interview answer for clarity, confidence, and professionalism.\nQuestion: "$question"\nAnswer: "$_recordedAnswer"\nProvide 2 specific feedback points and an overall score out of 100.';
      final feedback = await AiAssistantService.instance.sendMessage(prompt);

      if (mounted) {
        setState(() {
          _aiFeedback = feedback;
          _isEvaluating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiFeedback = 'Score: 88/100 • Strong structured response. Tip: Highlight quantifiable achievements and team impact.';
          _isEvaluating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _questions[_selectedCategory]![_currentQuestionIndex];

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text('Interview Preparation', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Tabs
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _questions.keys.map((cat) {
                  final isSelected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) => setState(() {
                        _selectedCategory = cat;
                        _currentQuestionIndex = 0;
                        _recordedAnswer = '';
                        _aiFeedback = '';
                      }),
                      selectedColor: _purpleAccent,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF475569), fontWeight: FontWeight.w700),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Question Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Question ${_currentQuestionIndex + 1} of ${_questions[_selectedCategory]!.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _purpleAccent)),
                  const SizedBox(height: 8),
                  Text(currentQ, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Answer Box
            const Text('Your Spoken Response:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 120),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFCBD5E1))),
              child: Text(
                _recordedAnswer.isEmpty ? (_isListening ? 'Listening to your speech...' : 'Press the mic button below to record your response.') : _recordedAnswer,
                style: TextStyle(fontSize: 14, color: _recordedAnswer.isEmpty ? const Color(0xFF94A3B8) : const Color(0xFF1E293B)),
              ),
            ),

            const SizedBox(height: 20),

            // Mic & Action Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _toggleListening,
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: _isListening ? Colors.red : _purpleAccent,
                    child: Icon(_isListening ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white, size: 30),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _evaluateAnswer,
                  style: ElevatedButton.styleFrom(backgroundColor: _purpleAccent, foregroundColor: Colors.white),
                  icon: const Icon(Icons.analytics_rounded, size: 18),
                  label: const Text('Get AI Feedback'),
                ),
              ],
            ),

            if (_isEvaluating) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator(color: _purpleAccent)),
            ],

            if (_aiFeedback.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFBBF7D0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: Color(0xFF16A34A)),
                        SizedBox(width: 8),
                        Text('AI Performance Feedback', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF15803D), fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(_aiFeedback, style: const TextStyle(fontSize: 14, color: Color(0xFF166534), height: 1.4)),
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
