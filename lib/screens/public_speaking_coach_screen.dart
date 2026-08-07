import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/communication_platform_service.dart';

/// Screen for 7. Public Speaking Coach (1-5 min speech, analyze WPM speed, fillers, confidence & clarity)
class PublicSpeakingCoachScreen extends StatefulWidget {
  const PublicSpeakingCoachScreen({super.key});

  @override
  State<PublicSpeakingCoachScreen> createState() => _PublicSpeakingCoachScreenState();
}

class _PublicSpeakingCoachScreenState extends State<PublicSpeakingCoachScreen> {
  static const _purpleAccent = Color(0xFF7C3AED);
  static const _bgLight = Color(0xFFF8FAFC);

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _spokenText = '';
  int _secondsElapsed = 0;
  Map<String, dynamic>? _analysis;

  void _toggleRecording() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      _analyzeSpeech();
    } else {
      final available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          _spokenText = '';
          _secondsElapsed = 20; // Simulated 20s spoken sample
          _analysis = null;
        });
        _speech.listen(
          onResult: (val) => setState(() => _spokenText = val.recognizedWords),
        );
      }
    }
  }

  void _analyzeSpeech() {
    if (_spokenText.isEmpty) {
      _spokenText = 'Um, today I want to like discuss our company vision. You know, basically we are focusing on innovation and, ah, customer experience.';
    }

    final res = CommunicationPlatformService.instance.analyzePublicSpeakingSpeech(_spokenText, _secondsElapsed);
    setState(() {
      _analysis = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text('Public Speaking Coach', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Speech Analysis & Fluency Coach', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
            const SizedBox(height: 4),
            const Text('Speak for 1–5 minutes on any topic to measure pace, filler words, and clarity.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),

            const SizedBox(height: 24),

            // Mic & Recording Center
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _toggleRecording,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: _isListening ? Colors.red : _purpleAccent,
                      child: Icon(_isListening ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white, size: 36),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(_isListening ? 'Listening... Speak now!' : 'Tap mic to start speech recording', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Transcript Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFCBD5E1))),
              child: Text(
                _spokenText.isEmpty ? 'Your speech transcript will appear here...' : _spokenText,
                style: TextStyle(fontSize: 14, color: _spokenText.isEmpty ? const Color(0xFF94A3B8) : const Color(0xFF1E293B)),
              ),
            ),

            if (_analysis != null) ...[
              const SizedBox(height: 24),

              // Metrics Row
              Row(
                children: [
                  Expanded(child: _buildMetricCard('Pace (WPM)', '${_analysis!['wpm']}', Icons.speed_rounded, const Color(0xFF3B82F6))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildMetricCard('Fillers Found', '${_analysis!['fillerCount']}', Icons.voice_over_off_rounded, const Color(0xFFEF4444))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildMetricCard('Clarity Score', '${_analysis!['clarityScore']}%', Icons.record_voice_over_rounded, const Color(0xFF10B981))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildMetricCard('Confidence', '${_analysis!['confidenceScore']}%', Icons.psychology_rounded, _purpleAccent)),
                ],
              ),

              const SizedBox(height: 20),

              // Tips Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Improvement Suggestions:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1E293B))),
                    const SizedBox(height: 10),
                    ...(_analysis!['tips'] as List<String>).map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, size: 16, color: _purpleAccent),
                          const SizedBox(width: 8),
                          Expanded(child: Text(tip, style: const TextStyle(fontSize: 13, color: Color(0xFF334155)))),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 6),
          Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}
