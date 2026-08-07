import 'package:flutter/material.dart';
import '../services/ai_assistant_service.dart';
import '../services/tts_service.dart';

/// Screen for 5. Conversation Simulator (Restaurant, Airport, Hotel, Interview, College, Shopping, Hospital, Customer Support)
class ConversationSimulatorScreen extends StatefulWidget {
  const ConversationSimulatorScreen({super.key});

  @override
  State<ConversationSimulatorScreen> createState() => _ConversationSimulatorScreenState();
}

class _ConversationSimulatorScreenState extends State<ConversationSimulatorScreen> {
  static const _purpleAccent = Color(0xFF7C3AED);
  static const _bgLight = Color(0xFFF8FAFC);

  String _selectedScenario = 'Restaurant';
  final List<Map<String, String>> _scenarios = const [
    {'name': 'Restaurant', 'icon': 'restaurant_rounded', 'desc': 'Order meals, ask recommendations & handle bills'},
    {'name': 'Airport', 'icon': 'flight_takeoff_rounded', 'desc': 'Check-in, baggage drop & gate inquiries'},
    {'name': 'Hotel', 'icon': 'hotel_rounded', 'desc': 'Book room, request room service & check-out'},
    {'name': 'Interview', 'icon': 'business_center_rounded', 'desc': 'Answer HR & technical questions with confidence'},
    {'name': 'College', 'icon': 'school_rounded', 'desc': 'Talk with professors, classmates & project teams'},
    {'name': 'Shopping', 'icon': 'shopping_bag_rounded', 'desc': 'Ask prices, try outfits & negotiate discounts'},
    {'name': 'Hospital', 'icon': 'local_hospital_rounded', 'desc': 'Describe symptoms & consult doctors'},
    {'name': 'Customer Support', 'icon': 'headset_mic_rounded', 'desc': 'Report issues & request refunds politely'},
  ];

  final TextEditingController _msgController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _startScenarioConversation('Restaurant');
  }

  void _startScenarioConversation(String scenarioName) {
    setState(() {
      _selectedScenario = scenarioName;
      _messages.clear();
      _messages.add({
        'role': 'assistant',
        'content': 'Welcome to the $scenarioName simulator! I am your conversation partner. How can I assist you today?',
      });
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _isSending) return;

    _msgController.clear();
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isSending = true;
    });

    try {
      final prompt = 'Roleplay as a native English conversation partner in a $_selectedScenario scenario. Respond naturally, politely, and keep your reply under 2-3 sentences. User said: "$text"';
      final response = await AiAssistantService.instance.sendMessage(prompt);

      if (mounted) {
        setState(() {
          _messages.add({'role': 'assistant', 'content': response});
          _isSending = false;
        });
        TtsService.instance.speak(text: response);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({'role': 'assistant', 'content': 'That sounds good! Could you elaborate a bit more?'});
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: Text('Simulator: $_selectedScenario', style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Scenario Selector Horizontal Strip
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _scenarios.length,
              itemBuilder: (context, idx) {
                final sc = _scenarios[idx];
                final isSelected = sc['name'] == _selectedScenario;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(sc['name']!),
                    onPressed: () => _startScenarioConversation(sc['name']!),
                    backgroundColor: isSelected ? _purpleAccent : Colors.white,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF475569), fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                );
              },
            ),
          ),

          // Message Thread
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, idx) {
                final msg = _messages[idx];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                    decoration: BoxDecoration(
                      color: isUser ? _purpleAccent : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isUser ? _purpleAccent : const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      msg['content']!,
                      style: TextStyle(color: isUser ? Colors.white : const Color(0xFF1E293B), fontSize: 14, height: 1.4),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isSending)
            const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(color: _purpleAccent, strokeWidth: 2)),

          // Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(hintText: 'Type your response...', border: InputBorder.none),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: _purpleAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
