import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/profile_service.dart';
import '../services/task_service.dart';
import '../services/diary_service.dart';
import '../services/transaction_service.dart';
import '../services/tts_service.dart';
import '../services/translation_service.dart';
import '../services/ai_memory_service.dart';
import '../theme/app_theme.dart';

/// Intelligent Lifemate AI Assistant screen.
/// Provides smart voice & text queries across tasks, diary memories, expenses, and daily recommendations.
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;
  bool _isSpeaking = false;
  
  final List<Map<String, String>> _messages = [
    {
      'sender': 'assistant',
      'text': 'Hello! I am your Lifemate AI Assistant  How can I help you organize your day, review expenses, or reflect on your memories?'
    }
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      await _speech.initialize();
    } catch (e) {
      debugPrint('[ASSISTANT] Error initializing speech to text: $e');
    }
  }

  void _sendMessage(String query) {
    if (query.trim().isEmpty) return;

    final userMessage = query.trim();
    _inputController.clear();

    setState(() {
      _messages.add({'sender': 'user', 'text': userMessage});
    });

    _scrollToBottom();
    _generateAiResponse(userMessage);
  }

  Future<void> _generateAiResponse(String query) async {
    final lower = query.toLowerCase();
    String response = '';

    final userName = ProfileService.instance.name.isNotEmpty
        ? ProfileService.instance.name
        : 'Friend';

    // 1. Explicit Memory Ingestion ("remember that ...")
    if (lower.startsWith('remember ') || lower.contains('remember that ') || lower.contains('my favorite ') || lower.contains('my nickname is ')) {
      String key = 'Preference';
      String val = query;

      if (lower.contains('favorite food is ')) {
        key = 'Favorite Food';
        val = query.substring(query.toLowerCase().indexOf('favorite food is ') + 17).trim();
      } else if (lower.contains('nickname is ')) {
        key = 'Nickname';
        val = query.substring(query.toLowerCase().indexOf('nickname is ') + 12).trim();
      } else if (lower.startsWith('remember ')) {
        key = 'Fact';
        val = query.substring(9).trim();
      }

      await AiMemoryService.instance.remember(key: key, value: val);
      response = 'Got it, $userName! I have stored "$val" in my AI Memory.';
    } else if (lower.contains('what do you remember') || lower.contains('show memory') || lower.contains('my preferences')) {
      final facts = AiMemoryService.instance.allFacts;
      if (facts.isEmpty) {
        response = 'I don\'t have any specific facts stored in my AI Memory yet, $userName. Tell me things like "Remember my favorite food is Biryani" or "My nickname is Hema"!';
      } else {
        final list = facts.values.map((f) => '${f.key}: ${f.value}').join(', ');
        response = 'Here is what I remember about you, $userName: $list.';
      }
    } else if (lower.contains('task') || lower.contains('todo') || lower.contains('do')) {
      final tasks = TaskService.instance.all;
      final pending = tasks.where((t) => !t.isCompleted).length;
      if (tasks.isEmpty) {
        response = 'You have no tasks created yet, $userName. Tap the Tasks tab to add your first goal!';
      } else {
        response = 'You currently have $pending pending tasks out of ${tasks.length} total. Keep up the great work!';
      }
    } else if (lower.contains('expense') || lower.contains('spent') || lower.contains('money') || lower.contains('budget')) {
      final now = DateTime.now();
      final monthTx = TransactionService.instance.getForMonth(DateTime(now.year, now.month));
      final totalSpent = TransactionService.instance.totalExpense(monthTx);
      final formatted = TransactionService.formatCurrency(totalSpent);
      response = 'This month you have recorded $formatted in total expenses across ${monthTx.length} transactions.';
    } else if (lower.contains('memory') || lower.contains('diary') || lower.contains('journal')) {
      final entries = DiaryService.instance.all;
      if (entries.isEmpty) {
        response = 'You haven\'t written any diary entries yet, $userName. Recording your thoughts daily boosts mindfulness!';
      } else {
        response = 'You have recorded ${entries.length} beautiful memories in your Lifemate Diary so far.';
      }
    } else if (lower.contains('affirmation') || lower.contains('inspire') || lower.contains('quote')) {
      final affirmations = [
        'You are capable of achieving incredible things today, $userName!',
        'Small progress every day adds up to big results.',
        'Take a deep breath. You are doing much better than you think.',
        'Focus on being productive, not just busy.'
      ];
      affirmations.shuffle();
      response = affirmations.first;
    } else {
      final memoryContext = AiMemoryService.instance.buildSystemContextPrompt();
      response = 'That\'s a great question, $userName! Lifemate is actively syncing your tasks, diary entries, expenses, and AI memory facts in real-time to keep your life balanced.';
      if (memoryContext.isNotEmpty) {
        final fav = AiMemoryService.instance.getFact('Favorite Food');
        if (fav != null) {
          response += ' By the way, hope you get to enjoy some $fav today!';
        }
      }
    }

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _messages.add({'sender': 'assistant', 'text': response});
      });
      _scrollToBottom();
      
      // Auto read response using TTS if enabled
      _speakResponse(response);
    }
  }

  Future<void> _speakResponse(String text) async {
    setState(() => _isSpeaking = true);
    final ok = await TtsService.instance.speak(text: text, targetLang: AppLanguage.english);
    if (mounted) {
      setState(() => _isSpeaking = false);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('English voice playback is unavailable on this device.'),
            backgroundColor: Color(0xFFE11D48),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _toggleListen() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      final available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _inputController.text = result.recognizedWords;
            });
            if (result.finalResult) {
              setState(() => _isListening = false);
              _sendMessage(result.recognizedWords);
            }
          },
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppTheme.brandSeed),
            SizedBox(width: 10),
            Text('Lifemate AI Assistant', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),

        actions: [
          IconButton(
            icon: Icon(_isSpeaking ? Icons.volume_up : Icons.volume_mute_outlined),
            onPressed: () {
              if (_isSpeaking) {
                TtsService.instance.stop();
                setState(() => _isSpeaking = false);
              }
            },
            tooltip: 'Toggle Voice Output',
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Chip Recommendations
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildQuickChip(' Expense Summary'),
                _buildQuickChip(' Pending Tasks'),
                _buildQuickChip(' Diary Insights'),
                _buildQuickChip(' Positive Affirmation'),
              ],
            ),
          ),

          const Divider(height: 1),

          // Message Feed
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return _buildMessageBubble(msg['text'] ?? '', isUser, theme);
              },
            ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: const [
                BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, -2)),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none_rounded,
                    color: _isListening ? Colors.red : AppTheme.brandSeed,
                  ),
                  onPressed: _toggleListen,
                  tooltip: 'Voice Input',
                ),
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: _isListening ? 'Listening...' : 'Ask Lifemate AI...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppTheme.brandSeed),
                  onPressed: () => _sendMessage(_inputController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        backgroundColor: AppTheme.brandSeed.withAlpha(20),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () => _sendMessage(label),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, ThemeData theme) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.brandSeed : theme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : theme.textTheme.bodyLarge?.color,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
