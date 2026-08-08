/// Authoritative Model for Verified Indian Government Schemes.
class GovernmentScheme {
  final String id;
  final String name;
  final String description;
  final String governmentDepartment;
  final String category;
  final String state; // 'Central' or State name e.g. 'Andhra Pradesh', 'Karnataka'
  final String benefits;
  final String eligibility;
  final List<String> requiredDocuments;
  final List<String> applicationSteps;
  final String officialWebsiteUrl;
  final List<String> targetGroups; // ['Student', 'Farmer', 'Women', 'Senior Citizen', 'Business', 'General']
  final String incomeCriteria; // e.g. 'Below ₹2.5 Lakhs per annum' or 'N/A'
  final String ageCriteria; // e.g. '18 - 40 years' or 'All ages'
  final String educationCriteria; // e.g. 'Class 10 Pass' or 'N/A'
  final String targetGender; // 'all', 'female', 'male'
  final String lastVerifiedAt; // e.g. '2026-08-01'

  const GovernmentScheme({
    required this.id,
    required this.name,
    required this.description,
    required this.governmentDepartment,
    required this.category,
    required this.state,
    required this.benefits,
    required this.eligibility,
    required this.requiredDocuments,
    required this.applicationSteps,
    required this.officialWebsiteUrl,
    required this.targetGroups,
    this.incomeCriteria = 'N/A',
    this.ageCriteria = 'All ages',
    this.educationCriteria = 'N/A',
    this.targetGender = 'all',
    required this.lastVerifiedAt,
  });

  /// Factory constructor to deserialize from Map (JSON / Firestore / Remote Config)
  factory GovernmentScheme.fromMap(Map<String, dynamic> map, String docId) {
    return GovernmentScheme(
      id: docId,
      name: (map['name'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      governmentDepartment: (map['governmentDepartment'] as String?) ?? (map['ministry'] as String?) ?? 'Government of India',
      category: (map['category'] as String?) ?? 'Financial Support',
      state: (map['state'] as String?) ?? (map['level'] as String?) ?? 'Central',
      benefits: (map['benefits'] as String?) ?? '',
      eligibility: (map['eligibility'] as String?) ?? '',
      requiredDocuments: (map['requiredDocuments'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (map['documents'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      applicationSteps: (map['applicationSteps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (map['howToApplySteps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      officialWebsiteUrl: (map['officialWebsiteUrl'] as String?) ?? (map['officialUrl'] as String?) ?? 'https://myscheme.gov.in',
      targetGroups: (map['targetGroups'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const ['General'],
      incomeCriteria: (map['incomeCriteria'] as String?) ?? 'N/A',
      ageCriteria: (map['ageCriteria'] as String?) ?? 'All ages',
      educationCriteria: (map['educationCriteria'] as String?) ?? 'N/A',
      targetGender: (map['targetGender'] as String?) ?? 'all',
      lastVerifiedAt: (map['lastVerifiedAt'] as String?) ?? '2026-08-01',
    );
  }

  /// Serialize to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'governmentDepartment': governmentDepartment,
      'category': category,
      'state': state,
      'benefits': benefits,
      'eligibility': eligibility,
      'requiredDocuments': requiredDocuments,
      'applicationSteps': applicationSteps,
      'officialWebsiteUrl': officialWebsiteUrl,
      'targetGroups': targetGroups,
      'incomeCriteria': incomeCriteria,
      'ageCriteria': ageCriteria,
      'educationCriteria': educationCriteria,
      'targetGender': targetGender,
      'lastVerifiedAt': lastVerifiedAt,
    };
  }
}
