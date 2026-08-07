import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/citizen_services_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  EMERGENCY HELPLINES SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class EmergencyHelplinesScreen extends StatelessWidget {
  const EmergencyHelplinesScreen({super.key});

  Future<void> _dial(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final helplines = CitizenServicesData.emergencyHelplines;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Emergency Helplines',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: const Color(0xFFF8F9FE),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF1A1A2E),
      ),
      body: Column(
        children: [
          // Prominent 112 card
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: GestureDetector(
              onTap: () => _dial('112'),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFDC2626).withAlpha(80),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.emergency_rounded,
                          color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('EMERGENCY: 112',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5)),
                          SizedBox(height: 4),
                          Text('Police • Ambulance • Fire — all in one',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFFFCCCC))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: Color(0xFF888899)),
                const SizedBox(width: 6),
                Text(
                  'Tap any card to dial directly',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF888899)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // All helplines grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.4,
              ),
              itemCount: helplines.length,
              itemBuilder: (_, i) => _HelplineCard(
                helpline: helplines[i],
                onTap: () => _dial(helplines[i].number),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelplineCard extends StatefulWidget {
  final EmergencyHelpline helpline;
  final VoidCallback onTap;
  const _HelplineCard({required this.helpline, required this.onTap});

  @override
  State<_HelplineCard> createState() => _HelplineCardState();
}

class _HelplineCardState extends State<_HelplineCard>
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
    final h = widget.helpline;
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
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: h.color.withAlpha(40)),
            boxShadow: [
              BoxShadow(
                color: h.color.withAlpha(15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: h.color.withAlpha(18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(h.icon, color: h.color, size: 18),
                  ),
                  Icon(Icons.phone_rounded, color: h.color, size: 16),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    h.number,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: h.color,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    h.name,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    h.description,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF888899),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
