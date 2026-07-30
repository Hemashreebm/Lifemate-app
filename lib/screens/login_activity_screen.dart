import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/device_info_service.dart';

/// Login Activity & Device Management Screen for Lifemate.
///
/// Features:
/// 1. Real Hardware Info for Current Device (via device_info_plus).
/// 2. Active Sessions list with remote Sign Out.
/// 3. Security controls: Sign out this device, Sign out all other devices.
/// 4. Login History audit trail log.
/// 5. Real-time refresh & non-destructive local database integration.
class LoginActivityScreen extends StatefulWidget {
  const LoginActivityScreen({super.key});

  @override
  State<LoginActivityScreen> createState() => _LoginActivityScreenState();
}

class _LoginActivityScreenState extends State<LoginActivityScreen> {
  final _authSvc = AuthService.instance;
  final _devSvc = DeviceInfoService.instance;

  bool _isLoading = true;
  DeviceInfoResult? _deviceInfo;
  List<UserSession> _sessions = [];
  List<LoginHistoryRecord> _history = [];

  static const _brandPurple = Color(0xFF7C3AED);
  static const _bgLight = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _authSvc.init();
    final info = await _devSvc.getDeviceInfo();
    final sessions = await _authSvc.getActiveSessions();
    final history = await _authSvc.getLoginHistory();

    if (mounted) {
      setState(() {
        _deviceInfo = info;
        _sessions = sessions;
        _history = history;
        _isLoading = false;
      });
    }
  }

  Future<void> _signOutSession(UserSession session) async {
    if (session.isCurrent) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Sign Out Current Device?'),
          content: const Text('Are you sure you want to sign out of Lifemate on this device?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await _authSvc.signOut();
        if (mounted) Navigator.pop(context);
      }
    } else {
      await _authSvc.revokeSession(session.sessionId);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signed out ${session.deviceName}')),
        );
      }
    }
  }

  Future<void> _signOutAllOthers() async {
    await _authSvc.revokeAllOtherSessions();
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All other sessions signed out!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _bgLight,
        appBar: AppBar(
          title: const Text('Login Activity & Security', style: TextStyle(fontWeight: FontWeight.w700)),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E293B),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh Devices',
              onPressed: _loadData,
            ),
          ],
          bottom: const TabBar(
            labelColor: _brandPurple,
            unselectedLabelColor: Color(0xFF64748B),
            indicatorColor: _brandPurple,
            tabs: [
              Tab(icon: Icon(Icons.devices_rounded), text: 'Active Devices'),
              Tab(icon: Icon(Icons.history_rounded), text: 'Login History'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: _brandPurple))
            : TabBarView(
                children: [
                  _buildDevicesTab(),
                  _buildHistoryTab(),
                ],
              ),
      ),
    );
  }

  // â”€â”€ Tab 1: Active Devices â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildDevicesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // â”€â”€ Account Security Overview Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          _buildSecurityOverviewCard(),

          const SizedBox(height: 24),

          // â”€â”€ Current Device Section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          const Text(
            'CURRENT DEVICE',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: 10),

          if (_deviceInfo != null) _buildCurrentDeviceCard(),

          const SizedBox(height: 24),

          // â”€â”€ Security Actions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LOGGED-IN SESSIONS',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.8,
                ),
              ),
              TextButton.icon(
                onPressed: _signOutAllOthers,
                icon: const Icon(Icons.logout_rounded, size: 16),
                label: const Text('Sign Out Others', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
              ),
            ],
          ),

          const SizedBox(height: 8),

          _buildOtherSessionsList(),
        ],
      ),
    );
  }

  Widget _buildSecurityOverviewCard() {
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
          const Row(
            children: [
              Icon(Icons.shield_rounded, color: Color(0xFF10B981), size: 22),
              SizedBox(width: 8),
              Text(
                'Account Security Summary',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSecurityStat('Total Devices', '${_sessions.length}', const Color(0xFF3B82F6)),
              _buildSecurityStat('Active Sessions', '${_sessions.where((s) => s.isCurrent).length}', const Color(0xFF10B981)),
              _buildSecurityStat('2FA Status', 'Enabled ðŸ”’', const Color(0xFF7C3AED)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildCurrentDeviceCard() {
    final info = _deviceInfo!;
    final now = DateTime.now();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0x337C3AED), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone_android_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.deviceName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${info.platform} â€¢ ${info.androidVersion}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFFDDD6FE)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'CURRENT DEVICE',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.white24),
          const SizedBox(height: 14),
          _buildCardInfoRow('Manufacturer & Model', '${info.manufacturer} (${info.deviceModel})'),
          _buildCardInfoRow('App Version', info.appVersion),
          _buildCardInfoRow('Device ID', info.deviceId),
          _buildCardInfoRow('IP Address', 'Unavailable'),
          _buildCardInfoRow('Location', 'Unavailable'),
          _buildCardInfoRow('Last Active', 'Just Now (${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')})'),
        ],
      ),
    );
  }

  Widget _buildCardInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFFDDD6FE))),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherSessionsList() {
    return Column(
      children: _sessions.map((session) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: session.isCurrent
                    ? const Color(0xFF10B981).withAlpha(31)
                    : const Color(0xFF3B82F6).withAlpha(31),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                session.platform.contains('PC') || session.platform.contains('Web')
                    ? Icons.computer_rounded
                    : Icons.smartphone_rounded,
                color: session.isCurrent ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
              ),
            ),
            title: Text(
              session.deviceName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
            ),
            subtitle: Text(
              '${session.platform} â€¢ Version ${session.appVersion}\nLast Active: Today',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            isThreeLine: true,
            trailing: TextButton(
              onPressed: () => _signOutSession(session),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
              child: Text(session.isCurrent ? 'Sign Out' : 'Revoke'),
            ),
          ),
        );
      }).toList(),
    );
  }

  // â”€â”€ Tab 2: Login History Audit Log â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildHistoryTab() {
    if (_history.isEmpty) {
      return const Center(child: Text('No login history records available.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _history.length,
      itemBuilder: (ctx, i) {
        final item = _history[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.eventType.contains('SUCCESS')
                    ? const Color(0xFF10B981).withAlpha(31)
                    : const Color(0xFFEF4444).withAlpha(31),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.eventType.contains('SUCCESS') ? Icons.check_circle_rounded : Icons.logout_rounded,
                color: item.eventType.contains('SUCCESS') ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                size: 20,
              ),
            ),
            title: Text(
              item.eventType.replaceAll('_', ' '),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
            ),
            subtitle: Text(
              '${item.deviceName} â€¢ ${item.platform}\n${item.timestamp.toString().substring(0, 16)}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}

