import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../models/diary_meta.dart';
import '../services/diary_service.dart';
import 'diary_editor_screen.dart';
import 'diary_voice_screen.dart';
import 'diary_detail_screen.dart';

/// Main My Life Book dashboard screen.
///
/// Features:
///  1. Header: "My Life Book" & subtitle
///  2. Quick action buttons: ÂÂ Write Memory &  Speak to Diary
///  3. Search & Filter Bar (title, content, tags)
///  4. Calendar Date Selector Filter
///  5. Mood Overview (monthly statistics)
///  6. Favorite Memories & Recent Memories lists
class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final _searchController = TextEditingController();
  final _svc = DiaryService.instance;

  List<DiaryEntry> _entries = [];
  DateTime? _selectedDateFilter;
  bool _showFavoritesOnly = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    await _svc.load();
    _applyFilters();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    var list = _svc.search(_searchController.text);
    if (_showFavoritesOnly) {
      list = list.where((e) => e.favorite).toList();
    }
    if (_selectedDateFilter != null) {
      final d = _selectedDateFilter!;
      list = list.where((e) =>
          e.createdAt.year == d.year &&
          e.createdAt.month == d.month &&
          e.createdAt.day == d.day).toList();
    }
    setState(() {
      _entries = list;
    });
  }

  Future<void> _openWriteMemory() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const DiaryEditorScreen()),
    );
    if (result == true) {
      _loadEntries();
    }
  }

  Future<void> _openSpeakToDiary() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const DiaryVoiceScreen()),
    );
    if (result == true) {
      _loadEntries();
    }
  }

  Future<void> _openDetail(DiaryEntry entry) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DiaryDetailScreen(entry: entry)),
    );
    if (result == true) {
      _loadEntries();
    }
  }

  Future<void> _pickDateFilter() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateFilter ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        _selectedDateFilter = picked;
        _applyFilters();
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDateFilter = null;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //  1. Top Header 
              _buildHeader(),

              const SizedBox(height: 16),

              //  2. Quick Action Buttons (Write & Speak to Diary) 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'ÂÂ Write Memory',
                        color: const Color(0xFF8B5CF6),
                        onTap: _openWriteMemory,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        label: ' Speak to Diary',
                        color: const Color(0xFFEC4899),
                        onTap: _openSpeakToDiary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              //  3. Search & Filter Bar 
              _buildSearchBar(),

              const SizedBox(height: 12),

              //  4. Filter Chips (Favorites & Calendar Date) 
              _buildFilterChips(),

              const SizedBox(height: 24),

              //  5. Mood Overview Section 
              _buildMoodOverview(),

              const SizedBox(height: 24),

              //  6. Memories List Header 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      _showFavoritesOnly
                          ? 'Â¤Â Favorite Memories'
                          : _selectedDateFilter != null
                              ? ' Memories on ${DiaryService.formatShortDate(_selectedDateFilter!)}'
                              : 'Recent Memories',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_entries.length} memories',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              //  7. Entries List or Empty State 
              _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _entries.isEmpty
                      ? _buildEmptyState()
                      : _buildEntryList(),
            ],
          ),
        ),
      ),
    );
  }

  //  Section Builders 

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'My Life Book',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF8B5CF6),
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Your memories, thoughts & moments',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: TextField(
          controller: _searchController,
          onChanged: (_) => _applyFilters(),
          decoration: InputDecoration(
            icon: const Icon(Icons.search, color: Color(0xFF8B5CF6)),
            hintText: 'Search memories by text, title, or #tags...',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _applyFilters();
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // All Filter
          ChoiceChip(
            label: const Text('All Memories'),
            selected: !_showFavoritesOnly && _selectedDateFilter == null,
            selectedColor: const Color(0xFF8B5CF6).withAlpha(38),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: (!_showFavoritesOnly && _selectedDateFilter == null)
                  ? const Color(0xFF8B5CF6)
                  : const Color(0xFF64748B),
            ),
            onSelected: (_) {
              setState(() {
                _showFavoritesOnly = false;
                _selectedDateFilter = null;
                _applyFilters();
              });
            },
          ),
          const SizedBox(width: 8),

          // Favorites Filter
          ChoiceChip(
            avatar: Icon(
              Icons.favorite,
              size: 14,
              color: _showFavoritesOnly ? Colors.white : const Color(0xFFEC4899),
            ),
            label: const Text('Favorites'),
            selected: _showFavoritesOnly,
            selectedColor: const Color(0xFFEC4899),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _showFavoritesOnly ? Colors.white : const Color(0xFF64748B),
            ),
            onSelected: (val) {
              setState(() {
                _showFavoritesOnly = val;
                _applyFilters();
              });
            },
          ),
          const SizedBox(width: 8),

          // Date Calendar Filter Button
          GestureDetector(
            onTap: _pickDateFilter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedDateFilter != null
                    ? const Color(0xFF8B5CF6)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _selectedDateFilter != null
                      ? const Color(0xFF8B5CF6)
                      : const Color(0xFFCBD5E1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: _selectedDateFilter != null
                        ? Colors.white
                        : const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _selectedDateFilter != null
                        ? DiaryService.formatShortDate(_selectedDateFilter!)
                        : 'Calendar Date',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _selectedDateFilter != null
                          ? Colors.white
                          : const Color(0xFF64748B),
                    ),
                  ),
                  if (_selectedDateFilter != null) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _clearDateFilter,
                      child: const Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodOverview() {
    final now = DateTime.now();
    final stats = _svc.getMoodStats(DateTime(now.year, now.month));
    if (stats.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              ' Mood Overview  This Month',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: stats.entries.map((e) {
                final mood = DiaryMood.findByLabel(e.key);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: mood.color.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(mood.emoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        '${mood.label} (${e.value})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: mood.color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearching = _searchController.text.trim().isNotEmpty ||
        _selectedDateFilter != null ||
        _showFavoritesOnly;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.book_outlined,
                size: 48,
                color: Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? 'No memories match your filter'
                  : 'Your Life Book is waiting for its first memory',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Try clearing the search or date filter to see all entries.'
                  : 'Tap ÂÂ Write Memory or  Speak to Diary to record your thoughts.',
              style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8), height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _entries.length,
      itemBuilder: (ctx, index) {
        final entry = _entries[index];
        final mood = DiaryMood.findByLabel(entry.mood);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
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
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => _openDetail(entry),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mood + Title + Favorite Heart
                      Row(
                        children: [
                          Text(mood.emoji, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.title.isNotEmpty ? entry.title : 'Untitled Memory',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (entry.favorite) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.favorite_rounded, size: 18, color: Color(0xFFEC4899)),
                          ],
                          if (entry.photoPaths.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.photo_outlined, size: 16, color: Color(0xFF8B5CF6)),
                          ],
                          if (entry.audioPath != null) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.mic_rounded, size: 16, color: Color(0xFF10B981)),
                          ],
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Content Preview
                      Text(
                        entry.content.isNotEmpty ? entry.content : '(No text content)',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (entry.tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          children: entry.tags.take(3).map((t) {
                            return Text(
                              '#$t ',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8B5CF6),
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Date Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DiaryService.formatDate(entry.createdAt),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: Color(0xFFCBD5E1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

//  Action Button Component 

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withAlpha(31),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(64)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

