import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Data class holding structured information extracted from a scanned bill/receipt.
class ScannedBillResult {
  final String imagePath;
  final String merchantName;
  final double totalAmount;
  final DateTime date;
  final String gstNumber;
  final List<String> items;
  final String rawText;

  const ScannedBillResult({
    required this.imagePath,
    required this.merchantName,
    required this.totalAmount,
    required this.date,
    required this.gstNumber,
    required this.items,
    required this.rawText,
  });
}

/// Service providing OCR bill/receipt scanning using Google ML Kit Text Recognition.
class OcrBillScannerService {
  static final OcrBillScannerService instance = OcrBillScannerService._();
  OcrBillScannerService._();

  final ImagePicker _picker = ImagePicker();

  /// Scan receipt image from Camera or Gallery and parse financial data.
  Future<ScannedBillResult?> scanReceipt({required ImageSource source}) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (photo == null) return null;

      final inputImage = InputImage.fromFilePath(photo.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      final fullText = recognizedText.text;
      debugPrint('Recognized OCR Text:\n$fullText');

      // 1. Parse Merchant / Shop Name (First non-empty line)
      String merchantName = 'Scanned Receipt';
      final lines = fullText
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      if (lines.isNotEmpty) {
        merchantName = lines.firstWhere(
          (l) => l.length > 2 && !l.toUpperCase().contains('TAX') && !l.toUpperCase().contains('RECEIPT'),
          orElse: () => lines.first,
        );
      }

      // 2. Parse Total Amount using RegEx
      double totalAmount = 0.0;
      final amountRegexes = [
        RegExp(r'(?:TOTAL|GRAND TOTAL|NET AMOUNT|AMOUNT PAID|DUE|BALANCE)\s*[:=]?\s*(?:|Rs\.?|USD|\$)?\s*(\d+(?:\.\d{1,2})?)', caseSensitive: false),
        RegExp(r'(?:|Rs\.?)\s*(\d+(?:\.\d{1,2})?)', caseSensitive: false),
        RegExp(r'\b(\d+\.\d{2})\b'),
      ];

      for (final regex in amountRegexes) {
        final matches = regex.allMatches(fullText);
        for (final m in matches) {
          final str = m.group(1);
          if (str != null) {
            final parsed = double.tryParse(str);
            if (parsed != null && parsed > totalAmount) {
              totalAmount = parsed;
            }
          }
        }
      }

      // 3. Parse Date (DD/MM/YYYY or YYYY-MM-DD)
      DateTime date = DateTime.now();
      final dateRegex = RegExp(r'\b(\d{1,2})[\/\.-](\d{1,2})[\/\.-](\d{2,4})\b');
      final dateMatch = dateRegex.firstMatch(fullText);
      if (dateMatch != null) {
        try {
          final day = int.parse(dateMatch.group(1)!);
          final month = int.parse(dateMatch.group(2)!);
          var year = int.parse(dateMatch.group(3)!);
          if (year < 100) year += 2000;
          date = DateTime(year, month.clamp(1, 12), day.clamp(1, 31));
        } catch (_) {}
      }

      // 4. Parse GST
      String gstNumber = '';
      final gstRegex = RegExp(r'\b\d{2}[A-Z]{5}\d{4}[A-Z]{1}[A-Z0-9]{1}[Z]{1}[A-Z0-9]{1}\b');
      final gstMatch = gstRegex.firstMatch(fullText);
      if (gstMatch != null) {
        gstNumber = gstMatch.group(0)!;
      }

      // 5. Line items
      final List<String> extractedItems = [];
      for (final line in lines) {
        if (RegExp(r'\d+\.\d{2}').hasMatch(line) && !line.toUpperCase().contains('TOTAL')) {
          extractedItems.add(line);
        }
      }

      return ScannedBillResult(
        imagePath: photo.path,
        merchantName: merchantName,
        totalAmount: totalAmount,
        date: date,
        gstNumber: gstNumber,
        items: extractedItems,
        rawText: fullText,
      );
    } catch (e) {
      debugPrint('Error scanning receipt OCR: $e');
      return null;
    }
  }
}
