import 'package:flutter/material.dart';
import '../services/communication_curriculum_service.dart';
import '../services/communication_platform_service.dart';
import 'spoken_english_practice_screen.dart';
import 'pronunciation_practice_screen.dart';
import 'daily_conversation_screen.dart';
import 'daily_english_challenge_screen.dart';
import 'grammar_coach_screen.dart';
import 'vocabulary_builder_screen.dart';
import 'conversation_simulator_screen.dart';
import 'interview_prep_screen.dart';
import 'public_speaking_coach_screen.dart';
import 'writing_assistant_screen.dart';
import 'daily_speaking_practice_screen.dart';
import 'pronunciation_lab_screen.dart';
import 'group_discussion_trainer_screen.dart';
import 'reading_listening_coach_screen.dart';
import 'communication_dashboard_screen.dart';
import 'coach_settings_screen.dart';

/// Gamified Communication Coach Screen
///
/// Features:
/// 1. Total XP ¡, Daily Streak , and Badges Â header banner.
/// 2. Structured Gamified Curriculum (Beginner Level 1 -> Intermediate Level 2 -> Advanced Level 3).
/// 3. Gated Unlock Progression (Lesson N+1 unlocks after Lesson N is completed).
/// 4. Interactive practice launchers: Spoken Practice, Pronunciation Scoring, Real-life Dialogue, Interview & Group Discussion.
class CommunicationCoachScreen extends StatefulWidget {
  const CommunicationCoachScreen({super.key});

  @override
  State<CommunicationCoachScreen> createState() => _CommunicationCoachScreenState();
}

class _CommunicationCoachScreenState extends State<CommunicationCoachScreen> {
  final _curriculumSvc = CommunicationCurriculumService.instance;
  bool _isLoading = true;
  String _selectedLevel = 'Beginner';

  static const _purpleAccent = Color(0xFF7C3AED);
  static const _bgLight = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _loadCurriculum();
  }

  Future<void> _loadCurriculum() async {
    await _curriculumSvc.load();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openLesson(CoachLesson lesson) {
    if (!lesson.isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(' Complete previous lessons to unlock "${lesson.title}"!'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    if (lesson.type == 'speaking' || lesson.type == 'interview') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SpokenEnglishPracticeScreen()),
      ).then((_) => _onLessonFinished(lesson));
    } else if (lesson.type == 'listening' || lesson.type == 'discussion') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PronunciationPracticeScreen()),
      ).then((_) => _onLessonFinished(lesson));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DailyConversationScreen()),
      ).then((_) => _onLessonFinished(lesson));
    }
  }

  Future<void> _onLessonFinished(CoachLesson lesson) async {
    await _curriculumSvc.completeLesson(lesson.id, 90);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text(
          'Communication Coach',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _purpleAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //  Gamified Stats Banner 
                  _buildGamifiedStatsHeader(),

                  const SizedBox(height: 20),

                  //  Level Selector Tabs 
                  _buildLevelSelector(),

                  const SizedBox(height: 20),

                  //  Lesson List 
                  Text(
                    '$_selectedLevel Lessons',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _buildLessonList(),

                  const SizedBox(height: 28),

                  //  Practice Modes & Learning Modules 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PRO Modules & Practice Tools',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.analytics_rounded, color: _purpleAccent),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CommunicationDashboardScreen()),
                          );
                        },
                        tooltip: 'Communication Dashboard & Progress',
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildPracticeModeCard(
                    icon: Icons.mic_rounded,
                    title: '1. Daily Speaking Practice',
                    subtitle: 'Topic of the day, 5-min task & AI streak evaluation',
                    color: const Color(0xFFEA580C),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DailySpeakingPracticeScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  _buildPracticeModeCard(
                    icon: Icons.local_fire_department_rounded,
                    title: '2. Daily English Challenge',
                    subtitle: '5 new words, pronunciations, audio, meanings & quiz',
                    color: const Color(0xFFD97706),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DailyEnglishChallengeScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  _buildPracticeModeCard(
                    icon: Icons.record_voice_over_rounded,
                    title: '3. Pronunciation Lab',
                    subtitle: 'Word, sentence, paragraph, tongue twisters & IPA guide',
                    color: const Color(0xFF7C3AED),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PronunciationLabScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  _buildPracticeModeCard(
                    icon: Icons.spellcheck_rounded,
                    title: '4. Grammar Master',
                    subtitle: 'Tenses, Articles, Prepositions, Voice & Conjunctions',
                    color: const Color(0xFF2563EB),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GrammarCoachScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  _buildPracticeModeCard(
                    icon: Icons.menu_book_rounded,
                    title: '5. Vocabulary Master',
                    subtitle: 'Business, Tech, Engineering, Medical & Saved Words',
                    color: const Color(0xFF10B981),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const VocabularyBuilderScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  _buildPracticeModeCard(
                    icon: Icons.forum_rounded,
                    title: '6. AI Conversation Partner',
                    subtitle: 'Student, Teacher, HR, Doctor, Police & Staff roleplay',
                    color: const Color(0xFF0284C7),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ConversationSimulatorScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  _buildPracticeModeCard(
                    icon: Icons.business_center_rounded,
                    title: '7. HR Interview Trainer',
                    subtitle: 'Mock rounds with Confidence, Grammar & Communication score',
                    color: const Color(0xFFD97706),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const InterviewPrepScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  _buildPracticeModeCard(
                    icon: Icons.groups_rounded,
                    title: '8. Group Discussion Trainer',
                    subtitle: 'AI topics, Climate Change, Tech & Women Empowerment',
                    color: const Color(0xFF4F46E5),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GroupDiscussionTrainerScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  _buildPracticeModeCard(
                    icon: Icons.graphic_eq_rounded,
                    title: '9. Public Speaking Trainer',
                    subtitle: '1, 3, 5-min speeches with pace WPM, fillers & confidence',
                    color: const Color(0xFF9333EA),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PublicSpeakingCoachScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  _buildPracticeModeCard(
                    icon: Icons.menu_book_outlined,
                    title: '10. Reading & Listening Coach',
                    subtitle: 'Passages read aloud + Audio comprehension quizzes',
                    color: const Color(0xFF0284C7),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReadingListeningCoachScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  _buildPracticeModeCard(
                    icon: Icons.edit_note_rounded,
                    title: '11. Writing Coach',
                    subtitle: 'Grammar, spelling, sentence & email proofreading',
                    color: const Color(0xFF059669),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WritingAssistantScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  _buildPracticeModeCard(
                    icon: Icons.insights_rounded,
                    title: '12. Communication Dashboard & Certificates',
                    subtitle: 'Overall score breakdown, Certificates & Weak Area AI Tips',
                    color: const Color(0xFF7C3AED),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CommunicationDashboardScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  _buildPracticeModeCard(
                    icon: Icons.settings_suggest_rounded,
                    title: '13. Settings & Reminders',
                    subtitle: 'Voice speed, daily reminder times & offline download quality',
                    color: const Color(0xFF64748B),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CoachSettingsScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildGamifiedStatsHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x337C3AED), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(' ', style: TextStyle(fontSize: 22)),
                  Text(
                    '${_curriculumSvc.streakDays} Day Streak!',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('¡ ', style: TextStyle(fontSize: 14)),
                    Text(
                      '${_curriculumSvc.totalXp} XP',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.white24),
          const SizedBox(height: 12),
          const Text(
            'Earned Badges',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFDDD6FE)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _curriculumSvc.earnedBadges.map((badge) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(64),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSelector() {
    final levels = ['Beginner', 'Intermediate', 'Advanced'];

    return Row(
      children: levels.map((lvl) {
        final isSelected = _selectedLevel == lvl;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedLevel = lvl),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? _purpleAccent : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? _purpleAccent : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                lvl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLessonList() {
    final filtered = _curriculumSvc.lessons
        .where((l) => l.level == _selectedLevel)
        .toList();

    return Column(
      children: filtered.map((lesson) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: lesson.isCompleted
                  ? const Color(0xFF10B981)
                  : (lesson.isUnlocked ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9)),
              width: lesson.isCompleted ? 1.5 : 1,
            ),
          ),
          child: ListTile(
            onTap: () => _openLesson(lesson),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: lesson.isCompleted
                    ? const Color(0xFF10B981).withAlpha(38)
                    : (lesson.isUnlocked
                        ? _purpleAccent.withAlpha(31)
                        : const Color(0xFFF1F5F9)),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                lesson.isCompleted
                    ? Icons.check_rounded
                    : (lesson.isUnlocked ? Icons.play_arrow_rounded : Icons.lock_outline_rounded),
                color: lesson.isCompleted
                    ? const Color(0xFF10B981)
                    : (lesson.isUnlocked ? _purpleAccent : const Color(0xFF94A3B8)),
              ),
            ),
            title: Text(
              'Lesson ${lesson.lessonNumber}: ${lesson.title}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: lesson.isUnlocked ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
              ),
            ),
            subtitle: Text(
              lesson.description,
              style: TextStyle(
                fontSize: 12,
                color: lesson.isUnlocked ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '+${lesson.xpReward} XP',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFD97706)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPracticeModeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha(31),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
      ),
    );
  }
}

