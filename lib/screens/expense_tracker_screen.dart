import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/transaction.dart';
import '../models/transaction_category.dart';
import '../services/transaction_service.dart';
import '../services/voice_transaction_parser.dart';
import '../services/ocr_bill_scanner_service.dart';
import '../services/sms_expense_parser_service.dart';
import 'add_edit_transaction_screen.dart';
import 'voice_transaction_screen.dart';

/// The Expense Tracker main dashboard.
///
/// Layout (top  bottom):
///  1. All-time summary card  (Total Money / Total Spent / Balance)
///  2. Quick action buttons   (+ Add Money | + Add Expense |  Voice)
///  3. This Month section     (month selector, income/spent/remaining, budget bar)
///  4. Spending by Category   (this month)
///  5. Recent Transactions    (last 10 across all months)
///  6. Monthly History        (per-month summaries)
class ExpenseTrackerScreen extends StatefulWidget {
  const ExpenseTrackerScreen({super.key});

  @override
  State<ExpenseTrackerScreen> createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  final _svc = TransactionService.instance;

  late DateTime _month;
  List<Transaction> _allTxs   = [];
  List<Transaction> _monthTxs = [];
  List<DateTime>    _monthHistory = [];
  double?           _budget;
  bool              _loading  = true;

  // Voice
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isListening     = false;
  String _voiceStatus   = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _loadData();
    _initSpeech();
  }

  //  Data loading 

  Future<void> _loadData() async {
    await _svc.load();
    _budget = await _svc.getBudget(_month);
    _refresh();
    if (mounted) setState(() => _loading = false);
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _allTxs      = _svc.all;
      _monthTxs    = _svc.getForMonth(_month);
      _monthHistory = _svc.getTransactionMonths();
    });
  }

  Future<void> _changeMonth(DateTime newMonth) async {
    _budget = await _svc.getBudget(newMonth);
    setState(() {
      _month    = newMonth;
      _monthTxs = _svc.getForMonth(newMonth);
    });
  }

  //  Speech initialisation 

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (e) {
        if (mounted) setState(() => _isListening = false);
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
    );
    if (mounted) setState(() {});
  }

  //  Navigation 

  Future<void> _openAdd({TransactionType? type}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTransactionScreen(initialType: type),
      ),
    );
    if (changed == true) _refresh();
  }

  Future<void> _openEdit(Transaction tx) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddEditTransactionScreen(existing: tx)),
    );
    if (changed == true) _refresh();
  }

  //  Voice entry 

  Future<void> _startVoiceEntry() async {
    if (!_speechAvailable) {
      _showVoiceErrorDialog(
          'Speech recognition is not available on this device.');
      return;
    }
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    setState(() {
      _isListening  = true;
      _voiceStatus  = 'Listening';
    });

    await _speech.listen(
      onResult: (result) async {
        if (!result.finalResult) return;
        final text = result.recognizedWords.trim();
        await _speech.stop();
        if (!mounted) return;
        setState(() => _isListening = false);

        if (text.isEmpty) {
          _showVoiceErrorDialog('No speech was detected. Please try again.');
          return;
        }

        final parsed = VoiceTransactionParser.parse(text);
        if (!mounted) return;

        final saved = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => VoiceTransactionScreen(parsed: parsed),
          ),
        );
        if (saved == true) _refresh();
      },
      listenFor: const Duration(seconds: 15),
      pauseFor:  const Duration(seconds: 4),
      partialResults: false,
      localeId:  'en_IN',
    );
  }

  void _showVoiceErrorDialog(String msg) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.mic_off, color: Color(0xFF6C5CE7)),
            SizedBox(width: 8),
            Text('Voice Entry'),
          ],
        ),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  //  Transaction detail / delete 

  void _showDetail(Transaction tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _TransactionDetailSheet(
        transaction: tx,
        onEdit:   () { Navigator.pop(context); _openEdit(tx); },
        onDelete: () { Navigator.pop(context); _confirmDelete(tx); },
      ),
    );
  }

  Future<void> _confirmDelete(Transaction tx) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Delete this transaction?'),
        content: Text(
          '${tx.type == TransactionType.expense ? "Expense" : "Income"}: '
          '${TransactionService.formatCurrency(tx.amount)}  ${tx.category}',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _svc.delete(tx.id);
      _refresh();
    }
  }

  //  OCR Bill Scanner 

  Future<void> _scanReceipt(ImageSource source) async {
    final result = await OcrBillScannerService.instance.scanReceipt(source: source);
    if (result == null || !mounted) return;

    final nameController = TextEditingController(text: result.merchantName);
    final amountController = TextEditingController(text: result.totalAmount > 0 ? result.totalAmount.toStringAsFixed(2) : '');
    String selectedCategory = 'shopping';

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.receipt_long_rounded, color: Color(0xFF8B5CF6)),
            SizedBox(width: 8),
            Text('OCR Bill Scanned'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Shop / Merchant Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Total Amount ()'),
              ),
              const SizedBox(height: 12),
              if (result.gstNumber.isNotEmpty)
                Text('GST: ${result.gstNumber}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final amt = double.tryParse(amountController.text.trim()) ?? 0.0;
              if (amt > 0) {
                final newTx = Transaction(
                  id: Transaction.generateId(),
                  type: TransactionType.expense,
                  amount: amt,
                  category: selectedCategory,
                  note: nameController.text.trim().isEmpty ? 'Scanned Bill' : '${nameController.text.trim()} (OCR Scanned)',
                  date: result.date,
                  createdAt: DateTime.now(),
                );
                await _svc.add(newTx);
                _refresh();
              }
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text('Save Expense'),
          ),
        ],
      ),
    );
  }

  //  SMS Tracking Dialog 

  Future<void> _showSmsTrackingDialog() async {
    await SmsExpenseParserService.instance.init();
    bool enabled = SmsExpenseParserService.instance.isSmsTrackingEnabled;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.sms_rounded, color: Color(0xFF00B894)),
              SizedBox(width: 8),
              Text('SMS Expense Tracking'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Automatically detect financial SMS from banks, UPI, Credit/Debit cards & wallets.',
                style: TextStyle(fontSize: 13, color: Color(0xFF636E72)),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Auto SMS Detection'),
                subtitle: Text(enabled ? 'Active - Parsing bank alerts' : 'Disabled'),
                value: enabled,
                onChanged: (val) async {
                  await SmsExpenseParserService.instance.setSmsTrackingEnabled(val);
                  setDialogState(() => enabled = val);
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final sample = SmsExpenseParserService.instance.parseSmsText(
                    'HDFCBK',
                    'Rs.450.00 debited from a/c **1234 at Swiggy on 30-07-26. Avail Bal: Rs.15200.00',
                  );
                  if (sample != null) {
                    await SmsExpenseParserService.instance.importParsedSms(sample);
                    _refresh();
                    if (mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sample HDFC SMS transaction imported!')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Import Recent Bank SMS'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
          ],
        ),
      ),
    );
  }

  //  Budget dialog 

  Future<void> _showBudgetDialog() async {
    final ctrl = TextEditingController(
        text: _budget != null ? _budget!.toStringAsFixed(0) : '');
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Set Budget  ${TransactionService.formatMonthYear(_month)}',
          style: const TextStyle(fontSize: 16),
        ),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            prefixText: ' ',
            hintText: 'e.g. 5000',
            labelText: 'Monthly budget',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          if (_budget != null)
            TextButton(
              onPressed: () async {
                await _svc.setBudget(0, _month);
                if (mounted) {
                  setState(() => _budget = null);
                  Navigator.pop(context);
                }
              },
              child: const Text('Remove',
                  style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final v = double.tryParse(ctrl.text.trim()) ?? 0;
              await _svc.setBudget(v, _month);
              if (mounted) {
                setState(() => _budget = v > 0 ? v : null);
                Navigator.pop(context);
              }
            },
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7)),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  //  Month navigation 

  Future<void> _prevMonth() async {
    await _changeMonth(DateTime(_month.year, _month.month - 1));
  }

  Future<void> _nextMonth() async {
    final now  = DateTime.now();
    final next = DateTime(_month.year, _month.month + 1);
    if (next.isAfter(DateTime(now.year, now.month))) return;
    await _changeMonth(next);
  }

  //  Build 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
      appBar: AppBar(
        title: const Text('Expense Tracker',
            style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.shade100),
        ),
        actions: [
          Tooltip(
            message: 'Set monthly budget',
            child: IconButton(
              icon: const Icon(Icons.tune_rounded),
              onPressed: _showBudgetDialog,
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final allIncome  = _svc.totalIncome(_allTxs);
    final allExpense = _svc.totalExpense(_allTxs);
    final balance    = allIncome - allExpense;

    final monthIncome  = _svc.totalIncome(_monthTxs);
    final monthExpense = _svc.totalExpense(_monthTxs);
    final monthNet     = monthIncome - monthExpense;

    final recentTxs = _allTxs.take(10).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1  ALL-TIME SUMMARY CARD 
          _buildAllTimeCard(allIncome, allExpense, balance),
          const SizedBox(height: 20),

          // 2  QUICK ACTION BUTTONS 
          _buildActionButtons(),
          const SizedBox(height: 28),

          // 3  THIS MONTH 
          _buildSectionHeader('This Month'),
          const SizedBox(height: 12),
          _buildMonthSelector(),
          const SizedBox(height: 12),
          _buildMonthSummaryCard(monthIncome, monthExpense, monthNet),
          const SizedBox(height: 28),

          // 4  SPENDING BY CATEGORY 
          if (_monthTxs.any((t) => t.type == TransactionType.expense)) ...[
            _buildSectionHeader('Spending by Category'),
            const SizedBox(height: 12),
            _buildCategorySpending(monthExpense),
            const SizedBox(height: 28),
          ],

          // 5  RECENT TRANSACTIONS 
          _buildSectionHeader('Recent Transactions'),
          const SizedBox(height: 12),
          recentTxs.isEmpty
              ? _buildEmptyState()
              : _buildTransactionList(recentTxs),
          const SizedBox(height: 28),

          // 6  MONTHLY HISTORY 
          if (_monthHistory.length > 1) ...[
            _buildSectionHeader('Monthly History'),
            const SizedBox(height: 12),
            _buildMonthlyHistory(),
          ],
        ],
      ),
    );
  }

  //  Section 1: All-time summary card 

  Widget _buildAllTimeCard(
      double allIncome, double allExpense, double balance) {
    final neg = balance < 0;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF2D2D5E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withAlpha(89),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Balance row
          const Text('Current Balance',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            '${neg ? '-' : ''}${TransactionService.formatCurrency(balance.abs())}',
            style: TextStyle(
              color: neg ? const Color(0xFFFCA5A5) : Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withAlpha(38), height: 1),
          const SizedBox(height: 16),

          // Income & Expenses row
          Row(
            children: [
              Expanded(
                child: _buildAllTimeStat(
                  ' Total Money',
                  TransactionService.formatCurrency(allIncome),
                  const Color(0xFF86EFAC),
                ),
              ),
              Container(
                  width: 1,
                  height: 44,
                  color: Colors.white.withAlpha(38)),
              Expanded(
                child: _buildAllTimeStat(
                  ' Total Spent',
                  TransactionService.formatCurrency(allExpense),
                  const Color(0xFFFCA5A5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllTimeStat(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
      ],
    );
  }

  //  Section 2: Action buttons 

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: '+ Add Money',
                icon: Icons.add_circle_outline,
                color: const Color(0xFF10B981),
                onTap: () => _openAdd(type: TransactionType.income),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                label: '+ Add Expense',
                icon: Icons.remove_circle_outline,
                color: const Color(0xFFFF6B6B),
                onTap: () => _openAdd(type: TransactionType.expense),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: ' Scan Bill',
                icon: Icons.receipt_long_rounded,
                color: const Color(0xFF8B5CF6),
                onTap: () => _scanReceipt(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                label: ' SMS Tracker',
                icon: Icons.sms_rounded,
                color: const Color(0xFF00B894),
                onTap: _showSmsTrackingDialog,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Voice button  full width
        _buildVoiceButton(),
      ],
    );
  }

  Widget _buildVoiceButton() {
    final isActive = _isListening;
    return GestureDetector(
      onTap: _startVoiceEntry,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isActive
                ? [const Color(0xFF6C5CE7), const Color(0xFF8B5CF6)]
                : [const Color(0xFF6C5CE7), const Color(0xFF9D8FFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C5CE7).withAlpha(89),
              blurRadius: isActive ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isActive
                  ? const _PulsingMic(key: ValueKey('pulsing'))
                  : const Icon(Icons.mic_rounded,
                      key: ValueKey('static'),
                      color: Colors.white,
                      size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              isActive ? 'Listening tap to stop' : '  Add by Voice',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  Section 3: This month 

  Widget _buildMonthSelector() {
    final now = DateTime.now();
    final isCurrentMonth =
        _month.year == now.year && _month.month == now.month;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: _prevMonth,
          color: const Color(0xFF6C5CE7),
        ),
        Text(
          TransactionService.formatMonthYear(_month),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFF1A1A2E),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.chevron_right_rounded,
            size: 28,
            color: isCurrentMonth
                ? const Color(0xFFD1D5DB)
                : const Color(0xFF6C5CE7),
          ),
          onPressed: isCurrentMonth ? null : _nextMonth,
        ),
      ],
    );
  }

  Widget _buildMonthSummaryCard(
      double income, double expense, double net) {
    final netNeg      = net < 0;
    final budgetPct   = (_budget != null && _budget! > 0)
        ? (expense / _budget!).clamp(0.0, 1.0)
        : null;
    final budgetWarn  = budgetPct != null && budgetPct >= 0.8;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFF9D8FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C5CE7).withAlpha(64),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Three stats
          Row(
            children: [
              Expanded(
                child: _buildMonthStat(
                  ' Income',
                  TransactionService.formatCurrency(income),
                  const Color(0xFF86EFAC),
                ),
              ),
              Expanded(
                child: _buildMonthStat(
                  ' Spent',
                  TransactionService.formatCurrency(expense),
                  const Color(0xFFFCA5A5),
                ),
              ),
              Expanded(
                child: _buildMonthStat(
                  ' Remaining',
                  '${netNeg ? '-' : ''}${TransactionService.formatCurrency(net.abs())}',
                  netNeg
                      ? const Color(0xFFFCA5A5)
                      : const Color(0xFFBFDBFE),
                ),
              ),
            ],
          ),

          // Budget bar
          if (budgetPct != null) ...[
            Divider(
                color: Colors.white.withAlpha(51), height: 24),
            Row(
              children: [
                const Expanded(
                  child: Text('Budget',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ),
                Text(
                  '${TransactionService.formatCurrency(expense)} / ${TransactionService.formatCurrency(_budget!)}',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: budgetPct,
                backgroundColor: Colors.white.withAlpha(51),
                valueColor: AlwaysStoppedAnimation(
                    budgetWarn
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFF86EFAC)),
                minHeight: 8,
              ),
            ),
            if (budgetWarn) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFFCA5A5), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    '${(budgetPct * 100).toStringAsFixed(0)}% of budget used',
                    style: const TextStyle(
                        color: Color(0xFFFCA5A5),
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildMonthStat(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontSize: 14,
                fontWeight: FontWeight.w700)),
      ],
    );
  }

  //  Section 4: Category spending 

  Widget _buildCategorySpending(double totalExpense) {
    final breakdown = _svc.expenseByCategory(_monthTxs);
    if (breakdown.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: breakdown.entries.map((entry) {
          final cat   = TransactionCategories.find(entry.key, TransactionType.expense)
              ?? TransactionCategories.fallback(TransactionType.expense);
          final pct   = totalExpense > 0 ? entry.value / totalExpense : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(cat.emoji,
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(cat.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ),
                    Text(TransactionService.formatCurrency(entry.value),
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: cat.color)),
                    const SizedBox(width: 8),
                    Text('${(pct * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                            color: Color(0xFF9E9E9E), fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor:
                        cat.color.withAlpha(31),
                    valueColor: AlwaysStoppedAnimation(cat.color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  //  Section 5: Recent transactions 

  Widget _buildTransactionList(List<Transaction> txs) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: txs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) => _TransactionTile(
        transaction: txs[i],
        onTap: () => _showDetail(txs[i]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.account_balance_wallet_rounded, size: 48, color: Color(0xFF7C3AED)),
          const SizedBox(height: 16),
          const Text('No transactions yet.',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 8),
          const Text(
            'Add your first expense or income\nto get started.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF9E9E9E), height: 1.5),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () => _openAdd(type: TransactionType.income),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Money'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              FilledButton.icon(
                onPressed: () => _openAdd(type: TransactionType.expense),
                icon: const Icon(Icons.remove, size: 18),
                label: const Text('Add Expense'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //  Section 6: Monthly history 

  Widget _buildMonthlyHistory() {
    final now     = DateTime.now();
    final current = DateTime(now.year, now.month);
    // Show all months except the currently viewed month
    final pastMonths = _monthHistory.where((m) => m != current).toList();

    if (pastMonths.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: pastMonths.asMap().entries.map((e) {
          final idx   = e.key;
          final month = e.value;
          final txs   = _svc.getForMonth(month);
          final inc   = _svc.totalIncome(txs);
          final exp   = _svc.totalExpense(txs);
          final net   = inc - exp;
          final netNeg = net < 0;
          final isLast = idx == pastMonths.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: () => _changeMonth(month),
                borderRadius: BorderRadius.only(
                  topLeft: idx == 0
                      ? const Radius.circular(20)
                      : Radius.zero,
                  topRight: idx == 0
                      ? const Radius.circular(20)
                      : Radius.zero,
                  bottomLeft: isLast
                      ? const Radius.circular(20)
                      : Radius.zero,
                  bottomRight: isLast
                      ? const Radius.circular(20)
                      : Radius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // Month label
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              TransactionService.formatMonthYear(month),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${txs.length} transaction${txs.length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9E9E9E)),
                            ),
                          ],
                        ),
                      ),

                      // Income
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('+${TransactionService.formatCurrency(inc)}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF10B981))),
                          Text('-${TransactionService.formatCurrency(exp)}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFF6B6B))),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Net
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: netNeg
                              ? const Color(0xFFFF6B6B).withAlpha(26)
                              : const Color(0xFF10B981).withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${netNeg ? '-' : '+'}${TransactionService.formatCurrency(net.abs())}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: netNeg
                                ? const Color(0xFFFF6B6B)
                                : const Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Colors.grey.shade100),
            ],
          );
        }).toList(),
      ),
    );
  }

  //  Shared helpers 

  Widget _buildSectionHeader(String title) {
    return Text(title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A2E),
        ));
  }
}

//  Action button widget 

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(64)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//  Pulsing mic animation 

class _PulsingMic extends StatefulWidget {
  const _PulsingMic({super.key});

  @override
  State<_PulsingMic> createState() => _PulsingMicState();
}

class _PulsingMicState extends State<_PulsingMic>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.6, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: const Icon(Icons.mic_rounded, color: Colors.white, size: 22),
    );
  }
}

//  Transaction tile widget 

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;

  const _TransactionTile({required this.transaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tx   = transaction;
    final isEx = tx.type == TransactionType.expense;
    final cat  = TransactionCategories.find(tx.category, tx.type)
        ?? TransactionCategories.fallback(tx.type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x07000000),
                blurRadius: 6,
                offset: Offset(0, 2)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cat.color.withAlpha(31),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(cat.emoji,
                  style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),

            // Category + note + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.category,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF1A1A2E))),
                  if (tx.note.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(tx.note,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF9E9E9E)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 2),
                  Text(TransactionService.formatShortDate(tx.date),
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFFB0B0B0))),
                ],
              ),
            ),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isEx ? '-' : '+'}${TransactionService.formatCurrency(tx.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isEx
                        ? const Color(0xFFFF6B6B)
                        : const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(height: 4),
                Icon(Icons.chevron_right,
                    size: 16, color: Colors.grey.shade300),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//  Transaction detail bottom sheet 

class _TransactionDetailSheet extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TransactionDetailSheet({
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tx   = transaction;
    final isEx = tx.type == TransactionType.expense;
    final cat  = TransactionCategories.find(tx.category, tx.type)
        ?? TransactionCategories.fallback(tx.type);
    final amountColor =
        isEx ? const Color(0xFFFF6B6B) : const Color(0xFF10B981);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          Text(cat.emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(
            '${isEx ? '-' : '+'}${TransactionService.formatCurrency(tx.amount)}',
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: amountColor),
          ),
          const SizedBox(height: 4),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: (isEx
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFF10B981))
                  .withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isEx ? 'Expense' : 'Income',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: amountColor),
            ),
          ),
          const SizedBox(height: 20),

          _DetailRow(label: 'Category', value: tx.category),
          if (tx.note.isNotEmpty)
            _DetailRow(label: 'Note', value: tx.note),
          _DetailRow(
              label: 'Date',
              value: TransactionService.formatShortDate(tx.date)),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(
                    color: Color(0xFF9E9E9E), fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1A1A2E))),
          ),
        ],
      ),
    );
  }
}

