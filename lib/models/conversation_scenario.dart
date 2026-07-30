import 'package:flutter/material.dart';

/// Represents a single conversation turn in a practice scenario.
class ConversationTurn {
  final String lifemateLine;
  final String suggestedReply;
  final String simpleMeaning;

  const ConversationTurn({
    required this.lifemateLine,
    required this.suggestedReply,
    required this.simpleMeaning,
  });
}

/// Represents a full conversation situation/scenario.
class ConversationScenario {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<ConversationTurn> turns;

  const ConversationScenario({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.turns,
  });
}
