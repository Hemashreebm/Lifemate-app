import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../widgets/user_avatar_widget.dart';

/// Screen for creating or editing comprehensive user profile information.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _nicknameController;
  late TextEditingController _ageController;
  late TextEditingController _districtController;

  late String _selectedGender;
  late String _selectedState;
  late String _selectedOccupation;
  late String _selectedEducation;
  late String _selectedEmployment;
  late String _selectedIncome;
  late String _selectedLanguage;
  late String _selectedAvatar;

  bool _isStudent = false;
  bool _isFarmer = false;
  bool _isBusiness = false;

  static const List<String> _genders = [
    'Prefer not to say',
    'Male',
    'Female',
    'Non-Binary / Other',
  ];

  static const List<String> _indianStates = [
    'Select State (Optional)',
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
    'Andaman & Nicobar',
    'Chandigarh',
    'Delhi NCR',
    'Jammu & Kashmir',
    'Ladakh',
    'Puducherry',
    'Other / Outside India',
  ];

  static const List<String> _occupations = [
    'Student',
    'Working Professional',
    'Software / Tech',
    'Government Service',
    'Healthcare / Medical',
    'Education / Teaching',
    'Business / Entrepreneur',
    'Farmer / Agriculture',
    'Homemaker',
    'Freelancer / Self-Employed',
    'Retired',
    'Other',
  ];

  static const List<String> _educationLevels = [
    'Select Education (Optional)',
    'School / High School',
    'Diploma / ITI',
    'Undergraduate (Bachelor\'s)',
    'Postgraduate (Master\'s)',
    'Doctorate / Ph.D.',
    'Other / Professional Degree',
  ];

  static const List<String> _employmentStatuses = [
    'Select Status (Optional)',
    'Student',
    'Employed (Full-Time)',
    'Employed (Part-Time)',
    'Self-Employed / Business',
    'Unemployed / Seeking Work',
    'Retired',
  ];

  static const List<String> _incomeRanges = [
    'Select Income Range (Optional)',
    'Below ₹1 Lakh per year',
    '₹1 Lakh - ₹3 Lakhs per year',
    '₹3 Lakhs - ₹5 Lakhs per year',
    '₹5 Lakhs - ₹10 Lakhs per year',
    'Above ₹10 Lakhs per year',
    'Prefer not to disclose',
  ];

  static const List<String> _languages = [
    'English',
    'Telugu',
    'Kannada',
    'Hindi',
    'Tamil',
    'Malayalam',
    'Bengali',
    'Marathi',
    'Gujarati',
  ];

  static const List<String> _avatars = [
    'Profile',
    '🎯',
    '🎨',
    '⭐',
    '☕',
    '🌿',
    '💡',
    '🚀',
    '📚',
  ];

  static const _purpleAccent = Color(0xFF7C3AED);

  @override
  void initState() {
    super.initState();
    final service = ProfileService.instance;
    _nameController = TextEditingController(text: service.name);
    _nicknameController = TextEditingController(text: service.nickname);
    _ageController = TextEditingController(text: service.age);
    _districtController = TextEditingController(text: service.district);

    _selectedGender = _genders.contains(service.gender) ? service.gender : _genders.first;
    _selectedState = _indianStates.contains(service.state) ? service.state : _indianStates.first;
    _selectedOccupation = _occupations.contains(service.occupation) ? service.occupation : _occupations.first;
    _selectedEducation = _educationLevels.contains(service.educationLevel) ? service.educationLevel : _educationLevels.first;
    _selectedEmployment = _employmentStatuses.contains(service.employmentStatus) ? service.employmentStatus : _employmentStatuses.first;
    _selectedIncome = _incomeRanges.contains(service.incomeRange) ? service.incomeRange : _incomeRanges.first;
    _selectedLanguage = _languages.contains(service.preferredLanguage) ? service.preferredLanguage : _languages.first;
    _selectedAvatar = _avatars.contains(service.avatar) ? service.avatar : _avatars.first;

    _isStudent = service.isStudent;
    _isFarmer = service.isFarmer;
    _isBusiness = service.isBusiness;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _ageController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    await ProfileService.instance.saveProfile(
      newName: _nameController.text,
      newNickname: _nicknameController.text,
      newAge: _ageController.text,
      newGender: _selectedGender == _genders.first ? '' : _selectedGender,
      newState: _selectedState == _indianStates.first ? '' : _selectedState,
      newDistrict: _districtController.text,
      newOccupation: _selectedOccupation,
      newEducationLevel: _selectedEducation == _educationLevels.first ? '' : _selectedEducation,
      newEmploymentStatus: _selectedEmployment == _employmentStatuses.first ? '' : _selectedEmployment,
      newIncomeRange: _selectedIncome == _incomeRanges.first ? '' : _selectedIncome,
      newIsFarmer: _isFarmer,
      newIsBusiness: _isBusiness,
      newIsStudent: _isStudent,
      newLanguage: _selectedLanguage,
      newAvatar: _selectedAvatar,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Preview Section
              Center(
                child: Column(
                  children: [
                    const UserAvatarWidget(radius: 40, backgroundColor: Color(0xFFEDE9FE), iconColor: _purpleAccent, textColor: _purpleAccent),
                    const SizedBox(height: 12),
                    const Text(
                      'Choose Avatar Badge',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _avatars.map((av) {
                        final isSelected = av == _selectedAvatar;
                        return ChoiceChip(
                          label: Text(av == 'Profile' ? 'Default' : av),
                          selected: isSelected,
                          selectedColor: const Color(0xFFDDD6FE),
                          backgroundColor: Colors.white,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedAvatar = av);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('1. Basic Information (Required)'),

              const SizedBox(height: 12),

              // Name Field
              const Text('Full Name *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Enter your full name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Preferred Language Field
              const Text('Preferred Language *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              const SizedBox(height: 4),
              const Text('Used for voice guidance and assistant recommendations', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedLanguage,
                decoration: _inputDecoration('Select preferred language'),
                items: _languages.map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedLanguage = val);
                },
              ),

              const SizedBox(height: 28),
              _buildSectionHeader('2. Personal & Demographics (Optional)'),
              const SizedBox(height: 12),

              // Nickname Field
              const Text('Nickname / Preferred Call Name (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nicknameController,
                decoration: _inputDecoration('How should Lifemate address you?'),
              ),

              const SizedBox(height: 16),

              // Row for Age & Gender
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Age (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('e.g. 24'),
                          validator: (value) {
                            if (value != null && value.trim().isNotEmpty) {
                              final num = int.tryParse(value.trim());
                              if (num == null || num < 1 || num > 120) {
                                return 'Enter age 1-120';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Gender (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedGender,
                          decoration: _inputDecoration('Select'),
                          items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontSize: 13)))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedGender = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // State Field
              const Text('State (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedState,
                decoration: _inputDecoration('Select State'),
                items: _indianStates.map((st) => DropdownMenuItem(value: st, child: Text(st, style: const TextStyle(fontSize: 14)))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedState = val);
                },
              ),

              const SizedBox(height: 16),

              // District Field
              const Text('District / City (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _districtController,
                decoration: _inputDecoration('Enter district or city name'),
              ),

              const SizedBox(height: 28),
              _buildSectionHeader('3. Career & Education (Optional)'),
              const SizedBox(height: 12),

              // Occupation Field
              const Text('Occupation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedOccupation,
                decoration: _inputDecoration('Select occupation'),
                items: _occupations.map((occ) => DropdownMenuItem(value: occ, child: Text(occ))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedOccupation = val);
                },
              ),

              const SizedBox(height: 16),

              // Education Level Field
              const Text('Education Level (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedEducation,
                decoration: _inputDecoration('Select education level'),
                items: _educationLevels.map((ed) => DropdownMenuItem(value: ed, child: Text(ed, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedEducation = val);
                },
              ),

              const SizedBox(height: 16),

              // Employment Status Field
              const Text('Employment Status (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedEmployment,
                decoration: _inputDecoration('Select employment status'),
                items: _employmentStatuses.map((emp) => DropdownMenuItem(value: emp, child: Text(emp, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedEmployment = val);
                },
              ),

              const SizedBox(height: 16),

              // Income Range Field
              const Text('Annual Income Range (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedIncome,
                decoration: _inputDecoration('Select income range'),
                items: _incomeRanges.map((inc) => DropdownMenuItem(value: inc, child: Text(inc, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedIncome = val);
                },
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('4. Eligibility Attributes (Optional)'),
              const SizedBox(height: 8),

              CheckboxListTile(
                title: const Text('I am currently a Student', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                value: _isStudent,
                activeColor: _purpleAccent,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (val) => setState(() => _isStudent = val ?? false),
              ),

              CheckboxListTile(
                title: const Text('I am a Farmer / Agriculturalist', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                value: _isFarmer,
                activeColor: _purpleAccent,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (val) => setState(() => _isFarmer = val ?? false),
              ),

              CheckboxListTile(
                title: const Text('I own a Business / Startup / MSME', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                value: _isBusiness,
                activeColor: _purpleAccent,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (val) => setState(() => _isBusiness = val ?? false),
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: const Text(
                    'Save Profile',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purpleAccent,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        const Divider(color: Color(0xFFCBD5E1), height: 1),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _purpleAccent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
    );
  }
}
