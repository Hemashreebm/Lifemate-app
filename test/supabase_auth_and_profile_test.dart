import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifemate/services/supabase_auth_service.dart';
import 'package:lifemate/repositories/supabase_profile_repository.dart';
import 'package:lifemate/services/profile_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Supabase Cloud Database & Auth Unit Tests (Phase 7)', () {
    late SupabaseAuthService authService;
    late SupabaseProfileRepository profileRepo;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      authService = SupabaseAuthService.instance;
      profileRepo = SupabaseProfileRepository.instance;
    });

    test('SupabaseAuthService handles uninitialized / offline state without crashing', () async {
      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentUser, isNull);
      expect(authService.currentUserId, isNull);

      final res = await authService.signUpWithEmail(email: 'test@example.com', password: 'Password123!');
      expect(res, isNull);
    });

    test('SupabaseProfileRepository loadProfileFromCloud returns null when offline without throwing', () async {
      final profile = await profileRepo.loadProfileFromCloud('user_123');
      expect(profile, isNull);
    });

    test('SupabaseProfileRepository saveProfileToCloud returns false when offline without throwing', () async {
      final profileService = ProfileService.instance;
      await profileService.load();
      final success = await profileRepo.saveProfileToCloud(profileService);
      expect(success, isFalse);
    });
  });
}
