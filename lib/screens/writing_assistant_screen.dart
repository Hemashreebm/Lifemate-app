import 'package:flutter/material.dart';
import '../services/communication_platform_service.dart';

/// Screen for 9. Writing Assistant (Correct grammar, spelling, sentence structure with line-by-line explanations)
class WritingAssistantScreen extends StatefulWidget {
  const WritingAssistantScreen({super.key});

  @override
  State<WritingAssistantScreen> createState() => _WritingAssistantScreenState();
}

class _WritingAssistantScreenState extends State<WritingAssistantScreen> {
  static const _purpleAccent = Color(0xFF7C3AED);
  static const _bgLight = Color(0xFFF8FAFC);

  final TextEditingController _inputController = TextEditingController();
  Map<String, dynamic>? _result;

  void _analyzeText() {
    final text = _inputController.text;
    final res = CommunicationPlatformService.instance.analyzeWritingText(text);
    setState(() {
      _result = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text('Writing Assistant', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Writing & Grammar Proofreader', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
            const SizedBox(height: 4),
            const Text('Paste any email, message, or essay to get instant corrections and explanations.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),

            const SizedBox(height: 20),

            TextField(
              controller: _inputController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter or paste your text here...\n(e.g., "I am having a doubt and I am agree with you. Please do one thing and revert back soon.")',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              ),
            ),

            const SizedBox(height: 14),

            ElevatedButton.icon(
              onPressed: _analyzeText,
              style: ElevatedButton.styleFrom(backgroundColor: _purpleAccent, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
              icon: const Icon(Icons.spellcheck_rounded, size: 20),
              label: const Text('Check Grammar & Structure'),
            ),

            if (_result != null) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Grammar Score', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(12)),
                    child: Text('${_result!['score']}/100', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Corrected Version:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF334155))),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFBBF7D0))),
                child: Text(_result!['correctedText'], style: const TextStyle(fontSize: 14, color: Color(0xFF166534), height: 1.4)),
              ),
              const SizedBox(height: 16),
              const Text('Explanations & Suggestions:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF334155))),
              const SizedBox(height: 8),
              ...(_result!['corrections'] as List<Map<String, String>>).map((corr) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('"${corr['original']}" → "${corr['suggestion']}"', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _purpleAccent)),
                    const SizedBox(height: 2),
                    Text(corr['explanation']!, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
