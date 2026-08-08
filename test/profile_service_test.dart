import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifemate/services/profile_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfileService Unit Tests (Phase 2)', () {
    late ProfileService profileService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      profileService = ProfileService.instance;
      // Reset in-memory fields
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

    test('Initial uncompleted profile returns 0% completeness', () {
      expect(profileService.name, isEmpty);
      expect(profileService.isCompleted, isFalse);
      expect(profileService.completenessPercentage, equals(0));
      expect(profileService.missingFields, contains('Age'));
      expect(profileService.missingFields, contains('State'));
    });

    test('Saving name and basic info updates completeness baseline', () async {
      await profileService.saveProfile(
        newName: 'Hemashree B M',
        newOccupation: 'Software Developer',
        newLanguage: 'English',
        newAvatar: 'Profile',
      );

      expect(profileService.name, equals('Hemashree B M'));
      expect(profileService.isCompleted, isTrue);
      expect(profileService.completenessPercentage, greaterThanOrEqualTo(40));
    });

    test('Personalization getters accurately evaluate age, occupation, and flags', () async {
      await profileService.saveProfile(
        newName: 'Test User',
        newAge: '62',
        newOccupation: 'Farmer / Agriculturalist',
        newIsFarmer: true,
        newIsStudent: false,
        newIsBusiness: false,
        newLanguage: 'Telugu',
        newAvatar: 'Profile',
      );

      expect(profileService.ageInt, equals(62));
      expect(profileService.isSeniorCitizen, isTrue);
      expect(profileService.isFarmerUser, isTrue);
      expect(profileService.isStudent, isFalse);
      expect(profileService.isBusinessUser, isFalse);
    });

    test('Full profile details achieve 100% completeness score', () async {
      await profileService.saveProfile(
        newName: 'Priya Sharma',
        newNickname: 'Priya',
        newAge: '24',
        newGender: 'Female',
        newState: 'Karnataka',
        newDistrict: 'Bengaluru Urban',
        newOccupation: 'Student',
        newEducationLevel: 'Postgraduate (Master\'s)',
        newEmploymentStatus: 'Student',
        newIncomeRange: 'Below ₹1 Lakh per year',
        newIsStudent: true,
        newLanguage: 'Kannada',
        newAvatar: '🎯',
      );

      expect(profileService.completenessPercentage, equals(100));
      expect(profileService.missingFields, isEmpty);
      expect(profileService.isStudent, isTrue);
    });
  });
}
