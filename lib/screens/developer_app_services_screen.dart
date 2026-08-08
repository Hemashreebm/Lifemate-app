import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../services/supabase_service.dart';
import '../services/gemini_service.dart';
import '../theme/app_theme.dart';

/// Developer-only App Services & Infrastructure Status Screen.
///
/// Features:
/// 1. Status indicators for Supabase, Gemini AI Backend, and Firebase.
/// 2. Developer test key configuration for local testing (Masked display).
/// 3. Developer diagnostic test runner.
/// 4. Never exposes production secrets or database credentials.
class DeveloperAppServicesScreen extends StatefulWidget {
  const DeveloperAppServicesScreen({super.key});

  @override
  State<DeveloperAppServicesScreen> createState() => _DeveloperAppServicesScreenState();
}

class _DeveloperAppServicesScreenState extends State<DeveloperAppServicesScreen> {
  final TextEditingController _devKeyController = TextEditingController();
  bool _isTesting = false;
  Map<String, dynamic>? _testResults;

  @override
  Widget build(BuildContext context) {
    final isSupabaseActive = SupabaseService.instance.isInitialized;
    final isFirebaseActive = Firebase.apps.isNotEmpty;
    const devKeyConfigured = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '').isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'App Services & Infrastructure',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Developer Configuration (Internal)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // 1. Supabase Status Card
            _buildStatusCard(
              title: 'Supabase Cloud Database',
              subtitle: isSupabaseActive
                  ? 'Connected (${SupabaseService.instance.activeUrl})'
                  : 'Development / Offline Fallback Mode',
              statusText: isSupabaseActive ? 'Connected' : 'Offline Fallback',
              statusColor: isSupabaseActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
              icon: Icons.cloud_done_rounded,
            ),
            const SizedBox(height: 12),

            // 2. Gemini AI Backend Card
            _buildStatusCard(
              title: 'Gemini AI Architecture',
              subtitle: isSupabaseActive
                  ? 'Server-Side Supabase Edge Function (gemini-chat)'
                  : (devKeyConfigured ? 'Local Developer Key (--dart-define)' : 'Contextual Fallback Engine Active'),
              statusText: (isSupabaseActive || devKeyConfigured) ? 'Configured' : 'Fallback Active',
              statusColor: (isSupabaseActive || devKeyConfigured) ? const Color(0xFF10B981) : const Color(0xFF64748B),
              icon: Icons.psychology_rounded,
            ),
            const SizedBox(height: 12),

            // 3. Firebase Services Card
            _buildStatusCard(
              title: 'Firebase Authentication & Firestore',
              subtitle: isFirebaseActive ? 'Connected & Active Production Backend' : 'Not Initialized',
              statusText: isFirebaseActive ? 'Connected' : 'Offline',
              statusColor: isFirebaseActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              icon: Icons.local_fire_department_rounded,
            ),
            const SizedBox(height: 24),

            // 4. Developer Connection Test Runner
            const Text(
              'Supabase & RLS Diagnostics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Run connection and Row Level Security (RLS) diagnostics on development tables.',
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isTesting ? null : _runDiagnostics,
                      icon: _isTesting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.speed_rounded, size: 18),
                      label: Text(_isTesting ? 'Running Test...' : 'Run Diagnostics Test'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    if (_testResults != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          _testResults!['message'] ?? 'Test complete.',
                          style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Color(0xFF334155)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String subtitle,
    required String statusText,
    required Color statusColor,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: statusColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isTesting = true;
      _testResults = null;
    });

    final res = await SupabaseService.instance.testConnectionAndRls();

    setState(() {
      _isTesting = false;
      _testResults = res;
    });
  }
}
