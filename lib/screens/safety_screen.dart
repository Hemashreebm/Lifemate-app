import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import '../models/trusted_contact.dart';
import '../services/location_service.dart';
import '../services/safety_service.dart';

/// Screen for Smart Location Phase 2 â€” Safety & SOS
class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  final _safetySvc = SafetyService.instance;
  final _locSvc = LocationService.instance;

  Position? _emergencyPos;
  LocationAddress _emergencyAddr = LocationAddress.fallback(0, 0);
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _safetySvc.loadContacts();
    await _fetchEmergencyLocation();
  }

  Future<void> _fetchEmergencyLocation() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);

    final pos = await _locSvc.getCurrentPosition();
    if (pos != null) {
      final addr = await _locSvc.getDetailedAddress(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() {
          _emergencyPos = pos;
          _emergencyAddr = addr;
        });
      }
    }

    if (mounted) {
      setState(() => _isLocating = false);
    }
  }

  // â”€â”€ SOS Trigger â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _triggerSOS() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 28),
            SizedBox(width: 8),
            Expanded(child: Text('Start Emergency Mode?', style: TextStyle(fontWeight: FontWeight.w800))),
          ],
        ),
        content: const Text(
          'This will fetch your current GPS location and let you quickly call or share an emergency message with your trusted contacts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _fetchEmergencyLocation();
      _showEmergencyActionModal();
    }
  }

  void _showEmergencyActionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.sos, color: Color(0xFFEF4444), size: 32),
                SizedBox(width: 10),
                Text(
                  'Emergency Mode Active',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Text(
                'Location: ${_emergencyAddr.fullFormatted}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF991B1B), fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select a contact to call or share emergency message:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 12),
            if (_safetySvc.contacts.isEmpty) ...[
              const Text(
                'No trusted contacts saved. You can share your location or add contacts below.',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _openShareMessageDialog();
                },
                icon: const Icon(Icons.share),
                label: const Text('Share Emergency Location Sheet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ] else ...[
              ..._safetySvc.contacts.map((contact) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(
                        contact.relationship.isNotEmpty
                            ? '${contact.relationship} â€¢ ${contact.phoneNumber}'
                            : contact.phoneNumber,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.call, color: Color(0xFF10B981)),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _confirmCallContact(contact);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.share, color: Color(0xFF8B5CF6)),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _openShareMessageDialog(targetContact: contact);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // â”€â”€ Quick Call â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _confirmCallContact(TrustedContact contact) async {
    if (contact.phoneNumber.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number is missing for this contact.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Call ${contact.name}?'),
        content: Text('Open phone dialer for ${contact.phoneNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: const Text('Call'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final launched = await _safetySvc.openDialer(contact.phoneNumber);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open phone dialer.')),
        );
      }
    }
  }

  // â”€â”€ Share Emergency Message â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _openShareMessageDialog({TrustedContact? targetContact}) async {
    final lat = _emergencyPos?.latitude ?? 0.0;
    final lng = _emergencyPos?.longitude ?? 0.0;

    final defaultText = _safetySvc.generateEmergencyMessage(
      address: _emergencyAddr,
      latitude: lat,
      longitude: lng,
    );

    final textCtrl = TextEditingController(text: defaultText);

    final shareText = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          targetContact != null ? 'Share with ${targetContact.name}' : 'Share Emergency Message',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Review and edit your emergency message before opening Android share sheet:',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: textCtrl,
                maxLines: 8,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, textCtrl.text),
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Open Share Sheet'),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
          ),
        ],
      ),
    );

    if (shareText != null && shareText.trim().isNotEmpty) {
      await Share.share(shareText);
    }
  }

  // â”€â”€ Contact Dialogs (Add & Edit) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _showAddEditContactDialog({TrustedContact? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phoneNumber ?? '');
    final relCtrl = TextEditingController(text: existing?.relationship ?? '');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          existing == null ? 'Add Trusted Contact' : 'Edit Contact',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Contact Name (e.g. Mom, Dad)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: relCtrl,
                decoration: const InputDecoration(
                  labelText: 'Relationship (e.g. Mother, Friend)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirm == true && nameCtrl.text.trim().isNotEmpty && phoneCtrl.text.trim().isNotEmpty) {
      if (existing == null) {
        final newContact = TrustedContact(
          id: TrustedContact.generateId(),
          name: nameCtrl.text.trim(),
          phoneNumber: phoneCtrl.text.trim(),
          relationship: relCtrl.text.trim(),
          createdAt: DateTime.now(),
        );
        await _safetySvc.addContact(newContact);
      } else {
        final updated = existing.copyWith(
          name: nameCtrl.text.trim(),
          phoneNumber: phoneCtrl.text.trim(),
          relationship: relCtrl.text.trim(),
        );
        await _safetySvc.updateContact(updated);
      }
      setState(() {});
    }
  }

  Future<void> _deleteContact(TrustedContact contact) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete "${contact.name}"?'),
        content: const Text('Are you sure you want to remove this trusted contact?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _safetySvc.deleteContact(contact.id);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
      appBar: AppBar(
        title: const Text('Safety & SOS', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // â”€â”€ Header Subtitle â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            const Text(
              'Help when you need it.',
              style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),

            // â”€â”€ ðŸ†˜ Large SOS Button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildSOSButtonCard(),

            const SizedBox(height: 24),

            // â”€â”€ ðŸ“ Emergency Location Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildEmergencyLocationCard(),

            const SizedBox(height: 24),

            // â”€â”€ ðŸ‘¥ Trusted Contacts Header & List â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildTrustedContactsHeader(),
            const SizedBox(height: 12),
            _buildTrustedContactsList(),

            const SizedBox(height: 24),

            // â”€â”€ ðŸ”’ Privacy Banner â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildPrivacyBanner(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // â”€â”€ Section Builders â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildSOSButtonCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33EF4444),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _triggerSOS,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 4)),
                ],
              ),
              child: const Center(
                child: Text(
                  'SOS',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFDC2626),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tap for Emergency Assistance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Fetches location & opens emergency contact actions',
            style: TextStyle(fontSize: 12, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.my_location_rounded, color: Color(0xFF8B5CF6), size: 22),
              const SizedBox(width: 8),
              const Text(
                'Current Emergency Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E)),
              ),
              const Spacer(),
              if (_isLocating)
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _emergencyAddr.fullFormatted,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
          ),
          if (_emergencyPos != null) ...[
            const SizedBox(height: 4),
            Text(
              'Lat: ${_emergencyPos!.latitude.toStringAsFixed(6)} â€¢ Lng: ${_emergencyPos!.longitude.toStringAsFixed(6)} (Â±${_emergencyPos!.accuracy.round()} m)',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _fetchEmergencyLocation,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8B5CF6),
                    side: const BorderSide(color: Color(0xFF8B5CF6)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _openShareMessageDialog(),
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('Share Location'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustedContactsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'ðŸ‘¥ Trusted Contacts',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E)),
        ),
        TextButton.icon(
          onPressed: () => _showAddEditContactDialog(),
          icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
          label: const Text('+ Add Contact'),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF8B5CF6)),
        ),
      ],
    );
  }

  Widget _buildTrustedContactsList() {
    final contacts = _safetySvc.contacts;
    if (contacts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'No trusted contacts added yet. Tap "+ Add Contact" to add key family members or friends.',
          style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contacts.length,
      itemBuilder: (ctx, i) {
        final c = contacts[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF10B981).withAlpha(31),
              child: const Icon(Icons.person, color: Color(0xFF10B981)),
            ),
            title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
            subtitle: Text(
              c.relationship.isNotEmpty ? '${c.relationship} â€¢ ${c.phoneNumber}' : c.phoneNumber,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.call, color: Color(0xFF10B981)),
                  onPressed: () => _confirmCallContact(c),
                  tooltip: 'Quick Call',
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Color(0xFF8B5CF6)),
                  onPressed: () => _openShareMessageDialog(targetContact: c),
                  tooltip: 'Share Message',
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Color(0xFF64748B)),
                  onPressed: () => _showAddEditContactDialog(existing: c),
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                  onPressed: () => _deleteContact(c),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrivacyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: const [
          Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy & Security',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1A1A2E)),
                ),
                SizedBox(height: 2),
                Text(
                  'All trusted contacts remain saved on your local device. Calls and emergency messages are triggered ONLY when you explicitly press Call or Share.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

