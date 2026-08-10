import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Centralized localization service for Lifemate.
/// Supports 7 regional & national languages:
/// English (en), Kannada (kn), Telugu (te), Hindi (hi), Tamil (ta), Malayalam (ml), Bengali (bn).
class AppLanguageService {
  static final AppLanguageService _instance = AppLanguageService._internal();
  factory AppLanguageService() => _instance;
  AppLanguageService._internal();

  static const String _prefLanguageKey = 'preferred_language_code';
  static const String defaultLanguage = 'en';

  String _currentLanguage = defaultLanguage;
  final FlutterTts _tts = FlutterTts();

  String get currentLanguage => _currentLanguage;

  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'kn', 'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
    {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు'},
    {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी'},
    {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்'},
    {'code': 'ml', 'name': 'Malayalam', 'native': 'മലയാളം'},
    {'code': 'bn', 'name': 'Bengali', 'native': 'বাংলা'},
  ];

  /// Initializes language preference from local storage.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_prefLanguageKey) ?? defaultLanguage;
    await _configureTtsLanguage(_currentLanguage);
  }

  /// Sets user preferred language, persists locally, and updates TTS voice.
  Future<void> setLanguage(String code) async {
    if (!supportedLanguages.any((l) => l['code'] == code)) return;
    _currentLanguage = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLanguageKey, code);
    await _configureTtsLanguage(code);
  }

  /// Configures Text-to-Speech language engine with graceful fallback.
  Future<void> _configureTtsLanguage(String code) async {
    try {
      final ttsLocale = _getTtsLocale(code);
      final isAvailable = await _tts.isLanguageAvailable(ttsLocale);
      if (isAvailable == true) {
        await _tts.setLanguage(ttsLocale);
      } else {
        // Graceful fallback to English if preferred voice is not installed on device
        await _tts.setLanguage('en-US');
      }
    } catch (_) {
      // Fallback silently without breaking app
    }
  }

  String _getTtsLocale(String code) {
    switch (code) {
      case 'kn': return 'kn-IN';
      case 'te': return 'te-IN';
      case 'hi': return 'hi-IN';
      case 'ta': return 'ta-IN';
      case 'ml': return 'ml-IN';
      case 'bn': return 'bn-IN';
      default: return 'en-US';
    }
  }

  /// Formats system instruction for Gemini AI in user's preferred language.
  String formatAiSystemPrompt(String baseInstruction) {
    final langName = supportedLanguages.firstWhere(
      (l) => l['code'] == _currentLanguage,
      orElse: () => {'name': 'English'},
    )['name'];

    return '$baseInstruction\n\nIMPORTANT LANGUAGE INSTRUCTION: The user prefers $langName language. Respond primarily in $langName. Keep technical terms (e.g. Gemini, API, Wi-Fi, GPS, OCR, Cloud Sync) in English where natural for technical clarity.';
  }

  /// Centralized String Translation Dictionary
  static final Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'app_title': 'Lifemate',
      'welcome_subtitle': 'Your AI Life Companion',
      'guest_mode': 'Guest Mode',
      'tasks': 'Tasks & Reminders',
      'diary': 'My Life Book',
      'expenses': 'Expense Tracker',
      'sms_tracker': 'SMS Money Tracker',
      'govt_schemes': 'Government Schemes',
      'english_coach': 'Spoken English Coach',
      'translation': 'Real-Time Translation',
      'ai_assistant': 'Gemini AI Companion',
      'safety_sos': 'Emergency Safety SOS',
      'profile': 'Profile & Settings',
      'save_scheme': 'Save Scheme',
      'interested': 'Interested',
      'remove_interest': 'Remove Interest',
      'enable_reminder': 'Enable Deadline Reminder',
      'reminder_scheduled': 'Reminder Scheduled',
      'scheme_disclaimer': 'According to available scheme information. Please verify at official government source.',
      'deadline_open': 'Open / Ongoing',
      'deadline_none': 'Deadline not available',
      'sync_status_synced': 'Synced with Cloud',
      'sync_status_syncing': 'Syncing...',
      'sync_status_offline': 'Offline Mode Active',
      'ai_fallback_title': 'AI Unavailable',
      'ai_fallback_desc': 'Gemini AI is currently busy or quota reached. Choose an alternative to continue:',
      'copy_prompt': 'Copy Prompt',
      'share_prompt': 'Share via Native App',
      'open_chatgpt': 'Open ChatGPT',
      'open_gemini': 'Open Gemini',
    },
    'kn': {
      'app_title': 'ಲೈಫ್‌ಮೇಟ್',
      'welcome_subtitle': 'ನಿಮ್ಮ ಎಐ ಜೀವನ ಸಂಗಾತಿ',
      'guest_mode': 'ಅತಿಥಿ ಮೋಡ್',
      'tasks': 'ಕಾರ್ಯಗಳು ಮತ್ತು ಜ್ಞಾಪನೆಗಳು',
      'diary': 'ನನ್ನ ಜೀವನ ಪುಸ್ತಕ',
      'expenses': 'ಖರ್ಚು ಟ್ರ್ಯಾಕರ್',
      'sms_tracker': 'SMS ಹಣದ ಟ್ರ್ಯಾಕರ್',
      'govt_schemes': 'ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು',
      'english_coach': 'ಇಂಗ್ಲಿಷ್ ತರಬೇತುದಾರ',
      'translation': 'ರಿಯಲ್-ಟೈಮ್ ಅನುವಾದ',
      'ai_assistant': 'ಜೆಮಿನಿ ಎಐ ಸಂಗಾತಿ',
      'safety_sos': 'ತುರ್ತು ಸುರಕ್ಷತೆ SOS',
      'profile': 'ಪ್ರೊಫೈಲ್ ಮತ್ತು ಸಂಯೋಜನೆಗಳು',
      'save_scheme': 'ಯೋಜನೆ ಉಳಿಸಿ',
      'interested': 'ಆಸಕ್ತಿ ಹೊಂದಿದೆ',
      'remove_interest': 'ಆಸಕ್ತಿ ತೆಗೆದುಹಾಕಿ',
      'enable_reminder': 'ಗಡುವು ಜ್ಞಾಪನೆ ಸಕ್ರಿಯಗೊಳಿಸಿ',
      'reminder_scheduled': 'ಜ್ಞಾಪನೆ ನಿಗದಿಯಾಗಿದೆ',
      'scheme_disclaimer': 'ಲಭ್ಯವಿರುವ ಯೋಜನೆಯ ಮಾಹಿತಿಯ ಪ್ರಕಾರ. ದಯವಿಟ್ಟು ಅಧಿಕೃತ ಸರ್ಕಾರಿ ಮೂಲದಲ್ಲಿ ಪರಿಶೀಲಿಸಿ.',
      'deadline_open': 'ತೆರೆದಿದೆ / ನಡೆಯುತ್ತಿದೆ',
      'deadline_none': 'ಗಡುವು ಲಭ್ಯವಿಲ್ಲ',
      'sync_status_synced': 'ಕ್ಲೌಡ್‌ನೊಂದಿಗೆ ಸಿಂಕ್ ಆಗಿದೆ',
      'sync_status_syncing': 'ಸಿಂಕ್ ಆಗುತ್ತಿದೆ...',
      'sync_status_offline': 'ಆಫ್‌ಲೈನ್ ಮೋಡ್ ಸಕ್ರಿಯವಾಗಿದೆ',
      'ai_fallback_title': 'ಎಐ ಲಭ್ಯವಿಲ್ಲ',
      'ai_fallback_desc': 'ಜೆಮಿನಿ ಎಐ ಪ್ರಸ್ತುತ ಕಾರ್ಯನಿರತವಾಗಿದೆ. ಮುಂದುವರೆಯಲು ಪರ್ಯಾಯ ಆಯ್ಕೆಮಾಡಿ:',
      'copy_prompt': 'ಪ್ರಾンプಟ್ ಕಾಪಿ ಮಾಡಿ',
      'share_prompt': 'ಅಪ್ಲಿಕೇಶನ್ ಮೂಲಕ ಹಂಚಿಕೊಳ್ಳಿ',
      'open_chatgpt': 'ChatGPT ತೆರೆಯಿರಿ',
      'open_gemini': 'Gemini ತೆರೆಯಿರಿ',
    },
    'te': {
      'app_title': 'లైఫ్‌మేట్',
      'welcome_subtitle': 'మీ AI జీవిత భాగస్వామి',
      'guest_mode': 'గెస్ట్ మోడ్',
      'tasks': 'టాస్క్‌లు & రిమైండర్లు',
      'diary': 'నా జీవిత పుస్తకం',
      'expenses': 'ఖర్చుల ట్రాకర్',
      'sms_tracker': 'SMS డబ్బు ట్రాకర్',
      'govt_schemes': 'ప్రభుత్వ పథకాలు',
      'english_coach': 'స్పోకెన్ ఇంగ్లీష్ కోచ్',
      'translation': 'రియల్-టైమ్ అనువాదం',
      'ai_assistant': 'జెమిని AI అసిస్టెంట్',
      'safety_sos': 'అత్యవసర రక్షణ SOS',
      'profile': 'ప్రొఫైల్ & సెట్టింగ్‌లు',
      'save_scheme': 'పథకం సేవ్ చేయండి',
      'interested': 'ఆసక్తి ఉంది',
      'remove_interest': 'ఆసక్తి తీసివేయండి',
      'enable_reminder': 'డెడ్‌లైన్ రిమైండర్ ఆన్ చేయండి',
      'reminder_scheduled': 'రిమైండర్ షెడ్యూల్ చేయబడింది',
      'scheme_disclaimer': 'అందుబాటులో ఉన్న సమాచారం ప్రకారం. దయచేసి అధికారిక ప్రభుత్వ పోర్టల్‌లో సరిచూసుకోండి.',
      'deadline_open': 'అందుబాటులో ఉంది / కొనసాగుతోంది',
      'deadline_none': 'డెడ్‌లైన్ అందుబాటులో లేదు',
      'sync_status_synced': 'క్లౌడ్‌తో సింక్ అయింది',
      'sync_status_syncing': 'సింక్ అవుతోంది...',
      'sync_status_offline': 'ఆఫ్‌లైన్ మోడ్ యాక్టివ్',
      'ai_fallback_title': 'AI అందుబాటులో లేదు',
      'ai_fallback_desc': 'జెమిని AI బిజీగా ఉంది. కొనసాగడానికి ప్రత్యామ్నాయాన్ని ఎంచుకోండి:',
      'copy_prompt': 'ప్రాంప్ట్ కాపీ చేయండి',
      'share_prompt': 'యాప్ ద్వారా షేర్ చేయండి',
      'open_chatgpt': 'ChatGPT తెరవండి',
      'open_gemini': 'Gemini తెరవండి',
    },
    'hi': {
      'app_title': 'लाइफमेट',
      'welcome_subtitle': 'आपका एआई जीवन साथी',
      'guest_mode': 'गेस्ट मोड',
      'tasks': 'कार्य और रिमाइंडर',
      'diary': 'मेरी जीवन पुस्तक',
      'expenses': 'खर्च ट्रैकर',
      'sms_tracker': 'एसएमएस मनी ट्रैकर',
      'govt_schemes': 'सरकारी योजनाएं',
      'english_coach': 'स्पोकन इंग्लिश कोच',
      'translation': 'रियल-टाइम अनुवाद',
      'ai_assistant': 'जेमिनी एआई साथी',
      'safety_sos': 'आपातकालीन सुरक्षा SOS',
      'profile': 'प्रोफाइल और सेटिंग्स',
      'save_scheme': 'योजना सहेजें',
      'interested': 'रुचि है',
      'remove_interest': 'रुचि हटाएं',
      'enable_reminder': 'अंतिम तिथि रिमाइंडर चालू करें',
      'reminder_scheduled': 'रिमाइंडर शेड्यूल किया गया',
      'scheme_disclaimer': 'उपलब्ध योजना जानकारी के अनुसार। कृपया आधिकारिक सरकारी स्रोत पर सत्यापित करें।',
      'deadline_open': 'खुला / जारी है',
      'deadline_none': 'अंतिम तिथि उपलब्ध नहीं है',
      'sync_status_synced': 'क्लाउड के साथ सिंक किया गया',
      'sync_status_syncing': 'सिंक हो रहा है...',
      'sync_status_offline': 'ऑफलाइन मोड सक्रिय',
      'ai_fallback_title': 'एआई उपलब्ध नहीं है',
      'ai_fallback_desc': 'जेमिनी एआई वर्तमान में व्यस्त है। जारी रखने के लिए विकल्प चुनें:',
      'copy_prompt': 'प्रॉम्प्ट कॉपी करें',
      'share_prompt': 'ऐप के माध्यम से शेयर करें',
      'open_chatgpt': 'ChatGPT खोलें',
      'open_gemini': 'Gemini खोलें',
    },
    'ta': {
      'app_title': 'லைஃப்மேட்',
      'welcome_subtitle': 'உங்கள் AI வாழ்க்கை துணை',
      'guest_mode': 'விருந்தினர் முறை',
      'tasks': 'பணிகள் & நினைவூட்டல்கள்',
      'diary': 'என் வாழ்க்கை புத்தகம்',
      'expenses': 'செலவு டிராக்கர்',
      'sms_tracker': 'SMS பண டிராக்கர்',
      'govt_schemes': 'அரசு திட்டங்கள்',
      'english_coach': 'ஆங்கிலப் பேச்சு பயிற்சியாளர்',
      'translation': 'நேரடி மொழிபெயர்ப்பு',
      'ai_assistant': 'ஜெமினி AI துணை',
      'safety_sos': 'அவசர பாதுகாப்பு SOS',
      'profile': 'சுயவிவரம் & அமைப்புகள்',
      'save_scheme': 'திட்டத்தை சேமி',
      'interested': 'ஆர்வமுள்ளது',
      'remove_interest': 'ஆர்வத்தை நீக்கு',
      'enable_reminder': 'கெடு நினைவூட்டலை இயக்கு',
      'reminder_scheduled': 'நினைவூட்டல் திட்டமிடப்பட்டது',
      'scheme_disclaimer': 'கிடைக்கக்கூடிய திட்ட தகவலின்படி. அதிகாரப்பூர்வ அரசு தளத்தில் சரிபார்க்கவும்.',
      'deadline_open': 'திறந்துள்ளது / தொடர்கிறது',
      'deadline_none': 'கெடு தேதி கிடைக்கவில்லை',
      'sync_status_synced': 'கிளவுட் உடன் ஒத்திசைக்கப்பட்டது',
      'sync_status_syncing': 'ஒத்திசைக்கப்படுகிறது...',
      'sync_status_offline': 'ஆஃப்லைன் முறை செயல்பாட்டில் உள்ளது',
      'ai_fallback_title': 'AI கிடைக்கவில்லை',
      'ai_fallback_desc': 'ஜெமினி AI தற்போது பிஸியாக உள்ளது. தொடர மாற்று வழியைத் தேர்ந்தெடுக்கவும்:',
      'copy_prompt': 'பிராம்ப் நகலெடு',
      'share_prompt': 'செயலி வழியாக பகிர்',
      'open_chatgpt': 'ChatGPT திற',
      'open_gemini': 'Gemini திற',
    },
    'ml': {
      'app_title': 'ലൈഫ്‌മേറ്റ്',
      'welcome_subtitle': 'നിങ്ങളുടെ എഐ ജീവിതാതിഥി',
      'guest_mode': 'ഗസ്റ്റ് മോഡ്',
      'tasks': 'ടാസ്കുകളും ഓർമ്മപ്പെടുത്തലുകളും',
      'diary': 'എന്റെ ജീവിത പുസ്തകം',
      'expenses': 'ചെലവ് ട്രാക്കർ',
      'sms_tracker': 'എസ്എംഎസ് മണി ട്രാക്കർ',
      'govt_schemes': 'സർക്കാർ പദ്ധതികൾ',
      'english_coach': 'സ്പോക്കൺ ഇംഗ്ലീഷ് പരിശീലകൻ',
      'translation': 'തത്സമയ വിവർത്തനം',
      'ai_assistant': 'ജെമിനി എഐ സഹായി',
      'safety_sos': 'അടിയന്തര സുരക്ഷാ SOS',
      'profile': 'പ്രൊഫൈലും ക്രമീകരണങ്ങളും',
      'save_scheme': 'പദ്ധതി സേവ് ചെയ്യുക',
      'interested': 'താല്പര്യമുണ്ട്',
      'remove_interest': 'താല്പര്യം നീക്കുക',
      'enable_reminder': 'അവസാന തീയതി ഓർമ്മപ്പെടുത്തൽ പ്രവർത്തിപ്പിക്കുക',
      'reminder_scheduled': 'ഓർമ്മപ്പെടുത്തൽ നിശ്ചയിച്ചു',
      'scheme_disclaimer': 'ലഭ്യമായ പദ്ധതി വിവരങ്ങൾ അനുസരിച്ച്. ഔദ്യോഗിക സർക്കാർ സ്രോതസ്സിൽ പരിശോധിക്കുക.',
      'deadline_open': 'തുറന്നിരിക്കുന്നു / തുടരുന്നു',
      'deadline_none': 'അവസാന തീയതി ലഭ്യമല്ല',
      'sync_status_synced': 'ക്ലൗഡുമായി സിങ്ക് ചെയ്തു',
      'sync_status_syncing': 'സിങ്ക് ചെയ്യുന്നു...',
      'sync_status_offline': 'ഓഫ്‌ലൈൻ മോഡ് സജീവം',
      'ai_fallback_title': 'എഐ ലഭ്യമല്ല',
      'ai_fallback_desc': 'ജെമിനി എഐ നിലവിൽ ലഭ്യമായിട്ടില്ല. തുടരാൻ മറ്റൊരു വഴി തിരഞ്ഞെടുക്കുക:',
      'copy_prompt': 'പ്രോംപ്റ്റ് കോപ്പി ചെയ്യുക',
      'share_prompt': 'ആപ്പ് വഴി പങ്കിടുക',
      'open_chatgpt': 'ChatGPT തുറക്കുക',
      'open_gemini': 'Gemini തുറക്കുക',
    },
    'bn': {
      'app_title': 'লাইফমেট',
      'welcome_subtitle': 'আপনার এআই জীবনসঙ্গী',
      'guest_mode': 'গেস্ট মোড',
      'tasks': 'টাস্ক এবং রিমাইন্ডার',
      'diary': 'আমার জীবন বই',
      'expenses': 'খরচ ট্র্যাকার',
      'sms_tracker': 'এসএমএস মানি ট্র্যাকার',
      'govt_schemes': 'সরকারি প্রকল্প',
      'english_coach': 'স্পোকেন ইংলিশ কোচ',
      'translation': 'রিয়েল-টাইম অনুবাদ',
      'ai_assistant': 'জেমিনি এআই সহকারী',
      'safety_sos': 'জরুরি নিরাপত্তা SOS',
      'profile': 'প্রোফাইল এবং সেটিংস',
      'save_scheme': 'প্রকল্প সংরক্ষণ করুন',
      'interested': 'আগ্রহী',
      'remove_interest': 'আগ্রহ সরান',
      'enable_reminder': 'শেষ তারিখের রিমাইন্ডার চালূ করুন',
      'reminder_scheduled': 'রিমাইন্ডার শিডিউল করা হয়েছে',
      'scheme_disclaimer': 'উপলব্ধ প্রকল্পের তথ্য অনুযায়ী। তথ্য যাচাই করতে সরকারি পোর্টালে দেখুন।',
      'deadline_open': 'উন্মুক্ত / চলমান',
      'deadline_none': 'শেষ তারিখ পাওয়া যায়নি',
      'sync_status_synced': 'ক্লাউডের সাথে সিঙ্ক হয়েছে',
      'sync_status_syncing': 'সিঙ্ক হচ্ছে...',
      'sync_status_offline': 'অফলাইন মোড সক্রিয়',
      'ai_fallback_title': 'এআই উপলব্ধ নেই',
      'ai_fallback_desc': 'জেমিনি এআই বর্তমানে ব্যস্ত। চালিয়ে যেতে বিকল্প বেছে নিন:',
      'copy_prompt': 'প্রম্পট কপি করুন',
      'share_prompt': 'অ্যাপের মাধ্যমে শেয়ার করুন',
      'open_chatgpt': 'ChatGPT খুলুন',
      'open_gemini': 'Gemini খুলুন',
    },
  };

  /// Returns localized string by key for current language with English fallback.
  String getString(String key) {
    return _localizedStrings[_currentLanguage]?[key] ??
        _localizedStrings['en']?[key] ??
        key;
  }
}
