import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../services/profile_service.dart';
import '../services/task_service.dart';
import '../services/diary_service.dart';
import '../services/transaction_service.dart';
import '../services/tts_service.dart';
import '../services/translation_service.dart';
import '../services/ai_memory_service.dart';
import '../services/gemini_service.dart';
import '../services/app_language_service.dart';
import '../theme/app_theme.dart';

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
  bool _isGenerating = false;
  
  final List<Map<String, String>> _messages = [
    {
      'sender': 'assistant',
      'text': 'Hello! I am your Lifemate AI Assistant. How can I help you organize your day, review expenses, or reflect on your memories?'
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
    if (query.trim().isEmpty || _isGenerating) return;

    final userMessage = query.trim();
    _inputController.clear();

    setState(() {
      _messages.add({'sender': 'user', 'text': userMessage});
      _isGenerating = true;
    });

    _scrollToBottom();
    _generateAiResponse(userMessage);
  }

  Future<void> _generateAiResponse(String query) async {
    String response = await GeminiService.instance.generateResponse(query);

    if (mounted) {
      setState(() {
        _isGenerating = false;
        _messages.add({'sender': 'assistant', 'text': response});
      });
      _scrollToBottom();
      
      _speakResponse(response);
    }
  }

  void _showAlternativeAiModal(String userQuery) {
    final readyMadePrompt = GeminiService.instance.buildReadyMadePrompt(userQuery);
    final lang = AppLanguageService();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_mosaic_rounded, color: AppTheme.brandSeed),
                const SizedBox(width: 8),
                Text(
                  lang.getString('ai_fallback_title'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              lang.getString('ai_fallback_desc'),
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: Colors.blue),
              title: Text(lang.getString('copy_prompt')),
              onTap: () {
                Clipboard.setData(ClipboardData(text: readyMadePrompt));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contextual prompt copied to clipboard!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded, color: Colors.green),
              title: Text(lang.getString('share_prompt')),
              onTap: () {
                Navigator.pop(ctx);
                Share.share(readyMadePrompt, subject: 'Lifemate AI Query');
              },
            ),
            ListTile(
              leading: const Icon(Icons.open_in_browser_rounded, color: Colors.purple),
              title: Text(lang.getString('open_chatgpt')),
              onTap: () async {
                Navigator.pop(ctx);
                final uri = Uri.parse('https://chatgpt.com');
                if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
              },
            ),
            ListTile(
              leading: const Icon(Icons.open_in_new_rounded, color: Colors.orange),
              title: Text(lang.getString('open_gemini')),
              onTap: () async {
                Navigator.pop(ctx);
                final uri = Uri.parse('https://gemini.google.com');
                if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _speakResponse(String text) async {
    setState(() => _isSpeaking = true);
    await TtsService.instance.speak(text: text, targetLang: AppLanguage.english);
    if (mounted) {
      setState(() => _isSpeaking = false);
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
            Flexible(child: Text('Lifemate AI Assistant', style: TextStyle(fontWeight: FontWeight.w700))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              final lastUserMsg = _messages.lastWhere(
                (m) => m['sender'] == 'user',
                orElse: () => {'text': 'Help me organize my day'},
              )['text']!;
              _showAlternativeAiModal(lastUserMsg);
            },
            tooltip: 'Alternative AI Options',
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildQuickChip('Expense Summary'),
                _buildQuickChip('Pending Tasks'),
                _buildQuickChip('Diary Insights'),
                _buildQuickChip('Positive Affirmation'),
              ],
            ),
          ),

          const Divider(height: 1),

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

          if (_isGenerating)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(color: AppTheme.brandSeed),
            ),

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
