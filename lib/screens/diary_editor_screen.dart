import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../models/diary_entry.dart';
import '../models/diary_meta.dart';
import '../services/diary_service.dart';
import '../widgets/audio_player_widget.dart';

/// Screen for creating or editing a My Life Book memory entry.
///
/// Supports manual typing, Voice-to-Text pre-fill, photo attachments,
/// quick tags, favorite toggle, date selection, and voice recording attachments.
class DiaryEditorScreen extends StatefulWidget {
  final DiaryEntry? existingEntry;
  final String? initialContent;

  const DiaryEditorScreen({
    super.key,
    this.existingEntry,
    this.initialContent,
  });

  @override
  State<DiaryEditorScreen> createState() => _DiaryEditorScreenState();
}

class _DiaryEditorScreenState extends State<DiaryEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();

  DateTime _entryDate = DateTime.now();
  DiaryMood _selectedMood = DiaryMood.defaultMood;
  DiaryLanguage _selectedLanguage = DiaryLanguage.defaultLanguage;
  bool _isFavorite = false;
  List<String> _tags = [];
  List<String> _photoPaths = [];

  // Audio Recording (Preserved)
  late AudioRecorder _audioRecorder;
  bool _isRecordingAudio = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  String? _recordedAudioPath;
  int? _recordedAudioDurationSeconds;

  bool get _isEditing => widget.existingEntry != null;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();

    if (_isEditing) {
      final entry = widget.existingEntry!;
      _titleController.text = entry.title;
      _contentController.text = entry.content;
      _entryDate = entry.createdAt;
      _selectedMood = DiaryMood.findByLabel(entry.mood);
      _selectedLanguage = DiaryLanguage.findByName(entry.language);
      _isFavorite = entry.favorite;
      _tags = List.from(entry.tags);
      _photoPaths = List.from(entry.photoPaths);
      _recordedAudioPath = entry.audioPath;
      _recordedAudioDurationSeconds = entry.audioDurationSeconds;
    } else if (widget.initialContent != null) {
      _contentController.text = widget.initialContent!;
    }
  }

  @override
  void dispose() {
    _stopRecordingTimer();
    _audioRecorder.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _entryDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        _entryDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _entryDate.hour,
          _entryDate.minute,
        );
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _photoPaths.add(image.path);
        });
      }
    } catch (e) {
      _showSnackBar('Could not pick image: $e');
    }
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_tags.contains(tag)) {
        _tags.remove(tag);
      } else {
        _tags.add(tag);
      }
    });
  }

  void _addCustomTag() {
    final val = _tagController.text.trim();
    if (val.isNotEmpty && !_tags.contains(val)) {
      setState(() {
        _tags.add(val);
        _tagController.clear();
      });
    }
  }

  // ── Voice Recording (Preserved) ──────────────────────────────────────────

  Future<void> _toggleAudioRecording() async {
    if (_isRecordingAudio) {
      await _stopAudioRecording();
      return;
    }

    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        _showSnackBar('Microphone permission is required for voice recording.');
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${dir.path}/lifemate_recordings');
      if (!audioDir.existsSync()) {
        audioDir.createSync(recursive: true);
      }

      final fileName = 'rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final path = '${audioDir.path}/$fileName';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );

      setState(() {
        _isRecordingAudio = true;
        _recordingSeconds = 0;
      });

      _startRecordingTimer();
    } catch (e) {
      _showSnackBar('Could not start audio recording: $e');
    }
  }

  Future<void> _stopAudioRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _stopRecordingTimer();

      if (mounted) {
        setState(() {
          _isRecordingAudio = false;
          if (path != null && File(path).existsSync()) {
            _recordedAudioPath = path;
            _recordedAudioDurationSeconds = _recordingSeconds;
          }
        });
      }
    } catch (e) {
      _stopRecordingTimer();
      if (mounted) {
        setState(() => _isRecordingAudio = false);
        _showSnackBar('Error stopping recording: $e');
      }
    }
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _isRecordingAudio) {
        setState(() => _recordingSeconds++);
      }
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  void _deleteAudioRecording() {
    if (_recordedAudioPath != null) {
      try {
        final f = File(_recordedAudioPath!);
        if (f.existsSync()) f.deleteSync();
      } catch (_) {}
    }
    setState(() {
      _recordedAudioPath = null;
      _recordedAudioDurationSeconds = null;
    });
  }

  // ── Save Logic ─────────────────────────────────────────────────────────────

  Future<void> _saveEntry() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty && _recordedAudioPath == null && _photoPaths.isEmpty) {
      _showSnackBar('Please add a title, text, photo, or audio memory before saving.');
      return;
    }

    final now = DateTime.now();
    final service = DiaryService.instance;

    if (_isEditing) {
      final updated = widget.existingEntry!.copyWith(
        title: title.isNotEmpty ? title : 'Untitled Memory',
        content: content,
        mood: _selectedMood.label,
        language: _selectedLanguage.name,
        audioPath: _recordedAudioPath,
        clearAudioPath: _recordedAudioPath == null,
        audioDurationSeconds: _recordedAudioDurationSeconds,
        favorite: _isFavorite,
        tags: _tags,
        photoPaths: _photoPaths,
        modifiedAt: now,
      );
      await service.update(updated);
    } else {
      final newEntry = DiaryEntry(
        id: DiaryEntry.generateId(),
        title: title.isNotEmpty ? title : 'Untitled Memory',
        content: content,
        mood: _selectedMood.label,
        language: _selectedLanguage.name,
        audioPath: _recordedAudioPath,
        audioDurationSeconds: _recordedAudioDurationSeconds,
        favorite: _isFavorite,
        tags: _tags,
        photoPaths: _photoPaths,
        createdAt: _entryDate,
        modifiedAt: now,
      );
      await service.add(newEntry);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Build UI ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Memory' : 'New Memory',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        actions: [
          // Favorite heart toggle
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFavorite ? const Color(0xFFEC4899) : Colors.grey,
            ),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _saveEntry,
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Save'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Date Selector ───────────────────────────────────────────────
            _buildDatePickerCard(),
            const SizedBox(height: 16),

            // ── Mood Selector ───────────────────────────────────────────────
            _buildMoodSelector(),
            const SizedBox(height: 16),

            // ── Title Input ─────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _titleController,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
                decoration: const InputDecoration(
                  hintText: 'Give this memory a title...',
                  hintStyle: TextStyle(
                    color: Color(0xFFC4C4C4),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Main Content Area ───────────────────────────────────────────
            Container(
              constraints: const BoxConstraints(minHeight: 180),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _contentController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Color(0xFF2D3748),
                ),
                decoration: const InputDecoration(
                  hintText: 'Write your memory, thoughts, or feelings...',
                  hintStyle: TextStyle(color: Color(0xFFC4C4C4), fontSize: 15),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Photos Section ──────────────────────────────────────────────
            _buildPhotosSection(),
            const SizedBox(height: 20),

            // ── Tags Section ────────────────────────────────────────────────
            _buildTagsSection(),
            const SizedBox(height: 20),

            // ── Audio Recording Section (Preserved) ────────────────────────
            _buildAudioRecordingSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Helper Component Builders ─────────────────────────────────────────────

  Widget _buildDatePickerCard() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF8B5CF6)),
            const SizedBox(width: 10),
            Text(
              DiaryService.formatShortDate(_entryDate),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How are you feeling?',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: DiaryMood.supportedMoods.map((mood) {
              final isSelected = _selectedMood.label == mood.label;
              return GestureDetector(
                onTap: () => setState(() => _selectedMood = mood),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? mood.color.withValues(alpha: 0.15)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? mood.color : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(mood.emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        mood.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? mood.color : const Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Photos & Attachments',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
              label: const Text('Add Photo'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF8B5CF6)),
            ),
          ],
        ),
        if (_photoPaths.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _photoPaths.length,
              itemBuilder: (ctx, i) {
                final path = _photoPaths[i];
                return Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 10),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: File(path).existsSync()
                            ? Image.file(File(path), width: 90, height: 90, fit: BoxFit.cover)
                            : Container(color: Colors.grey.shade300, child: const Icon(Icons.broken_image)),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _photoPaths.removeAt(i)),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black87,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Memory Tags',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DiaryTags.quickTags.map((tag) {
            final isSelected = _tags.contains(tag);
            return GestureDetector(
              onTap: () => _toggleTag(tag),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF8B5CF6) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),

        // Custom Tag Input
        Row(
          children: [
            Expanded(
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _tagController,
                  decoration: const InputDecoration(
                    hintText: 'Add custom tag...',
                    hintStyle: TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _addCustomTag(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle_rounded, color: Color(0xFF8B5CF6)),
              onPressed: _addCustomTag,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAudioRecordingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎙️ Voice Recording Attachment (Preserved)',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        if (_recordedAudioPath != null && !_isRecordingAudio)
          AudioPlayerWidget(
            audioPath: _recordedAudioPath!,
            initialDurationSeconds: _recordedAudioDurationSeconds,
            onDelete: _deleteAudioRecording,
          )
        else
          ElevatedButton.icon(
            onPressed: _toggleAudioRecording,
            icon: Icon(
              _isRecordingAudio ? Icons.stop_rounded : Icons.mic_rounded,
              color: Colors.white,
            ),
            label: Text(
              _isRecordingAudio
                  ? 'Stop Recording (${DiaryService.formatDuration(_recordingSeconds)})'
                  : 'Record Audio Memory',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isRecordingAudio ? Colors.red : const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
      ],
    );
  }
}
