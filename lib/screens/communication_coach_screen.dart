import 'package:flutter/material.dart';
import 'spoken_english_practice_screen.dart';
import 'pronunciation_practice_screen.dart';
import 'daily_conversation_screen.dart';

/// Communication Coach Screen
///
/// Features 4 cards:
/// 1. Spoken English Practice (functional)
/// 2. Pronunciation Practice (Coming Soon)
/// 3. Daily Conversation (Coming Soon)
/// 4. Interview Practice (Coming Soon)
class CommunicationCoachScreen extends StatelessWidget {
  const CommunicationCoachScreen({super.key});

  static const _brandPurple = Color(0xFF7C3AED);
  static const _bgLight = Color(0xFFF8FAFC);

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Header Banner Card ──────────────────────────────────────
            _buildHeaderCard(),

            const SizedBox(height: 24),

            const Text(
              'Select Practice Mode',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),

            const SizedBox(height: 12),

            // ── 1. Spoken English Practice (Functional) ─────────────────────
            _buildOptionCard(
              context: context,
              icon: Icons.mic_rounded,
              title: 'Spoken English Practice',
              subtitle: 'Practice speaking English confidently',
              badgeText: 'Available',
              badgeColor: const Color(0xFF10B981),
              accentColor: const Color(0xFF7C3AED),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SpokenEnglishPracticeScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            // ── 2. Pronunciation Practice (Functional) ─────────────────────
            _buildOptionCard(
              context: context,
              icon: Icons.volume_up_rounded,
              title: 'Pronunciation Practice',
              subtitle: 'Listen, repeat and improve pronunciation',
              badgeText: 'Available',
              badgeColor: const Color(0xFF10B981),
              accentColor: const Color(0xFF2563EB),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PronunciationPracticeScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            // ── 3. Daily Conversation (Functional) ─────────────────────────
            _buildOptionCard(
              context: context,
              icon: Icons.forum_rounded,
              title: 'Daily Conversation',
              subtitle: 'Practice real-life conversations',
              badgeText: 'Available',
              badgeColor: const Color(0xFF10B981),
              accentColor: const Color(0xFF059669),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DailyConversationScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            // ── 4. Interview Practice (Coming Soon) ─────────────────────────
            _buildOptionCard(
              context: context,
              icon: Icons.work_rounded,
              title: 'Interview Practice',
              subtitle: 'Prepare for interviews with speaking practice',
              badgeText: 'Coming Soon',
              badgeColor: const Color(0xFF64748B),
              accentColor: const Color(0xFFD97706),
              onTap: () => _showComingSoon(context, 'Interview Practice'),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_brandPurple, Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x337C3AED),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              shape: BoxShape.circle,
            ),
            child: const Text('🗣', style: TextStyle(fontSize: 32)),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Communication Coach',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Practice speaking, pronunciation & interviews',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFDDD6FE),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Icon box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: accentColor, size: 28),
                ),

                const SizedBox(width: 14),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: badgeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — Coming Soon! 🚀'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
