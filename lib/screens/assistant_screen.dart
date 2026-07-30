import 'package:flutter/material.dart';
import '../widgets/coming_soon_screen.dart';

/// Assistant tab — placeholder until the AI Assistant feature is built.
class AssistantScreen extends StatelessWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoonScreen(
      icon: Icons.auto_awesome_outlined,
      title: 'AI Assistant',
      description:
          'Your intelligent life companion is on the way.\nAsk questions, get help, and stay organised.',
      color: Color(0xFF6C5CE7),
    );
  }
}
