import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import 'transaction_service.dart';

/// Structured parsed transaction extracted from a financial SMS.
class ParsedSmsTransaction {
  final String body;
  final String sender;
  final double amount;
  final String type; // 'expense' or 'income'
  final String merchant;
  final String bankName;
  final double remainingBalance;
  final DateTime date;
  final String categoryId;

  const ParsedSmsTransaction({
    required this.body,
    required this.sender,
    required this.amount,
    required this.type,
    required this.merchant,
    required this.bankName,
    required this.remainingBalance,
    required this.date,
    required this.categoryId,
  });
}

/// Service that parses financial SMS messages into Lifemate Expense Tracker transactions.
class SmsExpenseParserService {
  static const String _prefSmsEnabled = 'lifemate_sms_tracking_enabled_v1';
  static final SmsExpenseParserService instance = SmsExpenseParserService._();
  SmsExpenseParserService._();

  bool _smsTrackingEnabled = false;
  bool get isSmsTrackingEnabled => _smsTrackingEnabled;

  /// Load SMS tracking settings from SharedPreferences.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _smsTrackingEnabled = prefs.getBool(_prefSmsEnabled) ?? false;
  }

  /// Enable or disable automatic SMS tracking.
  Future<void> setSmsTrackingEnabled(bool enabled) async {
    _smsTrackingEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefSmsEnabled, enabled);
  }

  /// Parse a financial SMS body string and extract transaction details.
  ParsedSmsTransaction? parseSmsText(String sender, String body, {DateTime? messageDate}) {
    final text = body.toLowerCase();
    final date = messageDate ?? DateTime.now();

    // Check if the SMS is a bank/financial notification
    final isFinancial = text.contains('debited') ||
        text.contains('credited') ||
        text.contains('spent') ||
        text.contains('sent to') ||
        text.contains('received') ||
        text.contains('transferred') ||
        text.contains('vpa') ||
        text.contains('upi') ||
        text.contains('bank');

    if (!isFinancial) return null;

    // 1. Determine Type: Expense vs Income
    String type = 'expense';
    if (text.contains('credited') || text.contains('received') || text.contains('deposited')) {
      type = 'income';
    }

    // 2. Extract Amount
    double amount = 0.0;
    final amountRegex = RegExp(r'(?:rs\.?|inr|₹)\s*(\d+(?:\.\d{1,2})?)', caseSensitive: false);
    final match = amountRegex.firstMatch(text);
    if (match != null) {
      amount = double.tryParse(match.group(1)!) ?? 0.0;
    }

    if (amount <= 0.0) return null; // No valid transaction amount

    // 3. Extract Merchant Name
    String merchant = 'Bank Transaction';
    final merchantRegexes = [
      RegExp(r'(?:at|to|via|vpa)\s+([a-zA-Z0-9\s&\.\-\_]{3,20})(?:\s+on|\s+ref|\s+avail|\.|$)', caseSensitive: false),
      RegExp(r'info:\s*([a-zA-Z0-9\s&\.\-\_]{3,20})', caseSensitive: false),
    ];

    for (final r in merchantRegexes) {
      final m = r.firstMatch(body);
      if (m != null) {
        final extracted = m.group(1)!.trim();
        if (extracted.length > 2 && !extracted.toLowerCase().contains('account') && !extracted.toLowerCase().contains('card')) {
          merchant = extracted;
          break;
        }
      }
    }

    // 4. Extract Remaining Balance
    double remainingBalance = 0.0;
    final balRegex = RegExp(r'(?:bal|balance)\s*(?:is|:)?\s*(?:rs\.?|inr|₹)?\s*(\d+(?:\.\d{1,2})?)', caseSensitive: false);
    final balMatch = balRegex.firstMatch(text);
    if (balMatch != null) {
      remainingBalance = double.tryParse(balMatch.group(1)!) ?? 0.0;
    }

    // 5. Detect Bank Name from Sender ID or Body
    String bankName = 'Bank';
    final senderUpper = sender.toUpperCase();
    if (senderUpper.contains('HDFC') || text.contains('hdfc')) {
      bankName = 'HDFC Bank';
    } else if (senderUpper.contains('SBI') || text.contains('sbi')) bankName = 'State Bank of India';
    else if (senderUpper.contains('ICICI') || text.contains('icici')) bankName = 'ICICI Bank';
    else if (senderUpper.contains('AXIS') || text.contains('axis')) bankName = 'Axis Bank';
    else if (senderUpper.contains('PAYTM') || text.contains('paytm')) bankName = 'Paytm Wallet';
    else if (senderUpper.contains('GPAY') || text.contains('gpay')) bankName = 'Google Pay';
    else if (senderUpper.contains('PHONEPE') || text.contains('phonepe')) bankName = 'PhonePe';

    // 6. Auto-Categorize Category ID
    String categoryId = 'other';
    final mLower = merchant.toLowerCase();
    if (type == 'income') {
      categoryId = 'income';
    } else if (mLower.contains('swiggy') || mLower.contains('zomato') || mLower.contains('food') || mLower.contains('restaurant') || mLower.contains('hotel')) {
      categoryId = 'food';
    } else if (mLower.contains('uber') || mLower.contains('ola') || mLower.contains('metro') || mLower.contains('petrol') || mLower.contains('fuel')) {
      categoryId = 'transport';
    } else if (mLower.contains('amazon') || mLower.contains('flipkart') || mLower.contains('myntra') || mLower.contains('mart') || mLower.contains('store')) {
      categoryId = 'shopping';
    } else if (mLower.contains('bill') || mLower.contains('bescom') || mLower.contains('jio') || mLower.contains('airtel') || mLower.contains('wifi')) {
      categoryId = 'bills';
    }

    return ParsedSmsTransaction(
      body: body,
      sender: sender,
      amount: amount,
      type: type,
      merchant: merchant,
      bankName: bankName,
      remainingBalance: remainingBalance,
      date: date,
      categoryId: categoryId,
    );
  }

  /// Automatically import parsed SMS as a new transaction in TransactionService.
  Future<bool> importParsedSms(ParsedSmsTransaction smsTx) async {
    try {
      final newTx = Transaction(
        id: Transaction.generateId(),
        type: smsTx.type == 'income' ? TransactionType.income : TransactionType.expense,
        amount: smsTx.amount,
        category: smsTx.categoryId,
        note: '${smsTx.merchant} (Auto-imported from ${smsTx.bankName} SMS)',
        date: smsTx.date,
        createdAt: DateTime.now(),
      );

      await TransactionService.instance.add(newTx);
      debugPrint('SMS transaction successfully imported: ${smsTx.merchant} - ₹${smsTx.amount}');
      return true;
    } catch (e) {
      debugPrint('Error importing SMS transaction: $e');
      return false;
    }
  }
}
