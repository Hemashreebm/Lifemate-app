import 'package:flutter/material.dart';
import '../services/citizen_services_data.dart';
import 'govt_schemes_screen.dart';
import 'digital_services_screen.dart';
import 'emergency_helplines_screen.dart';
import 'scholarship_finder_screen.dart';
import 'citizen_ai_assistant_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  CITIZEN SERVICES HUB SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class CitizenServicesScreen extends StatelessWidget {
  const CitizenServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Citizen Services',
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
            // ── HERO BANNER ─────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFF138808)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withAlpha(60),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🇮🇳 Citizen Services Hub',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.3)),
                        const SizedBox(height: 6),
                        Text(
                          'Government schemes, digital services & helplines — all in one place',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withAlpha(220),
                              height: 1.4),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _StatPill(
                                label: '${CitizenServicesData.allSchemes.length}+ Schemes'),
                            const SizedBox(width: 8),
                            _StatPill(
                                label:
                                    '${CitizenServicesData.digitalServices.length} Services'),
                            const SizedBox(width: 8),
                            _StatPill(
                                label:
                                    '${CitizenServicesData.emergencyHelplines.length} Helplines'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('🏛️',
                      style: TextStyle(fontSize: 52)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── AI ELIGIBILITY CTA ───────────────────────────────────────────
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CitizenAiAssistantScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(35),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.psychology_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ask AI — What schemes am I eligible for?',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          SizedBox(height: 2),
                          Text(
                              'Answer 3 questions · Instant personalised results',
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

            const SizedBox(height: 24),

            // ── SECTION HEADER ───────────────────────────────────────────────
            const Text('Explore Services',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 2),
            const Text('Everything you need from the Government of India',
                style: TextStyle(fontSize: 12, color: Color(0xFF888899))),

            const SizedBox(height: 14),

            // ── MAIN CATEGORY GRID ───────────────────────────────────────────
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _HubCard(
                  icon: Icons.account_balance_rounded,
                  emoji: '🏛️',
                  title: 'Government\nSchemes',
                  subtitle: '${CitizenServicesData.allSchemes.length}+ central & state schemes',
                  color: const Color(0xFF6366F1),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const GovtSchemesScreen())),
                ),
                _HubCard(
                  icon: Icons.phone_iphone_rounded,
                  emoji: '📱',
                  title: 'Digital\nServices',
                  subtitle: '${CitizenServicesData.digitalServices.length} official portals & guides',
                  color: const Color(0xFF1D4ED8),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const DigitalServicesScreen())),
                ),
                _HubCard(
                  icon: Icons.emergency_rounded,
                  emoji: '🚨',
                  title: 'Emergency\nHelplines',
                  subtitle: 'Tap to call — 100, 108, 112 & more',
                  color: const Color(0xFFDC2626),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const EmergencyHelplinesScreen())),
                ),
                _HubCard(
                  icon: Icons.school_rounded,
                  emoji: '🎓',
                  title: 'Scholarship\nFinder',
                  subtitle: 'Match scholarships to your profile',
                  color: const Color(0xFF7C3AED),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const ScholarshipFinderScreen())),
                ),
                _HubCard(
                  icon: Icons.grass_rounded,
                  emoji: '🌾',
                  title: 'Farmer\'s\nCorner',
                  subtitle: 'PM-Kisan, PMFBY, KCC & more',
                  color: const Color(0xFF16A34A),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GovtSchemesScreen(),
                    ),
                  ).then((_) {
                    // Auto-filter to Agriculture
                  }),
                ),
                _HubCard(
                  icon: Icons.favorite_rounded,
                  emoji: '🏥',
                  title: 'Health\nSchemes',
                  subtitle: 'Ayushman, PMJJBY, PMSBY & more',
                  color: const Color(0xFFDB2777),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const GovtSchemesScreen())),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── QUICK FACTS STRIP ────────────────────────────────────────────
            const Text('Did You Know?',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 10),
            ..._quickFacts.map((f) => _FactTile(fact: f)),

            const SizedBox(height: 24),

            // ── OFFICIAL DISCLAIMER ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withAlpha(8),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color(0xFF6366F1).withAlpha(30)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.verified_rounded,
                      color: Color(0xFF6366F1), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'All information sourced from official Government of India portals (india.gov.in, myscheme.gov.in). Verify eligibility at official websites before applying.',
                      style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF555566),
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

const _quickFacts = [
  _QuickFact(
    emoji: '💰',
    text: 'PM-KISAN gives ₹6,000/year to 11+ crore farmers directly to their bank accounts.',
  ),
  _QuickFact(
    emoji: '🏥',
    text: 'Ayushman Bharat covers ₹5 lakh health insurance for 50+ crore Indians.',
  ),
  _QuickFact(
    emoji: '📚',
    text: 'Over ₹2,600 crore is distributed annually via the National Scholarship Portal.',
  ),
  _QuickFact(
    emoji: '🏠',
    text: 'PM Awas Yojana has built 3+ crore pucca houses for rural families.',
  ),
];

class _QuickFact {
  final String emoji;
  final String text;
  const _QuickFact({required this.emoji, required this.text});
}

class _FactTile extends StatelessWidget {
  final _QuickFact fact;
  const _FactTile({required this.fact});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(fact.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fact.text,
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF555566),
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ── WIDGETS ──────────────────────────────────────────────────────────────────

class _HubCard extends StatefulWidget {
  final IconData icon;
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _HubCard({
    required this.icon,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_HubCard> createState() => _HubCardState();
}

class _HubCardState extends State<_HubCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 120),
        lowerBound: 0.96,
        upperBound: 1.0)
      ..value = 1.0;
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: widget.color.withAlpha(20),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: widget.color.withAlpha(18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon,
                        color: widget.color, size: 22),
                  ),
                  Text(widget.emoji,
                      style: const TextStyle(fontSize: 20)),
                ],
              ),
              const Spacer(),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                widget.subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF888899),
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  const _StatPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withAlpha(80)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
