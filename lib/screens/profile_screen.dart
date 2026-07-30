import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import 'edit_profile_screen.dart';

/// Lifemate Profile Screen
///
/// Features:
/// 1. Profile Avatar & User Info display.
/// 2. First-time setup banner (if profile not set).
/// 3. Edit Profile action button.
/// 4. Settings section: Notifications, Voice & Speech, Language, Privacy, About Lifemate.
/// 5. 100% Local device SharedPreferences storage (No Firebase / No cloud).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService.instance;
  bool _isLoading = true;

  static const _purpleAccent = Color(0xFF7C3AED);
  static const _bgLight = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await _profileService.load();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openEditProfile() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );

    if (result == true) {
      _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text(
          'Profile',
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
                  // ── Hero User Profile Card ──────────────────────────────
                  _buildProfileHeroCard(),

                  const SizedBox(height: 20),

                  // ── First-Time Profile Setup Banner (If not completed) ─
                  if (!_profileService.isCompleted) _buildSetupCalloutCard(),

                  if (!_profileService.isCompleted) const SizedBox(height: 24),

                  // ── Personal Info Summary Details ────────────────────────
                  if (_profileService.isCompleted) _buildInfoSummaryCard(),

                  if (_profileService.isCompleted) const SizedBox(height: 24),

                  // ── Settings & App Section ───────────────────────────────
                  const Text(
                    'Settings & Preferences',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),

                  const SizedBox(height: 12),

                  _buildSettingsOptionsList(),

                  const SizedBox(height: 20),

                  // ── Temporary Profile Build Diagnostic Marker ───────────────
                  const Center(
                    child: Text(
                      'PROFILE BUILD CHECK v1',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeroCard() {
    final displayName = _profileService.name.isNotEmpty
        ? _profileService.name
        : 'Your Name';

    final displayNickname = _profileService.nickname.isNotEmpty
        ? '("${_profileService.nickname}")'
        : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
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
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.40), width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  _profileService.avatar,
                  style: const TextStyle(fontSize: 34),
                ),
              ),

              const SizedBox(width: 16),

              // Name & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$displayName $displayNickname',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _profileService.isCompleted
                          ? '${_profileService.occupation} • ${_profileService.preferredLanguage}'
                          : 'Personalize Lifemate for you',
                      style: const TextStyle(
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

          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0x33FFFFFF)),
          const SizedBox(height: 14),

          // Edit Button
          OutlinedButton.icon(
            onPressed: _openEditProfile,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(
              _profileService.isCompleted ? '✏️ Edit Profile' : '✏️ Set Up Profile',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupCalloutCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 24),
              SizedBox(width: 10),
              Text(
                'Complete your profile',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFB45309),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Tell Lifemate a little about you so the app can become more useful.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF92400E),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: _openEditProfile,
            icon: const Icon(Icons.person_add_rounded, size: 16),
            label: const Text('Set Up Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Details',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 14),
          _buildInfoRow('Name', _profileService.name),
          if (_profileService.nickname.isNotEmpty)
            _buildInfoRow('Nickname', _profileService.nickname),
          if (_profileService.age.isNotEmpty)
            _buildInfoRow('Age', _profileService.age),
          _buildInfoRow('Occupation', _profileService.occupation),
          _buildInfoRow('Preferred Language', _profileService.preferredLanguage),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOptionsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.notifications_active_rounded,
            iconColor: const Color(0xFF3B82F6),
            title: 'Notifications',
            subtitle: 'Task reminders & alert settings',
            onTap: _showNotificationsInfo,
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildSettingTile(
            icon: Icons.mic_rounded,
            iconColor: const Color(0xFF8B5CF6),
            title: 'Voice & Speech',
            subtitle: 'Text-to-Speech engine & recognition',
            onTap: _showVoiceInfo,
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildSettingTile(
            icon: Icons.language_rounded,
            iconColor: const Color(0xFF10B981),
            title: 'Language',
            subtitle: 'Voice guidance language preference',
            onTap: _showLanguageInfo,
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildSettingTile(
            icon: Icons.lock_outline_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: 'Privacy',
            subtitle: 'Local data storage & security policy',
            onTap: _showPrivacyDialog,
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildSettingTile(
            icon: Icons.info_outline_rounded,
            iconColor: const Color(0xFF06B6D4),
            title: 'About Lifemate',
            subtitle: 'App version and companion details',
            onTap: _showAboutDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFF94A3B8),
        size: 22,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  // ── Settings Dialog Handlers ───────────────────────────────────────────────

  void _showNotificationsInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications_active_rounded, color: Color(0xFF3B82F6)),
            SizedBox(width: 10),
            Text('Notifications'),
          ],
        ),
        content: const Text(
          'Task and daily reminders run locally on your phone using Android local notification services.\n\nNo internet connection is required to receive scheduled reminders.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showVoiceInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.mic_rounded, color: Color(0xFF8B5CF6)),
            SizedBox(width: 10),
            Text('Voice & Speech'),
          ],
        ),
        content: const Text(
          'Lifemate uses standard Android Text-to-Speech (Google TTS) and Speech Recognition services.\n\nVoice input and audio playback work offline and online.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLanguageInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.language_rounded, color: Color(0xFF10B981)),
            SizedBox(width: 10),
            Text('Preferred Language'),
          ],
        ),
        content: Text(
          'Your preferred language is currently set to:\n\n👉 ${_profileService.preferredLanguage}\n\nThis language is used for voice practice and guidance throughout Lifemate.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_rounded, color: Color(0xFFF59E0B)),
            SizedBox(width: 10),
            Text('Privacy Information'),
          ],
        ),
        content: const Text(
          'Your basic profile information is stored locally on this device.\n\nYour profile is not uploaded to a Lifemate cloud account in this version.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_rounded, color: Color(0xFF06B6D4)),
            SizedBox(width: 10),
            Text('About Lifemate'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lifemate',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 4),
            Text(
              'Your personal everyday companion.',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            SizedBox(height: 14),
            Text(
              'Version: 1.0.0\nBuild: Development build',
              style: TextStyle(fontSize: 13, color: Color(0xFF334155)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
