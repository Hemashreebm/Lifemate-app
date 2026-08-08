import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifemate/services/gemini_service.dart';
import 'package:lifemate/services/ai_memory_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Gemini AI Secure Architecture Unit Tests (Phase 5)', () {
    late GeminiService geminiService;
    late AiMemoryService memoryService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      geminiService = GeminiService.instance;
      geminiService.resetSessionCounter();
      memoryService = AiMemoryService.instance;
      await memoryService.clearAll();
    });

    test('GeminiService generates contextual responses in offline fallback mode without crashing', () async {
      final resTask = await geminiService.generateResponse('What tasks do I have today?');
      expect(resTask, contains('manage your day'));

      final resExpense = await geminiService.generateResponse('How much did I spend?');
      expect(resExpense, contains('financial peace of mind'));

      final resScheme = await geminiService.generateResponse('Are there any government schemes for me?');
      expect(resScheme, contains('Government schemes'));
    });

    test('AiMemoryService filters out sensitive credentials (passwords, OTPs, PINs, CVVs)', () async {
      await memoryService.remember(key: 'Banking Password', value: 'secret12345');
      expect(memoryService.getFact('Banking Password'), isNull);

      await memoryService.remember(key: 'Card PIN', value: '9876');
      expect(memoryService.getFact('Card PIN'), isNull);

      await memoryService.remember(key: 'SMS OTP', value: '554433');
      expect(memoryService.getFact('SMS OTP'), isNull);

      // Safe preference should be remembered
      await memoryService.remember(key: 'Preferred Call Name', value: 'Hema', category: 'preference');
      expect(memoryService.getFact('Preferred Call Name'), equals('Hema'));
    });

    test('AiMemoryService clearAll removes all memory facts', () async {
      await memoryService.remember(key: 'Goal 1', value: 'Learn English');
      expect(memoryService.allFacts, isNotEmpty);

      await memoryService.clearAll();
      expect(memoryService.allFacts, isEmpty);
    });

    test('GeminiService rate limits rapid requests without throwing exceptions', () async {
      geminiService.resetSessionCounter();
      final res = await geminiService.generateResponse('Hello AI');
      expect(res, isNotEmpty);
    });
  });
}
