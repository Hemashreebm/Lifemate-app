import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/government_scheme.dart';
import '../repositories/government_scheme_repository.dart';
import '../repositories/local_verified_scheme_repository.dart';
import '../services/profile_service.dart';
import '../services/scheme_personalization_engine.dart';
import '../services/interested_scheme_service.dart';
import '../services/app_language_service.dart';
import 'edit_profile_screen.dart';

/// Screen for displaying, searching, and personalizing verified Indian Government Schemes,
/// with Interest tracking and Deadline Reminder notifications.
class GovtSchemesScreen extends StatefulWidget {
  final GovernmentSchemeRepository? repository;

  const GovtSchemesScreen({super.key, this.repository});

  @override
  State<GovtSchemesScreen> createState() => _GovtSchemesScreenState();
}

class _GovtSchemesScreenState extends State<GovtSchemesScreen> with SingleTickerProviderStateMixin {
  late final GovernmentSchemeRepository _repository;
  final ProfileService _profileService = ProfileService.instance;
  final InterestedSchemeService _interestedService = InterestedSchemeService();
  final TextEditingController _searchCtrl = TextEditingController();

  late TabController _tabController;

  String _selectedCategory = 'All';
  String _selectedStateFilter = 'All';
  String _query = '';
  bool _isLoading = true;

  List<GovernmentScheme> _allSchemes = [];
  List<GovernmentScheme> _recommendedSchemes = [];
  Set<String> _interestedSchemeIds = {};

  static const List<String> _categories = [
    'All',
    'Agriculture',
    'MSME',
    'Scholarships',
    'Women',
    'Housing',
    'Healthcare',
    'Pension',
    'Financial Support',
  ];

  static const List<String> _states = [
    'All',
    'Central Only',
    'Andhra Pradesh',
    'Telangana',
    'Karnataka',
    'Tamil Nadu',
    'Maharashtra',
    'Delhi NCR',
  ];

  static const _purpleAccent = Color(0xFF7C3AED);

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? LocalVerifiedSchemeRepository.instance;
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _profileService.load();
    final all = await _repository.getAllSchemes();
    final recommended = await _repository.getRecommendedSchemes(_profileService);
    final interestedItems = await _interestedService.getInterestedSchemes();
    final interestedIds = interestedItems.map((e) => e.schemeId).toSet();

    if (mounted) {
      setState(() {
        _allSchemes = all;
        _recommendedSchemes = recommended;
        _interestedSchemeIds = interestedIds;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleInterest(GovernmentScheme scheme) async {
    final isInterested = _interestedSchemeIds.contains(scheme.id);
    if (isInterested) {
      await _interestedService.removeInterestedScheme(scheme.id);
      _interestedSchemeIds.remove(scheme.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${scheme.name} removed from Interested schemes.')),
        );
      }
    } else {
      final deadlineText = scheme.lastVerifiedAt.contains('20')
          ? scheme.lastVerifiedAt
          : 'Open / Ongoing';

      final item = InterestedSchemeItem(
        schemeId: scheme.id,
        schemeName: scheme.name,
        deadlineText: deadlineText,
        savedAt: DateTime.now(),
      );
      await _interestedService.saveInterestedScheme(item);
      _interestedSchemeIds.add(scheme.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${scheme.name} saved to Interested schemes!'),
            action: SnackBarAction(
              label: 'Set Reminder',
              textColor: Colors.amber,
              onPressed: () => _showReminderDialog(scheme),
            ),
          ),
        );
      }
    }
    setState(() {});
  }

  Future<void> _showReminderDialog(GovernmentScheme scheme) async {
    int selectedDays = 7;
    final deadlineText = scheme.lastVerifiedAt;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Flexible(
          child: Text('Scheme Deadline Reminder', overflow: TextOverflow.ellipsis),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scheme: ${scheme.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Deadline: $deadlineText'),
            const SizedBox(height: 12),
            const Text('Remind me before deadline:'),
            DropdownButton<int>(
              value: selectedDays,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 30, child: Text('30 Days Before')),
                DropdownMenuItem(value: 14, child: Text('14 Days Before')),
                DropdownMenuItem(value: 7, child: Text('7 Days Before')),
                DropdownMenuItem(value: 3, child: Text('3 Days Before')),
                DropdownMenuItem(value: 1, child: Text('1 Day Before')),
              ],
              onChanged: (val) {
                if (val != null) selectedDays = val;
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'Disclaimer: According to available scheme information. Please verify at official government source.',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await _interestedService.enableDeadlineReminder(
                schemeId: scheme.id,
                schemeName: scheme.name,
                deadlineText: deadlineText,
                daysBefore: selectedDays,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Reminder scheduled for $selectedDays days before deadline!'
                          : 'Scheme has no future deadline to schedule reminder.',
                    ),
                  ),
                );
              }
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  List<GovernmentScheme> _applyFilters(List<GovernmentScheme> input) {
    return input.where((scheme) {
      if (_selectedCategory != 'All') {
        if (scheme.category.toLowerCase() != _selectedCategory.toLowerCase()) return false;
      }

      if (_selectedStateFilter != 'All') {
        final scState = scheme.state.toLowerCase();
        final selState = _selectedStateFilter.toLowerCase();
        if (selState == 'central only') {
          if (scState != 'central') return false;
        } else {
          if (scState != 'central' && scState != selState) return false;
        }
      }

      if (_query.trim().isNotEmpty) {
        final q = _query.trim().toLowerCase();
        final nameMatch = scheme.name.toLowerCase().contains(q);
        final deptMatch = scheme.governmentDepartment.toLowerCase().contains(q);
        final descMatch = scheme.description.toLowerCase().contains(q);
        final catMatch = scheme.category.toLowerCase().contains(q);
        if (!nameMatch && !deptMatch && !descMatch && !catMatch) return false;
      }

      return true;
    }).toList();
  }

  Future<void> _launchOfficialUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open $urlString')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching website: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recFiltered = _applyFilters(_recommendedSchemes);
    final allFiltered = _applyFilters(_allSchemes);
    final interestedSchemes = _allSchemes.where((s) => _interestedSchemeIds.contains(s.id)).toList();
    final interestedFiltered = _applyFilters(interestedSchemes);

    final lang = AppLanguageService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          '🇮🇳 ${lang.getString("govt_schemes")}',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: _purpleAccent,
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: _purpleAccent,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          tabs: [
            Tab(text: 'Recommended (${recFiltered.length})'),
            Tab(text: 'Interested (${interestedFiltered.length})'),
            Tab(text: 'All (${allFiltered.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _purpleAccent))
          : Column(
              children: [
                // Top Verification Disclaimer Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFFFFF7ED), Color(0xFFFEF2F2)]),
                    border: Border(bottom: BorderSide(color: Color(0xFFFED7AA))),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_outlined, size: 16, color: Color(0xFFEA580C)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          lang.getString('scheme_disclaimer'),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF9A3412)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar & Filter
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => setState(() => _query = v),
                          decoration: InputDecoration(
                            hintText: 'Search scheme or department...',
                            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 16),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      setState(() => _query = '');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _purpleAccent, width: 1.5)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStateFilter,
                            icon: const Icon(Icons.tune_rounded, size: 18, color: _purpleAccent),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                            items: _states.map((st) => DropdownMenuItem(value: st, child: Text(st))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedStateFilter = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Category Chips
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, idx) {
                      final cat = _categories[idx];
                      final isSel = cat == _selectedCategory;
                      return ChoiceChip(
                        label: Text(cat, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.w700 : FontWeight.w500)),
                        selected: isSel,
                        selectedColor: const Color(0xFFDDD6FE),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(color: isSel ? _purpleAccent : const Color(0xFF475569)),
                        side: BorderSide(color: isSel ? _purpleAccent : const Color(0xFFE2E8F0)),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedCategory = cat);
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSchemeListView(recFiltered, isRecommendedTab: true),
                      _buildSchemeListView(interestedFiltered, isInterestedTab: true),
                      _buildSchemeListView(allFiltered, isRecommendedTab: false),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSchemeListView(List<GovernmentScheme> list, {bool isRecommendedTab = false, bool isInterestedTab = false}) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isInterestedTab
                    ? Icons.bookmark_border_rounded
                    : isRecommendedTab
                        ? Icons.person_search_rounded
                        : Icons.search_off_rounded,
                size: 54,
                color: const Color(0xFF94A3B8),
              ),
              const SizedBox(height: 14),
              Text(
                isInterestedTab
                    ? 'No Saved Interested Schemes'
                    : isRecommendedTab
                        ? 'No Recommended Schemes Match'
                        : 'No Schemes Found',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 6),
              Text(
                isInterestedTab
                    ? 'Tap the star/save icon on any scheme to mark it as interested.'
                    : isRecommendedTab
                        ? 'Complete your Profile to enable personalized scheme matching.'
                        : 'Try adjusting your category, state filter, or search query.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final scheme = list[idx];
        final match = SchemePersonalizationEngine.evaluate(scheme, _profileService);
        return _buildSchemeCard(scheme, match);
      },
    );
  }

  Widget _buildSchemeCard(GovernmentScheme scheme, SchemeMatchResult match) {
    final isInterested = _interestedSchemeIds.contains(scheme.id);
    final lang = AppLanguageService();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isInterested ? _purpleAccent.withValues(alpha: 0.5) : const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _showSchemeDetailsModal(scheme, match),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        scheme.governmentDepartment,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isInterested ? Icons.star_rounded : Icons.star_border_rounded,
                            color: isInterested ? Colors.amber : const Color(0xFF94A3B8),
                            size: 24,
                          ),
                          onPressed: () => _toggleInterest(scheme),
                          tooltip: isInterested ? lang.getString('remove_interest') : lang.getString('interested'),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: scheme.state == 'Central' ? const Color(0xFFE0F2FE) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            scheme.state == 'Central' ? '🇮🇳 Central' : '📍 ${scheme.state}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: scheme.state == 'Central' ? const Color(0xFF0369A1) : const Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  scheme.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 6),
                Text(
                  scheme.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.35),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.card_giftcard_rounded, size: 16, color: Color(0xFF16A34A)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          scheme.benefits,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Deadline: ${lang.getString("deadline_open")}',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                    const Row(
                      children: [
                        Text('View & Apply', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _purpleAccent)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios_rounded, size: 12, color: _purpleAccent),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSchemeDetailsModal(GovernmentScheme scheme, SchemeMatchResult match) {
    final isInterested = _interestedSchemeIds.contains(scheme.id);
    final lang = AppLanguageService();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      scheme.governmentDepartment,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _toggleInterest(scheme);
                    },
                    icon: Icon(isInterested ? Icons.star_rounded : Icons.star_border_rounded, size: 16),
                    label: Text(isInterested ? lang.getString('interested') : lang.getString('save_scheme')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isInterested ? Colors.amber : _purpleAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(scheme.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(scheme.description, style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4)),
                      const SizedBox(height: 16),
                      Text('🎁 Benefits Provided', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBBF7D0))),
                        child: Text(scheme.benefits, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF15803D))),
                      ),
                      const SizedBox(height: 16),
                      Text('✅ Eligibility Criteria', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(scheme.eligibility, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lang.getString('scheme_disclaimer'), style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchOfficialUrl(scheme.officialWebsiteUrl),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: Text('Apply / Visit Official Website (${Uri.parse(scheme.officialWebsiteUrl).host})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purpleAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
