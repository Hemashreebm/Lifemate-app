import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction.dart';
import '../models/transaction_category.dart';
import '../services/transaction_service.dart';
import '../services/voice_transaction_parser.dart';

/// Shows the result of voice speech recognition and lets the user review,
/// edit, and confirm the transaction before it is saved.
class VoiceTransactionScreen extends StatefulWidget {
  final ParsedTransaction parsed;

  const VoiceTransactionScreen({super.key, required this.parsed});

  @override
  State<VoiceTransactionScreen> createState() => _VoiceTransactionScreenState();
}

class _VoiceTransactionScreenState extends State<VoiceTransactionScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();

  late TransactionType _type;
  String?  _category;
  DateTime _date   = DateTime.now();
  bool     _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.parsed;
    _type     = p.type;
    _category = p.category;
    _date     = p.date;
    _amountCtrl.text = p.amount != null ? p.amount!.toStringAsFixed(0) : '';
    _noteCtrl.text   = p.note;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // ── Colors ─────────────────────────────────────────────────────────────────

  Color get _accent =>
      _type == TransactionType.expense
          ? const Color(0xFFFF6B6B)
          : const Color(0xFF10B981);

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      _showSnack('Please select a category.');
      return;
    }
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      _showSnack('Amount must be greater than ₹0.');
      return;
    }

    setState(() => _saving = true);

    final tx = Transaction(
      id:        Transaction.generateId(),
      type:      _type,
      amount:    amount,
      category:  _category!,
      note:      _noteCtrl.text.trim(),
      date:      DateTime(_date.year, _date.month, _date.day),
      createdAt: DateTime.now(),
    );
    await TransactionService.instance.add(tx);

    if (mounted) Navigator.pop(context, true);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade700,
      margin: const EdgeInsets.all(16),
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
      appBar: AppBar(
        title: const Text('Review Voice Entry',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        actions: [
          if (!_saving)
            TextButton(
              onPressed: _save,
              child: Text('Save',
                  style: TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
            )
          else
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Recognized speech ─────────────────────────────────────────
              _buildRecognizedCard(),
              const SizedBox(height: 24),

              // ── Type toggle ───────────────────────────────────────────────
              _buildLabel('Transaction Type'),
              const SizedBox(height: 8),
              _buildTypeToggle(),
              const SizedBox(height: 24),

              // ── Amount ────────────────────────────────────────────────────
              _buildLabel('Amount'),
              const SizedBox(height: 8),
              _buildAmountField(),
              const SizedBox(height: 24),

              // ── Category ──────────────────────────────────────────────────
              _buildLabel('Category'),
              const SizedBox(height: 10),
              _buildCategoryGrid(),
              const SizedBox(height: 24),

              // ── Date ──────────────────────────────────────────────────────
              _buildLabel('Date'),
              const SizedBox(height: 8),
              _buildDatePicker(),
              const SizedBox(height: 24),

              // ── Note ──────────────────────────────────────────────────────
              _buildLabel('Note (optional)'),
              const SizedBox(height: 8),
              _buildNoteField(),
              const SizedBox(height: 32),

              // ── Save button ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Save Transaction',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widgets ────────────────────────────────────────────────────────────────

  Widget _buildRecognizedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6C5CE7).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF6C5CE7).withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mic, color: Color(0xFF6C5CE7), size: 18),
              const SizedBox(width: 8),
              const Text('You said:',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6C5CE7))),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"${widget.parsed.rawText}"',
            style: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Color(0xFF374151),
              height: 1.5,
            ),
          ),
          if (!widget.parsed.isComplete) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 14, color: Colors.orange.shade700),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Amount not detected. Please enter it below.',
                      style: TextStyle(
                          fontSize: 12, color: Colors.orange.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Color(0xFF6B7280),
          letterSpacing: 0.4,
        ));
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 6,
              offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: TransactionType.values.map((t) {
          final selected = _type == t;
          final isExp    = t == TransactionType.expense;
          final color    = isExp
              ? const Color(0xFFFF6B6B)
              : const Color(0xFF10B981);
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _type     = t;
                _category = null;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  isExp ? '📤  Expense' : '📥  Income',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color:
                        selected ? Colors.white : const Color(0xFF9E9E9E),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAmountField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 6,
              offset: Offset(0, 2))
        ],
      ),
      child: TextFormField(
        controller: _amountCtrl,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: _accent,
        ),
        decoration: InputDecoration(
          prefixText: '₹ ',
          prefixStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: _accent,
          ),
          hintText: '0',
          hintStyle: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFFD1D5DB)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        validator: (val) {
          if (val == null || val.trim().isEmpty) return 'Enter an amount';
          final n = double.tryParse(val.trim());
          if (n == null || n <= 0) return 'Enter a valid amount > ₹0';
          return null;
        },
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = TransactionCategories.forType(_type);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final selected = _category == cat.name;
        return GestureDetector(
          onTap: () => setState(() => _category = cat.name),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? cat.color : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? cat.color : const Color(0xFFE5E7EB),
                width: selected ? 0 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                          color: cat.color.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ]
                  : const [
                      BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 4,
                          offset: Offset(0, 1))
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(cat.emoji,
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(cat.name,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF374151))),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker() {
    final now     = DateTime.now();
    final isToday = _date.year == now.year &&
        _date.month == now.month &&
        _date.day == now.day;
    final isYesterday = _date ==
        DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 1));

    final dateLabel = isToday
        ? '${TransactionService.formatShortDate(_date)}  (Today)'
        : isYesterday
            ? '${TransactionService.formatShortDate(_date)}  (Yesterday)'
            : '${TransactionService.formatShortDate(_date)}  ${_date.year}';

    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 6,
                offset: Offset(0, 2))
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: Color(0xFF6C5CE7), size: 20),
            const SizedBox(width: 12),
            Text(dateLabel,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E))),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 6,
              offset: Offset(0, 2))
        ],
      ),
      child: TextFormField(
        controller: _noteCtrl,
        maxLines: 3,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText: 'Add a note (optional)',
          hintStyle: TextStyle(color: Color(0xFFD1D5DB)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }
}
