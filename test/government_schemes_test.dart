import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifemate/models/government_scheme.dart';
import 'package:lifemate/repositories/local_verified_scheme_repository.dart';
import 'package:lifemate/services/profile_service.dart';
import 'package:lifemate/services/scheme_personalization_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Government Schemes Unit Tests (Phase 3)', () {
    late LocalVerifiedSchemeRepository repo;
    late ProfileService profileService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repo = LocalVerifiedSchemeRepository.instance;
      profileService = ProfileService.instance;

      // Reset profile service
      profileService.name = '';
      profileService.nickname = '';
      profileService.age = '';
      profileService.gender = '';
      profileService.state = '';
      profileService.district = '';
      profileService.occupation = 'Student';
      profileService.educationLevel = '';
      profileService.employmentStatus = '';
      profileService.incomeRange = '';
      profileService.isFarmer = false;
      profileService.isBusiness = false;
      profileService.isStudentFlag = false;
      profileService.preferredLanguage = 'English';
      profileService.avatar = 'Profile';
      profileService.isCompleted = false;
    });

    test('GovernmentScheme model serialization and map parsing', () {
      final scheme = GovernmentScheme(
        id: 'test_scheme_01',
        name: 'Test Farmer Subsidy',
        description: 'Test Description',
        governmentDepartment: 'Ministry of Agriculture',
        category: 'Agriculture',
        state: 'Andhra Pradesh',
        benefits: '₹10,000 per year',
        eligibility: 'Farmers in AP',
        requiredDocuments: const ['Aadhaar', 'Passbook'],
        applicationSteps: const ['Visit CSC', 'Submit details'],
        officialWebsiteUrl: 'https://ap.gov.in',
        targetGroups: const ['Farmer'],
        lastVerifiedAt: '2026-08-01',
      );

      final map = scheme.toMap();
      final parsed = GovernmentScheme.fromMap(map, 'test_scheme_01');

      expect(parsed.id, equals('test_scheme_01'));
      expect(parsed.name, equals('Test Farmer Subsidy'));
      expect(parsed.state, equals('Andhra Pradesh'));
      expect(parsed.officialWebsiteUrl, equals('https://ap.gov.in'));
    });

    test('LocalVerifiedSchemeRepository returns verified official schemes', () async {
      final schemes = await repo.getAllSchemes();
      expect(schemes.length, greaterThanOrEqualTo(10));
      for (final s in schemes) {
        expect(s.officialWebsiteUrl, startsWith('http'));
        expect(s.governmentDepartment, isNotEmpty);
      }
    });

    test('Filter schemes by category and state', () async {
      final agSchemes = await repo.filterSchemes(category: 'Agriculture');
      expect(agSchemes.every((s) => s.category == 'Agriculture'), isTrue);

      final apSchemes = await repo.filterSchemes(state: 'Andhra Pradesh');
      expect(apSchemes.every((s) => s.state == 'Central' || s.state == 'Andhra Pradesh'), isTrue);
    });

    test('SchemePersonalizationEngine matches Student profile', () async {
      await profileService.saveProfile(
        newName: 'Ananya Rao',
        newOccupation: 'Student',
        newIsStudent: true,
        newLanguage: 'English',
        newAvatar: 'Profile',
      );

      final nmmss = await repo.getSchemeById('scheme_nsp_scholarship');
      expect(nmmss, isNotNull);

      final result = SchemePersonalizationEngine.evaluate(nmmss!, profileService);
      expect(result.isRecommended, isTrue);
      expect(result.reasonTags, contains('🎓 Student Match'));
    });

    test('SchemePersonalizationEngine matches Farmer profile & State match', () async {
      await profileService.saveProfile(
        newName: 'Ramesh Kumar',
        newState: 'Andhra Pradesh',
        newOccupation: 'Farmer / Agriculture',
        newIsFarmer: true,
        newLanguage: 'Telugu',
        newAvatar: 'Profile',
      );

      final rythu = await repo.getSchemeById('scheme_ap_rythu_bharosa');
      expect(rythu, isNotNull);

      final result = SchemePersonalizationEngine.evaluate(rythu!, profileService);
      expect(result.isRecommended, isTrue);
      expect(result.reasonTags, contains('🌾 Farmer / Agriculture Match'));
      expect(result.reasonTags, contains('📍 State Match (Andhra Pradesh)'));
    });

    test('SchemePersonalizationEngine matches Senior Citizen age (60+)', () async {
      await profileService.saveProfile(
        newName: 'Venkat Rao',
        newAge: '65',
        newOccupation: 'Retired',
        newLanguage: 'Kannada',
        newAvatar: 'Profile',
      );

      final apy = await repo.getSchemeById('scheme_apy');
      expect(apy, isNotNull);

      final result = SchemePersonalizationEngine.evaluate(apy!, profileService);
      expect(result.reasonTags, contains('👴 Senior Citizen Match (60+ yrs)'));
    });

    test('Empty / uncompleted profile does not claim false eligibility', () async {
      final pmkisan = await repo.getSchemeById('scheme_pm_kisan');
      expect(pmkisan, isNotNull);

      final result = SchemePersonalizationEngine.evaluate(pmkisan!, profileService);
      expect(result.isRecommended, isFalse);
      expect(result.matchScore, equals(0));
      expect(result.reasonTags, contains('Complete profile for personalization'));
    });
  });
}
