import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/sms_expense_parser_service.dart';
import '../services/transaction_service.dart';
import 'add_edit_transaction_screen.dart';

/// Screen displaying all auto-imported bank & UPI SMS transactions with options to test, edit, or delete entries.
class SmsImportHistoryScreen extends StatefulWidget {
  const SmsImportHistoryScreen({super.key});

  @override
  State<SmsImportHistoryScreen> createState() => _SmsImportHistoryScreenState();
}

class _SmsImportHistoryScreenState extends State<SmsImportHistoryScreen> {
  static const _purpleAccent = Color(0xFF7C3AED);
  static const _bgLight = Color(0xFFF8FAFC);

  bool _isLoading = false;
  List<Transaction> _smsTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadSmsTransactions();
  }

  Future<void> _loadSmsTransactions() async {
    setState(() => _isLoading = true);
    await TransactionService.instance.load();
    if (mounted) {
      setState(() {
        _smsTransactions = TransactionService.instance.all
            .where((t) => t.source == 'sms' || (t.smsReference?.isNotEmpty ?? false))
            .toList();
        _smsTransactions.sort((a, b) => b.date.compareTo(a.date));
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteTransaction(Transaction tx) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Imported SMS Entry?'),
        content: Text('Are you sure you want to delete "${tx.note}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await TransactionService.instance.delete(tx.id);
      _loadSmsTransactions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted.')),
        );
      }
    }
  }

  Future<void> _editTransaction(Transaction tx) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddEditTransactionScreen(existing: tx)),
    );

    if (result == true) {
      _loadSmsTransactions();
    }
  }

  Future<void> _runSampleSmsImport(Map<String, String> sms) async {
    final parsed = SmsExpenseParserService.instance.parseSmsText(
      sms['sender']!,
      sms['body']!,
    );

    if (parsed != null) {
      final success = await SmsExpenseParserService.instance.importParsedSms(parsed);
      await _loadSmsTransactions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Imported: ${parsed.merchant} - Rs. ${parsed.amount}'
                  : 'Duplicate transaction ignored.',
            ),
            backgroundColor: success ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not parse SMS format or non-financial message.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        title: const Text('SMS Import History', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadSmsTransactions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _purpleAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Privacy & Security Guarantee Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFC7D2FE)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: _purpleAccent, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '100% Local Device Privacy Guarantee',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E1B4B),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Only bank transaction SMS messages are analyzed locally on your device. OTPs, passwords, and personal texts are never read or stored.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF4338CA)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Demo Sample SMS Simulator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Simulate Bank SMS Import',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _purpleAccent.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Test Tool',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _purpleAccent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: SmsExpenseParserService.instance.getSampleBankSmsTemplates().length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, idx) {
                        final sms = SmsExpenseParserService.instance.getSampleBankSmsTemplates()[idx];
                        return GestureDetector(
                          onTap: () => _runSampleSmsImport(sms),
                          child: Container(
                            width: 220,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: const [
                                BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.sms_outlined, size: 16, color: _purpleAccent),
                                    const SizedBox(width: 6),
                                    Text(
                                      sms['sender']!,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: Text(
                                    sms['body']!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Tap to parse & import →',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _purpleAccent),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // History Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Imported SMS Transactions (${_smsTransactions.length})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _smsTransactions.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.mark_email_read_outlined, size: 48, color: Color(0xFF94A3B8)),
                              SizedBox(height: 12),
                              Text(
                                'No SMS Transactions Imported Yet',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF475569)),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Enable Automatic SMS Tracking in Settings or tap sample cards above to test.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _smsTransactions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, idx) {
                            final tx = _smsTransactions[idx];
                            final isIncome = tx.type == TransactionType.income;
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: const [
                                  BoxShadow(color: Color(0x05000000), blurRadius: 4, offset: Offset(0, 2)),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isIncome
                                          ? const Color(0xFFD1FAE5)
                                          : const Color(0xFFFEE2E2),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                      color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tx.note,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Color(0xFF1E293B),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Category: ${tx.category.toUpperCase()} • ${_formatDate(tx.date)}',
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${isIncome ? '+' : '-'} ₹${tx.amount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF64748B)),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () => _editTransaction(tx),
                                            tooltip: 'Edit',
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () => _deleteTransaction(tx),
                                            tooltip: 'Delete',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
