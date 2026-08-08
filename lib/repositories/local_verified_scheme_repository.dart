import '../models/government_scheme.dart';
import '../services/profile_service.dart';
import '../services/scheme_personalization_engine.dart';
import 'government_scheme_repository.dart';

/// Production Implementation of GovernmentSchemeRepository holding verified official Indian Government Schemes.
class LocalVerifiedSchemeRepository implements GovernmentSchemeRepository {
  static final LocalVerifiedSchemeRepository instance = LocalVerifiedSchemeRepository._internal();
  LocalVerifiedSchemeRepository._internal();

  static const List<GovernmentScheme> _verifiedSchemes = [
    GovernmentScheme(
      id: 'scheme_pm_kisan',
      name: 'PM-KISAN (Pradhan Mantri Kisan Samman Nidhi)',
      description: 'Income support scheme providing ₹6,000 per year in 3 equal installments to small and marginal farmer families across India.',
      governmentDepartment: 'Ministry of Agriculture and Farmers Welfare',
      category: 'Agriculture',
      state: 'Central',
      benefits: '₹6,000 per year directly transferred to Aadhaar-seeded bank account in 3 installments of ₹2,000 each.',
      eligibility: 'All landholding farmer families with cultivable land in their name.',
      requiredDocuments: ['Aadhaar Card', 'Land Holding Records (Khasra/Khatauni)', 'Aadhaar-seeded Bank Account Passbook', 'Active Mobile Number'],
      applicationSteps: [
        'Visit official portal pmkisan.gov.in or nearest Common Service Centre (CSC).',
        'Click on "Farmers Corner" -> "New Farmer Registration".',
        'Enter Aadhaar number and select state.',
        'Upload land details and bank account information.',
        'Submit for verification by State Nodal Officer.',
      ],
      officialWebsiteUrl: 'https://pmkisan.gov.in',
      targetGroups: ['Farmer'],
      incomeCriteria: 'Small and marginal farmers holding cultivable land',
      ageCriteria: '18 years and above',
      lastVerifiedAt: '2026-08-01',
    ),
    GovernmentScheme(
      id: 'scheme_pm_mudra',
      name: 'Pradhan Mantri Mudra Yojana (PMEGP / MUDRA Loans)',
      description: 'Micro-finance loan scheme providing collateral-free credit up to ₹10 Lakhs for non-corporate, non-farm small/micro enterprises.',
      governmentDepartment: 'Ministry of Finance / SIDBI',
      category: 'MSME',
      state: 'Central',
      benefits: 'Shishu (up to ₹50,000), Kishore (₹50,000 to ₹5 Lakhs), and Tarun (₹5 Lakhs to ₹10 Lakhs) collateral-free loans.',
      eligibility: 'Any Indian citizen running or starting a non-farm micro business (retailers, traders, artisans, startups).',
      requiredDocuments: ['Identity Proof (Aadhaar/Voter ID/PAN)', 'Address Proof', 'Business Proposal / Project Report', 'Bank Statements (6 months)'],
      applicationSteps: [
        'Apply at any commercial bank, RRB, MFI, or online at udyamimitra.in / mudra.org.in.',
        'Fill Mudra Loan Application Form for Shishu/Kishore/Tarun category.',
        'Submit business plan and required KYC documents to bank officer.',
        'Upon approval, Mudra Card / Loan amount is sanctioned.',
      ],
      officialWebsiteUrl: 'https://www.mudra.org.in',
      targetGroups: ['Business', 'Entrepreneur'],
      incomeCriteria: 'Micro & small business owners',
      ageCriteria: '18 to 65 years',
      lastVerifiedAt: '2026-08-01',
    ),
    GovernmentScheme(
      id: 'scheme_pmay',
      name: 'Pradhan Mantri Awas Yojana (PMAY Urban / Gramin)',
      description: 'Housing scheme providing interest subsidy or financial assistance to construct or purchase a pucca house.',
      governmentDepartment: 'Ministry of Housing and Urban Affairs / MoRD',
      category: 'Housing',
      state: 'Central',
      benefits: 'Up to ₹2.67 Lakhs interest subsidy on home loans under Credit Linked Subsidy Scheme (CLSS) or financial grant of ₹1.2 to ₹1.3 Lakhs for rural housing.',
      eligibility: 'Beneficiary family must not own a pucca house in any part of India in their name.',
      requiredDocuments: ['Aadhaar Card', 'Income Certificate', 'Bank Account Details', 'Sworn Affidavit of Not Owning Pucca House'],
      applicationSteps: [
        'Apply online at pmaymis.gov.in or through CSC.',
        'Select Citizen Assessment -> Benefit under 3 components.',
        'Enter Aadhaar details and fill personal & income information.',
        'Track application status using Application Reference Number.',
      ],
      officialWebsiteUrl: 'https://pmaymis.gov.in',
      targetGroups: ['General', 'Women', 'Senior Citizen'],
      incomeCriteria: 'EWS (up to ₹3L), LIG (₹3L-₹6L), MIG-I (₹6L-₹12L), MIG-II (₹12L-₹18L)',
      ageCriteria: '18 years and above',
      lastVerifiedAt: '2026-08-01',
    ),
    GovernmentScheme(
      id: 'scheme_pmjay',
      name: 'Ayushman Bharat - PM-JAY (Jan Arogya Yojana)',
      description: 'World’s largest health insurance scheme providing cashless secondary and tertiary hospitalization cover up to ₹5 Lakhs per family per year.',
      governmentDepartment: 'National Health Authority (NHA) / Ministry of Health',
      category: 'Healthcare',
      state: 'Central',
      benefits: '₹5 Lakhs per family per year cashless treatment at empaneled public & private hospitals.',
      eligibility: 'Families identified based on SECC 2011 deprivation criteria and occupational categories.',
      requiredDocuments: ['Aadhaar Card / Ration Card', 'Ayushman Card (or check eligibility using Mobile Number)'],
      applicationSteps: [
        'Check eligibility at beneficiary.ha.gov.in or call 14555.',
        'Visit nearest Empaneled Hospital or Ayushman Mitra booth.',
        'Verify identity using Aadhaar e-KYC.',
        'Generate Ayushman Card for all family members.',
      ],
      officialWebsiteUrl: 'https://pmjay.gov.in',
      targetGroups: ['General', 'Senior Citizen', 'Women', 'Farmer'],
      incomeCriteria: 'EWS / SECC 2011 Deprived Households',
      ageCriteria: 'No age restriction',
      lastVerifiedAt: '2026-08-01',
    ),
    GovernmentScheme(
      id: 'scheme_apy',
      name: 'Atal Pension Yojana (APY)',
      description: 'Guaranteed pension scheme for unorganized sector workers providing fixed monthly pension of ₹1,000 to ₹5,000 after age 60.',
      governmentDepartment: 'Pension Fund Regulatory and Development Authority (PFRDA)',
      category: 'Pension',
      state: 'Central',
      benefits: 'Guaranteed pension of ₹1,000, ₹2,000, ₹3,000, ₹4,000, or ₹5,000 per month starting at age 60 until death.',
      eligibility: 'All Indian citizens in unorganized sector with a savings bank account, aged 18 to 40 years.',
      requiredDocuments: ['Aadhaar Card', 'Savings Bank Account Number', 'Mobile Number'],
      applicationSteps: [
        'Visit bank branch or use NetBanking of bank holding your savings account.',
        'Fill APY registration form with auto-debit consent.',
        'Select target monthly pension amount (₹1k to ₹5k).',
        'Contributions debited automatically every month.',
      ],
      officialWebsiteUrl: 'https://www.pfrda.org.in',
      targetGroups: ['General', 'Farmer', 'Business'],
      incomeCriteria: 'Non-taxpayer citizens (as per recent guidelines)',
      ageCriteria: '18 to 40 years at entry',
      lastVerifiedAt: '2026-08-01',
    ),
    GovernmentScheme(
      id: 'scheme_ssy',
      name: 'Sukanya Samriddhi Yojana (SSY)',
      description: 'Small deposit savings scheme for girl child under Beti Bachao Beti Padhao offering high government interest rate & tax benefits.',
      governmentDepartment: 'Ministry of Finance / Department of Posts',
      category: 'Financial Support',
      state: 'Central',
      benefits: 'High government-backed interest rate (8.2% p.a.), Section 80C tax deduction, lump sum maturity payout at age 21.',
      eligibility: 'Girl child below 10 years of age (maximum 2 accounts per family).',
      requiredDocuments: ['Girl Child Birth Certificate', 'Guardian Aadhaar & PAN Card', 'Address Proof'],
      applicationSteps: [
        'Visit Post Office or authorized bank branch.',
        'Fill SSY Account Opening Form.',
        'Deposit initial minimum amount of ₹250.',
        'Passbook issued to legal guardian.',
      ],
      officialWebsiteUrl: 'https://www.indiapost.gov.in',
      targetGroups: ['Women'],
      incomeCriteria: 'Open to all Indian families',
      ageCriteria: 'Girl child age below 10 years',
      lastVerifiedAt: '2026-08-01',
    ),
    GovernmentScheme(
      id: 'scheme_pm_vishwakarma',
      name: 'PM Vishwakarma Scheme',
      description: 'Comprehensive support scheme for traditional artisans and craftspeople providing skill training, toolkit incentive of ₹15,000, and low-interest collateral-free loans.',
      governmentDepartment: 'Ministry of Micro, Small and Medium Enterprises (MSME)',
      category: 'MSME',
      state: 'Central',
      benefits: '₹15,000 e-voucher for toolkit, skill training stipend of ₹500/day, collateral-free enterprise loan at 5% interest (₹1L First tranche, ₹2L Second tranche).',
      eligibility: 'Artisans or craftspeople working with hands and tools in 18 traditional trades (Carpanters, Blacksmiths, Potters, Tailors, Goldsmiths, etc.).',
      requiredDocuments: ['Aadhaar Card', 'Mobile Number', 'Bank Account Passbook', 'Ration Card'],
      applicationSteps: [
        'Register through Common Service Centre (CSC) at pmvishwakarma.gov.in.',
        'Undergo Aadhaar-based e-KYC and biometric verification.',
        'Verification by Gram Panchayat / Urban Local Body.',
        'Receive PM Vishwakarma Digital ID and Skill Training certificate.',
      ],
      officialWebsiteUrl: 'https://pmvishwakarma.gov.in',
      targetGroups: ['Business', 'Farmer', 'General'],
      incomeCriteria: 'Traditional artisans & craftspeople',
      ageCriteria: '18 years and above',
      lastVerifiedAt: '2026-08-01',
    ),
    GovernmentScheme(
      id: 'scheme_nsp_scholarship',
      name: 'NSP National Means-cum-Merit Scholarship (NMMSS)',
      description: 'Central scholarship scheme providing financial assistance of ₹12,000 per annum to meritorious students from economically weaker sections.',
      governmentDepartment: 'Ministry of Education (Department of School Education & Literacy)',
      category: 'Scholarships',
      state: 'Central',
      benefits: 'Scholarship of ₹12,000 per annum (₹1,000 per month) for Class 9 to Class 12.',
      eligibility: 'Students studying in Class 9 in government/aided schools who cleared Class 8 exam with min 55% marks.',
      requiredDocuments: ['Class 8 Marksheet', 'Income Certificate of Parents', 'Caste Certificate (if applicable)', 'Bank Account Passbook'],
      applicationSteps: [
        'Register on National Scholarship Portal at scholarships.gov.in.',
        'Complete OTR (One Time Registration) using Aadhaar.',
        'Select NMMSS Scheme and fill marks & bank details.',
        'Submit application for institute verification.',
      ],
      officialWebsiteUrl: 'https://scholarships.gov.in',
      targetGroups: ['Student'],
      incomeCriteria: 'Parents annual income not exceeding ₹3.5 Lakhs',
      ageCriteria: 'Students in Class 9-12',
      educationCriteria: 'Class 8 passed with 55%+ marks',
      lastVerifiedAt: '2026-08-01',
    ),
    GovernmentScheme(
      id: 'scheme_ap_rythu_bharosa',
      name: 'YSR Rythu Bharosa - PM KISAN (Andhra Pradesh)',
      description: 'State financial assistance scheme providing ₹13,500 per year to farmer families in Andhra Pradesh.',
      governmentDepartment: 'Department of Agriculture, Govt of Andhra Pradesh',
      category: 'Agriculture',
      state: 'Andhra Pradesh',
      benefits: 'Financial assistance of ₹13,500 per annum per farmer family (including PM-KISAN component).',
      eligibility: 'Farmer families owning cultivable land or tenant farmers belonging to SC/ST/BC/Minority categories in Andhra Pradesh.',
      requiredDocuments: ['Aadhaar Card', 'Pattadar Passbook / Land Records', 'Aadhaar-seeded Bank Account', 'Rythu Bharosa Registration'],
      applicationSteps: [
        'Visit nearest Rythu Bharosa Kendra (RBK) or Village Secretariat.',
        'Verify name in published list of beneficiaries.',
        'Submit land e-Crop registration details if missing.',
      ],
      officialWebsiteUrl: 'https://ap.gov.in',
      targetGroups: ['Farmer'],
      incomeCriteria: 'Farmer families in Andhra Pradesh',
      ageCriteria: '18 years and above',
      lastVerifiedAt: '2026-08-01',
    ),
    GovernmentScheme(
      id: 'scheme_ts_rythu_bandhu',
      name: 'Rythu Bandhu Scheme (Telangana)',
      description: 'Agriculture investment support scheme providing ₹10,000 per acre per year to landowning farmers in Telangana.',
      governmentDepartment: 'Department of Agriculture, Govt of Telangana',
      category: 'Agriculture',
      state: 'Telangana',
      benefits: '₹5,000 per acre per season (Kharif and Rabi total ₹10,000 per acre per year) directly credited to bank account.',
      eligibility: 'All landowning farmers possessing Pattadar Passbook in Telangana.',
      requiredDocuments: ['Pattadar Passbook (Pahani)', 'Aadhaar Card', 'Bank Account Passbook'],
      applicationSteps: [
        'Submit Pattadar Passbook and bank details to Agriculture Extension Officer (AEO).',
        'Details uploaded to Rythu Bandhu portal.',
        'Amount credited via Direct Benefit Transfer (DBT).',
      ],
      officialWebsiteUrl: 'https://telangana.gov.in',
      targetGroups: ['Farmer'],
      incomeCriteria: 'Landowning farmers in Telangana',
      ageCriteria: '18 years and above',
      lastVerifiedAt: '2026-08-01',
    ),
    GovernmentScheme(
      id: 'scheme_ka_gruha_lakshmi',
      name: 'Gruha Lakshmi Scheme (Karnataka)',
      description: 'Financial assistance scheme providing ₹2,000 per month to female head of household in Karnataka.',
      governmentDepartment: 'Department of Women and Child Development, Govt of Karnataka',
      category: 'Women',
      state: 'Karnataka',
      benefits: '₹2,000 per month transferred directly to bank account of female head of household.',
      eligibility: 'Women recognized as head of family in BPL, APL, or Antyodaya Ration Cards in Karnataka (non-income tax paying households).',
      requiredDocuments: ['Ration Card (BPL/APL)', 'Aadhaar Card of Female Head', 'Aadhaar Card of Husband', 'Bank Account Passbook'],
      applicationSteps: [
        'Apply online at Seva Sindhu Portal (sevasindhuservices.karnataka.gov.in) or Karnataka One / Grama One centers.',
        'Submit Ration card and Aadhaar linked bank details.',
        'Track status using Ration card number.',
      ],
      officialWebsiteUrl: 'https://sevasindhuservices.karnataka.gov.in',
      targetGroups: ['Women'],
      incomeCriteria: 'Non-income tax paying households',
      ageCriteria: '18 years and above',
      lastVerifiedAt: '2026-08-01',
    ),
    GovernmentScheme(
      id: 'scheme_tn_pudhumai_penn',
      name: 'Pudhumai Penn Scheme (Tamil Nadu)',
      description: 'Higher education incentive scheme providing ₹1,000 per month to girl students who studied in Tamil Nadu Government schools.',
      governmentDepartment: 'Department of Social Welfare, Govt of Tamil Nadu',
      category: 'Scholarships',
      state: 'Tamil Nadu',
      benefits: '₹1,000 per month transferred directly into girl student’s bank account until completion of undergraduate degree/diploma.',
      eligibility: 'Girl students who studied Class 6 to Class 12 in Tamil Nadu Government schools and pursuing higher education.',
      requiredDocuments: ['Class 10 & 12 Marksheets', 'School Transfer Certificate (TC)', 'Aadhaar Card', 'Bank Account Passbook'],
      applicationSteps: [
        'Apply through college portal or Moovalur Ramamirtham Ammaiyar Higher Education Assurance Scheme portal (penkalvi.tn.gov.in).',
        'Upload school study certificate and Aadhaar.',
        'Verified by college principal.',
      ],
      officialWebsiteUrl: 'https://penkalvi.tn.gov.in',
      targetGroups: ['Student', 'Women'],
      incomeCriteria: 'Students from TN Govt schools',
      educationCriteria: 'Class 6-12 in TN Govt schools',
      lastVerifiedAt: '2026-08-01',
    ),
  ];

  @override
  Future<List<GovernmentScheme>> getAllSchemes() async {
    return _verifiedSchemes;
  }

  @override
  Future<List<GovernmentScheme>> filterSchemes({
    String? category,
    String? state,
    String? query,
  }) async {
    return _verifiedSchemes.where((scheme) {
      // Category filter
      if (category != null && category.isNotEmpty && category != 'All') {
        if (scheme.category.toLowerCase() != category.toLowerCase()) {
          return false;
        }
      }

      // State filter
      if (state != null && state.isNotEmpty && state != 'All') {
        final scState = scheme.state.toLowerCase();
        final selState = state.toLowerCase();
        if (selState == 'central') {
          if (scState != 'central') return false;
        } else {
          if (scState != 'central' && scState != selState) return false;
        }
      }

      // Search query
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final matchName = scheme.name.toLowerCase().contains(q);
        final matchDept = scheme.governmentDepartment.toLowerCase().contains(q);
        final matchDesc = scheme.description.toLowerCase().contains(q);
        final matchCat = scheme.category.toLowerCase().contains(q);
        if (!matchName && !matchDept && !matchDesc && !matchCat) {
          return false;
        }
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
    try {
      return _verifiedSchemes.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
