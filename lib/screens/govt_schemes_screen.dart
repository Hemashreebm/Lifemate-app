import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/government_scheme.dart';
import '../repositories/government_scheme_repository.dart';
import '../repositories/local_verified_scheme_repository.dart';
import '../services/profile_service.dart';
import '../services/scheme_personalization_engine.dart';
import 'edit_profile_screen.dart';

/// Screen for displaying, searching, and personalizing verified Indian Government Schemes.
class GovtSchemesScreen extends StatefulWidget {
  final GovernmentSchemeRepository? repository;

  const GovtSchemesScreen({super.key, this.repository});

  @override
  State<GovtSchemesScreen> createState() => _GovtSchemesScreenState();
}

class _GovtSchemesScreenState extends State<GovtSchemesScreen> with SingleTickerProviderStateMixin {
  late final GovernmentSchemeRepository _repository;
  final ProfileService _profileService = ProfileService.instance;
  final TextEditingController _searchCtrl = TextEditingController();

  late TabController _tabController;

  String _selectedCategory = 'All';
  String _selectedStateFilter = 'All';
  String _query = '';
  bool _isLoading = true;

  List<GovernmentScheme> _allSchemes = [];
  List<GovernmentScheme> _recommendedSchemes = [];

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
    _tabController = TabController(length: 2, vsync: this);
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

    if (mounted) {
      setState(() {
        _allSchemes = all;
        _recommendedSchemes = recommended;
        _isLoading = false;
      });
    }
  }

  List<GovernmentScheme> _applyFilters(List<GovernmentScheme> input) {
    return input.where((scheme) {
      // Category filter
      if (_selectedCategory != 'All') {
        if (scheme.category.toLowerCase() != _selectedCategory.toLowerCase()) {
          return false;
        }
      }

      // State filter
      if (_selectedStateFilter != 'All') {
        final scState = scheme.state.toLowerCase();
        final selState = _selectedStateFilter.toLowerCase();
        if (selState == 'central only') {
          if (scState != 'central') return false;
        } else {
          if (scState != 'central' && scState != selState) return false;
        }
      }

      // Search query
      if (_query.trim().isNotEmpty) {
        final q = _query.trim().toLowerCase();
        final nameMatch = scheme.name.toLowerCase().contains(q);
        final deptMatch = scheme.governmentDepartment.toLowerCase().contains(q);
        final descMatch = scheme.description.toLowerCase().contains(q);
        final catMatch = scheme.category.toLowerCase().contains(q);
        if (!nameMatch && !deptMatch && !descMatch && !catMatch) {
          return false;
        }
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          '🇮🇳 Citizen Government Schemes',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
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
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            Tab(text: 'Recommended (${recFiltered.length})'),
            Tab(text: 'All Schemes (${allFiltered.length})'),
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
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFF7ED), Color(0xFFFEF2F2)],
                    ),
                    border: Border(bottom: BorderSide(color: Color(0xFFFED7AA))),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_outlined, size: 16, color: Color(0xFFEA580C)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Official Govt Data • Verify final eligibility on official .gov.in websites.',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9A3412)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar & State Filter Row
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: _purpleAccent, width: 1.5),
                            ),
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
                            items: _states.map((st) {
                              return DropdownMenuItem(value: st, child: Text(st));
                            }).toList(),
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
                      // Recommended Tab
                      _buildSchemeListView(recFiltered, isRecommendedTab: true),
                      // All Schemes Tab
                      _buildSchemeListView(allFiltered, isRecommendedTab: false),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSchemeListView(List<GovernmentScheme> list, {required bool isRecommendedTab}) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isRecommendedTab ? Icons.person_search_rounded : Icons.search_off_rounded,
                size: 54,
                color: const Color(0xFF94A3B8),
              ),
              const SizedBox(height: 14),
              Text(
                isRecommendedTab ? 'No Recommended Schemes Match' : 'No Schemes Found',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 6),
              Text(
                isRecommendedTab
                    ? 'Complete your Profile (State, Occupation, Age, Demographics) to enable personalized scheme matching.'
                    : 'Try adjusting your category, state filter, or search query.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
              ),
              if (isRecommendedTab) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final res = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                    if (res == true) _loadData();
                  },
                  icon: const Icon(Icons.edit_note_rounded, size: 16),
                  label: const Text('Update Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purpleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
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
                // Department & State Badge Row
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

                const SizedBox(height: 8),

                // Scheme Title
                Text(
                  scheme.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                ),

                const SizedBox(height: 6),

                // Description
                Text(
                  scheme.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.35),
                ),

                const SizedBox(height: 10),

                // Benefit Highlight Box
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

                // Recommendation Tags (if present)
                if (match.reasonTags.isNotEmpty && match.isRecommended) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: match.reasonTags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _purpleAccent),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 8),

                // Action Link Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'You may be eligible • Verify on official website',
                      style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: const [
                        Text(
                          'View & Apply',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _purpleAccent),
                        ),
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
              // Modal Grab Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Department & State Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      scheme.governmentDepartment,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                    ),
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
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: scheme.state == 'Central' ? const Color(0xFF0369A1) : const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Title
              Text(
                scheme.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      Text(
                        scheme.description,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                      ),

                      const SizedBox(height: 16),

                      // Benefits Section
                      _buildModalSectionTitle('🎁 Benefits Provided'),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Text(
                          scheme.benefits,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF15803D), height: 1.35),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Eligibility Section
                      _buildModalSectionTitle('✅ Eligibility Criteria'),
                      const SizedBox(height: 6),
                      Text(scheme.eligibility, style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.35)),
                      if (scheme.incomeCriteria != 'N/A') ...[
                        const SizedBox(height: 4),
                        Text('• Income Criteria: ${scheme.incomeCriteria}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                      if (scheme.ageCriteria != 'All ages') ...[
                        const SizedBox(height: 2),
                        Text('• Age Limit: ${scheme.ageCriteria}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],

                      const SizedBox(height: 16),

                      // Required Documents
                      if (scheme.requiredDocuments.isNotEmpty) ...[
                        _buildModalSectionTitle('📄 Required Documents'),
                        const SizedBox(height: 6),
                        ...scheme.requiredDocuments.map((doc) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFF10B981)),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(doc, style: const TextStyle(fontSize: 12, color: Color(0xFF334155)))),
                                ],
                              ),
                            )),
                        const SizedBox(height: 16),
                      ],

                      // Application Steps
                      if (scheme.applicationSteps.isNotEmpty) ...[
                        _buildModalSectionTitle('📝 How to Apply'),
                        const SizedBox(height: 6),
                        ...scheme.applicationSteps.asMap().entries.map((entry) {
                          final idx = entry.key + 1;
                          final step = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: const Color(0xFFDDD6FE),
                                  child: Text('$idx', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _purpleAccent)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(step, style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.35))),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],

                      // Official Verification Stamp & Disclaimer Banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.verified_user_outlined, size: 14, color: Color(0xFF0284C7)),
                                const SizedBox(width: 6),
                                Text(
                                  'Official Source Verified on ${scheme.lastVerifiedAt}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0369A1)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Always verify final rules and application requirements on the official government website. Lifemate does not issue official approvals.',
                              style: TextStyle(fontSize: 10, color: Color(0xFF64748B), height: 1.3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Launch Official Website Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchOfficialUrl(scheme.officialWebsiteUrl),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: Text(
                    'Apply / Visit Official Website (${Uri.parse(scheme.officialWebsiteUrl).host})',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
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

  Widget _buildModalSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
    );
  }
}
