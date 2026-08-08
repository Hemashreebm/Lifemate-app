import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifemate/services/supabase_service.dart';
import 'package:lifemate/repositories/supabase_government_scheme_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Supabase Development Integration Unit Tests (Phase 4)', () {
    late SupabaseService supabaseService;
    late SupabaseGovernmentSchemeRepository supabaseRepo;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      supabaseService = SupabaseService.instance;
      supabaseRepo = SupabaseGovernmentSchemeRepository();
    });

    test('SupabaseService handles placeholder/offline configuration gracefully', () async {
      final initialized = await supabaseService.initialize(customUrl: 'dev-project-placeholder', customAnonKey: '');
      // Should return false for placeholder credentials without crashing
      expect(initialized, isFalse);
      expect(supabaseService.isInitialized, isFalse);
      expect(supabaseService.client, isNull);
    });

    test('SupabaseService connection test returns offline fallback status', () async {
      final diag = await supabaseService.testConnectionAndRls();
      expect(diag['connected'], isFalse);
      expect(diag['rlsWorking'], isTrue);
      expect(diag['message'], contains('Firebase remains primary backend'));
    });

    test('SupabaseGovernmentSchemeRepository falls back to LocalVerifiedSchemeRepository when offline', () async {
      final schemes = await supabaseRepo.getAllSchemes();
      expect(schemes, isNotEmpty);
      expect(schemes.length, greaterThanOrEqualTo(10));
      expect(schemes.first.officialWebsiteUrl, startsWith('http'));
    });

    test('SupabaseGovernmentSchemeRepository filters schemes under fallback mode', () async {
      final agSchemes = await supabaseRepo.filterSchemes(category: 'Agriculture');
      expect(agSchemes, isNotEmpty);
      expect(agSchemes.every((s) => s.category == 'Agriculture'), isTrue);
    });
  });
}
