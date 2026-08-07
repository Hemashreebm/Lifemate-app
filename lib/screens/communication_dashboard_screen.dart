import 'package:flutter/material.dart';
import '../services/communication_platform_service.dart';

/// Screen for 13. Communication Dashboard, 14. Personalized Learning & 15. Certificates
class CommunicationDashboardScreen extends StatefulWidget {
  const CommunicationDashboardScreen({super.key});

  @override
  State<CommunicationDashboardScreen> createState() => _CommunicationDashboardScreenState();
}

class _CommunicationDashboardScreenState extends State<CommunicationDashboardScreen> {
  static const _purpleAccent = Color(0xFF7C3AED);
  static const _bgLight = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    final service = CommunicationPlatformService.instance;
    final overall = service.overallScore;
    final certs = service.certificates;

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text('Communication Dashboard', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Score Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_purpleAccent, Color(0xFF4F46E5)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Color(0x207C3AED), blurRadius: 12, offset: Offset(0, 6))],
              ),
              child: Column(
                children: [
                  const Text('Overall Communication Score', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('$overall', style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Text('Pro Level • Top 10% Communicator', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Skill Metrics Breakdown
            const Text('Skill Score Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _buildSkillTile('Grammar', '${service.grammarScore}%', Icons.spellcheck_rounded, const Color(0xFF2563EB))),
                const SizedBox(width: 10),
                Expanded(child: _buildSkillTile('Vocabulary', '${service.vocabScore}%', Icons.menu_book_rounded, const Color(0xFF10B981))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildSkillTile('Pronunciation', '${service.pronunciationScore}%', Icons.volume_up_rounded, const Color(0xFF7C3AED))),
                const SizedBox(width: 10),
                Expanded(child: _buildSkillTile('Speaking', '${service.speakingScore}%', Icons.mic_rounded, const Color(0xFFEA580C))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildSkillTile('Listening', '${service.listeningScore}%', Icons.headphones_rounded, const Color(0xFF0284C7))),
                const SizedBox(width: 10),
                Expanded(child: _buildSkillTile('Writing', '${service.writingScore}%', Icons.edit_note_rounded, const Color(0xFF059669))),
              ],
            ),

            const SizedBox(height: 24),

            // AI Personal Recommendation Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFBFDBFE))),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: Color(0xFF2563EB)),
                      SizedBox(width: 8),
                      Text('AI Weakness & Recommendation', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1D4ED8), fontSize: 15)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('Weakest Skill: Pronunciation (82%). Recommended: Practice 5 minutes in Pronunciation Lab on /θ/ and /ʃ/ sounds today to reach 90%+.', style: TextStyle(fontSize: 13, color: Color(0xFF1E40AF), height: 1.4)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Earned Certificates
            const Text('Earned Certificates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
            const SizedBox(height: 12),

            ...certs.map((cert) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: cert.isEarned ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9), shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Icon(Icons.workspace_premium_rounded, color: cert.isEarned ? const Color(0xFFD97706) : const Color(0xFF94A3B8), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cert.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1E293B))),
                        const SizedBox(height: 2),
                        Text(cert.description, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillTile(String label, String score, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569)))),
          Text(score, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}
