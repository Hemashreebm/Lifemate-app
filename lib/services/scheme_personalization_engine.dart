import '../models/government_scheme.dart';
import 'profile_service.dart';

/// Match Result object returned by the personalization engine.
class SchemeMatchResult {
  final GovernmentScheme scheme;
  final bool isRecommended;
  final int matchScore; // 0 to 100
  final List<String> reasonTags;
  final String disclaimer;

  const SchemeMatchResult({
    required this.scheme,
    required this.isRecommended,
    required this.matchScore,
    required this.reasonTags,
    this.disclaimer = 'Eligibility information should be verified on the official government website.',
  });
}

/// Privacy-First On-Device Personalization Engine for Government Schemes.
class SchemePersonalizationEngine {
  /// Evaluates a GovernmentScheme against the current ProfileService instance.
  static SchemeMatchResult evaluate(GovernmentScheme scheme, ProfileService profile) {
    if (profile.name.trim().isEmpty) {
      return SchemeMatchResult(
        scheme: scheme,
        isRecommended: false,
        matchScore: 0,
        reasonTags: const ['Complete profile for personalization'],
      );
    }

    int score = 0;
    final reasons = <String>[];

    // 1. State / Regional Matching
    final schemeState = scheme.state.trim().toLowerCase();
    final userState = profile.state.trim().toLowerCase();

    if (schemeState == 'central' || schemeState == 'all' || schemeState.isEmpty) {
      score += 25;
      reasons.add('🇮🇳 Central Scheme (All India)');
    } else if (userState.isNotEmpty && (userState == schemeState || schemeState.contains(userState))) {
      score += 40;
      reasons.add('📍 State Match (${profile.state})');
    } else if (userState.isNotEmpty && schemeState != 'central') {
      // Scheme is for a different state
      return SchemeMatchResult(
        scheme: scheme,
        isRecommended: false,
        matchScore: 0,
        reasonTags: const [],
      );
    }

    // 2. Student Target Matching
    if (profile.isStudent) {
      if (scheme.targetGroups.contains('Student') ||
          scheme.category == 'Education' ||
          scheme.category == 'Scholarships') {
        score += 35;
        reasons.add('🎓 Student Match');
      }
    }

    // 3. Farmer Target Matching
    if (profile.isFarmerUser) {
      if (scheme.targetGroups.contains('Farmer') ||
          scheme.category == 'Agriculture') {
        score += 35;
        reasons.add('🌾 Farmer / Agriculture Match');
      }
    }

    // 4. Business Owner / Entrepreneur Matching
    if (profile.isBusinessUser) {
      if (scheme.targetGroups.contains('Business') ||
          scheme.targetGroups.contains('Entrepreneur') ||
          scheme.category == 'Entrepreneurship' ||
          scheme.category == 'MSME') {
        score += 35;
        reasons.add('💼 Business & MSME Match');
      }
    }

    // 5. Senior Citizen Age Matching
    if (profile.isSeniorCitizen) {
      if (scheme.targetGroups.contains('Senior Citizen') ||
          scheme.category == 'Senior Citizens' ||
          scheme.category == 'Pension') {
        score += 35;
        reasons.add('👴 Senior Citizen Match (60+ yrs)');
      }
    }

    // 6. Gender Matching
    final userGender = profile.gender.trim().toLowerCase();
    if (scheme.targetGender.toLowerCase() == 'female') {
      if (userGender == 'female') {
        score += 30;
        reasons.add('👩 Designed for Women');
      } else if (userGender == 'male') {
        // Gender mismatch for women-only scheme
        return SchemeMatchResult(
          scheme: scheme,
          isRecommended: false,
          matchScore: 0,
          reasonTags: const [],
        );
      }
    }

    // 7. General Occupation Match
    final userOcc = profile.occupation.toLowerCase();
    if (userOcc.isNotEmpty && !profile.isStudent && !profile.isFarmerUser && !profile.isBusinessUser) {
      if (scheme.targetGroups.any((tg) => tg.toLowerCase() == userOcc)) {
        score += 20;
        reasons.add('👔 Occupation Match (${profile.occupation})');
      }
    }

    final isRecommended = score >= 50;

    return SchemeMatchResult(
      scheme: scheme,
      isRecommended: isRecommended,
      matchScore: score,
      reasonTags: reasons.isEmpty ? const ['Verified Government Scheme'] : reasons,
    );
  }
}
