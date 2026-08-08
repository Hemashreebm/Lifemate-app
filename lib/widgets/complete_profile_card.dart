import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../screens/edit_profile_screen.dart';

/// Non-blocking prompt banner inviting users to complete their profile
/// for better AI personalization (Govt schemes, Scholarships, Coach, Finance).
class CompleteProfileCard extends StatefulWidget {
  final VoidCallback? onCompleted;
  final bool isDismissible;

  const CompleteProfileCard({
    super.key,
    this.onCompleted,
    this.isDismissible = true,
  });

  @override
  State<CompleteProfileCard> createState() => _CompleteProfileCardState();
}

class _CompleteProfileCardState extends State<CompleteProfileCard> {
  bool _isSkipped = false;

  @override
  Widget build(BuildContext context) {
    final profile = ProfileService.instance;
    final completeness = profile.completenessPercentage;

    // If profile is already 100% complete or user chose to skip for now
    if (completeness >= 100 || _isSkipped) {
      return const SizedBox.shrink();
    }

    final missing = profile.missingFields;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_pin_rounded,
                  color: Color(0xFF7C3AED),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Complete your profile',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Profile $completeness% completed',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completeness / 100.0,
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Add state, occupation, and demographics for personalized Government schemes, scholarships, and AI recommendations.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.35),
          ),

          if (missing.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: missing.take(3).map((field) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+ $field',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 14),

          // Action Buttons: Skip for now & Complete Profile
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.isDismissible)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSkipped = true;
                    });
                  },
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                  if (result == true) {
                    widget.onCompleted?.call();
                    if (mounted) setState(() {});
                  }
                },
                icon: const Icon(Icons.edit_note_rounded, size: 16),
                label: const Text(
                  'Complete Profile',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
