import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/citizen_services_data.dart';
import '../services/ai_assistant_service.dart';
import '../services/ai_memory_service.dart';
import '../services/profile_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  GOVERNMENT SCHEMES SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class GovtSchemesScreen extends StatefulWidget {
  const GovtSchemesScreen({super.key});

  @override
  State<GovtSchemesScreen> createState() => _GovtSchemesScreenState();
}

class _GovtSchemesScreenState extends State<GovtSchemesScreen> {
  String _selectedCategory = 'All';
  String _selectedLevel = 'All';
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = CitizenServicesData.instance.filterSchemes(
      category: _selectedCategory,
      level: _selectedLevel,
      query: _query,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Government Schemes',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: const Color(0xFFF8F9FE),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF1A1A2E),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search schemes...',
                hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFAAAAAA)),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE8E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE8E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                ),
              ),
            ),
          ),

          // Category filter
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: CitizenServicesData.schemeCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = CitizenServicesData.schemeCategories[i];
                final selected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF6366F1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF6366F1)
                            : const Color(0xFFE0E0F0),
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF666680),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // State filter
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: CitizenServicesData.majorStates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final st = CitizenServicesData.majorStates[i];
                final selected = _selectedLevel == st;
                return GestureDetector(
                  onTap: () => setState(() =>
                      _selectedLevel = selected ? 'All' : st),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFFF6B35).withAlpha(220)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFFFF6B35)
                            : const Color(0xFFE8E8F0),
                      ),
                    ),
                    child: Text(
                      st,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF888899),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${filtered.length} schemes found',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888899),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Schemes list
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 48, color: Color(0xFFCCCCDD)),
                        SizedBox(height: 12),
                        Text('No schemes found',
                            style: TextStyle(
                                color: Color(0xFF888899),
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) =>
                        _SchemeCard(scheme: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SchemeCard extends StatelessWidget {
  final GovernmentScheme scheme;
  const _SchemeCard({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => SchemeDetailScreen(scheme: scheme)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: scheme.color, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.color.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(scheme.icon, color: scheme.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scheme.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: scheme.color.withAlpha(18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          scheme.category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: scheme.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: scheme.level == 'Central'
                              ? const Color(0xFF6366F1).withAlpha(18)
                              : const Color(0xFFFF6B35).withAlpha(18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          scheme.level,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: scheme.level == 'Central'
                                ? const Color(0xFF6366F1)
                                : const Color(0xFFFF6B35),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    scheme.benefits,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF666680),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFCCCCDD), size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SCHEME DETAIL SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class SchemeDetailScreen extends StatefulWidget {
  final GovernmentScheme scheme;
  const SchemeDetailScreen({super.key, required this.scheme});

  @override
  State<SchemeDetailScreen> createState() => _SchemeDetailScreenState();
}

class _SchemeDetailScreenState extends State<SchemeDetailScreen> {
  bool _checkingEligibility = false;
  Map<String, dynamic>? _eligibilityResult;

  Future<void> _checkEligibility() async {
    setState(() {
      _checkingEligibility = true;
      _eligibilityResult = null;
    });

    // Gather from profile + memory
    final profile = ProfileService.instance;
    final memory = AiMemoryService.instance;

    final ageStr = memory.getFact('age') ?? '25';
    final age = int.tryParse(ageStr) ?? 25;
    final gender = memory.getFact('gender') ?? 'male';
    final occupation = memory.getFact('occupation') ?? 'all';
    final incomeStr = memory.getFact('annual_income') ?? '0';
    final income = double.tryParse(incomeStr) ?? 0;
    final state = memory.getFact('state') ??
        (profile.name.isNotEmpty ? 'All' : 'All');

    // If profile is incomplete, show bottom sheet to collect info
    if (age == 25 && gender == 'male' && income == 0) {
      if (!mounted) return;
      await _showProfileQuickFill();
      setState(() => _checkingEligibility = false);
      return;
    }

    final result = CitizenServicesData.instance.checkEligibility(
      widget.scheme,
      age: age,
      gender: gender,
      occupation: occupation,
      annualIncome: income,
      state: state,
    );

    if (mounted) {
      setState(() {
        _eligibilityResult = result;
        _checkingEligibility = false;
      });
    }
  }

  Future<void> _showProfileQuickFill() async {
    final ageCtrl = TextEditingController();
    String gender = 'male';
    String occupation = 'student';
    final incomeCtrl = TextEditingController();
    String state = 'Central';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setBS) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 24, right: 24, top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quick Profile for Eligibility Check',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: ageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Your Age', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: gender,
                decoration:
                    const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (v) => setBS(() => gender = v ?? 'male'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: occupation,
                decoration:
                    const InputDecoration(labelText: 'Occupation', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('Student')),
                  DropdownMenuItem(value: 'farmer', child: Text('Farmer')),
                  DropdownMenuItem(value: 'business owner', child: Text('Business Owner')),
                  DropdownMenuItem(value: 'salaried', child: Text('Salaried Employee')),
                  DropdownMenuItem(value: 'daily-wage worker', child: Text('Daily Wage Worker')),
                  DropdownMenuItem(value: 'unemployed', child: Text('Unemployed')),
                  DropdownMenuItem(value: 'professional', child: Text('Professional')),
                ],
                onChanged: (v) => setBS(() => occupation = v ?? 'student'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: incomeCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Annual Family Income (₹)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: state,
                decoration:
                    const InputDecoration(labelText: 'Your State', border: OutlineInputBorder()),
                items: CitizenServicesData.majorStates
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setBS(() => state = v ?? 'Central'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () async {
                    final age = int.tryParse(ageCtrl.text) ?? 25;
                    final income = double.tryParse(incomeCtrl.text) ?? 0;
                    await AiMemoryService.instance.remember(
                        key: 'age', value: '$age');
                    await AiMemoryService.instance.remember(
                        key: 'gender', value: gender);
                    await AiMemoryService.instance.remember(
                        key: 'occupation', value: occupation);
                    await AiMemoryService.instance.remember(
                        key: 'annual_income', value: '$income');
                    await AiMemoryService.instance.remember(
                        key: 'state', value: state);
                    if (ctx.mounted) Navigator.pop(ctx);
                    await _checkEligibility();
                  },
                  child: const Text('Check Eligibility'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scheme;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: s.color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [s.color, s.color.withAlpha(180)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(40),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(s.category,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(40),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(s.level,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.ministry,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withAlpha(200),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Eligibility AI button
                  GestureDetector(
                    onTap: _checkEligibility,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withAlpha(60),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(40),
                              shape: BoxShape.circle,
                            ),
                            child: _checkingEligibility
                                ? const SizedBox(
                                    width: 18, height: 18,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Icon(Icons.psychology_rounded,
                                    color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Am I Eligible?',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                                Text('AI checks your eligibility instantly',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFDDD6FE))),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                  ),

                  // Eligibility result
                  if (_eligibilityResult != null) ...[
                    const SizedBox(height: 12),
                    _buildEligibilityResult(_eligibilityResult!),
                  ],

                  const SizedBox(height: 20),

                  // Benefits
                  _buildSection('🎁 Benefits', s.benefits),

                  // Eligibility
                  _buildSection('✅ Eligibility', s.eligibility),

                  // Documents
                  _buildListSection('📄 Required Documents', s.documents),

                  // How to apply
                  _buildStepsSection('📋 How to Apply', s.howToApplySteps),

                  const SizedBox(height: 20),

                  // Official link
                  GestureDetector(
                    onTap: () => _launchUrl(s.officialUrl),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFF6366F1).withAlpha(80)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.open_in_new_rounded,
                              color: Color(0xFF6366F1), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Apply / Learn More',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: Color(0xFF6366F1))),
                                Text(s.officialUrl,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF888899)),
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilityResult(Map<String, dynamic> result) {
    final eligible = result['eligible'] as bool;
    final reasons = result['reasons'] as List<String>;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: eligible
            ? const Color(0xFF16A34A).withAlpha(15)
            : const Color(0xFFDC2626).withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: eligible
              ? const Color(0xFF16A34A).withAlpha(60)
              : const Color(0xFFDC2626).withAlpha(60),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                eligible
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: eligible
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFDC2626),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                eligible ? 'You appear eligible!' : 'May not be eligible',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: eligible
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          if (reasons.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...reasons.map((r) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Color(0xFF888899))),
                      Expanded(
                        child: Text(r,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF555566))),
                      ),
                    ],
                  ),
                )),
          ],
          if (eligible) ...[
            const SizedBox(height: 8),
            const Text(
              'Scroll down to see How to Apply →',
              style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF16A34A),
                  fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(content,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF444455), height: 1.5)),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildListSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_rounded,
                              size: 14, color: Color(0xFF16A34A)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(d,
                                style: const TextStyle(
                                    fontSize: 13, color: Color(0xFF444455))),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStepsSection(String title, List<String> steps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: steps.asMap().entries.map((e) {
              final i = e.key;
              final step = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6366F1),
                        shape: BoxShape.circle,
                      ),
                      child: Text('${i + 1}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(step,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF444455),
                              height: 1.4)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
