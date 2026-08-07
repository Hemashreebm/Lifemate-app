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
  final String smsReference;

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
    required this.smsReference,
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
  /// Rejects OTP, personal, or non-financial messages.
  ParsedSmsTransaction? parseSmsText(String sender, String body, {DateTime? messageDate}) {
    final text = body.toLowerCase();
    final date = messageDate ?? DateTime.now();

    // 1. REJECT OTP, Personal, or Security verification messages immediately
    final isOtpOrSecurity = text.contains('otp') ||
        text.contains('one time password') ||
        text.contains('secret code') ||
        text.contains('verification code') ||
        text.contains('do not share') ||
        text.contains('auth code') ||
        text.contains('password reset') ||
        text.contains('login alert');

    if (isOtpOrSecurity) {
      debugPrint('[SMS PARSER] Ignored OTP/Security message from $sender');
      return null;
    }

    // 2. Check for Financial Keywords
    final isFinancial = text.contains('debited') ||
        text.contains('credited') ||
        text.contains('spent') ||
        text.contains('sent to') ||
        text.contains('paid to') ||
        text.contains('received') ||
        text.contains('transferred') ||
        text.contains('vpa') ||
        text.contains('upi') ||
        text.contains('a/c') ||
        text.contains('acct') ||
        text.contains('card');

    if (!isFinancial) return null;

    // 3. Determine Type: Expense vs Income
    String type = 'expense';
    if (text.contains('credited') || text.contains('received') || text.contains('deposited')) {
      type = 'income';
    }

    // 4. Extract Amount (handles Rs. 1,500.00 / INR 250 / Rs 500)
    double amount = 0.0;
    final amountRegex = RegExp(r'(?:rs\.?|inr|\$)\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false);
    final match = amountRegex.firstMatch(text);
    if (match != null) {
      final rawAmountStr = match.group(1)!.replaceAll(',', '');
      amount = double.tryParse(rawAmountStr) ?? 0.0;
    }

    if (amount <= 0.0) return null; // No valid transaction amount

    // 5. Extract Merchant Name
    String merchant = 'Bank Transaction';
    final merchantRegexes = [
      RegExp(r'(?:at|to|via|vpa|info:)\s+([a-zA-Z0-9\s&\.\-\_]{3,25})(?:\s+on|\s+ref|\s+avail|\.|$)', caseSensitive: false),
      RegExp(r'paid to\s+([a-zA-Z0-9\s&\.\-\_]{3,25})', caseSensitive: false),
    ];

    for (final r in merchantRegexes) {
      final m = r.firstMatch(body);
      if (m != null) {
        final extracted = m.group(1)!.trim();
        final extLower = extracted.toLowerCase();
        if (extracted.length > 2 &&
            !extLower.contains('account') &&
            !extLower.contains('card') &&
            !extLower.contains('your a/c')) {
          merchant = extracted;
          break;
        }
      }
    }

    // 6. Extract Remaining Balance
    double remainingBalance = 0.0;
    final balRegex = RegExp(r'(?:bal|balance)\s*(?:is|:)?\s*(?:rs\.?|inr|\$)?\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false);
    final balMatch = balRegex.firstMatch(text);
    if (balMatch != null) {
      final rawBal = balMatch.group(1)!.replaceAll(',', '');
      remainingBalance = double.tryParse(rawBal) ?? 0.0;
    }

    // 7. Detect Bank Name from Sender ID or Body
    String bankName = 'Bank';
    final senderUpper = sender.toUpperCase();
    if (senderUpper.contains('HDFC') || text.contains('hdfc')) {
      bankName = 'HDFC Bank';
    } else if (senderUpper.contains('SBI') || text.contains('sbi')) {
      bankName = 'State Bank of India';
    } else if (senderUpper.contains('ICICI') || text.contains('icici')) {
      bankName = 'ICICI Bank';
    } else if (senderUpper.contains('AXIS') || text.contains('axis')) {
      bankName = 'Axis Bank';
    } else if (senderUpper.contains('KOTAK') || text.contains('kotak')) {
      bankName = 'Kotak Mahindra Bank';
    } else if (senderUpper.contains('PNB') || text.contains('pnb')) {
      bankName = 'Punjab National Bank';
    } else if (senderUpper.contains('BOB') || text.contains('baroda')) {
      bankName = 'Bank of Baroda';
    } else if (senderUpper.contains('PAYTM') || text.contains('paytm')) {
      bankName = 'Paytm';
    } else if (senderUpper.contains('GPAY') || text.contains('gpay')) {
      bankName = 'Google Pay';
    } else if (senderUpper.contains('PHONEPE') || text.contains('phonepe')) {
      bankName = 'PhonePe';
    } else if (senderUpper.contains('CRED') || text.contains('cred')) {
      bankName = 'CRED';
    }

    // 8. Auto-Categorize Category ID
    String categoryId = 'other';
    final mLower = merchant.toLowerCase();
    if (type == 'income') {
      categoryId = 'income';
    } else if (mLower.contains('swiggy') ||
        mLower.contains('zomato') ||
        mLower.contains('food') ||
        mLower.contains('restaurant') ||
        mLower.contains('cafe') ||
        mLower.contains('hotel') ||
        mLower.contains('blinkit') ||
        mLower.contains('zepto')) {
      categoryId = 'food';
    } else if (mLower.contains('uber') ||
        mLower.contains('ola') ||
        mLower.contains('rapido') ||
        mLower.contains('metro') ||
        mLower.contains('petrol') ||
        mLower.contains('fuel') ||
        mLower.contains('shell') ||
        mLower.contains('indianoil')) {
      categoryId = 'transport';
    } else if (mLower.contains('amazon') ||
        mLower.contains('flipkart') ||
        mLower.contains('myntra') ||
        mLower.contains('ajio') ||
        mLower.contains('store') ||
        mLower.contains('mart') ||
        mLower.contains('retail')) {
      categoryId = 'shopping';
    } else if (mLower.contains('bill') ||
        mLower.contains('bescom') ||
        mLower.contains('electricity') ||
        mLower.contains('jio') ||
        mLower.contains('airtel') ||
        mLower.contains('vi') ||
        mLower.contains('wifi') ||
        mLower.contains('recharge')) {
      categoryId = 'bills';
    } else if (mLower.contains('pharmacy') ||
        mLower.contains('apollo') ||
        mLower.contains('1mg') ||
        mLower.contains('hospital') ||
        mLower.contains('clinic')) {
      categoryId = 'health';
    } else if (mLower.contains('netflix') ||
        mLower.contains('bookmyshow') ||
        mLower.contains('hotstar') ||
        mLower.contains('spotify') ||
        mLower.contains('prime')) {
      categoryId = 'entertainment';
    }

    // Unique reference hash to prevent duplicate imports
    final ref = 'sms_${sender}_${amount}_${date.millisecondsSinceEpoch}';

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
      smsReference: ref,
    );
  }

  /// Automatically import parsed SMS into TransactionService if not already imported.
  Future<bool> importParsedSms(ParsedSmsTransaction smsTx) async {
    try {
      // Prevent Duplicate Import
      final existingTx = TransactionService.instance.transactions.firstWhere(
        (t) => t.smsReference == smsTx.smsReference ||
               (t.amount == smsTx.amount &&
                t.date.day == smsTx.date.day &&
                t.date.month == smsTx.date.month &&
                t.note.contains(smsTx.merchant)),
        orElse: () => Transaction(
          id: '',
          type: TransactionType.expense,
          amount: 0,
          category: '',
          note: '',
          date: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );

      if (existingTx.id.isNotEmpty) {
        debugPrint('[SMS PARSER] Duplicate transaction ignored: ${smsTx.merchant} - ${smsTx.amount}');
        return false;
      }

      final newTx = Transaction(
        id: Transaction.generateId(),
        type: smsTx.type == 'income' ? TransactionType.income : TransactionType.expense,
        amount: smsTx.amount,
        category: smsTx.categoryId,
        note: '${smsTx.merchant} (Auto-imported from ${smsTx.bankName} SMS)',
        date: smsTx.date,
        createdAt: DateTime.now(),
        source: 'sms',
        smsReference: smsTx.smsReference,
      );

      await TransactionService.instance.add(newTx);
      debugPrint('[SMS PARSER] Transaction imported: ${smsTx.merchant} - ${smsTx.amount}');
      return true;
    } catch (e) {
      debugPrint('[SMS PARSER] Error importing transaction: $e');
      return false;
    }
  }

  /// Get sample bank SMS templates for instant testing & demo.
  List<Map<String, String>> getSampleBankSmsTemplates() {
    return const [
      {
        'sender': 'AD-HDFCBK',
        'body': 'Rs. 1,450.00 debited from A/C **9823 at Swiggy via UPI on 07-08-26. Avail Bal: Rs. 14,230.50.',
      },
      {
        'sender': 'VM-SBINB',
        'body': 'Dear Customer, your A/C XXXXX1234 has been credited by Rs. 25,000.00 on 07-08-26 by Salary/Employer. Avail Bal: Rs. 42,500.00.',
      },
      {
        'sender': 'AX-ICICIB',
        'body': 'ALERT: Rs. 2,999.00 spent on ICICI Bank Card xx4012 at Amazon India on 07-08-26. Avail Bal: Rs. 38,100.00.',
      },
      {
        'sender': 'BP-PAYTM',
        'body': 'Paid Rs. 420.00 to Shell Petrol Pump via Paytm UPI. Transaction ID: 39401294812.',
      },
      {
        'sender': 'VK-PHONEPE',
        'body': 'Rs. 699.00 paid to Bescom Electricity Bill via PhonePe. Ref: 2049182391.',
      },
    ];
  }
}

