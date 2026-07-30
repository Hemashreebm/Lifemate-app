import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'diary_editor_screen.dart';

/// "Speak to Diary ðŸŽ¤" screen.
///
/// Uses the app's existing `speech_to_text` dependency to record speech,
/// convert it to text, and pass it into the editor screen for review and saving.
class DiaryVoiceScreen extends StatefulWidget {
  const DiaryVoiceScreen({super.key});

  @override
  State<DiaryVoiceScreen> createState() => _DiaryVoiceScreenState();
}

class _DiaryVoiceScreenState extends State<DiaryVoiceScreen>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController _textCtrl = TextEditingController();

  bool _isListening = false;
  bool _speechAvailable = false;
  String _statusMessage = 'Tap the microphone and start speakingâ€¦';

  late AnimationController _animCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
    _initSpeech();
  }

  @override
  void dispose() {
    _speech.stop();
    _animCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (e) {
        if (mounted) {
          setState(() {
            _isListening = false;
            _statusMessage = 'Speech error: ${e.errorMsg}';
          });
          _animCtrl.stop();
        }
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            setState(() {
              _isListening = false;
              if (_textCtrl.text.isEmpty) {
                _statusMessage = 'Tap mic to speak your memoryâ€¦';
              }
            });
            _animCtrl.stop();
          }
        }
      },
    );
    if (mounted) setState(() {});
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available on this device.')),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
        _statusMessage = 'Listening stopped. You can edit your text below.';
      });
      _animCtrl.stop();
    } else {
      setState(() {
        _isListening = true;
        _statusMessage = 'ðŸŽ¤ Listeningâ€¦ Speak your memory clearly.';
      });
      _animCtrl.repeat(reverse: true);

      await _speech.listen(
        onResult: (result) {
          setState(() {
            _textCtrl.text = result.recognizedWords;
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: 'en_IN',
      );
    }
  }

  Future<void> _proceedToSave() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please speak or type a memory first.')),
      );
      return;
    }

    await _speech.stop();
    if (!mounted) return;

    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DiaryEditorScreen(initialContent: text),
      ),
    );

    if (saved == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
      appBar: AppBar(
        title: const Text('Speak to Diary',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Status message
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _isListening ? const Color(0xFF8B5CF6) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 30),

              // Mic Pulse Button
              GestureDetector(
                onTap: _toggleListening,
                child: ScaleTransition(
                  scale: _isListening ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isListening
                            ? [const Color(0xFF8B5CF6), const Color(0xFFEC4899)]
                            : [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withAlpha(89),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isListening ? 'Tap to Stop' : 'Tap to Start Speaking',
                style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),

              const SizedBox(height: 30),

              // Recognized Text Box
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 2)),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.notes_rounded, size: 18, color: Color(0xFF8B5CF6)),
                          SizedBox(width: 8),
                          Text(
                            'Recognized Memory Text:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: TextField(
                          controller: _textCtrl,
                          maxLines: null,
                          expands: true,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1A1A2E),
                            height: 1.5,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Your spoken words will appear here. You can also edit them directly.',
                            hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _proceedToSave,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Review & Save Memory',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

