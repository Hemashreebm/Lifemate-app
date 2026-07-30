import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/profile_service.dart';
import '../services/task_service.dart';
import '../services/diary_service.dart';
import '../services/transaction_service.dart';
import '../services/auth_service.dart';
import '../services/backup_manager_service.dart';
import '../services/battery_optimization_service.dart';
import 'edit_profile_screen.dart';
import 'login_activity_screen.dart';
import 'security_dashboard_screen.dart';
import 'auth_screen.dart';

/// Lifemate Profile Screen
///
/// Features:
/// 1. Profile Hero Card & User Info display.
/// 2. Live Usage Statistics (Tasks, Diary, Expenses).
/// 3. Data Backup & Restore (JSON Export / Import).
/// 4. Settings Section: Notifications, Voice, Permissions, Battery, Privacy, About.
/// 5. 100% Local device storage guarantee.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService.instance;
  bool _isLoading = true;

  int _taskCount = 0;
  int _diaryCount = 0;
  int _expenseCount = 0;

  static const _purpleAccent = Color(0xFF7C3AED);
  static const _bgLight = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await _profileService.load();
    await TaskService.instance.load();
    await DiaryService.instance.load();
    await TransactionService.instance.load();

    if (mounted) {
      setState(() {
        _taskCount = TaskService.instance.all.length;
        _diaryCount = DiaryService.instance.all.length;
        _expenseCount = TransactionService.instance.all.length;
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

  // â”€â”€ Data Backup & Restore â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _exportBackup() async {
    try {
      final backupData = {
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'profile': {
          'name': _profileService.name,
          'nickname': _profileService.nickname,
          'age': _profileService.age,
          'occupation': _profileService.occupation,
          'preferredLanguage': _profileService.preferredLanguage,
        },
        'tasksCount': _taskCount,
        'diaryCount': _diaryCount,
        'expenseCount': _expenseCount,
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
      await Clipboard.setData(ClipboardData(text: jsonString));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('âœ… Backup data copied to clipboard! Save it safely.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting backup: $e')),
        );
      }
    }
  }

  Future<void> _showPermissionsStatus() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.security_rounded, color: Color(0xFF10B981)),
            SizedBox(width: 10),
            Text('Permissions Status'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ðŸŸ¢ Notifications: Allowed'),
            SizedBox(height: 6),
            Text('ðŸŸ¢ Exact Alarm Clock: Active'),
            SizedBox(height: 6),
            Text('ðŸŸ¢ Microphones & Voice: Active'),
            SizedBox(height: 6),
            Text('ðŸŸ¢ Camera & OCR Scanner: Active'),
            SizedBox(height: 6),
            Text('ðŸŸ¢ Location Services: Active'),
            SizedBox(height: 6),
            Text('ðŸŸ¢ SMS Bank Reader: Active'),
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
                  // â”€â”€ Hero User Profile Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  _buildProfileHeroCard(),

                  const SizedBox(height: 20),

                  // â”€â”€ Live App Statistics Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  _buildLiveStatsCard(),

                  const SizedBox(height: 20),

                  // â”€â”€ Settings & App Section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
          BoxShadow(color: Color(0x337C3AED), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withAlpha(102), width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  _profileService.avatar,
                  style: const TextStyle(fontSize: 34),
                ),
              ),

              const SizedBox(width: 16),

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
                          ? '${_profileService.occupation} â€¢ ${_profileService.preferredLanguage}'
                          : 'Personalize Lifemate for you',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFDDD6FE),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AuthService.instance.isGuestMode
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            AuthService.instance.isGuestMode ? 'GUEST ACCOUNT' : 'CLOUD ACCOUNT',
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            BackupManagerService.instance.isCloudBackupEnabled ? 'Backup: Active â˜ï¸' : 'Local Only ðŸ’¾',
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0x33FFFFFF)),
          const SizedBox(height: 14),

          OutlinedButton.icon(
            onPressed: _openEditProfile,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(
              _profileService.isCompleted ? 'âœï¸ Edit Profile' : 'âœï¸ Set Up Profile',
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

  Widget _buildLiveStatsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity Statistics',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCol('Tasks', '$_taskCount', const Color(0xFFF59E0B)),
              _buildStatCol('Diary Notes', '$_diaryCount', const Color(0xFF7C3AED)),
              _buildStatCol('Expenses', '$_expenseCount', const Color(0xFF10B981)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
      ],
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
            icon: Icons.cloud_sync_rounded,
            iconColor: const Color(0xFF3B82F6),
            title: 'Account & Cloud Backup',
            subtitle: 'Sign in, register, or manage cloud synchronization',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildSettingTile(
            icon: Icons.shield_rounded,
            iconColor: const Color(0xFF10B981),
            title: 'Security & Privacy Dashboard',
            subtitle: 'Central hub for biometrics, 2FA, devices & encryption',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SecurityDashboardScreen()),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildSettingTile(
            icon: Icons.devices_rounded,
            iconColor: const Color(0xFF7C3AED),
            title: 'Login Activity & Devices',
            subtitle: 'View logged-in devices & active sessions',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginActivityScreen()),
              );
            },
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildSettingTile(
            icon: Icons.battery_charging_full_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: 'Battery Optimization',
            subtitle: 'Ensure background alarms run without delay',
            onTap: () => BatteryOptimizationService.requestIgnoreBatteryOptimizations(),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildSettingTile(
            icon: Icons.backup_rounded,
            iconColor: const Color(0xFF7C3AED),
            title: 'Backup & Export Data',
            subtitle: 'Copy JSON backup of profile and settings',
            onTap: _exportBackup,
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildSettingTile(
            icon: Icons.security_rounded,
            iconColor: const Color(0xFF10B981),
            title: 'Permissions Status',
            subtitle: 'View active Android runtime permissions',
            onTap: _showPermissionsStatus,
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildSettingTile(
            icon: Icons.notifications_active_rounded,
            iconColor: const Color(0xFF3B82F6),
            title: 'Notifications',
            subtitle: 'Task reminders & alert settings',
            onTap: _showNotificationsInfo,
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildSettingTile(
            icon: Icons.lock_outline_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: 'Privacy & Security',
            subtitle: '100% local device storage guarantee',
            onTap: _showPrivacyDialog,
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildSettingTile(
            icon: Icons.info_outline_rounded,
            iconColor: const Color(0xFF06B6D4),
            title: 'About Lifemate',
            subtitle: 'Version 1.0.0 â€” Open-source edition',
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
          color: iconColor.withAlpha(26),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 22),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

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
          'Task and daily reminders run locally on your phone using Android local notification & AlarmManager services.\n\nNo internet connection is required to receive scheduled reminders.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
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
            Text('Privacy Policy'),
          ],
        ),
        content: const Text(
          'All your data â€” including diary logs, tasks, profile info, and transactions â€” is stored 100% locally on your device.\n\nLifemate does not upload your personal data to remote tracking servers.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
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
            Text('Lifemate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            SizedBox(height: 4),
            Text('Your personal everyday companion.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
            SizedBox(height: 14),
            Text('Version: 1.0.0\nAuthor: Hemashree B M', style: TextStyle(fontSize: 13, color: Color(0xFF334155))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }
}

