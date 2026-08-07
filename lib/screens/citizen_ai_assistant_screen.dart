import 'package:flutter/material.dart';
import '../services/ai_assistant_service.dart';
import '../services/ai_memory_service.dart';
import '../services/citizen_services_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  CITIZEN AI ASSISTANT SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class CitizenAiAssistantScreen extends StatefulWidget {
  const CitizenAiAssistantScreen({super.key});

  @override
  State<CitizenAiAssistantScreen> createState() =>
      _CitizenAiAssistantScreenState();
}

class _CitizenAiAssistantScreenState extends State<CitizenAiAssistantScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  static const _quickQuestions = [
    'What schemes am I eligible for?',
    'How do I apply for Ayushman Bharat?',
    'What is PM-Kisan and who gets it?',
    'How to get a ration card?',
    'What is DigiLocker and how to use it?',
    'Which scholarships are available for SC students?',
    'How to apply for a passport online?',
    'What is Atal Pension Yojana?',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(const _ChatMessage(
      text:
          '🇮🇳 Namaste! I am your Citizen Services Assistant.\n\nAsk me anything about government schemes, eligibility, how to apply, or any government service. I\'m here to help!',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final userText = text.trim();
    _inputCtrl.clear();

    setState(() {
      _messages.add(_ChatMessage(text: userText, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    // Build citizen-context system prompt
    final memory = AiMemoryService.instance;
    final age = memory.getFact('age') ?? 'unknown';
    final state = memory.getFact('state') ?? 'unknown';
    final occupation = memory.getFact('occupation') ?? 'unknown';
    final income = memory.getFact('annual_income') ?? 'unknown';

    // Count available schemes for context
    final schemeCount = CitizenServicesData.allSchemes.length;
    final helplineCount = CitizenServicesData.emergencyHelplines.length;

    final systemPrompt = '''
You are a knowledgeable and helpful Indian Government Schemes & Citizen Services AI Assistant for the Lifemate app.

User Profile (from memory):
- Age: $age
- State: $state
- Occupation: $occupation
- Annual Income: ₹$income

You have access to information about:
- $schemeCount+ government schemes (Central + major states)
- $helplineCount emergency helplines
- 14 digital services (DigiLocker, Aadhaar, PAN, Passport, Railway, etc.)
- Multiple scholarships

IMPORTANT RULES:
1. Only provide information based on official Government of India sources.
2. Never fabricate scheme details, amounts, or eligibility criteria.
3. Always mention the official website for verification.
4. If you don't know exact details, say so and direct to myscheme.gov.in.
5. Be helpful, concise, and in simple English (or add Hindi terms where helpful).
6. If a user asks about eligibility, consider their profile above.
7. Always mention how to apply step by step.

Respond to the user's question naturally and helpfully.
''';

    try {
      final response = await AiAssistantService.instance.sendMessage(
        '$systemPrompt\n\nUser question: $userText',
      );

      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(text: response, isUser: false));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text:
                'Sorry, I encountered an error. Please check your internet connection and try again.\n\nFor offline scheme information, visit the Government Schemes section.',
            isUser: false,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFFF6B35),
              child: Text('🇮🇳', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Citizen AI Assistant',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                Text('Government schemes & services',
                    style: TextStyle(
                        fontSize: 10, color: Color(0xFF888899))),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF8F9FE),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF1A1A2E),
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _messages.length && _isLoading) {
                  return const _TypingIndicator();
                }
                return _MessageBubble(message: _messages[i]);
              },
            ),
          ),

          // Quick questions (only when chat is just starting)
          if (_messages.length <= 1) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Quick questions:',
                    style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888899),
                        fontWeight: FontWeight.w500)),
              ),
            ),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickQuestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _sendMessage(_quickQuestions[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withAlpha(18),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: const Color(0xFFFF6B35).withAlpha(80)),
                    ),
                    child: Text(
                      _quickQuestions[i],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFFF6B35),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Input area
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                  top: BorderSide(color: Color(0xFFEEEEF5))),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      minLines: 1,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Ask about any govt scheme...',
                        hintStyle: const TextStyle(
                            color: Color(0xFFBBBBCC), fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFFF5F5FA),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(_inputCtrl.text),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isLoading
                            ? const Color(0xFFCCCCDD)
                            : const Color(0xFFFF6B35),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isLoading
                            ? Icons.hourglass_empty_rounded
                            : Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  const _ChatMessage({required this.text, required this.isUser});
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFFF6B35),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🇮🇳', style: TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUser
                    ? const Color(0xFFFF6B35)
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 13,
                  color: message.isUser
                      ? Colors.white
                      : const Color(0xFF333344),
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFFF6B35),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🇮🇳', style: TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 6,
                    height: 6 + (i == 1 ? _ctrl.value * 4 : 0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35)
                          .withAlpha((100 + _ctrl.value * 155).toInt()),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
