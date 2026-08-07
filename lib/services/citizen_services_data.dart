import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────

class GovernmentScheme {
  final String id;
  final String name;
  final String ministry;
  final String category;
  final String level; // 'central' or state name
  final String benefits;
  final String eligibility;
  final List<String> documents;
  final List<String> howToApplySteps;
  final String officialUrl;
  final int minAge;
  final int maxAge; // 0 = no upper limit
  final double maxIncomePerAnnum; // 0 = no limit
  final String targetGender; // 'all', 'female', 'male'
  final List<String> targetOccupations;
  final IconData icon;
  final Color color;

  const GovernmentScheme({
    required this.id,
    required this.name,
    required this.ministry,
    required this.category,
    required this.level,
    required this.benefits,
    required this.eligibility,
    required this.documents,
    required this.howToApplySteps,
    required this.officialUrl,
    this.minAge = 0,
    this.maxAge = 0,
    this.maxIncomePerAnnum = 0,
    this.targetGender = 'all',
    this.targetOccupations = const ['all'],
    this.icon = Icons.policy_rounded,
    this.color = const Color(0xFF6366F1),
  });
}

class DigitalService {
  final String id;
  final String name;
  final String description;
  final String whatItIs;
  final List<String> steps;
  final String officialUrl;
  final IconData icon;
  final Color color;

  const DigitalService({
    required this.id,
    required this.name,
    required this.description,
    required this.whatItIs,
    required this.steps,
    required this.officialUrl,
    required this.icon,
    required this.color,
  });
}

class EmergencyHelpline {
  final String name;
  final String number;
  final String description;
  final IconData icon;
  final Color color;

  const EmergencyHelpline({
    required this.name,
    required this.number,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class Scholarship {
  final String id;
  final String name;
  final String provider;
  final String amount;
  final String deadline;
  final String eligibility;
  final List<String> eligibleCourses;
  final List<String> eligibleCategories;
  final List<String> eligibleStates; // empty = all India
  final double maxFamilyIncome;
  final String officialUrl;

  const Scholarship({
    required this.id,
    required this.name,
    required this.provider,
    required this.amount,
    required this.deadline,
    required this.eligibility,
    required this.eligibleCourses,
    required this.eligibleCategories,
    required this.eligibleStates,
    required this.maxFamilyIncome,
    required this.officialUrl,
  });
}

// ─────────────────────────────────────────────
//  CITIZEN SERVICES DATA SERVICE
// ─────────────────────────────────────────────

class CitizenServicesData {
  static final CitizenServicesData instance = CitizenServicesData._();
  CitizenServicesData._();

  // ── CATEGORIES ──────────────────────────────
  static const List<String> schemeCategories = [
    'All',
    'Education',
    'Agriculture',
    'Women',
    'Healthcare',
    'Housing',
    'Employment',
    'Startups',
    'Pension',
    'Banking',
    'Insurance',
    'Senior Citizens',
    'Students',
    'Others',
  ];

  static const List<String> majorStates = [
    'Central',
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  // ── GOVERNMENT SCHEMES ───────────────────────
  static final List<GovernmentScheme> allSchemes = [
    // ── AGRICULTURE ─────────────────────────────
    const GovernmentScheme(
      id: 'pm_kisan',
      name: 'PM-KISAN (Pradhan Mantri Kisan Samman Nidhi)',
      ministry: 'Ministry of Agriculture & Farmers Welfare',
      category: 'Agriculture',
      level: 'Central',
      benefits: '₹6,000 per year (₹2,000 every 4 months) directly to farmers\' bank accounts.',
      eligibility: 'All small and marginal farmers with cultivable land up to 2 hectares. Must have Aadhaar-linked bank account.',
      documents: ['Aadhaar Card', 'Land Records (Khasra/Khatauni)', 'Bank Account Passbook', 'Mobile Number linked to Aadhaar'],
      howToApplySteps: [
        'Visit pmkisan.gov.in or your nearest Common Service Centre (CSC)',
        'Click on "Farmers Corner" → "New Farmer Registration"',
        'Enter Aadhaar number and state',
        'Fill in personal & land details',
        'Submit and get registration number',
        'Amount is transferred in 3 installments per year',
      ],
      officialUrl: 'https://pmkisan.gov.in',
      minAge: 18,
      targetOccupations: ['farmer'],
      icon: Icons.grass_rounded,
      color: Color(0xFF16A34A),
    ),
    const GovernmentScheme(
      id: 'pmfby',
      name: 'PMFBY – Pradhan Mantri Fasal Bima Yojana',
      ministry: 'Ministry of Agriculture & Farmers Welfare',
      category: 'Agriculture',
      level: 'Central',
      benefits: 'Crop insurance coverage for losses due to natural calamities, pests, and diseases. Up to 100% financial support.',
      eligibility: 'All farmers including sharecroppers and tenant farmers growing notified crops.',
      documents: ['Aadhaar Card', 'Land Records or Lease Agreement', 'Bank Passbook', 'Sown Certificate from Patwari'],
      howToApplySteps: [
        'Visit pmfby.gov.in or nearest bank branch / CSC',
        'Fill the crop insurance form with crop and land details',
        'Pay the premium (2% for Kharif, 1.5% for Rabi, 5% for commercial crops)',
        'Receive acknowledgment with policy number',
        'Claims processed automatically on crop loss notification',
      ],
      officialUrl: 'https://pmfby.gov.in',
      targetOccupations: ['farmer'],
      icon: Icons.agriculture_rounded,
      color: Color(0xFF15803D),
    ),
    const GovernmentScheme(
      id: 'kcc',
      name: 'Kisan Credit Card (KCC)',
      ministry: 'Ministry of Agriculture & Farmers Welfare',
      category: 'Agriculture',
      level: 'Central',
      benefits: 'Short-term credit up to ₹3 lakh at 4% interest rate for crop cultivation, post-harvest expenses & maintenance.',
      eligibility: 'All farmers — individual or joint borrowers who are owner cultivators, tenant farmers, sharecroppers, and SHG members.',
      documents: ['Aadhaar Card', 'Land Records', 'Passport Photo', 'Bank Account Details'],
      howToApplySteps: [
        'Visit your nearest nationalised bank, cooperative bank, or RRB',
        'Fill KCC application form',
        'Submit land documents and KYC',
        'Bank processes within 14 days',
        'KCC-linked RuPay debit card issued',
      ],
      officialUrl: 'https://www.myscheme.gov.in/schemes/kcc',
      targetOccupations: ['farmer'],
      icon: Icons.credit_card_rounded,
      color: Color(0xFF0891B2),
    ),

    // ── WOMEN ────────────────────────────────────
    const GovernmentScheme(
      id: 'sukanya_samriddhi',
      name: 'Sukanya Samriddhi Yojana',
      ministry: 'Ministry of Finance',
      category: 'Women',
      level: 'Central',
      benefits: 'High-interest savings scheme (8.2% p.a.) for girl child education and marriage. Tax-free under Section 80C.',
      eligibility: 'Parents/guardians of girl child below 10 years of age. Max 2 accounts per family (3 if twins/triplets).',
      documents: ['Birth Certificate of Girl Child', 'Parent/Guardian Aadhaar', 'Parent/Guardian PAN Card', 'Photograph'],
      howToApplySteps: [
        'Visit nearest Post Office or authorized bank (SBI, PNB, Bank of Baroda, etc.)',
        'Fill SSY account opening form',
        'Submit documents and initial deposit (min ₹250)',
        'Account matures when girl turns 21',
        'Partial withdrawal allowed after age 18 for education',
      ],
      officialUrl: 'https://www.indiapost.gov.in',
      maxAge: 10,
      targetGender: 'female',
      icon: Icons.girl_rounded,
      color: Color(0xFFDB2777),
    ),
    const GovernmentScheme(
      id: 'bbbp',
      name: 'Beti Bachao Beti Padhao',
      ministry: 'Ministry of Women & Child Development',
      category: 'Women',
      level: 'Central',
      benefits: 'Financial incentives, awareness programs and educational support for girl child. Conditional cash transfers at birth, education milestones.',
      eligibility: 'Families with girl children in selected districts. Focus on districts with low Child Sex Ratio (CSR).',
      documents: ['Birth Certificate of Girl Child', 'Aadhaar of Parents', 'BPL Card (if applicable)'],
      howToApplySteps: [
        'Contact your district Women & Child Development Office',
        'Fill enrollment form for girl child',
        'Submit documents to Anganwadi worker',
        'Benefits credited at various education milestones',
      ],
      officialUrl: 'https://wcd.nic.in/bbbp-schemes',
      targetGender: 'female',
      icon: Icons.child_care_rounded,
      color: Color(0xFFEC4899),
    ),
    const GovernmentScheme(
      id: 'ujjwala',
      name: 'PM Ujjwala Yojana',
      ministry: 'Ministry of Petroleum & Natural Gas',
      category: 'Women',
      level: 'Central',
      benefits: 'Free LPG connection with first refill free + stove subsidy for BPL families.',
      eligibility: 'Women aged 18+ from BPL household. Priority to SC/ST, OBC, PMAY beneficiaries, Antyodaya Anna Yojana cardholders.',
      documents: ['Aadhaar Card', 'BPL Ration Card', 'Bank Account Passbook', 'Passport Photo'],
      howToApplySteps: [
        'Visit nearest LPG distributor (HP Gas, Bharat Gas, Indane)',
        'Fill KYC form for new connection',
        'Submit BPL certificate and Aadhaar',
        'Connection provided within 7 days',
      ],
      officialUrl: 'https://www.pmuy.gov.in',
      minAge: 18,
      targetGender: 'female',
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFEA580C),
    ),

    // ── HEALTHCARE ───────────────────────────────
    const GovernmentScheme(
      id: 'pmjay',
      name: 'Ayushman Bharat PM-JAY',
      ministry: 'Ministry of Health & Family Welfare',
      category: 'Healthcare',
      level: 'Central',
      benefits: 'Health insurance coverage up to ₹5 lakh per family per year for secondary and tertiary hospitalisation at empanelled hospitals.',
      eligibility: 'Families identified in SECC 2011 data. Includes rural & urban deprived families. No age/family size restriction.',
      documents: ['Aadhaar Card', 'Ration Card', 'Mobile Number'],
      howToApplySteps: [
        'Check eligibility at pmjay.gov.in or call 14555',
        'Visit nearest Ayushman Mitra at empanelled hospital',
        'Complete e-KYC with Aadhaar',
        'Receive Ayushman Card (Golden Card)',
        'Show card at any empanelled hospital for cashless treatment',
      ],
      officialUrl: 'https://pmjay.gov.in',
      icon: Icons.local_hospital_rounded,
      color: Color(0xFFDC2626),
    ),
    const GovernmentScheme(
      id: 'pmsby',
      name: 'PMSBY – Pradhan Mantri Suraksha Bima Yojana',
      ministry: 'Ministry of Finance',
      category: 'Insurance',
      level: 'Central',
      benefits: 'Accident insurance: ₹2 lakh for accidental death/total disability, ₹1 lakh for partial disability. Premium just ₹20/year.',
      eligibility: 'Indian citizens aged 18–70 with a savings bank account and Aadhaar-linked mobile number.',
      documents: ['Aadhaar Card', 'Bank Account linked to Aadhaar'],
      howToApplySteps: [
        'Visit your bank branch or net banking portal',
        'Fill PMSBY enrollment form or enroll online',
        'Auto-debit of ₹20 annually from savings account',
        'Insurance certificate issued immediately',
      ],
      officialUrl: 'https://www.myscheme.gov.in/schemes/pmsby',
      minAge: 18,
      maxAge: 70,
      icon: Icons.shield_rounded,
      color: Color(0xFF0284C7),
    ),
    const GovernmentScheme(
      id: 'pmjjby',
      name: 'PMJJBY – Pradhan Mantri Jeevan Jyoti Bima Yojana',
      ministry: 'Ministry of Finance',
      category: 'Insurance',
      level: 'Central',
      benefits: '₹2 lakh life insurance coverage for death due to any reason. Premium ₹436/year.',
      eligibility: 'Indian citizens aged 18–50 with a savings bank account.',
      documents: ['Aadhaar Card', 'Bank Account', 'Health Self-Declaration Form'],
      howToApplySteps: [
        'Visit bank branch or enroll via net banking/mobile banking',
        'Fill PMJJBY enrollment form',
        'Annual premium of ₹436 auto-debited from account',
        'Nominee receives ₹2 lakh on policyholder\'s death',
      ],
      officialUrl: 'https://www.myscheme.gov.in/schemes/pmjjby',
      minAge: 18,
      maxAge: 50,
      icon: Icons.favorite_rounded,
      color: Color(0xFFBE185D),
    ),

    // ── HOUSING ──────────────────────────────────
    const GovernmentScheme(
      id: 'pmay_gramin',
      name: 'PM Awas Yojana – Gramin (Rural)',
      ministry: 'Ministry of Rural Development',
      category: 'Housing',
      level: 'Central',
      benefits: 'Financial assistance of ₹1.20 lakh (plain areas) to ₹1.30 lakh (hilly/NE states) for constructing pucca house.',
      eligibility: 'Rural households without a pucca house. Priority to SC/ST, minorities, ex-servicemen, disabled persons.',
      documents: ['Aadhaar Card', 'BPL Ration Card', 'Bank Passbook', 'Land Document', 'Caste Certificate (if applicable)'],
      howToApplySteps: [
        'Contact your Gram Panchayat office',
        'Check name in SECC-2011 list at pmayg.nic.in',
        'Fill application via Awaas App or CSC',
        'Funds transferred in installments on house completion milestones',
        'MGNREGS wages for 90 days additional benefit',
      ],
      officialUrl: 'https://pmayg.nic.in',
      icon: Icons.home_rounded,
      color: Color(0xFF7C3AED),
    ),
    const GovernmentScheme(
      id: 'pmay_urban',
      name: 'PM Awas Yojana – Urban (PMAY-U)',
      ministry: 'Ministry of Housing & Urban Affairs',
      category: 'Housing',
      level: 'Central',
      benefits: 'Central assistance of ₹1.5 lakh per EWS/LIG beneficiary. Interest subsidy up to ₹2.67 lakh on home loans.',
      eligibility: 'Urban households not owning a pucca house anywhere in India. EWS (income up to ₹3 lakh), LIG (₹3–6 lakh), MIG-I (₹6–12 lakh), MIG-II (₹12–18 lakh).',
      documents: ['Aadhaar Card', 'Income Certificate', 'Affidavit of no pucca house', 'Bank Passbook'],
      howToApplySteps: [
        'Visit pmaymis.gov.in or nearest CSC/ULB office',
        'Select appropriate component (BLC/AHP/CLSS)',
        'Fill online application with household details',
        'Submit documents for verification',
        'Subsidy credited directly to loan account',
      ],
      officialUrl: 'https://pmaymis.gov.in',
      icon: Icons.apartment_rounded,
      color: Color(0xFF6D28D9),
    ),

    // ── EMPLOYMENT ───────────────────────────────
    const GovernmentScheme(
      id: 'mgnregs',
      name: 'MGNREGS – Mahatma Gandhi NREGA',
      ministry: 'Ministry of Rural Development',
      category: 'Employment',
      level: 'Central',
      benefits: 'Guaranteed 100 days of wage employment per year to rural households. Current wage ₹221–374/day depending on state.',
      eligibility: 'All adult members (18+) of rural households willing to do unskilled manual work.',
      documents: ['Aadhaar Card', 'Job Card (issued by Gram Panchayat)', 'Bank Passbook'],
      howToApplySteps: [
        'Apply for Job Card at your Gram Panchayat',
        'Submit application for work within 15 days of applying',
        'Work to be provided within 15 days of application',
        'Wages paid within 15 days of work completion',
        'Unemployment allowance if work not provided within 15 days',
      ],
      officialUrl: 'https://nrega.nic.in',
      minAge: 18,
      targetOccupations: ['farmer', 'daily-wage worker'],
      icon: Icons.construction_rounded,
      color: Color(0xFFD97706),
    ),
    const GovernmentScheme(
      id: 'pmegp',
      name: 'PMEGP – PM Employment Generation Programme',
      ministry: 'Ministry of MSME',
      category: 'Startups',
      level: 'Central',
      benefits: 'Subsidy up to 35% for general category and 25% for urban areas on project cost up to ₹25 lakh (manufacturing) / ₹10 lakh (services).',
      eligibility: 'Any individual aged 18+ for new ventures. For projects above ₹10 lakh in manufacturing/₹5 lakh in service, 8th class pass required.',
      documents: ['Aadhaar Card', 'Project Report', 'Educational Certificate', 'EDP Training Certificate', 'Caste/Special Category Certificate'],
      howToApplySteps: [
        'Register at kviconline.gov.in/pmegpeportal',
        'Fill application with project details and required funds',
        'Select implementing agency (KVIC/KVIB/DIC)',
        'Attend EDP (Entrepreneurship Development Programme) training',
        'Application forwarded to bank for loan sanction',
        'Subsidy released after repayment of first installment',
      ],
      officialUrl: 'https://kviconline.gov.in/pmegpeportal',
      minAge: 18,
      icon: Icons.business_center_rounded,
      color: Color(0xFF059669),
    ),

    // ── EDUCATION / STUDENTS ──────────────────────
    const GovernmentScheme(
      id: 'pm_scholarship',
      name: 'PM Scholarship Scheme for CAPF & Police',
      ministry: 'Ministry of Home Affairs',
      category: 'Education',
      level: 'Central',
      benefits: '₹2,500/month for boys and ₹3,000/month for girls pursuing first professional degree programmes.',
      eligibility: 'Children/widows of CAPF personnel and state police officers who died in action or are disabled. Min 60% in Class 12.',
      documents: ['Service/Death Certificate of CAPF/Police parent', 'Class 12 Marksheet', 'Aadhaar', 'Bank Passbook', 'College Admission Letter'],
      howToApplySteps: [
        'Register at scholarships.gov.in (National Scholarship Portal)',
        'Select "PM Scholarship Scheme" under MHA',
        'Upload all required documents',
        'Submit application online',
        'Verification by concerned CAPF/Police unit',
        'Scholarship credited to bank account',
      ],
      officialUrl: 'https://scholarships.gov.in',
      icon: Icons.school_rounded,
      color: Color(0xFF1D4ED8),
    ),
    const GovernmentScheme(
      id: 'nsp_prematric',
      name: 'Pre-Matric Scholarship (Minorities)',
      ministry: 'Ministry of Minority Affairs',
      category: 'Students',
      level: 'Central',
      benefits: 'Day scholar: ₹1,000/month + ₹500 book grant. Hostel students: ₹3,000/month + ₹500 book grant.',
      eligibility: 'Students from minority communities (Muslim, Christian, Sikh, Buddhist, Jain, Parsi) studying in Class 1–10. Family income below ₹1 lakh/year.',
      documents: ['Income Certificate', 'Community Certificate', 'Previous Year Marksheet', 'Aadhaar', 'Bank Passbook'],
      howToApplySteps: [
        'Visit scholarships.gov.in',
        'Register as new student with Aadhaar',
        'Select Pre-Matric Scholarship for Minorities',
        'Fill academic and income details',
        'Upload documents and submit',
        'Principal verification, then disbursement',
      ],
      officialUrl: 'https://scholarships.gov.in',
      maxIncomePerAnnum: 100000,
      icon: Icons.menu_book_rounded,
      color: Color(0xFF7C3AED),
    ),

    // ── PENSION ──────────────────────────────────
    const GovernmentScheme(
      id: 'atal_pension',
      name: 'Atal Pension Yojana (APY)',
      ministry: 'Ministry of Finance (PFRDA)',
      category: 'Pension',
      level: 'Central',
      benefits: 'Guaranteed monthly pension of ₹1,000–₹5,000 after age 60, depending on contribution amount.',
      eligibility: 'Indian citizens aged 18–40 with a savings bank account. Not already covered under any statutory social security scheme.',
      documents: ['Aadhaar Card', 'Bank Account', 'Mobile Number'],
      howToApplySteps: [
        'Visit your bank branch or apply online via net banking',
        'Fill APY subscriber registration form',
        'Select pension amount (₹1000/2000/3000/4000/5000)',
        'Auto-debit of monthly contribution set up',
        'Pension starts at age 60',
      ],
      officialUrl: 'https://npscra.nsdl.co.in/apy.php',
      minAge: 18,
      maxAge: 40,
      icon: Icons.elderly_rounded,
      color: Color(0xFF9333EA),
    ),
    const GovernmentScheme(
      id: 'ignoaps',
      name: 'Indira Gandhi National Old Age Pension',
      ministry: 'Ministry of Rural Development',
      category: 'Senior Citizens',
      level: 'Central',
      benefits: '₹200–₹500/month pension for senior citizens from BPL families. States may add additional top-up.',
      eligibility: 'BPL senior citizens aged 60 and above.',
      documents: ['Aadhaar Card', 'Age Proof', 'BPL Ration Card', 'Bank Passbook'],
      howToApplySteps: [
        'Visit Gram Panchayat (rural) or Municipal office (urban)',
        'Fill NSAP application form',
        'Submit age proof and BPL documents',
        'Pension credited monthly to bank account',
      ],
      officialUrl: 'https://nsap.nic.in',
      minAge: 60,
      icon: Icons.accessibility_new_rounded,
      color: Color(0xFF0369A1),
    ),

    // ── BANKING ──────────────────────────────────
    const GovernmentScheme(
      id: 'pmjdy',
      name: 'PM Jan Dhan Yojana (PMJDY)',
      ministry: 'Ministry of Finance',
      category: 'Banking',
      level: 'Central',
      benefits: 'Zero-balance bank account + RuPay debit card + ₹1 lakh accident insurance + ₹30,000 life insurance + ₹5,000 overdraft facility.',
      eligibility: 'Any Indian citizen without a bank account. No minimum balance required.',
      documents: ['Aadhaar Card', 'Passport Photo', 'Address Proof (if address differs from Aadhaar)'],
      howToApplySteps: [
        'Visit any nearest bank branch with Aadhaar',
        'Fill PMJDY account opening form',
        'Submit KYC documents',
        'Account opens same day',
        'RuPay card issued within 7-10 days',
      ],
      officialUrl: 'https://pmjdy.gov.in',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF0E7490),
    ),
    const GovernmentScheme(
      id: 'mudra',
      name: 'PM Mudra Yojana – Micro Business Loans',
      ministry: 'Ministry of Finance',
      category: 'Startups',
      level: 'Central',
      benefits: 'Collateral-free loans: Shishu (up to ₹50,000), Kishore (₹50k–₹5 lakh), Tarun (₹5–10 lakh) for micro-enterprises.',
      eligibility: 'Non-corporate, non-farm small/micro enterprises. Any individual, proprietorship, partnership, private limited company.',
      documents: ['Aadhaar/PAN Card', 'Business Plan/Quotation', 'Bank Statement (6 months)', 'Address Proof of Business'],
      howToApplySteps: [
        'Visit any bank/MFI/NBFC or apply at udyamimitra.in',
        'Fill loan application with business details',
        'Submit income proof and business plan',
        'Loan sanctioned within 7-10 days for Shishu',
        'Mudra card issued for Kishore/Tarun loans',
      ],
      officialUrl: 'https://www.mudra.org.in',
      minAge: 18,
      icon: Icons.savings_rounded,
      color: Color(0xFF16A34A),
    ),

    // ── STARTUPS ─────────────────────────────────
    const GovernmentScheme(
      id: 'startup_india',
      name: 'Startup India Initiative',
      ministry: 'Ministry of Commerce & Industry (DPIIT)',
      category: 'Startups',
      level: 'Central',
      benefits: 'Tax exemptions (3 years), fast-track patent, self-certification, ₹10,000 crore fund, mentorship network, procurement preference.',
      eligibility: 'Entities up to 10 years old with annual turnover < ₹100 crore. Working on innovation/scalable business model.',
      documents: ['Incorporation Certificate', 'PAN Card', 'Business Description', 'Self-certification of innovation'],
      howToApplySteps: [
        'Register at startupindia.gov.in',
        'Click "Register your Startup"',
        'Fill entity and founder details',
        'Describe your innovative product/service',
        'DPIIT recognition issued within 2 days online',
        'Apply for tax exemptions through Income Tax Department',
      ],
      officialUrl: 'https://startupindia.gov.in',
      targetOccupations: ['business owner', 'student', 'professional'],
      icon: Icons.rocket_launch_rounded,
      color: Color(0xFFF59E0B),
    ),

    // ── STATE: TELANGANA ─────────────────────────
    const GovernmentScheme(
      id: 'ts_rythu_bandhu',
      name: 'Rythu Bandhu Scheme',
      ministry: 'Government of Telangana',
      category: 'Agriculture',
      level: 'Telangana',
      benefits: '₹5,000 per acre per season (₹10,000/year) investment support directly to farmers.',
      eligibility: 'All landholder farmers in Telangana. Land must be registered as agricultural land.',
      documents: ['Aadhaar Card', 'Pattadar Passbook', 'Bank Account', 'Mobile Number'],
      howToApplySteps: [
        'Visit nearest MeeSeva center or Agriculture Office',
        'Submit Pattadar Passbook and Aadhaar details',
        'Bank account linked to Aadhaar',
        'Funds credited before Kharif and Rabi seasons',
      ],
      officialUrl: 'https://rythubandhu.telangana.gov.in',
      targetOccupations: ['farmer'],
      icon: Icons.grass_rounded,
      color: Color(0xFF166534),
    ),
    const GovernmentScheme(
      id: 'ts_aasara',
      name: 'Aasara Pension Scheme',
      ministry: 'Government of Telangana',
      category: 'Pension',
      level: 'Telangana',
      benefits: '₹2,016–₹3,016/month pension for old age, widows, disabled, PLHIV, toddy tappers, and weavers.',
      eligibility: 'BPL families in Telangana. Age criteria varies by category (60+ for old age, 18+ for widow/disabled).',
      documents: ['Aadhaar Card', 'Residence Proof', 'BPL Card', 'Category-specific certificate'],
      howToApplySteps: [
        'Visit nearest MeeSeva or Gram Panchayat/Municipal office',
        'Fill Aasara Pension application form',
        'Submit category certificate and BPL proof',
        'Biometric authentication with Aadhaar',
        'Pension credited monthly to Aadhaar-linked bank account',
      ],
      officialUrl: 'https://treasury.telangana.gov.in',
      icon: Icons.elderly_rounded,
      color: Color(0xFF0369A1),
    ),

    // ── STATE: KARNATAKA ─────────────────────────
    const GovernmentScheme(
      id: 'ka_anna_bhagya',
      name: 'Anna Bhagya Scheme',
      ministry: 'Government of Karnataka',
      category: 'Others',
      level: 'Karnataka',
      benefits: '10 kg free rice per BPL family member per month.',
      eligibility: 'BPL ration cardholders in Karnataka.',
      documents: ['BPL Ration Card', 'Aadhaar Card'],
      howToApplySteps: [
        'BPL card holders are automatically enrolled',
        'Collect rice from Fair Price Shop (FPS) each month',
        'Show ration card and Aadhaar for biometric authentication',
      ],
      officialUrl: 'https://ahara.kar.nic.in',
      targetOccupations: ['all'],
      icon: Icons.rice_bowl_rounded,
      color: Color(0xFFD97706),
    ),
    const GovernmentScheme(
      id: 'ka_yuva_nidhi',
      name: 'Yuva Nidhi Scheme',
      ministry: 'Government of Karnataka',
      category: 'Employment',
      level: 'Karnataka',
      benefits: '₹3,000/month unemployment allowance for degree graduates, ₹1,500/month for diploma holders for up to 2 years.',
      eligibility: 'Karnataka domicile graduates/diploma holders who are unemployed. Age 18–25 years.',
      documents: ['Aadhaar Card', 'Degree/Diploma Certificate', 'Domicile Certificate', 'Bank Passbook', 'Self-declaration of unemployment'],
      howToApplySteps: [
        'Register at sevasindhu.karnataka.gov.in',
        'Fill Yuva Nidhi application',
        'Upload educational certificates and Aadhaar',
        'Verification by Department of Employment',
        'Allowance credited monthly for max 2 years',
      ],
      officialUrl: 'https://sevasindhu.karnataka.gov.in',
      minAge: 18,
      maxAge: 25,
      targetOccupations: ['student', 'unemployed'],
      icon: Icons.work_outlined,
      color: Color(0xFF7C3AED),
    ),

    // ── STATE: TAMIL NADU ────────────────────────
    const GovernmentScheme(
      id: 'tn_kalaignar_insurance',
      name: 'Kalaignar Arivalayam Thittam (Insurance)',
      ministry: 'Government of Tamil Nadu',
      category: 'Healthcare',
      level: 'Tamil Nadu',
      benefits: 'Health insurance up to ₹5 lakh for 1,447 procedures at government and empanelled private hospitals.',
      eligibility: 'All families in Tamil Nadu holding ration card.',
      documents: ['Ration Card', 'Aadhaar Card'],
      howToApplySteps: [
        'Show ration card and Aadhaar at any empanelled hospital',
        'Hospital registers patient in CMCHAT system',
        'Treatment provided cashless',
        'Claims settled directly between hospital and government',
      ],
      officialUrl: 'https://www.cmchat.tn.gov.in',
      icon: Icons.medical_services_rounded,
      color: Color(0xFFDC2626),
    ),

    // ── STATE: ANDHRA PRADESH ───────────────────
    const GovernmentScheme(
      id: 'ap_ysrcp_jagananna',
      name: 'YSR Rythu Bharosa',
      ministry: 'Government of Andhra Pradesh',
      category: 'Agriculture',
      level: 'Andhra Pradesh',
      benefits: '₹13,500 per year per farmer family — ₹5,500 (state) + ₹6,000 (PM-Kisan) + ₹2,000 (input subsidy).',
      eligibility: 'All cultivable land-owning farmer families in Andhra Pradesh.',
      documents: ['Aadhaar Card', 'Pattadar Passbook', 'Bank Passbook'],
      howToApplySteps: [
        'Visit nearest Village/Ward Secretariat',
        'Submit Aadhaar and land documents',
        'Amount transferred directly to bank account twice a year',
      ],
      officialUrl: 'https://ysrrythubharosa.ap.gov.in',
      targetOccupations: ['farmer'],
      icon: Icons.agriculture_rounded,
      color: Color(0xFF15803D),
    ),

    // ── STATE: MAHARASHTRA ───────────────────────
    const GovernmentScheme(
      id: 'mh_mahatma_jyotirao',
      name: 'Mahatma Jyotirao Phule Shetkari Karj Mafi Yojana',
      ministry: 'Government of Maharashtra',
      category: 'Agriculture',
      level: 'Maharashtra',
      benefits: 'Farm loan waiver up to ₹2 lakh for eligible farmers.',
      eligibility: 'Small and marginal farmers in Maharashtra with outstanding agricultural loans.',
      documents: ['Aadhaar Card', 'Land Records', 'Loan Account Details', 'Bank Passbook'],
      howToApplySteps: [
        'Check eligibility at aaplesarkar.mahaonline.gov.in',
        'Register and verify loan details',
        'Submit application with bank loan documents',
        'Waiver credited directly to loan account',
      ],
      officialUrl: 'https://aaplesarkar.mahaonline.gov.in',
      targetOccupations: ['farmer'],
      icon: Icons.money_off_rounded,
      color: Color(0xFFB45309),
    ),
  ];

  // ── DIGITAL SERVICES ─────────────────────────
  static const List<DigitalService> digitalServices = [
    DigitalService(
      id: 'digilocker',
      name: 'DigiLocker',
      description: 'Store & access all your documents online — Aadhaar, PAN, driving licence, marksheets — accepted everywhere officially.',
      whatItIs: 'DigiLocker is India\'s official cloud-based document wallet by the Government of India. Issued documents are legally equivalent to originals.',
      steps: [
        'Download DigiLocker app or visit digilocker.gov.in',
        'Register with your mobile number linked to Aadhaar',
        'Set a PIN/password for the account',
        'Go to "Issued Documents" → search for your documents',
        'Select issuer (CBSE, RTO, UIDAI, etc.) and fetch document',
        'Documents appear in "Issued Documents" section',
        'Share documents digitally via sharing link — no need to carry physical copies',
      ],
      officialUrl: 'https://digilocker.gov.in',
      icon: Icons.folder_special_rounded,
      color: Color(0xFF2563EB),
    ),
    DigitalService(
      id: 'aadhaar',
      name: 'Aadhaar Services',
      description: 'Update address, download e-Aadhaar, check Aadhaar–bank link status, lock/unlock biometrics.',
      whatItIs: 'Aadhaar is India\'s 12-digit unique identity issued by UIDAI. It links your biometrics to identity — used for all government services.',
      steps: [
        'Visit myaadhaar.uidai.gov.in',
        'Login with Aadhaar number + OTP',
        'For Address Update: Upload address proof and pay ₹50',
        'For Download: Download e-Aadhaar PDF (free)',
        'For Biometric Lock: Enable temporarily for security',
        'For Bank Link Check: Visit NPCI mapper or your bank',
        'For Name/DOB correction: Visit nearest Aadhaar Seva Kendra',
      ],
      officialUrl: 'https://myaadhaar.uidai.gov.in',
      icon: Icons.fingerprint_rounded,
      color: Color(0xFF0F766E),
    ),
    DigitalService(
      id: 'pan',
      name: 'PAN Card Services',
      description: 'Apply for new PAN, download e-PAN, link PAN with Aadhaar, update details.',
      whatItIs: 'Permanent Account Number (PAN) is a 10-digit alphanumeric identity issued by Income Tax Department. Mandatory for financial transactions above ₹50,000.',
      steps: [
        'New PAN: Visit onlineservices.nsdl.com → Form 49A',
        'Fill personal details (Name, DOB, address)',
        'Submit photograph & signature digitally',
        'Pay fee (₹107 for Indian address)',
        'e-PAN delivered to email within 48 hours',
        'Link with Aadhaar: Visit incometax.gov.in → Link Aadhaar',
        'Enter PAN, Aadhaar, and name → Pay ₹1,000 fee (if not linked before)',
      ],
      officialUrl: 'https://onlineservices.nsdl.com',
      icon: Icons.credit_card_rounded,
      color: Color(0xFFD97706),
    ),
    DigitalService(
      id: 'voter_id',
      name: 'Voter ID / EPIC Services',
      description: 'Register as new voter, download e-EPIC, correct voter details, find polling station.',
      whatItIs: 'Voter ID (EPIC) is issued by Election Commission of India. Required for voting in elections. Now downloadable as e-EPIC (PDF).',
      steps: [
        'New Registration: Visit voters.eci.gov.in',
        'Click "Register as New Voter" (Form 6)',
        'Fill personal and address details',
        'Upload photo and supporting documents',
        'Download e-EPIC: Login → "Download e-EPIC"',
        'For corrections: Fill Form 8 online',
        'Find Polling Booth: Search by name at electoralsearch.eci.gov.in',
      ],
      officialUrl: 'https://voters.eci.gov.in',
      icon: Icons.how_to_vote_rounded,
      color: Color(0xFF0891B2),
    ),
    DigitalService(
      id: 'driving_licence',
      name: 'Driving Licence Services',
      description: 'Apply for learner\'s licence, permanent licence, renewal, and check DL status on Sarathi portal.',
      whatItIs: 'Driving Licence is issued by RTO (Regional Transport Office). Now apply online — visit RTO only for biometrics/test.',
      steps: [
        'Visit parivahan.gov.in → Sarathi Services',
        'Select your state RTO',
        'For Learner\'s Licence: Apply online, take online test',
        'For Permanent DL: Apply after 30 days of getting LL',
        'Schedule slot for driving test at RTO',
        'Documents: Aadhaar, Age proof, Passport photo, Form 1A (medical)',
        'DL delivered by post within 7 days',
      ],
      officialUrl: 'https://parivahan.gov.in/sarathiservice',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF7C3AED),
    ),
    DigitalService(
      id: 'passport',
      name: 'Passport Services',
      description: 'Apply for fresh passport, renewal, tatkal passport, and track application status.',
      whatItIs: 'Passport is issued by Ministry of External Affairs. Apply online via Passport Seva Portal, visit PSK for biometrics and document verification.',
      steps: [
        'Register at passportindia.gov.in',
        'Fill online application (fresh/renewal/tatkal)',
        'Pay fee online (₹1,500 for 36-page, ₹2,000 for 60-page)',
        'Schedule appointment at nearest PSK/POPSK',
        'Visit PSK with original documents + photocopies',
        'Documents: Aadhaar, DOB proof, Address proof',
        'Passport dispatched by Speed Post within 3-5 days after police verification',
      ],
      officialUrl: 'https://www.passportindia.gov.in',
      icon: Icons.flight_rounded,
      color: Color(0xFF1D4ED8),
    ),
    DigitalService(
      id: 'railway',
      name: 'IRCTC Railway Services',
      description: 'Book train tickets, check PNR status, find trains, tatkal booking tips.',
      whatItIs: 'IRCTC is Indian Railway\'s official ticketing portal. Book regular, tatkal, and premium tatkal tickets online.',
      steps: [
        'Register at irctc.co.in or IRCTC Rail Connect app',
        'Verify mobile and email',
        'Search trains between source and destination',
        'Select class (Sleeper/3AC/2AC/1AC)',
        'Add passenger details (Name, Age, ID proof)',
        'Pay via UPI, net banking, or debit card',
        'Tatkal opens at 10 AM (AC) and 11 AM (Non-AC) one day before journey',
      ],
      officialUrl: 'https://www.irctc.co.in',
      icon: Icons.train_rounded,
      color: Color(0xFF0369A1),
    ),
    DigitalService(
      id: 'ayushman_bharat',
      name: 'Ayushman Bharat PM-JAY',
      description: 'Check eligibility, find empanelled hospitals, get Ayushman Card, cashless treatment up to ₹5 lakh.',
      whatItIs: 'World\'s largest government-funded health insurance scheme. Covers ₹5 lakh per family per year for 1,929 medical procedures.',
      steps: [
        'Check eligibility: pmjay.gov.in → "Am I Eligible?"',
        'Enter ration card/mobile number to check',
        'Visit nearest Ayushman Mitra at empanelled hospital',
        'Get e-KYC done with Aadhaar biometrics',
        'Ayushman Card issued (Golden Card)',
        'Show card at any empanelled hospital for cashless treatment',
        'Helpline: 14555',
      ],
      officialUrl: 'https://pmjay.gov.in',
      icon: Icons.local_hospital_rounded,
      color: Color(0xFFDC2626),
    ),
    DigitalService(
      id: 'epfo',
      name: 'EPFO – Employee Provident Fund',
      description: 'Check PF balance, transfer PF, withdraw PF, update KYC, and download UAN passbook.',
      whatItIs: 'EPFO manages Employees\' Provident Fund. Your employer deducts 12% of basic salary as PF. This is your retirement corpus.',
      steps: [
        'Activate UAN at unifiedportal-mem.epfindia.gov.in',
        'Link Aadhaar and PAN to UAN for full access',
        'Check Balance: Visit UAN portal or UMANG app',
        'Send SMS "EPFOHO UAN ENG" to 7738299899 for balance',
        'Withdraw PF: Login → Online Services → Claim (Form 31/19/10C)',
        'Transfer PF: Login → One Member-One EPF Account → Transfer Request',
        'Helpline: 1800-118-005',
      ],
      officialUrl: 'https://www.epfindia.gov.in',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF059669),
    ),
    DigitalService(
      id: 'nsp',
      name: 'National Scholarship Portal',
      description: 'Apply for 50+ central and state scholarships — Pre-Matric, Post-Matric, Merit-cum-Means for all categories.',
      whatItIs: 'NSP is India\'s one-stop scholarship portal for all government scholarships. Over ₹2,600 crore distributed annually.',
      steps: [
        'Visit scholarships.gov.in',
        'Click "New Registration" → select appropriate scheme',
        'Fill Aadhaar and personal details',
        'Enter academic details for current year',
        'Upload documents (income certificate, marksheet, bank passbook)',
        'Submit and note application ID',
        'Institute verifies application online',
        'Scholarship credited directly to bank account',
      ],
      officialUrl: 'https://scholarships.gov.in',
      icon: Icons.school_rounded,
      color: Color(0xFF7C3AED),
    ),
    DigitalService(
      id: 'umang',
      name: 'UMANG App',
      description: 'Access 1,200+ government services — PF, Aadhaar, passport, DigiLocker, CBSE results — all in one app.',
      whatItIs: 'UMANG (Unified Mobile Application for New-age Governance) is India\'s unified mobile platform for all government services.',
      steps: [
        'Download UMANG from Play Store / App Store',
        'Register with your mobile number',
        'Browse services by category or search by name',
        'Use M-Aadhaar, EPFO, DigiLocker, Scholarship, and 1,200+ other services',
        'One-stop solution for all government service needs',
      ],
      officialUrl: 'https://web.umang.gov.in',
      icon: Icons.apps_rounded,
      color: Color(0xFF0F766E),
    ),
    DigitalService(
      id: 'pm_kisan_portal',
      name: 'PM-Kisan Portal',
      description: 'Check PM-Kisan installment status, registration status, and beneficiary list.',
      whatItIs: 'Official portal for PM-KISAN scheme. Track your ₹6,000/year direct income support and check installment status.',
      steps: [
        'Visit pmkisan.gov.in',
        'Click "Farmers Corner" → "Beneficiary Status"',
        'Enter Aadhaar number / Account number / Mobile number',
        'View installment status and payment history',
        'For new registration: Click "New Farmer Registration"',
        'Helpline: 011-24300606',
      ],
      officialUrl: 'https://pmkisan.gov.in',
      icon: Icons.grass_rounded,
      color: Color(0xFF16A34A),
    ),
    DigitalService(
      id: 'jan_dhan',
      name: 'PM Jan Dhan Yojana',
      description: 'Open a zero-balance bank account with free RuPay card, insurance & overdraft benefits.',
      whatItIs: 'PMJDY ensures every Indian has access to a bank account. Zero minimum balance, free RuPay card, built-in accident & life insurance.',
      steps: [
        'Visit any nearest bank branch (PSU banks, cooperative banks)',
        'Request PMJDY account opening',
        'Submit Aadhaar (or any KYC document)',
        'Passport photo required',
        'Account opens same day — no minimum balance',
        'RuPay Debit Card delivered within 10 days',
        'Overdraft up to ₹5,000 after 6 months of satisfactory operation',
      ],
      officialUrl: 'https://pmjdy.gov.in',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF0E7490),
    ),
    DigitalService(
      id: 'myscheme',
      name: 'MyScheme Portal',
      description: 'Discover all government schemes you are eligible for — filter by age, category, income, state.',
      whatItIs: 'myScheme.gov.in is India\'s official scheme finder portal. Enter your profile details and instantly see all schemes you qualify for.',
      steps: [
        'Visit myscheme.gov.in',
        'Click "Find Schemes for You"',
        'Answer questions: State, Age, Gender, Category, Occupation, Income',
        'View personalised list of matching schemes',
        'Click any scheme for full details and apply link',
        'Also browse by category or search by name',
      ],
      officialUrl: 'https://www.myscheme.gov.in',
      icon: Icons.search_rounded,
      color: Color(0xFF9333EA),
    ),
  ];

  // ── EMERGENCY HELPLINES ───────────────────────
  static const List<EmergencyHelpline> emergencyHelplines = [
    EmergencyHelpline(
      name: 'Police',
      number: '100',
      description: 'Emergency police assistance anywhere in India',
      icon: Icons.local_police_rounded,
      color: Color(0xFF1D4ED8),
    ),
    EmergencyHelpline(
      name: 'Ambulance',
      number: '108',
      description: 'Free emergency ambulance service',
      icon: Icons.local_hospital_rounded,
      color: Color(0xFFDC2626),
    ),
    EmergencyHelpline(
      name: 'Fire',
      number: '101',
      description: 'Fire emergency and rescue services',
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFEA580C),
    ),
    EmergencyHelpline(
      name: 'National Emergency',
      number: '112',
      description: 'Single emergency number — Police, Ambulance & Fire',
      icon: Icons.emergency_rounded,
      color: Color(0xFF7C3AED),
    ),
    EmergencyHelpline(
      name: 'Women Helpline',
      number: '1091',
      description: 'Women in distress — 24x7 support',
      icon: Icons.woman_rounded,
      color: Color(0xFFDB2777),
    ),
    EmergencyHelpline(
      name: 'Child Helpline',
      number: '1098',
      description: 'CHILDLINE — 24x7 emergency for children in need',
      icon: Icons.child_care_rounded,
      color: Color(0xFFBE185D),
    ),
    EmergencyHelpline(
      name: 'Disaster (NDRF)',
      number: '1078',
      description: 'National Disaster Response Force',
      icon: Icons.flood_rounded,
      color: Color(0xFF0891B2),
    ),
    EmergencyHelpline(
      name: 'Road Accident',
      number: '1073',
      description: 'Highway accident helpline & relief',
      icon: Icons.car_crash_rounded,
      color: Color(0xFFD97706),
    ),
    EmergencyHelpline(
      name: 'Cyber Crime',
      number: '1930',
      description: 'Report online fraud, cyber crime & scams',
      icon: Icons.security_rounded,
      color: Color(0xFF0F766E),
    ),
    EmergencyHelpline(
      name: 'Senior Citizen',
      number: '14567',
      description: 'Elder helpline — Elder Line, Ministry of Social Justice',
      icon: Icons.elderly_rounded,
      color: Color(0xFF9333EA),
    ),
    EmergencyHelpline(
      name: 'Mental Health',
      number: '9152987821',
      description: 'iCall — free mental health counselling (TISS)',
      icon: Icons.psychology_rounded,
      color: Color(0xFF16A34A),
    ),
    EmergencyHelpline(
      name: 'Railway Accident',
      number: '1072',
      description: 'Railway emergency and accident helpline',
      icon: Icons.train_rounded,
      color: Color(0xFF1D4ED8),
    ),
    EmergencyHelpline(
      name: 'Consumer',
      number: '1915',
      description: 'National Consumer Helpline — product & service complaints',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFB45309),
    ),
    EmergencyHelpline(
      name: 'Anti-Corruption',
      number: '1031',
      description: 'CVC Anti-Corruption helpline',
      icon: Icons.gavel_rounded,
      color: Color(0xFF7C3AED),
    ),
    EmergencyHelpline(
      name: 'Tax Helpline',
      number: '1800-103-0025',
      description: 'Income Tax Department helpline (free)',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFF059669),
    ),
    EmergencyHelpline(
      name: 'COVID / Health',
      number: '1075',
      description: 'Ministry of Health national helpline',
      icon: Icons.coronavirus_rounded,
      color: Color(0xFF0891B2),
    ),
  ];

  // ── SCHOLARSHIPS ─────────────────────────────
  static const List<Scholarship> scholarships = [
    Scholarship(
      id: 'nsp_prematric_sc',
      name: 'Pre-Matric Scholarship for SC Students',
      provider: 'Ministry of Social Justice (NSP)',
      amount: 'Day Scholar: ₹1,400–₹5,700/year | Hostel: ₹13,000–₹20,000/year',
      deadline: 'October 31 (every year)',
      eligibility: 'SC students in Class 9–10 with family income < ₹2.5 lakh/year.',
      eligibleCourses: ['Class 9', 'Class 10'],
      eligibleCategories: ['SC'],
      eligibleStates: [],
      maxFamilyIncome: 250000,
      officialUrl: 'https://scholarships.gov.in',
    ),
    Scholarship(
      id: 'nsp_postmatric_sc',
      name: 'Post-Matric Scholarship for SC Students',
      provider: 'Ministry of Social Justice (NSP)',
      amount: 'Up to ₹1,20,000/year based on course and hostel status',
      deadline: 'October 31 (every year)',
      eligibility: 'SC students studying post-Class 10. Family income < ₹2.5 lakh/year.',
      eligibleCourses: ['11th', '12th', 'UG', 'PG', 'PhD', 'Diploma', 'ITI'],
      eligibleCategories: ['SC'],
      eligibleStates: [],
      maxFamilyIncome: 250000,
      officialUrl: 'https://scholarships.gov.in',
    ),
    Scholarship(
      id: 'nsp_postmatric_st',
      name: 'Post-Matric Scholarship for ST Students',
      provider: 'Ministry of Tribal Affairs (NSP)',
      amount: 'Maintenance allowance + tuition fee as per course',
      deadline: 'October 31 (every year)',
      eligibility: 'ST students post-Class 10 with family income < ₹2.5 lakh/year.',
      eligibleCourses: ['11th', '12th', 'UG', 'PG', 'PhD', 'Diploma'],
      eligibleCategories: ['ST'],
      eligibleStates: [],
      maxFamilyIncome: 250000,
      officialUrl: 'https://scholarships.gov.in',
    ),
    Scholarship(
      id: 'nsp_minority_postmatric',
      name: 'Post-Matric Scholarship for Minorities',
      provider: 'Ministry of Minority Affairs (NSP)',
      amount: 'Day Scholar: ₹2,300–₹5,300/year | Hostel: ₹13,400–₹20,000/year',
      deadline: 'October 31 (every year)',
      eligibility: 'Muslim, Christian, Sikh, Buddhist, Jain, Parsi students. Family income < ₹2 lakh/year.',
      eligibleCourses: ['11th', '12th', 'UG', 'PG', 'PhD'],
      eligibleCategories: ['Minority'],
      eligibleStates: [],
      maxFamilyIncome: 200000,
      officialUrl: 'https://scholarships.gov.in',
    ),
    Scholarship(
      id: 'nsp_merit_mcm',
      name: 'Merit-cum-Means Scholarship for Minorities',
      provider: 'Ministry of Minority Affairs (NSP)',
      amount: '₹30,000/year (50% tuition + ₹12,000 maintenance)',
      deadline: 'October 31 (every year)',
      eligibility: 'Minority students in UG/PG professional/technical courses. 50%+ in previous exam. Family income < ₹2.5 lakh/year.',
      eligibleCourses: ['UG', 'PG'],
      eligibleCategories: ['Minority'],
      eligibleStates: [],
      maxFamilyIncome: 250000,
      officialUrl: 'https://scholarships.gov.in',
    ),
    Scholarship(
      id: 'central_sector',
      name: 'Central Sector Scholarship (12th pass)',
      provider: 'Ministry of Education (NSP)',
      amount: '₹10,000/year for UG | ₹20,000/year for PG',
      deadline: 'November 15 (every year)',
      eligibility: 'Top 20 percentile in Class 12 board exams. Family income < ₹8 lakh/year. Regular college students only.',
      eligibleCourses: ['UG', 'PG'],
      eligibleCategories: ['General', 'OBC', 'SC', 'ST', 'Minority'],
      eligibleStates: [],
      maxFamilyIncome: 800000,
      officialUrl: 'https://scholarships.gov.in',
    ),
    Scholarship(
      id: 'pm_scholarship_capf',
      name: 'PM Scholarship for CAPF/Police Wards',
      provider: 'Ministry of Home Affairs (NSP)',
      amount: '₹2,500/month (boys) | ₹3,000/month (girls)',
      deadline: 'October 31 (every year)',
      eligibility: 'Children/widows of CAPF & state police personnel. Min 60% in Class 12. First professional degree courses only.',
      eligibleCourses: ['BE', 'MBBS', 'B.Tech', 'BDS', 'MBA', 'BBA', 'B.Ed'],
      eligibleCategories: ['General', 'OBC', 'SC', 'ST'],
      eligibleStates: [],
      maxFamilyIncome: 0,
      officialUrl: 'https://scholarships.gov.in',
    ),
    Scholarship(
      id: 'inspire_moe',
      name: 'INSPIRE Scholarship (Science)',
      provider: 'Dept. of Science & Technology, Govt. of India',
      amount: '₹80,000/year + ₹20,000 summer project grant',
      deadline: 'December 31 (every year)',
      eligibility: 'Students who secured top 1% in Class 12 board exams and pursuing BSc/BS/B.Stat/B.Math/Int-MSc/Int-MS in natural/basic sciences.',
      eligibleCourses: ['BSc', 'B.Stat', 'B.Math', 'Int-MSc', 'Int-MS'],
      eligibleCategories: ['General', 'OBC', 'SC', 'ST'],
      eligibleStates: [],
      maxFamilyIncome: 0,
      officialUrl: 'https://online-inspire.gov.in',
    ),
  ];

  // ── HELPER METHODS ────────────────────────────

  /// Filter schemes by category and/or state level.
  List<GovernmentScheme> filterSchemes({
    String category = 'All',
    String level = 'All',
    String query = '',
  }) {
    return allSchemes.where((s) {
      final matchCat = category == 'All' || s.category == category;
      final matchLevel = level == 'All' || s.level == level;
      final matchQuery = query.isEmpty ||
          s.name.toLowerCase().contains(query.toLowerCase()) ||
          s.benefits.toLowerCase().contains(query.toLowerCase()) ||
          s.ministry.toLowerCase().contains(query.toLowerCase());
      return matchCat && matchLevel && matchQuery;
    }).toList();
  }

  /// Simple eligibility check based on user profile.
  Map<String, dynamic> checkEligibility(
    GovernmentScheme scheme, {
    required int age,
    required String gender, // 'male', 'female', 'other'
    required String occupation, // 'farmer', 'student', 'business owner', etc.
    required double annualIncome,
    required String state,
  }) {
    final reasons = <String>[];
    bool eligible = true;

    // Age check
    if (scheme.minAge > 0 && age < scheme.minAge) {
      eligible = false;
      reasons.add('Minimum age required is ${scheme.minAge} years (you are $age).');
    }
    if (scheme.maxAge > 0 && age > scheme.maxAge) {
      eligible = false;
      reasons.add('Maximum age allowed is ${scheme.maxAge} years (you are $age).');
    }

    // Gender check
    if (scheme.targetGender != 'all' && scheme.targetGender != gender) {
      eligible = false;
      reasons.add('This scheme is for ${scheme.targetGender == 'female' ? 'women' : 'men'} only.');
    }

    // Income check
    if (scheme.maxIncomePerAnnum > 0 && annualIncome > scheme.maxIncomePerAnnum) {
      eligible = false;
      reasons.add('Maximum family income allowed is ₹${scheme.maxIncomePerAnnum ~/ 1000}k/year.');
    }

    // State check
    if (scheme.level != 'Central' &&
        scheme.level.toLowerCase() != state.toLowerCase()) {
      eligible = false;
      reasons.add('This scheme is only for ${scheme.level} residents.');
    }

    // Occupation check
    if (!scheme.targetOccupations.contains('all') &&
        !scheme.targetOccupations.contains(occupation.toLowerCase())) {
      // Soft warning, not hard block
      reasons.add('This scheme is primarily for: ${scheme.targetOccupations.join(', ')}.');
    }

    return {
      'eligible': eligible,
      'reasons': reasons,
    };
  }

  /// Filter scholarships by student profile.
  List<Scholarship> filterScholarships({
    required String courseLevel,
    required String category,
    required String state,
    required double familyIncome,
  }) {
    return scholarships.where((s) {
      final matchCourse = s.eligibleCourses.isEmpty ||
          s.eligibleCourses.any((c) => c.toLowerCase() == courseLevel.toLowerCase());
      final matchCat = s.eligibleCategories.isEmpty ||
          s.eligibleCategories.any((c) => c.toLowerCase() == category.toLowerCase());
      final matchState = s.eligibleStates.isEmpty ||
          s.eligibleStates.any((st) => st.toLowerCase() == state.toLowerCase());
      final matchIncome =
          s.maxFamilyIncome == 0 || familyIncome <= s.maxFamilyIncome;
      return matchCourse && matchCat && matchState && matchIncome;
    }).toList();
  }
}
