import 'package:flutter/foundation.dart';
import '../models/government_scheme.dart';
import '../services/profile_service.dart';
import '../services/scheme_personalization_engine.dart';
import '../services/supabase_service.dart';
import 'government_scheme_repository.dart';
import 'local_verified_scheme_repository.dart';

/// Supabase Implementation of GovernmentSchemeRepository.
///
/// Features:
/// 1. Queries Supabase `government_schemes` development table when connected.
/// 2. Falls back seamlessly to LocalVerifiedSchemeRepository if offline or uninitialized.
/// 3. Plugs directly into existing GovtSchemesScreen without UI rewrites.
class SupabaseGovernmentSchemeRepository implements GovernmentSchemeRepository {
  final LocalVerifiedSchemeRepository _localFallback = LocalVerifiedSchemeRepository.instance;

  @override
  Future<List<GovernmentScheme>> getAllSchemes() async {
    final supabase = SupabaseService.instance;
    if (!supabase.isInitialized || supabase.client == null) {
      debugPrint('[SUPABASE REPO] Offline/Uninitialized. Using LocalVerifiedSchemeRepository fallback.');
      return _localFallback.getAllSchemes();
    }

    try {
      final response = await supabase.client!
          .from('government_schemes')
          .select()
          .timeout(const Duration(seconds: 8));

      final list = (response as List<dynamic>).map((map) {
        return GovernmentScheme.fromMap(map as Map<String, dynamic>, (map['id'] as String?) ?? '');
      }).toList();

      if (list.isEmpty) {
        return _localFallback.getAllSchemes();
      }

      return list;
    } catch (e) {
      debugPrint('[SUPABASE REPO WARNING] Error fetching remote schemes: $e. Falling back to local verified repository.');
      return _localFallback.getAllSchemes();
    }
  }

  @override
  Future<List<GovernmentScheme>> filterSchemes({
    String? category,
    String? state,
    String? query,
  }) async {
    final all = await getAllSchemes();
    return all.where((scheme) {
      if (category != null && category.isNotEmpty && category != 'All') {
        if (scheme.category.toLowerCase() != category.toLowerCase()) return false;
      }

      if (state != null && state.isNotEmpty && state != 'All') {
        final scState = scheme.state.toLowerCase();
        final selState = state.toLowerCase();
        if (selState == 'central only') {
          if (scState != 'central') return false;
        } else {
          if (scState != 'central' && scState != selState) return false;
        }
      }

      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final matchName = scheme.name.toLowerCase().contains(q);
        final matchDept = scheme.governmentDepartment.toLowerCase().contains(q);
        final matchDesc = scheme.description.toLowerCase().contains(q);
        if (!matchName && !matchDept && !matchDesc) return false;
      }

      return true;
    }).toList();
  }

  @override
  Future<List<GovernmentScheme>> getRecommendedSchemes(ProfileService profile) async {
    final all = await getAllSchemes();
    return all.where((scheme) {
      final match = SchemePersonalizationEngine.evaluate(scheme, profile);
      return match.isRecommended;
    }).toList();
  }

  @override
  Future<GovernmentScheme?> getSchemeById(String id) async {
    final all = await getAllSchemes();
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
