import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction.dart';
import '../models/transaction_category.dart';
import '../services/transaction_service.dart';

/// Screen for adding a new transaction or editing an existing one.
///
/// Pass [existing] to pre-fill fields for editing.
/// If [existing] is null, the screen opens in "Add" mode.
class AddEditTransactionScreen extends StatefulWidget {
  final Transaction? existing;
  final TransactionType? initialType;

  const AddEditTransactionScreen({super.key, this.existing, this.initialType});

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends State<AddEditTransactionScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();

  TransactionType _type     = TransactionType.expense;
  String?         _category;
  DateTime        _date     = DateTime.now();
  bool            _saving   = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    // Pre-fill if editing
    if (_isEditing) {
      final tx = widget.existing!;
      _type     = tx.type;
      _category = tx.category;
      _date     = tx.date;
      _amountCtrl.text = tx.amount.toStringAsFixed(0);
      _noteCtrl.text   = tx.note;
    } else if (widget.initialType != null) {
      _type = widget.initialType!;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

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
      _showError('Please select a category.');
      return;
    }

    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      _showError('Amount must be greater than ₹0.');
      return;
    }

    setState(() => _saving = true);

    final service = TransactionService.instance;
    if (_isEditing) {
      final updated = widget.existing!.copyWith(
        type:     _type,
        amount:   amount,
        category: _category,
        note:     _noteCtrl.text.trim(),
        date:     _date,
      );
      await service.update(updated);
    } else {
      final tx = Transaction(
        id:        Transaction.generateId(),
        type:      _type,
        amount:    amount,
        category:  _category!,
        note:      _noteCtrl.text.trim(),
        date:      _date,
        createdAt: DateTime.now(),
      );
      await service.add(tx);
    }

    if (mounted) Navigator.pop(context, true); // true = data changed
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isExp  = _type == TransactionType.expense;
    final accent = isExp ? const Color(0xFFFF6B6B) : const Color(0xFF10B981);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        actions: [
          if (!_saving)
            TextButton(
              onPressed: _save,
              child: Text(
                'Save',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
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
              // ── Type Toggle ───────────────────────────────────────────────
              _buildTypeToggle(theme),
              const SizedBox(height: 24),

              // ── Amount ────────────────────────────────────────────────────
              _buildSectionLabel('Amount'),
              const SizedBox(height: 8),
              _buildAmountField(accent),
              const SizedBox(height: 24),

              // ── Category ──────────────────────────────────────────────────
              _buildSectionLabel('Category'),
              const SizedBox(height: 10),
              _buildCategoryGrid(),
              const SizedBox(height: 24),

              // ── Date ──────────────────────────────────────────────────────
              _buildSectionLabel('Date'),
              const SizedBox(height: 8),
              _buildDatePicker(theme),
              const SizedBox(height: 24),

              // ── Note ──────────────────────────────────────────────────────
              _buildSectionLabel('Note (optional)'),
              const SizedBox(height: 8),
              _buildNoteField(),
              const SizedBox(height: 40),

              // ── Save Button ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Update Transaction' : 'Save Transaction',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section builders ──────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: Color(0xFF6B7280),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTypeToggle(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: TransactionType.values.map((t) {
          final selected = _type == t;
          final isExp    = t == TransactionType.expense;
          final color    = isExp ? const Color(0xFFFF6B6B) : const Color(0xFF10B981);
          final label    = isExp ? 'Expense' : 'Income';
          final emoji    = isExp ? '📤' : '📥';
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _type     = t;
                _category = null; // reset category when type changes
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
                  '$emoji  $label',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: selected ? Colors.white : const Color(0xFF9E9E9E),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAmountField(Color accent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: TextFormField(
        controller: _amountCtrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: accent,
        ),
        decoration: InputDecoration(
          prefixText: '₹ ',
          prefixStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: accent,
          ),
          hintText: '0',
          hintStyle: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFFD1D5DB),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        validator: (val) {
          if (val == null || val.trim().isEmpty) return 'Enter an amount';
          final n = double.tryParse(val.trim());
          if (n == null || n <= 0) return 'Enter a valid amount greater than ₹0';
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
                  ? [BoxShadow(color: cat.color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))]
                  : const [BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(cat.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  cat.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : const Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker(ThemeData theme) {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 12),
            Text(
              TransactionService.formatShortDate(_date) +
                  (DateTime(_date.year, _date.month, _date.day) ==
                          DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
                      ? '  (Today)'
                      : '  ${_date.year}'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A2E),
              ),
            ),
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
          BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: TextFormField(
        controller: _noteCtrl,
        maxLines: 3,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText: 'What was this for? (optional)',
          hintStyle: TextStyle(color: Color(0xFFD1D5DB)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }
}
