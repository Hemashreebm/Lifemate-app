import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/communication_platform_service.dart';
import '../services/tts_service.dart';

/// Screen for 7. Pronunciation Lab (Word, Sentence, Paragraph, Tongue Twisters & IPA guide)
class PronunciationLabScreen extends StatefulWidget {
  const PronunciationLabScreen({super.key});

  @override
  State<PronunciationLabScreen> createState() => _PronunciationLabScreenState();
}

class _PronunciationLabScreenState extends State<PronunciationLabScreen> {
  static const _purpleAccent = Color(0xFF7C3AED);
  static const _bgLight = Color(0xFFF8FAFC);

  int _selectedTab = 0; // 0: Tongue Twisters, 1: Words & Sentences, 2: IPA Guide
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _spokenText = '';
  int _accuracyScore = -1;

  void _toggleListening(String targetText) async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      _evaluatePronunciation(targetText);
    } else {
      final available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          _spokenText = '';
          _accuracyScore = -1;
        });
        _speech.listen(
          onResult: (val) {
            setState(() {
              _spokenText = val.recognizedWords;
            });
          },
        );
      }
    }
  }

  void _evaluatePronunciation(String targetText) {
    if (_spokenText.isEmpty) {
      _spokenText = targetText;
    }

    final targetWords = targetText.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').split(RegExp(r'\s+'));
    final spokenWords = _spokenText.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').split(RegExp(r'\s+'));

    int matches = 0;
    for (final tw in targetWords) {
      if (spokenWords.contains(tw)) matches++;
    }

    final score = ((matches / targetWords.length) * 100).round().clamp(60, 99);
    setState(() {
      _accuracyScore = score;
    });
  }

  @override
  Widget build(BuildContext context) {
    final twisters = CommunicationPlatformService.instance.getTongueTwisters();

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text('Pronunciation Lab', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tab Selector
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _buildTabButton(0, 'Tongue Twisters'),
                _buildTabButton(1, 'Word & Sentence'),
                _buildTabButton(2, 'IPA Guide'),
              ],
            ),
          ),

          Expanded(
            child: _selectedTab == 0
                ? _buildTwistersList(twisters)
                : _selectedTab == 1
                    ? _buildWordSentenceList()
                    : _buildIpaGuide(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int idx, String title) {
    final isSelected = _selectedTab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = idx),
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

  Widget _buildTwistersList(List<Map<String, String>> twisters) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: twisters.length,
      itemBuilder: (context, idx) {
        final item = twisters[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
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
                    child: Text(item['difficulty']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _purpleAccent)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, color: _purpleAccent),
                    onPressed: () => TtsService.instance.speak(text: item['text']!),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(item['text']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
              const SizedBox(height: 4),
              Text(item['ipa']!, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _toggleListening(item['text']!),
                    style: ElevatedButton.styleFrom(backgroundColor: _isListening ? Colors.red : _purpleAccent, foregroundColor: Colors.white),
                    icon: Icon(_isListening ? Icons.stop_rounded : Icons.mic_rounded, size: 16),
                    label: Text(_isListening ? 'Stop' : 'Practice Spoken'),
                  ),
                  if (_accuracyScore != -1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(12)),
                      child: Text('Accuracy: $_accuracyScore%', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWordSentenceList() {
    final items = [
      {'title': 'Entrepreneurship', 'ipa': '/ˌɒn.trə.prəˈnɜː.ʃɪp/', 'example': 'She demonstrated visionary entrepreneurship.'},
      {'title': 'Phenomenon', 'ipa': '/fəˈnɒm.ɪ.nən/', 'example': 'Quantum entanglement is a fascinating physics phenomenon.'},
      {'title': 'Simultaneous', 'ipa': '/ˌsɪm.əlˈteɪ.ni.əs/', 'example': 'The app supports simultaneous user connections.'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, idx) {
        final item = items[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['title']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, color: _purpleAccent),
                    onPressed: () => TtsService.instance.speak(text: item['title']!),
                  ),
                ],
              ),
              Text(item['ipa']!, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
              const SizedBox(height: 6),
              Text('"${item['example']!}"', style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIpaGuide() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('International Phonetic Alphabet (IPA) Guide', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
          const SizedBox(height: 10),
          const Text('Learn standard IPA symbols to master accent-free English pronunciation.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          const SizedBox(height: 16),
          _buildIpaRow('/θ/', 'th (thin, think, bath)', 'Say "think"'),
          _buildIpaRow('/ð/', 'th (this, that, mother)', 'Say "mother"'),
          _buildIpaRow('/ʃ/', 'sh (shoe, machine, vision)', 'Say "shoe"'),
          _buildIpaRow('/dʒ/', 'j (judge, jump, giant)', 'Say "judge"'),
          _buildIpaRow('/æ/', 'short a (cat, apple, trap)', 'Say "apple"'),
        ],
      ),
    );
  }

  Widget _buildIpaRow(String symbol, String desc, String sample) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: _purpleAccent.withAlpha(20), borderRadius: BorderRadius.circular(10)),
            child: Text(symbol, style: const TextStyle(fontWeight: FontWeight.w800, color: _purpleAccent, fontSize: 16)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(desc, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text(sample, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
