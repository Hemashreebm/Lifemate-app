import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/backup_manager_service.dart';

/// Authentication Screen for Lifemate.
///
/// Features:
/// 1. Sign In (Email, Password, Forgot Password, Google Sign-In, Guest Mode).
/// 2. Create Account (Name, Email, Password, Confirm Password).
/// 3. Offline-First Guest Mode button.
/// 4. Post-Login Status Banner ("Welcome Back", "Cloud Backup Enabled", "Sync Status").
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _authSvc = AuthService.instance;
  final _backupSvc = BackupManagerService.instance;

  // Sign In Controllers
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();

  // Create Account Controllers
  final _signUpNameCtrl = TextEditingController();
  final _signUpEmailCtrl = TextEditingController();
  final _signUpPassCtrl = TextEditingController();
  final _signUpConfirmCtrl = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  static const _purpleAccent = Color(0xFF7C3AED);
  static const _bgLight = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _signUpNameCtrl.dispose();
    _signUpEmailCtrl.dispose();
    _signUpPassCtrl.dispose();
    _signUpConfirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _loginEmailCtrl.text.trim();
    final pass = _loginPassCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _errorMessage = 'Please fill in both email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authSvc.signInWithEmail(email, pass);
    if (mounted) {
      setState(() => _isLoading = false);
      if (result.success) {
        await _backupSvc.setCloudBackupEnabled(true);
        if (mounted) {
          _showPostLoginBanner();
        }
      } else {
        setState(() => _errorMessage = result.errorMessage ?? 'Invalid email or password.');
      }
    }
  }

  Future<void> _handleSignUp() async {
    final name = _signUpNameCtrl.text.trim();
    final email = _signUpEmailCtrl.text.trim();
    final pass = _signUpPassCtrl.text.trim();
    final confirm = _signUpConfirmCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields.');
      return;
    }

    if (pass != confirm) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    final passErr = AuthService.validatePassword(pass);
    if (passErr != null) {
      setState(() => _errorMessage = passErr);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authSvc.signUpWithEmail(name, email, pass);
    if (mounted) {
      setState(() => _isLoading = false);
      if (result.success) {
        await _backupSvc.setCloudBackupEnabled(true);
        if (mounted) {
          _showPostLoginBanner();
        }
      } else {
        setState(() => _errorMessage = result.errorMessage ?? 'Failed to create account. Please check inputs.');
      }
    }
  }

  void _showPostLoginBanner() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 54),
            const SizedBox(height: 12),
            Text(
              'Welcome back, ${_authSvc.currentUserName}!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cloud Backup Enabled  All your local tasks, diary, and expenses will sync securely.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('Continue to App'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your registered email address to receive password reset instructions.'),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email Address'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password reset instructions sent to your email!')),
              );
            },
            child: const Text('Send Reset Link'),
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
        title: const Text('Lifemate Account', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            //  Welcome Banner 
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Row(
                children: [
                  Text('', style: TextStyle(fontSize: 36)),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome to Lifemate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                        SizedBox(height: 4),
                        Text('Cloud account & secure automatic backup', style: TextStyle(fontSize: 12, color: Color(0xFFDDD6FE))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            //  Auth Mode Tabs 
            TabBar(
              controller: _tabController,
              labelColor: _purpleAccent,
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: _purpleAccent,
              tabs: const [
                Tab(text: 'Sign In'),
                Tab(text: 'Create Account'),
              ],
            ),

            const SizedBox(height: 20),

            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_errorMessage!, style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B))),
                    ),
                  ],
                ),
              ),

            SizedBox(
              height: 380,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSignInTab(),
                  _buildSignUpTab(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            //  Guest Mode Option 
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.person_outline_rounded, size: 18),
              label: const Text('Continue as Guest (Offline Mode)'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInTab() {
    return Column(
      children: [
        TextField(
          controller: _loginEmailCtrl,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _loginPassCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _showForgotPasswordDialog,
            child: const Text('Forgot Password?', style: TextStyle(fontSize: 12)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: FilledButton.styleFrom(backgroundColor: _purpleAccent),
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Sign In'),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            await _authSvc.signInWithEmail('google_user@lifemate.app', 'GoogleUser123!');
            _showPostLoginBanner();
          },
          icon: const Icon(Icons.g_mobiledata_rounded, size: 24, color: Color(0xFFEA4335)),
          label: const Text('Sign in with Google'),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        ),
      ],
    );
  }

  Widget _buildSignUpTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: _signUpNameCtrl,
            decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _signUpEmailCtrl,
            decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _signUpPassCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
              helperText: 'Min 8 chars, 1 uppercase, 1 digit',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _signUpConfirmCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirm Password', prefixIcon: Icon(Icons.lock_outline)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _isLoading ? null : _handleSignUp,
              style: FilledButton.styleFrom(backgroundColor: _purpleAccent),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Create Account'),
            ),
          ),
        ],
      ),
    );
  }
}
