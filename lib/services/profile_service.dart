import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

/// User Profile Service with Extensible Personalization Attributes,
/// Local Persistence (SharedPreferences), and Authenticated Cloud Firestore Sync.
class ProfileService {
  static final ProfileService instance = ProfileService._internal();
  ProfileService._internal();

  // SharedPreferences Keys
  static const String _keyName = 'profile_name';
  static const String _keyNickname = 'profile_nickname';
  static const String _keyAge = 'profile_age';
  static const String _keyGender = 'profile_gender';
  static const String _keyState = 'profile_state';
  static const String _keyDistrict = 'profile_district';
  static const String _keyOccupation = 'profile_occupation';
  static const String _keyEducation = 'profile_education';
  static const String _keyEmploymentStatus = 'profile_employment_status';
  static const String _keyIncomeRange = 'profile_income_range';
  static const String _keyIsFarmer = 'profile_is_farmer';
  static const String _keyIsBusiness = 'profile_is_business';
  static const String _keyIsStudent = 'profile_is_student';
  static const String _keyLanguage = 'profile_language';
  static const String _keyAvatar = 'profile_avatar';
  static const String _keyCompleted = 'profile_completed';

  // Profile Fields
  String name = '';
  String nickname = '';
  String age = '';
  String gender = '';
  String state = '';
  String district = '';
  String occupation = 'Student';
  String educationLevel = '';
  String employmentStatus = '';
  String incomeRange = '';
  bool isFarmer = false;
  bool isBusiness = false;
  bool isStudentFlag = false;
  String preferredLanguage = 'English';
  String avatar = 'Profile';
  bool isCompleted = false;

  //  Personalization & Helper Getters 

  /// Returns true if occupation or flag indicates student
  bool get isStudent {
    if (isStudentFlag) return true;
    final occ = occupation.toLowerCase();
    return occ.contains('student');
  }

  /// Returns true if user specified farmer occupation or flag
  bool get isFarmerUser {
    if (isFarmer) return true;
    final occ = occupation.toLowerCase();
    return occ.contains('farmer') || occ.contains('agricultur');
  }

  /// Returns true if user specified business/entrepreneur occupation or flag
  bool get isBusinessUser {
    if (isBusiness) return true;
    final occ = occupation.toLowerCase();
    return occ.contains('business') || occ.contains('entrepreneur') || occ.contains('self-employed');
  }

  /// Returns user age as integer, or 0 if unprovided/invalid
  int get ageInt {
    if (age.trim().isEmpty) return 0;
    return int.tryParse(age.trim()) ?? 0;
  }

  /// Returns true if user is 60 or older
  bool get isSeniorCitizen => ageInt >= 60;

  /// Calculate Profile Completeness Percentage (0 to 100)
  int get completenessPercentage {
    if (name.trim().isEmpty) return 0;
    int score = 30; // Baseline for name & app usage

    if (preferredLanguage.isNotEmpty) score += 10;
    if (age.trim().isNotEmpty) score += 10;
    if (gender.trim().isNotEmpty) score += 10;
    if (state.trim().isNotEmpty) score += 15;
    if (district.trim().isNotEmpty) score += 5;
    if (occupation.trim().isNotEmpty) score += 10;
    if (educationLevel.trim().isNotEmpty) score += 5;
    if (incomeRange.trim().isNotEmpty) score += 5;

    return score > 100 ? 100 : score;
  }

  /// List missing optional fields that could improve personalization
  List<String> get missingFields {
    final list = <String>[];
    if (age.trim().isEmpty) list.add('Age');
    if (gender.trim().isEmpty) list.add('Gender');
    if (state.trim().isEmpty) list.add('State');
    if (district.trim().isEmpty) list.add('District');
    if (occupation.trim().isEmpty) list.add('Occupation');
    if (educationLevel.trim().isEmpty) list.add('Education Level');
    if (incomeRange.trim().isEmpty) list.add('Income Range');
    return list;
  }

  //  Local Persistence & Firebase Firestore Sync 

  /// Loads profile from local SharedPreferences and initiates Firestore Cloud Sync
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      name = prefs.getString(_keyName) ?? '';
      nickname = prefs.getString(_keyNickname) ?? '';
      age = prefs.getString(_keyAge) ?? '';
      gender = prefs.getString(_keyGender) ?? '';
      state = prefs.getString(_keyState) ?? '';
      district = prefs.getString(_keyDistrict) ?? '';
      occupation = prefs.getString(_keyOccupation) ?? 'Student';
      educationLevel = prefs.getString(_keyEducation) ?? '';
      employmentStatus = prefs.getString(_keyEmploymentStatus) ?? '';
      incomeRange = prefs.getString(_keyIncomeRange) ?? '';
      isFarmer = prefs.getBool(_keyIsFarmer) ?? false;
      isBusiness = prefs.getBool(_keyIsBusiness) ?? false;
      isStudentFlag = prefs.getBool(_keyIsStudent) ?? false;
      preferredLanguage = prefs.getString(_keyLanguage) ?? 'English';
      avatar = prefs.getString(_keyAvatar) ?? 'Profile';
      isCompleted = prefs.getBool(_keyCompleted) ?? false;

      // Automatically sync from cloud if user is authenticated
      await fetchFromCloud();
    } catch (e) {
      debugPrint('[PROFILE SERVICE] Error loading profile: $e');
    }
  }

  /// Downloads profile data from Cloud Firestore (`users/{uid}`) and updates local storage
  Future<bool> fetchFromCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || AuthService.instance.isGuestMode) {
        return false;
      }

      debugPrint('[PROFILE CLOUD] Fetching profile from Firestore for UID: ${user.uid}...');
      final docSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 10));

      if (docSnap.exists && docSnap.data() != null) {
        final data = docSnap.data()!;
        name = (data['name'] as String?) ?? user.displayName ?? name;
        nickname = (data['nickname'] as String?) ?? nickname;
        age = (data['age'] as String?) ?? age;
        gender = (data['gender'] as String?) ?? gender;
        state = (data['state'] as String?) ?? state;
        district = (data['district'] as String?) ?? district;
        occupation = (data['occupation'] as String?) ?? occupation;
        educationLevel = (data['educationLevel'] as String?) ?? educationLevel;
        employmentStatus = (data['employmentStatus'] as String?) ?? employmentStatus;
        incomeRange = (data['incomeRange'] as String?) ?? incomeRange;
        isFarmer = (data['isFarmer'] as bool?) ?? isFarmer;
        isBusiness = (data['isBusiness'] as bool?) ?? isBusiness;
        isStudentFlag = (data['isStudentFlag'] as bool?) ?? isStudentFlag;
        preferredLanguage = (data['language'] as String?) ?? preferredLanguage;
        avatar = (data['avatar'] as String?) ?? avatar;
        isCompleted = name.trim().isNotEmpty;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyName, name);
        await prefs.setString(_keyNickname, nickname);
        await prefs.setString(_keyAge, age);
        await prefs.setString(_keyGender, gender);
        await prefs.setString(_keyState, state);
        await prefs.setString(_keyDistrict, district);
        await prefs.setString(_keyOccupation, occupation);
        await prefs.setString(_keyEducation, educationLevel);
        await prefs.setString(_keyEmploymentStatus, employmentStatus);
        await prefs.setString(_keyIncomeRange, incomeRange);
        await prefs.setBool(_keyIsFarmer, isFarmer);
        await prefs.setBool(_keyIsBusiness, isBusiness);
        await prefs.setBool(_keyIsStudent, isStudentFlag);
        await prefs.setString(_keyLanguage, preferredLanguage);
        await prefs.setString(_keyAvatar, avatar);
        await prefs.setBool(_keyCompleted, isCompleted);

        debugPrint('[PROFILE CLOUD SUCCESS] Restored cloud profile for ${user.email} (${user.uid})');
        return true;
      }
    } catch (e) {
      debugPrint('[PROFILE CLOUD WARNING] Unable to fetch cloud profile: $e');
    }
    return false;
  }

  /// Saves updated profile data to local storage and syncs to Cloud Firestore immediately
  Future<void> saveProfile({
    required String newName,
    String? newNickname,
    String? newAge,
    String? newGender,
    String? newState,
    String? newDistrict,
    required String newOccupation,
    String? newEducationLevel,
    String? newEmploymentStatus,
    String? newIncomeRange,
    bool? newIsFarmer,
    bool? newIsBusiness,
    bool? newIsStudent,
    required String newLanguage,
    required String newAvatar,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      name = newName.trim();
      nickname = (newNickname ?? '').trim();
      age = (newAge ?? '').trim();
      gender = (newGender ?? '').trim();
      state = (newState ?? '').trim();
      district = (newDistrict ?? '').trim();
      occupation = newOccupation;
      educationLevel = (newEducationLevel ?? '').trim();
      employmentStatus = (newEmploymentStatus ?? '').trim();
      incomeRange = (newIncomeRange ?? '').trim();
      isFarmer = newIsFarmer ?? false;
      isBusiness = newIsBusiness ?? false;
      isStudentFlag = newIsStudent ?? false;
      preferredLanguage = newLanguage;
      avatar = newAvatar;
      isCompleted = name.trim().isNotEmpty;

      await prefs.setString(_keyName, name);
      await prefs.setString(_keyNickname, nickname);
      await prefs.setString(_keyAge, age);
      await prefs.setString(_keyGender, gender);
      await prefs.setString(_keyState, state);
      await prefs.setString(_keyDistrict, district);
      await prefs.setString(_keyOccupation, occupation);
      await prefs.setString(_keyEducation, educationLevel);
      await prefs.setString(_keyEmploymentStatus, employmentStatus);
      await prefs.setString(_keyIncomeRange, incomeRange);
      await prefs.setBool(_keyIsFarmer, isFarmer);
      await prefs.setBool(_keyIsBusiness, isBusiness);
      await prefs.setBool(_keyIsStudent, isStudentFlag);
      await prefs.setString(_keyLanguage, preferredLanguage);
      await prefs.setString(_keyAvatar, avatar);
      await prefs.setBool(_keyCompleted, isCompleted);

      // Cloud Firestore Sync (scoped to authenticated UID)
      await syncToCloud();
    } catch (e) {
      debugPrint('[PROFILE SERVICE] Error saving profile: $e');
    }
  }

  /// Uploads current local profile data to Cloud Firestore (`users/{uid}`)
  Future<bool> syncToCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || AuthService.instance.isGuestMode) {
        return false;
      }

      final profileMap = {
        'uid': user.uid,
        'name': name,
        'nickname': nickname,
        'email': user.email ?? AuthService.instance.currentUserEmail,
        'age': age,
        'gender': gender,
        'state': state,
        'district': district,
        'occupation': occupation,
        'educationLevel': educationLevel,
        'employmentStatus': employmentStatus,
        'incomeRange': incomeRange,
        'isFarmer': isFarmer,
        'isBusiness': isBusiness,
        'isStudentFlag': isStudentFlag,
        'language': preferredLanguage,
        'avatar': avatar,
        'photoURL': user.photoURL,
        'completeness': completenessPercentage,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      debugPrint('[PROFILE CLOUD] Uploading profile update to users/${user.uid}...');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(profileMap, SetOptions(merge: true))
          .timeout(const Duration(seconds: 12));

      debugPrint('[PROFILE CLOUD SUCCESS] Firestore users/${user.uid} document updated successfully.');
      return true;
    } on FirebaseException catch (dbErr) {
      debugPrint('[PROFILE CLOUD ERROR] FirebaseException: ${dbErr.code} - ${dbErr.message}');
    } catch (e) {
      debugPrint('[PROFILE CLOUD ERROR] Sync exception: $e');
    }
    return false;
  }
}
