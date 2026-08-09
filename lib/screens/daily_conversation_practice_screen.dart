import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/conversation_scenario.dart';
import '../services/translation_service.dart';
import '../services/tts_service.dart';

/// Daily Conversation Practice Screen
///
/// Features:
/// 1. Scripted 5-6 turn practice conversations for 8 situations.
/// 2. Chat-style UI (Lifemate on left, User on right).
/// 3.  Listen to Lifemate line &  Listen to suggestion.
/// 4.  Suggested reply & Need Help? simple meaning toggle.
/// 5.  Speak Reply (speech_to_text with direct localeId: 'en_US').
/// 6. ▶ Continue button to advance to next turn.
/// 7.  Practice Complete screen with Practice Again & Choose Another Situation.
class DailyConversationPracticeScreen extends StatefulWidget {
  final ConversationScenario scenario;

  const DailyConversationPracticeScreen({
    super.key,
    required this.scenario,
  });

  @override
  State<DailyConversationPracticeScreen> createState() =>
      _DailyConversationPracticeScreenState();
}

class _DailyConversationPracticeScreenState
    extends State<DailyConversationPracticeScreen> {
  int _currentTurnIndex = 0;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechInitialized = false;
  bool _isListening = false;
  bool _isSpeakingTts = false;
  bool _showHelp = false;
  bool _isCompleted = false;

  String _userRecognizedText = '';
  String _statusMessage = '';

  static const _purpleAccent = Color(0xFF7C3AED);

  ConversationTurn get _currentTurn => widget.scenario.turns[_currentTurnIndex];

  @override
  void dispose() {
    _speech.stop();
    TtsService.instance.stop();
    super.dispose();
  }

  void _resetTurnState() {
    _speech.stop();
    TtsService.instance.stop();
    setState(() {
      _isListening = false;
      _isSpeakingTts = false;
      _userRecognizedText = '';
      _statusMessage = '';
      _showHelp = false;
    });
  }

  void _nextTurn() {
    _resetTurnState();
    if (_currentTurnIndex < widget.scenario.turns.length - 1) {
      setState(() {
        _currentTurnIndex++;
      });
    } else {
      setState(() {
        _isCompleted = true;
      });
    }
  }

  void _restartConversation() {
    _resetTurnState();
    setState(() {
      _currentTurnIndex = 0;
      _isCompleted = false;
    });
  }

  Future<void> _speakText(String text) async {
    if (_isSpeakingTts) {
      await TtsService.instance.stop();
      if (mounted) setState(() => _isSpeakingTts = false);
      return;
    }

    _speech.stop();
    setState(() {
      _isListening = false;
      _isSpeakingTts = true;
    });

    final ok = await TtsService.instance.speak(
      text: text,
      targetLang: AppLanguage.english,
    );

    if (mounted) {
      setState(() => _isSpeakingTts = false);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('English spoken playback is not available on this device.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _startRecordingReply() async {
    await TtsService.instance.stop();
    if (mounted) setState(() => _isSpeakingTts = false);

    if (_isListening) {
      await _speech.stop();
      if (mounted) {
        setState(() {
          _isListening = false;
          _statusMessage = '';
        });
      }
      return;
    }

    if (!_speechInitialized) {
      final ok = await _speech.initialize(
        onError: (err) {
          debugPrint('[CONVERSATION PRACTICE STT] ERROR: ${err.errorMsg}');
          if (mounted) {
            setState(() {
              _isListening = false;
              _statusMessage = 'Speech error: ${err.errorMsg}';
            });
          }
        },
        onStatus: (status) {
          debugPrint('[CONVERSATION PRACTICE STT] STATUS: $status');
          if (mounted && (status == 'done' || status == 'notListening')) {
            setState(() => _isListening = false);
          }
        },
      );

      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone or Speech Recognition service not ready.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      _speechInitialized = true;
    }

    debugPrint('[CONVERSATION PRACTICE STT] CALLING speech.listen(localeId: "en_US")');

    setState(() {
      _isListening = true;
      _userRecognizedText = '';
      _statusMessage = 'Listening... Speak your reply!';
    });

    await _speech.listen(
      localeId: 'en_US',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        debugPrint(
            '[CONVERSATION PRACTICE STT] RESULT: "${result.recognizedWords}" (final: ${result.finalResult})');
        if (mounted) {
          setState(() {
            _userRecognizedText = result.recognizedWords;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.scenario.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: _isCompleted ? _buildCompletionView() : _buildPracticeView(),
    );
  }

  Widget _buildPracticeView() {
    final hasUserSpoken = _userRecognizedText.trim().isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //  Header Progress 
          _buildProgressHeader(),

          const SizedBox(height: 20),

          //  Chat Bubble: Lifemate Line (Left) 
          _buildLifemateChatBubble(_currentTurn.lifemateLine),

          const SizedBox(height: 14),

          //  Chat Bubble: User Line (Right - if spoken) 
          if (hasUserSpoken) ...[
            _buildUserChatBubble(_userRecognizedText),
            const SizedBox(height: 14),
          ],

          //  Suggested Reply & Help Card 
          _buildSuggestedReplyCard(_currentTurn),

          const SizedBox(height: 20),

          //  Microphone Speak Reply Button 
          _buildMicButton(),

          if (_statusMessage.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _isListening ? _purpleAccent : const Color(0xFF64748B),
              ),
            ),
          ],

          const SizedBox(height: 20),

          //  Encouraging Banner & Continue Button (Enabled after speaking or ready)
          if (hasUserSpoken) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF166534), size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Great! Let\'s continue.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // ▶ Continue Button
          ElevatedButton.icon(
            onPressed: _nextTurn,
            icon: const Icon(Icons.arrow_forward_rounded, size: 20),
            label: Text(
              _currentTurnIndex < widget.scenario.turns.length - 1
                  ? '▶ Continue to Next Turn'
                  : ' Finish Conversation',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(widget.scenario.icon, color: widget.scenario.color, size: 20),
              const SizedBox(width: 8),
              Text(
                'Situation: ${widget.scenario.title}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: widget.scenario.color.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Turn ${_currentTurnIndex + 1} of ${widget.scenario.turns.length}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: widget.scenario.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifemateChatBubble(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(4),
            ),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    ' Lifemate',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _purpleAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '"$text"',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _speakText(text),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _purpleAccent.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.volume_up_rounded, size: 14, color: _purpleAccent),
                      SizedBox(width: 4),
                      Text(
                        ' Listen',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _purpleAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserChatBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE9FE),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(4),
            ),
            border: Border.all(color: const Color(0xFFDDD6FE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                ' You said:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5B21B6),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '"$text"',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3B0764),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedReplyCard(ConversationTurn turn) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                ' Suggested reply:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB45309),
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _showHelp = !_showHelp),
                icon: const Icon(Icons.help_outline_rounded, size: 14),
                label: Text(_showHelp ? 'Hide help' : 'Need help?'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFB45309),
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            '"${turn.suggestedReply}"',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF78350F),
              height: 1.35,
            ),
          ),

          const SizedBox(height: 10),

          // Action row
          Row(
            children: [
              GestureDetector(
                onTap: () => _speakText(turn.suggestedReply),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withAlpha(38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.volume_up_rounded, size: 14, color: Color(0xFFB45309)),
                      SizedBox(width: 4),
                      Text(
                        ' Listen to suggestion',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (_showHelp) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFFDE68A)),
            const SizedBox(height: 10),
            Text(
              'Simple Meaning: ${turn.simpleMeaning}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF92400E),
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMicButton() {
    return ElevatedButton.icon(
      onPressed: _startRecordingReply,
      icon: Icon(
        _isListening ? Icons.stop_rounded : Icons.mic_rounded,
        size: 26,
      ),
      label: Text(
        _isListening ? '⏹ Stop' : '🎤 Speak Reply',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isListening ? const Color(0xFFEF4444) : _purpleAccent,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }

  Widget _buildCompletionView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Text('', style: TextStyle(fontSize: 54)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Practice Complete!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You completed the ${widget.scenario.title} conversation practice.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 36),

          //  Practice Again
          ElevatedButton.icon(
            onPressed: _restartConversation,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: const Text(' Practice Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _purpleAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),

          const SizedBox(height: 14),

          // 🏠 Choose Another Situation
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.home_rounded, size: 20),
            label: const Text('🏠 Choose Another Situation'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _purpleAccent,
              side: const BorderSide(color: _purpleAccent, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

