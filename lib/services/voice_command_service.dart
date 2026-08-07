import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/transaction.dart';
import '../models/task.dart';
import 'transaction_service.dart';
import 'task_service.dart';
import 'ai_memory_service.dart';
import 'tts_service.dart';
import 'translation_service.dart';

/// Command Execution Result after parsing spoken intent.
class VoiceCommandResult {
  final bool success;
  final String actionName;
  final String responseText;
  final int targetTabIndex; // -1 if no navigation needed

  const VoiceCommandResult({
    required this.success,
    required this.actionName,
    required this.responseText,
    this.targetTabIndex = -1,
  });
}

/// Centralized Global Voice Assistant & Navigation Command Executor for Lifemate v2.0.
class VoiceCommandService {
  static final VoiceCommandService instance = VoiceCommandService._();
  VoiceCommandService._();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _initialized = false;
  bool _isListening = false;
  bool get isListening => _isListening;

  /// Initialize speech recognition service.
  Future<bool> init() async {
    if (_initialized) return true;
    try {
      _initialized = await _speech.initialize(
        onError: (e) => debugPrint('[VOICE CMD] Error: ${e.errorMsg}'),
        onStatus: (status) => debugPrint('[VOICE CMD] Status: $status'),
      );
      debugPrint('[VOICE CMD] Initialized: $_initialized');
      return _initialized;
    } catch (e) {
      debugPrint('[VOICE CMD] Initialization exception: $e');
      return false;
    }
  }

  /// Listen for a voice command and process spoken text.
  Future<void> listenAndExecute({
    required Function(String text) onSpeechResult,
    required Function(VoiceCommandResult result) onCommandExecuted,
  }) async {
    final ready = await init();
    if (!ready) {
      onCommandExecuted(const VoiceCommandResult(
        success: false,
        actionName: 'init_failed',
        responseText: 'Speech recognition engine is unavailable on this device.',
      ));
      return;
    }

    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      return;
    }

    _isListening = true;
    await _speech.listen(
      onResult: (val) async {
        final recognizedText = val.recognizedWords;
        onSpeechResult(recognizedText);

        if (val.finalResult && recognizedText.trim().isNotEmpty) {
          _isListening = false;
          await _speech.stop();
          final result = await parseAndExecute(recognizedText);
          onCommandExecuted(result);
          if (result.responseText.isNotEmpty) {
            await TtsService.instance.speak(
              text: result.responseText,
              targetLang: AppLanguage.english,
            );
          }
        }
      },
    );
  }

  /// Stop active voice listening.
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }

  /// Parse spoken text query into concrete actions.
  Future<VoiceCommandResult> parseAndExecute(String input) async {
    final text = input.trim().toLowerCase();
    debugPrint('[VOICE CMD] Parsing intent for: "$input"');

    // 1. App Navigation Commands
    if (text.contains('expense') || text.contains('spent') || text.contains('money') || text.contains('wallet')) {
      return const VoiceCommandResult(
        success: true,
        actionName: 'navigate_expenses',
        responseText: 'Opening Expense Tracker.',
        targetTabIndex: 1,
      );
    } else if (text.contains('task') || text.contains('todo') || text.contains('goal')) {
      return const VoiceCommandResult(
        success: true,
        actionName: 'navigate_tasks',
        responseText: 'Opening Tasks and Goals.',
        targetTabIndex: 2,
      );
    } else if (text.contains('diary') || text.contains('memory') || text.contains('journal')) {
      return const VoiceCommandResult(
        success: true,
        actionName: 'navigate_diary',
        responseText: 'Opening Lifemate Diary.',
        targetTabIndex: 3,
      );
    } else if (text.contains('home') || text.contains('dashboard')) {
      return const VoiceCommandResult(
        success: true,
        actionName: 'navigate_home',
        responseText: 'Opening Home Dashboard.',
        targetTabIndex: 0,
      );
    } else if (text.contains('profile') || text.contains('settings') || text.contains('account')) {
      return const VoiceCommandResult(
        success: true,
        actionName: 'navigate_profile',
        responseText: 'Opening Profile Settings.',
        targetTabIndex: 4,
      );
    }

    // 2. Direct Action: Add Expense ("add expense 500 for groceries")
    final expenseRegex = RegExp(r'(?:add|record|spent)\s+(?:expense\s+)?(?:rs\.?|inr|\$)?\s*(\d+(?:\.\d{1,2})?)\s+(?:for|on|at)?\s*(.*)', caseSensitive: false);
    final expMatch = expenseRegex.firstMatch(text);
    if (expMatch != null) {
      final amount = double.tryParse(expMatch.group(1)!) ?? 0.0;
      final note = expMatch.group(2)!.trim();
      if (amount > 0) {
        final tx = Transaction(
          id: Transaction.generateId(),
          type: TransactionType.expense,
          amount: amount,
          category: _categorize(note),
          note: note.isNotEmpty ? note : 'Voice Expense',
          date: DateTime.now(),
          createdAt: DateTime.now(),
          source: 'voice',
        );
        await TransactionService.instance.add(tx);
        return VoiceCommandResult(
          success: true,
          actionName: 'add_expense',
          responseText: 'Added expense of ₹$amount for ${tx.note}.',
          targetTabIndex: 1,
        );
      }
    }

    // 3. Direct Action: Add Task ("add task buy milk")
    if (text.startsWith('add task ') || text.startsWith('create task ')) {
      final taskTitle = input.substring(9).trim();
      if (taskTitle.isNotEmpty) {
        final task = Task(
          id: Task.generateId(),
          title: taskTitle,
          date: DateTime.now(),
          createdAt: DateTime.now(),
        );
        await TaskService.instance.add(task);
        return VoiceCommandResult(
          success: true,
          actionName: 'add_task',
          responseText: 'Created new task: "$taskTitle".',
          targetTabIndex: 2,
        );
      }
    }

    // 4. Direct Action: AI Memory ("remember my favorite food is biryani")
    if (text.startsWith('remember ') || text.contains('my favorite ')) {
      String key = 'Preference';
      String val = input;
      if (text.contains('favorite food is ')) {
        key = 'Favorite Food';
        val = input.substring(input.toLowerCase().indexOf('favorite food is ') + 17).trim();
      } else if (text.startsWith('remember ')) {
        key = 'Fact';
        val = input.substring(9).trim();
      }
      await AiMemoryService.instance.remember(key: key, value: val);
      return VoiceCommandResult(
        success: true,
        actionName: 'save_memory',
        responseText: 'Saved to AI Memory: "$val".',
      );
    }

    // 5. Fallback Default Answer
    return VoiceCommandResult(
      success: true,
      actionName: 'ai_response',
      responseText: 'I heard "$input". Try commands like "Open Expense Tracker", "Add expense 500 for lunch", or "Create task Buy groceries".',
    );
  }

  String _categorize(String note) {
    final lower = note.toLowerCase();
    if (lower.contains('food') || lower.contains('lunch') || lower.contains('dinner') || lower.contains('swiggy')) return 'food';
    if (lower.contains('fuel') || lower.contains('petrol') || lower.contains('uber')) return 'transport';
    if (lower.contains('amazon') || lower.contains('cloth') || lower.contains('shopping')) return 'shopping';
    if (lower.contains('bill') || lower.contains('recharge') || lower.contains('jio')) return 'bills';
    return 'other';
  }
}
