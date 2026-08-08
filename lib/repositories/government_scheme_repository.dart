import '../models/government_scheme.dart';
import '../services/profile_service.dart';

/// Abstract Data Repository for Government Schemes.
///
/// Decouples the UI layer from the underlying data source (Local Data, Firebase, Supabase, Remote JSON, or Official API).
abstract class GovernmentSchemeRepository {
  /// Fetch all available verified schemes
  Future<List<GovernmentScheme>> getAllSchemes();

  /// Filter schemes by category, state, and search query
  Future<List<GovernmentScheme>> filterSchemes({
    String? category,
    String? state,
    String? query,
  });

  /// Get schemes personalized for the user's ProfileService attributes
  Future<List<GovernmentScheme>> getRecommendedSchemes(ProfileService profile);

  /// Fetch a single scheme by unique ID
  Future<GovernmentScheme?> getSchemeById(String id);
}
