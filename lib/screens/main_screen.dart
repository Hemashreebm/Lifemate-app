import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/diary_screen.dart';
import '../screens/assistant_screen.dart';
import '../screens/tasks_screen.dart';
import '../screens/profile_screen.dart';
import '../services/battery_optimization_service.dart';

/// The top-level navigation shell for Lifemate.
///
/// Manages the bottom [NavigationBar] and switches between the five
/// main sections using an [IndexedStack] to preserve each page's state.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  /// All top-level pages in tab order.
  static const List<Widget> _pages = [
    HomeScreen(),
    DiaryScreen(),
    AssistantScreen(),
    TasksScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Prompt for battery optimization exemption once after first frame renders.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBatteryOptimization();
    });
  }

  /// Checks if Lifemate needs battery optimization exemption.
  /// Shows a one-time dialog explaining why this is needed for reliable reminders.
  Future<void> _checkBatteryOptimization() async {
    final shouldPrompt = await BatteryOptimizationService.shouldPrompt();
    if (!shouldPrompt || !mounted) return;

    // Mark as shown so it won't appear again on next launch.
    await BatteryOptimizationService.markPromptShown();

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: Color(0xFF6B7FD7)),
            SizedBox(width: 8),
            Expanded(child: Text('Enable Reliable Reminders')),
          ],
        ),
        content: const Text(
          'To make sure your task reminders arrive on time — even when '
          'Lifemate is in the background — please tap "Allow" on the next '
          'screen to exempt Lifemate from battery optimization.\n\n'
          'Without this, your phone\'s battery saver may delay or block notifications.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Not Now'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              BatteryOptimizationService.requestIgnoreBatteryOptimizations();
            },
            child: const Text('Allow'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack renders all pages but only shows the selected one.
      // This keeps page state (scroll position, data) when switching tabs.
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book_rounded),
            label: 'Diary',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome_rounded),
            label: 'Assistant',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle_rounded),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
