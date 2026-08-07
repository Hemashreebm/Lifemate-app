import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

/// User Profile Service with Hybrid Local Storage & Firebase Firestore Cloud Sync
class ProfileService {
  static final ProfileService instance = ProfileService._internal();
  ProfileService._internal();

  static const String _keyName = 'profile_name';
  static const String _keyNickname = 'profile_nickname';
  static const String _keyAge = 'profile_age';
  static const String _keyOccupation = 'profile_occupation';
  static const String _keyLanguage = 'profile_language';
  static const String _keyAvatar = 'profile_avatar';
  static const String _keyCompleted = 'profile_completed';

  String name = '';
  String nickname = '';
  String age = '';
  String occupation = 'Student';
  String preferredLanguage = 'English';
  String avatar = 'Profile';
  bool isCompleted = false;

  /// Loads profile from local SharedPreferences and initiates Firestore Cloud Sync
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      name = prefs.getString(_keyName) ?? '';
      nickname = prefs.getString(_keyNickname) ?? '';
      age = prefs.getString(_keyAge) ?? '';
      occupation = prefs.getString(_keyOccupation) ?? 'Student';
      preferredLanguage = prefs.getString(_keyLanguage) ?? 'English';
      avatar = prefs.getString(_keyAvatar) ?? 'Profile';
      isCompleted = prefs.getBool(_keyCompleted) ?? false;

      // Automatically sync from cloud if user is authenticated
      await fetchFromCloud();
    } catch (e) {
      debugPrint('[PROFILE SERVICE] Error loading profile: $e');
    }
  }

  /// Downloads profile data from Cloud Firestore (users/{uid}) and updates local storage
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
        final cloudName = (data['name'] as String?) ?? user.displayName ?? '';
        final cloudNickname = (data['nickname'] as String?) ?? '';
        final cloudAge = (data['age'] as String?) ?? '';
        final cloudOccupation = (data['occupation'] as String?) ?? 'Student';
        final cloudLanguage = (data['language'] as String?) ?? 'English';
        final cloudAvatar = (data['avatar'] as String?) ?? 'Profile';

        if (cloudName.isNotEmpty) {
          name = cloudName;
          nickname = cloudNickname;
          age = cloudAge;
          occupation = cloudOccupation;
          preferredLanguage = cloudLanguage;
          avatar = cloudAvatar;
          isCompleted = true;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_keyName, name);
          await prefs.setString(_keyNickname, nickname);
          await prefs.setString(_keyAge, age);
          await prefs.setString(_keyOccupation, occupation);
          await prefs.setString(_keyLanguage, preferredLanguage);
          await prefs.setString(_keyAvatar, avatar);
          await prefs.setBool(_keyCompleted, true);

          debugPrint('[PROFILE CLOUD SUCCESS] Restored cloud profile for ${user.email} (${user.uid})');
          return true;
        }
      }
    } catch (e) {
      debugPrint('[PROFILE CLOUD WARNING] Unable to fetch cloud profile: $e');
    }
    return false;
  }

  /// Saves updated profile data to SharedPreferences and syncs to Cloud Firestore immediately
  Future<void> saveProfile({
    required String newName,
    String? newNickname,
    String? newAge,
    required String newOccupation,
    required String newLanguage,
    required String newAvatar,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      name = newName.trim();
      nickname = (newNickname ?? '').trim();
      age = (newAge ?? '').trim();
      occupation = newOccupation;
      preferredLanguage = newLanguage;
      avatar = newAvatar;
      isCompleted = true;

      await prefs.setString(_keyName, name);
      await prefs.setString(_keyNickname, nickname);
      await prefs.setString(_keyAge, age);
      await prefs.setString(_keyOccupation, occupation);
      await prefs.setString(_keyLanguage, preferredLanguage);
      await prefs.setString(_keyAvatar, avatar);
      await prefs.setBool(_keyCompleted, true);

      // Cloud Firestore Sync
      await syncToCloud();
    } catch (e) {
      debugPrint('[PROFILE SERVICE] Error saving profile: $e');
    }
  }

  /// Uploads current local profile data to Cloud Firestore (users/{uid})
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
        'occupation': occupation,
        'language': preferredLanguage,
        'avatar': avatar,
        'photoURL': user.photoURL,
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
