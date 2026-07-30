import 'dart:io';
import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../models/diary_meta.dart';
import '../services/diary_service.dart';
import '../widgets/audio_player_widget.dart';
import 'diary_editor_screen.dart';

/// Screen for viewing a complete My Life Book memory in detail, including photos and audio.
class DiaryDetailScreen extends StatefulWidget {
  final DiaryEntry entry;

  const DiaryDetailScreen({super.key, required this.entry});

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  late DiaryEntry _entry;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  Future<void> _editEntry() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DiaryEditorScreen(existingEntry: _entry),
      ),
    );
    if (updated == true && mounted) {
      await DiaryService.instance.load();
      final fresh = DiaryService.instance.all.firstWhere(
        (e) => e.id == _entry.id,
        orElse: () => _entry,
      );
      setState(() => _entry = fresh);
    }
  }

  Future<void> _toggleFavorite() async {
    await DiaryService.instance.toggleFavorite(_entry.id);
    setState(() {
      _entry = _entry.copyWith(favorite: !_entry.favorite);
    });
  }

  Future<void> _deleteEntry() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete this memory?'),
        content: const Text(
          'This action will permanently delete this memory from your Life Book.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await DiaryService.instance.delete(_entry.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mood = DiaryMood.findByLabel(_entry.mood);
    final lang = DiaryLanguage.findByName(_entry.language);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
      appBar: AppBar(
        title: const Text(
          'Memory Detail',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _entry.favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _entry.favorite ? const Color(0xFFEC4899) : Colors.grey,
            ),
            onPressed: _toggleFavorite,
            tooltip: 'Favorite',
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF8B5CF6)),
            onPressed: _editEntry,
            tooltip: 'Edit Entry',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
            onPressed: _deleteEntry,
            tooltip: 'Delete Entry',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card with Mood & Date
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Mood Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: mood.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(mood.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          mood.label,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: mood.color,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Language Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${lang.flag} ${lang.name}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Voice Recording Player (if attached)
            if (_entry.audioPath != null) ...[
              AudioPlayerWidget(
                audioPath: _entry.audioPath!,
                initialDurationSeconds: _entry.audioDurationSeconds,
              ),
              const SizedBox(height: 16),
            ],

            // Photos Gallery (if attached)
            if (_entry.photoPaths.isNotEmpty) ...[
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _entry.photoPaths.length,
                  itemBuilder: (ctx, i) {
                    final path = _entry.photoPaths[i];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: File(path).existsSync()
                            ? Image.file(File(path), height: 180, fit: BoxFit.cover)
                            : Container(
                                width: 140,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.broken_image),
                              ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Content Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _entry.title.isNotEmpty ? _entry.title : 'Untitled Memory',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 12),
                  // Content
                  Text(
                    _entry.content.isNotEmpty ? _entry.content : '(No text content)',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Color(0xFF334155),
                    ),
                  ),
                  if (_entry.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _entry.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#$tag',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8B5CF6),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Timestamp Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Memory Date: ${DiaryService.formatDate(_entry.createdAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
