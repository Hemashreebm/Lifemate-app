import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/citizen_services_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  SCHOLARSHIP FINDER SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class ScholarshipFinderScreen extends StatefulWidget {
  const ScholarshipFinderScreen({super.key});

  @override
  State<ScholarshipFinderScreen> createState() =>
      _ScholarshipFinderScreenState();
}

class _ScholarshipFinderScreenState extends State<ScholarshipFinderScreen> {
  String _courseLevel = 'UG';
  String _category = 'General';
  String _state = 'All';
  final TextEditingController _incomeCtrl = TextEditingController();
  List<Scholarship>? _results;
  bool _searched = false;

  static const _courseLevels = [
    'Class 9',
    'Class 10',
    '11th',
    '12th',
    'Diploma',
    'ITI',
    'UG',
    'PG',
    'PhD',
    'BE',
    'MBBS',
    'B.Tech',
    'MBA',
  ];

  static const _categories = [
    'General',
    'OBC',
    'SC',
    'ST',
    'Minority',
    'Minority',
    'EWS',
  ];

  @override
  void dispose() {
    _incomeCtrl.dispose();
    super.dispose();
  }

  void _search() {
    final income = double.tryParse(_incomeCtrl.text.replaceAll(',', '')) ?? 0;
    final results = CitizenServicesData.instance.filterScholarships(
      courseLevel: _courseLevel,
      category: _category,
      state: _state,
      familyIncome: income,
    );
    setState(() {
      _results = results;
      _searched = true;
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Scholarship Finder',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: const Color(0xFFF8F9FE),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF1A1A2E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🎓 Find Your Scholarship',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(
                          'Match from 50+ government scholarships',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withAlpha(200)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.school_rounded,
                      color: Colors.white, size: 40),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Filters
            const Text('Tell us about your profile',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 12),

            _buildDropdown(
              label: 'Current Course / Level',
              value: _courseLevel,
              items: _courseLevels,
              onChanged: (v) => setState(() => _courseLevel = v ?? 'UG'),
            ),
            const SizedBox(height: 12),

            _buildDropdown(
              label: 'Category',
              value: _category,
              items: _categories,
              onChanged: (v) => setState(() => _category = v ?? 'General'),
            ),
            const SizedBox(height: 12),

            _buildDropdown(
              label: 'State',
              value: _state,
              items: ['All', ...CitizenServicesData.majorStates],
              onChanged: (v) => setState(() => _state = v ?? 'All'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _incomeCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Annual Family Income (₹)',
                hintText: 'e.g. 150000',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 18),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFE0E0F0))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFE0E0F0))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF7C3AED), width: 1.5)),
              ),
            ),
            const SizedBox(height: 20),

            // Search button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _search,
                icon: const Icon(Icons.search_rounded),
                label: const Text('Find Matching Scholarships',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),

            const SizedBox(height: 24),

            // Results
            if (_searched) ...[
              if (_results == null || _results!.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off_rounded,
                          size: 40, color: Color(0xFFCCCCDD)),
                      const SizedBox(height: 8),
                      const Text('No exact matches found',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF888899))),
                      const SizedBox(height: 4),
                      const Text(
                          'Try changing income or category filters.',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFFAAAAAA))),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () =>
                            _launchUrl('https://scholarships.gov.in'),
                        child: const Text('Browse all on scholarships.gov.in →',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF7C3AED),
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                )
              else ...[
                Text(
                  '${_results!.length} scholarships found',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF16A34A)),
                ),
                const SizedBox(height: 12),
                ..._results!.map((s) => _ScholarshipCard(
                    scholarship: s, onLaunch: () => _launchUrl(s.officialUrl))),
              ],
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0F0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0F0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF7C3AED), width: 1.5)),
      ),
      items: items
          .map((i) => DropdownMenuItem(value: i, child: Text(i)))
          .toList(),
    );
  }
}

class _ScholarshipCard extends StatelessWidget {
  final Scholarship scholarship;
  final VoidCallback onLaunch;
  const _ScholarshipCard(
      {required this.scholarship, required this.onLaunch});

  @override
  Widget build(BuildContext context) {
    final s = scholarship;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
            left: BorderSide(color: Color(0xFF7C3AED), width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.name,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 4),
          Text(s.provider,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF888899))),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.currency_rupee_rounded,
                  size: 13, color: Color(0xFF16A34A)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(s.amount,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF16A34A),
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          if (s.deadline.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded,
                    size: 12, color: Color(0xFFD97706)),
                const SizedBox(width: 4),
                Text('Deadline: ${s.deadline}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFD97706),
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Text(s.eligibility,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF555566), height: 1.4)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onLaunch,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withAlpha(15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFF7C3AED).withAlpha(60)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.open_in_new_rounded,
                      size: 13, color: Color(0xFF7C3AED)),
                  SizedBox(width: 6),
                  Text('Apply on NSP',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7C3AED))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
