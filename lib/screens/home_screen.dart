import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ask_lifemate_card.dart';
import '../widgets/feature_card.dart';
import '../services/profile_service.dart';
import '../services/transaction_service.dart';
import 'expense_tracker_screen.dart';
import 'diary_screen.dart';
import 'tasks_screen.dart';
import 'location_screen.dart';
import 'translation_screen.dart';
import 'communication_coach_screen.dart';

/// The main home screen of Lifemate.
///
/// Shows the app header, time-based greeting, AI entry card,
/// Expense Tracker quick-access, and the feature cards grid.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  double _thisMonthSpent = 0;
  bool _hasExpenseData   = false;

  /// Returns a friendly greeting based on the current time of day.
  String get _greeting {
    final name = ProfileService.instance.name.trim();
    final nameSuffix = name.isNotEmpty ? ', $name' : '';
    final hour = DateTime.now().hour;
    if (hour >= 5  && hour < 12) return 'Good morning$nameSuffix';
    if (hour >= 12 && hour < 17) return 'Good afternoon$nameSuffix';
    if (hour >= 17 && hour < 21) return 'Good evening$nameSuffix';
    return 'Good night$nameSuffix';
  }

  @override
  void initState() {
    super.initState();
    _loadExpenseSummary();
  }

  Future<void> _loadExpenseSummary() async {
    final svc = TransactionService.instance;
    await svc.load();
    final now     = DateTime.now();
    final monthTx = svc.getForMonth(DateTime(now.year, now.month));
    final spent   = svc.totalExpense(monthTx);
    if (mounted) {
      setState(() {
        _thisMonthSpent  = spent;
        _hasExpenseData  = true;
      });
    }
  }

  Future<void> _openExpenseTracker() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExpenseTrackerScreen()),
    );
    // Refresh summary when returning
    _loadExpenseSummary();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),

            // â”€â”€ App Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildHeader(theme),

            const SizedBox(height: 24),

            // â”€â”€ Greeting Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildGreetingCard(theme),

            const SizedBox(height: 22),

            // â”€â”€ Ask Lifemate AI Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            const AskLifemateCard(),

            const SizedBox(height: 24),

            // â”€â”€ Expense Tracker quick-access â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildExpenseTrackerCard(theme),

            const SizedBox(height: 28),

            // â”€â”€ Features Section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildSectionHeader(theme),

            const SizedBox(height: 14),

            // â”€â”€ Feature Cards Grid â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildFeatureGrid(context),

            const SizedBox(height: 16),

            // â”€â”€ Temporary Build Diagnostic Marker â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            const Center(
              child: Text(
                'Build check: Coach Card v1',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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

  // â”€â”€ Private builders â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lifemate',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppTheme.brandSeed,
            letterSpacing: -1.0,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your Life. Smarter. Together.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFFAAAAAA),
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.brandSeed.withAlpha(18),
            AppTheme.brandSeed.withAlpha(5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.brandSeed.withAlpha(26),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _greeting,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'How can Lifemate help you today?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF888888),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationCoachHeroCard(ThemeData theme) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CommunicationCoachScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x337C3AED),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.record_voice_over_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Communication Coach',
                    style: TextStyle(
                      fontSize: 18,
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
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseTrackerCard(ThemeData theme) {
    return GestureDetector(
      onTap: _openExpenseTracker,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentExpense.withAlpha(31),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppTheme.accentExpense.withAlpha(38),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            // Icon badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentExpense.withAlpha(26),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                color: AppTheme.accentExpense,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expense Tracker',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Show mini summary if data exists
                  if (_hasExpenseData && _thisMonthSpent > 0)
                    Text(
                      'This month: Spent ${TransactionService.formatCurrency(_thisMonthSpent)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.accentExpense,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    const Text(
                      'Track your spending, income, and balance.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 15, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Features',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Tap a card to explore what\'s coming.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFFAAAAAA),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      _FeatureData(
        title: 'Friendly Diary',
        description: 'Capture your thoughts\nand memories.',
        icon: Icons.book_outlined,
        color: AppTheme.accentDiary,
      ),
      _FeatureData(
        title: 'Real-Time Translation',
        description: 'Understand conversations\nacross languages.',
        icon: Icons.translate_rounded,
        color: AppTheme.accentTranslation,
      ),
      _FeatureData(
        title: 'Smart Location',
        description: 'Stay connected with\nplaces that matter.',
        icon: Icons.location_on_outlined,
        color: AppTheme.accentLocation,
      ),
      _FeatureData(
        title: 'Tasks & Reminders',
        description: 'Keep your day\norganized.',
        icon: Icons.check_circle_outline_rounded,
        color: AppTheme.accentTasks,
      ),
      _FeatureData(
        title: 'Communication Coach',
        description: 'Practice English speaking\nand communication.',
        icon: Icons.record_voice_over_rounded,
        color: const Color(0xFF7C3AED),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      // Disable grid's own scrolling — parent SingleChildScrollView handles it
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.88,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final f = features[index];
        return FeatureCard(
          title: f.title,
          description: f.description,
          icon: f.icon,
          color: f.color,
          onTap: () {
            if (f.title == 'Communication Coach') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CommunicationCoachScreen()),
              );
            } else if (f.title == 'Friendly Diary') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DiaryScreen()),
              );
            } else if (f.title == 'Tasks & Reminders') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TasksScreen()),
              );
            } else if (f.title == 'Smart Location') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LocationScreen()),
              );
            } else if (f.title == 'Real-Time Translation') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TranslationScreen()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${f.title} — coming soon.'),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        );
      },
    );
  }
}

/// Internal data model for a feature card entry.
class _FeatureData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _FeatureData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

