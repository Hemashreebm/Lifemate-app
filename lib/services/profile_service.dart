import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local Storage Service for Lifemate User Profile
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
  String avatar = '👤';
  bool isCompleted = false;

  /// Loads saved profile data from SharedPreferences
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      name = prefs.getString(_keyName) ?? '';
      nickname = prefs.getString(_keyNickname) ?? '';
      age = prefs.getString(_keyAge) ?? '';
      occupation = prefs.getString(_keyOccupation) ?? 'Student';
      preferredLanguage = prefs.getString(_keyLanguage) ?? 'English';
      avatar = prefs.getString(_keyAvatar) ?? '👤';
      isCompleted = prefs.getBool(_keyCompleted) ?? false;
    } catch (e) {
      debugPrint('[PROFILE SERVICE] Error loading profile: $e');
    }
  }

  /// Saves updated profile data to SharedPreferences
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
    } catch (e) {
      debugPrint('[PROFILE SERVICE] Error saving profile: $e');
    }
  }
}
