import 'package:flutter/material.dart';
import '../services/settings_service.dart';

/// Screen for 18. Settings & 19. Notifications (Language, Voice, Speed, Difficulty, Reminders)
class CoachSettingsScreen extends StatefulWidget {
  const CoachSettingsScreen({super.key});

  @override
  State<CoachSettingsScreen> createState() => _CoachSettingsScreenState();
}

class _CoachSettingsScreenState extends State<CoachSettingsScreen> {
  static const _purpleAccent = Color(0xFF7C3AED);
  static const _bgLight = Color(0xFFF8FAFC);

  String _selectedDifficulty = 'Intermediate';
  double _speechSpeed = 1.0;
  bool _dailyReminder = true;
  bool _offlineDownload = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text('Coach Settings & Reminders', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Learning Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Course Difficulty Level', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      DropdownButton<String>(
                        value: _selectedDifficulty,
                        underline: const SizedBox.shrink(),
                        items: const [
                          DropdownMenuItem(value: 'Beginner', child: Text('Beginner')),
                          DropdownMenuItem(value: 'Intermediate', child: Text('Intermediate')),
                          DropdownMenuItem(value: 'Advanced', child: Text('Advanced')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedDifficulty = val);
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TTS Playback Speed', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text('${_speechSpeed.toStringAsFixed(1)}x', style: const TextStyle(fontWeight: FontWeight.w800, color: _purpleAccent)),
                    ],
                  ),
                  Slider(
                    value: _speechSpeed,
                    min: 0.5,
                    max: 1.5,
                    divisions: 10,
                    activeColor: _purpleAccent,
                    onChanged: (val) => setState(() => _speechSpeed = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text('Daily Reminders & Offline Mode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Daily Learning Reminders', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: const Text('Receive daily notifications for vocabulary and speaking practice', style: TextStyle(fontSize: 12)),
                    value: _dailyReminder,
                    activeColor: _purpleAccent,
                    onChanged: (val) => setState(() => _dailyReminder = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Offline Lesson Pre-download', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: const Text('Automatically cache vocabulary & grammar lessons for offline use', style: TextStyle(fontSize: 12)),
                    value: _offlineDownload,
                    activeColor: _purpleAccent,
                    onChanged: (val) => setState(() => _offlineDownload = val),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
