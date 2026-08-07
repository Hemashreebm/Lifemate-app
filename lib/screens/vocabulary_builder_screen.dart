import 'package:flutter/material.dart';
import '../services/communication_platform_service.dart';
import '../services/tts_service.dart';

/// Screen for 3. Vocabulary Builder (Daily Life, Office, Business, Technology, Travel, Interview, Education & Favorites)
class VocabularyBuilderScreen extends StatefulWidget {
  const VocabularyBuilderScreen({super.key});

  @override
  State<VocabularyBuilderScreen> createState() => _VocabularyBuilderScreenState();
}

class _VocabularyBuilderScreenState extends State<VocabularyBuilderScreen> {
  static const _purpleAccent = Color(0xFF7C3AED);
  static const _bgLight = Color(0xFFF8FAFC);

  String _selectedCategory = 'Daily Life';
  final List<String> _categories = [
    'Daily Life',
    'Office',
    'Business',
    'Technology',
    'Travel',
    'Interview',
    'Education',
    'Favorites',
  ];

  @override
  Widget build(BuildContext context) {
    final words = CommunicationPlatformService.instance.getVocabularyByCategory(_selectedCategory);

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text('Vocabulary Builder', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Selector Chips
          SizedBox(
            height: 54,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, idx) {
                final cat = _categories[idx];
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    selectedColor: _purpleAccent,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: words.isEmpty
                ? const Center(child: Text('No bookmarked favorite words yet.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: words.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, idx) {
                      final word = words[idx];
                      final isFav = CommunicationPlatformService.instance.favoriteWords.contains(word.word);

                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: const [BoxShadow(color: Color(0x04000000), blurRadius: 6, offset: Offset(0, 2))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(word.word, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.volume_up_rounded, color: _purpleAccent, size: 22),
                                      onPressed: () => TtsService.instance.speak(text: word.word),
                                      tooltip: 'Listen Pronunciation',
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: _purpleAccent),
                                  onPressed: () async {
                                    await CommunicationPlatformService.instance.toggleFavoriteWord(word.word);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                            Text('${word.phonetic} • ${word.partOfSpeech}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
                            const SizedBox(height: 8),
                            Text(word.meaning, style: const TextStyle(fontSize: 14, color: Color(0xFF334155))),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                              child: Text('"${word.example}"', style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontStyle: FontStyle.italic)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
