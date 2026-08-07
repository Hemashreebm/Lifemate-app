import 'package:flutter/material.dart';
import '../services/communication_platform_service.dart';

/// Screen for 2. Grammar Coach (Tenses, Articles, Prepositions, Active/Passive, Direct/Indirect, Sentence Formation)
class GrammarCoachScreen extends StatefulWidget {
  const GrammarCoachScreen({super.key});

  @override
  State<GrammarCoachScreen> createState() => _GrammarCoachScreenState();
}

class _GrammarCoachScreenState extends State<GrammarCoachScreen> {
  static const _purpleAccent = Color(0xFF7C3AED);
  static const _bgLight = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    final topics = CommunicationPlatformService.instance.getGrammarTopics();

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text('Grammar Coach', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Master Essential English Rules',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Complete rules and practice interactive quizzes with instant explanations.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),

            const SizedBox(height: 20),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topics.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, idx) {
                final topic = topics[idx];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [BoxShadow(color: Color(0x04000000), blurRadius: 8, offset: Offset(0, 3))],
                  ),
                  child: ExpansionTile(
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: topic.isCompleted ? const Color(0xFFD1FAE5) : _purpleAccent.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        topic.isCompleted ? Icons.check_circle_rounded : Icons.menu_book_rounded,
                        color: topic.isCompleted ? const Color(0xFF10B981) : _purpleAccent,
                        size: 22,
                      ),
                    ),
                    title: Text(topic.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    subtitle: Text(topic.description, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            const Text('Key Rules & Concepts:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _purpleAccent)),
                            const SizedBox(height: 6),
                            ...topic.keyRules.map((rule) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: _purpleAccent)),
                                  Expanded(child: Text(rule, style: const TextStyle(fontSize: 13, color: Color(0xFF334155)))),
                                ],
                              ),
                            )),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: () => _openGrammarQuiz(topic),
                              style: ElevatedButton.styleFrom(backgroundColor: _purpleAccent, foregroundColor: Colors.white),
                              icon: const Icon(Icons.quiz_rounded, size: 16),
                              label: Text(topic.isCompleted ? 'Retake Quiz' : 'Start Practice Quiz'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openGrammarQuiz(GrammarTopic topic) {
    int selectedIdx = -1;
    bool submitted = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final q = topic.questions.first;
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.help_center_rounded, color: _purpleAccent),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Quiz: ${topic.title}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                  ],
                ),
                const SizedBox(height: 14),
                Text(q.question, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                const SizedBox(height: 14),
                ...List.generate(q.options.length, (idx) {
                  final opt = q.options[idx];
                  final isSelected = selectedIdx == idx;
                  final isCorrect = idx == q.correctIndex;

                  Color bg = Colors.white;
                  Color border = const Color(0xFFE2E8F0);
                  if (submitted) {
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
                    onTap: submitted ? null : () => setModalState(() => selectedIdx = idx),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: isSelected ? 2 : 1)),
                      child: Text(opt, style: const TextStyle(fontSize: 14)),
                    ),
                  );
                }),
                if (submitted) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
                    child: Text('Explanation: ${q.explanation}', style: const TextStyle(fontSize: 12, color: Color(0xFF4338CA))),
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: selectedIdx == -1
                      ? null
                      : () async {
                          if (!submitted) {
                            setModalState(() => submitted = true);
                            final score = selectedIdx == q.correctIndex ? 100 : 50;
                            await CommunicationPlatformService.instance.markGrammarTopicCompleted(topic.id, score);
                            setState(() {});
                          } else {
                            Navigator.pop(ctx);
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: _purpleAccent, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48)),
                  child: Text(submitted ? 'Done' : 'Check Answer'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
