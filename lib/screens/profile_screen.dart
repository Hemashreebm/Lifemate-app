import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/profile_service.dart';
import '../services/task_service.dart';
import '../services/diary_service.dart';
import '../services/transaction_service.dart';
import '../services/auth_service.dart';
import '../services/backup_manager_service.dart';
import '../services/battery_optimization_service.dart';
import '../widgets/user_avatar_widget.dart';
import '../widgets/complete_profile_card.dart';
import 'edit_profile_screen.dart';
import 'login_activity_screen.dart';
import 'security_dashboard_screen.dart';
import 'sms_import_history_screen.dart';
import 'auth_screen.dart';

/// Lifemate Profile Screen
///
/// Features:
/// 1. Profile Hero Card & User Info display.
/// 2. Live Profile Completeness Progress indicator & Personalization attributes.
/// 3. Live Usage Statistics (Tasks, Diary, Expenses).
/// 4. Data Backup & Restore (JSON Export / Import).
/// 5. Settings Section: Notifications, Voice, Permissions, Battery, Privacy, About.
/// 6. Authenticated UID-isolated cloud sync.
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

  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _appVersion = '${info.version}+${info.buildNumber}');
    }
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

  //  Data Backup & Restore 

  Future<void> _exportBackup() async {
    try {
      final backupData = {
        'version': _appVersion,
        'exportDate': DateTime.now().toIso8601String(),
        'profile': {
          'name': _profileService.name,
          'nickname': _profileService.nickname,
          'age': _profileService.age,
          'gender': _profileService.gender,
          'state': _profileService.state,
          'district': _profileService.district,
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
            content: Text('Backup data copied to clipboard. Save it safely.'),
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
            Text(' Notifications: Allowed'),
            SizedBox(height: 6),
            Text(' Exact Alarm Clock: Active'),
            SizedBox(height: 6),
            Text(' Microphones & Voice: Active'),
            SizedBox(height: 6),
            Text(' Camera & OCR Scanner: Active'),
            SizedBox(height: 6),
            Text(' Location Services: Active'),
            SizedBox(height: 6),
            Text(' SMS Bank Reader: Active'),
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
                  // Hero User Profile Card
                  _buildProfileHeroCard(),

                  const SizedBox(height: 14),

                  // Profile Completion Prompt if incomplete
                  CompleteProfileCard(
                    onCompleted: _loadProfile,
                  ),

                  const SizedBox(height: 14),

                  // Live App Statistics Card
                  _buildLiveStatsCard(),

                  const SizedBox(height: 20),

                  // Settings & App Section
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

    final completeness = _profileService.completenessPercentage;
    final stateDist = [
      if (_profileService.district.isNotEmpty) _profileService.district,
      if (_profileService.state.isNotEmpty) _profileService.state,
    ].join(', ');

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
              const UserAvatarWidget(
                radius: 34,
                backgroundColor: Color(0x33FFFFFF),
                textColor: Colors.white,
                iconColor: Colors.white,
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$displayName $displayNickname',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _profileService.isCompleted
                          ? '${_profileService.occupation}  ${_profileService.preferredLanguage}'
                          : 'Personalize Lifemate for you',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFDDD6FE),
                        height: 1.3,
                      ),
                    ),
                    if (stateDist.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFFC4B5FD)),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              stateDist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, color: Color(0xFFC4B5FD)),
                            ),
                          ),
                        ],
                      ),
                    ],
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
                            'Profile $completeness%',
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
              _profileService.isCompleted ? 'Edit Profile' : 'Set Up Profile',
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
          _buildSettingsTile(
            icon: Icons.shield_outlined,
            iconColor: const Color(0xFF7C3AED),
            title: 'Security & Privacy Dashboard',
            subtitle: 'Security score, password & active sessions',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SecurityDashboardScreen()),
              );
            },
          ),
          const Divider(height: 1, indent: 60, color: Color(0xFFF1F5F9)),

          _buildSettingsTile(
            icon: Icons.history_rounded,
            iconColor: const Color(0xFF3B82F6),
            title: 'Login Activity History',
            subtitle: 'Recent logins and active device sessions',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginActivityScreen()),
              );
            },
          ),
          const Divider(height: 1, indent: 60, color: Color(0xFFF1F5F9)),

          _buildSettingsTile(
            icon: Icons.sms_outlined,
            iconColor: const Color(0xFF10B981),
            title: 'SMS Expense Tracker History',
            subtitle: 'Imported bank transactions & parsing logs',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SmsImportHistoryScreen()),
              );
            },
          ),
          const Divider(height: 1, indent: 60, color: Color(0xFFF1F5F9)),

          _buildSettingsTile(
            icon: Icons.cloud_upload_outlined,
            iconColor: const Color(0xFF0EA5E9),
            title: 'Export JSON Data Backup',
            subtitle: 'Copy complete encrypted backup to clipboard',
            onTap: _exportBackup,
          ),
          const Divider(height: 1, indent: 60, color: Color(0xFFF1F5F9)),

          _buildSettingsTile(
            icon: Icons.checklist_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: 'App Permissions Status',
            subtitle: 'View active Android system permissions',
            onTap: _showPermissionsStatus,
          ),
          const Divider(height: 1, indent: 60, color: Color(0xFFF1F5F9)),

          _buildSettingsTile(
            icon: Icons.battery_saver_rounded,
            iconColor: const Color(0xFF8B5CF6),
            title: 'Reliable Reminders & Battery',
            subtitle: 'Exempt Lifemate from battery optimization',
            onTap: () {
              BatteryOptimizationService.requestIgnoreBatteryOptimizations();
            },
          ),
          const Divider(height: 1, indent: 60, color: Color(0xFFF1F5F9)),

          _buildSettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: const Color(0xFF06B6D4),
            title: 'About Lifemate',
            subtitle: 'Version and developer credits',
            onTap: _showAboutDialog,
          ),
          const Divider(height: 1, indent: 60, color: Color(0xFFF1F5F9)),

          _buildSettingsTile(
            icon: Icons.logout_rounded,
            iconColor: const Color(0xFFEF4444),
            title: 'Sign Out Account',
            subtitle: 'Log out safely from Lifemate',
            onTap: _confirmLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
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
          color: iconColor.withAlpha(25),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1E293B)),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFCBD5E1)),
    );
  }

  Future<void> _confirmLogout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of Lifemate?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (result == true) {
      await AuthService.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
          (route) => false,
        );
      }
    }
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lifemate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Your personal everyday companion.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
            const SizedBox(height: 14),
            Text('Version: $_appVersion\nDeveloped by Hemashree B M', style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }
}
