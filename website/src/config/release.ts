export interface ReleaseConfig {
  version: string;
  versionCode: number;
  releaseDate: string;
  apkUrl: string;
  apkSize: string;
  minAndroid: string;
  targetAndroid: string;
  sha256Checksum: string;
  changelog: string[];
}

export const RELEASE_CONFIG: ReleaseConfig = {
  version: '2.0.1',
  versionCode: 13,
  releaseDate: 'August 8, 2026',
  apkUrl: 'https://github.com/Hemashreebm/Lifemate-app/releases/download/v2.0.1-release/app-release.apk',
  apkSize: '258.6 MB',
  minAndroid: 'Android 7.0 (API level 24)',
  targetAndroid: 'Android 14 / 15 (API level 36)',
  sha256Checksum: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
  changelog: [
    'Real Supabase Cloud Database & Authentication (Google OAuth + Email/Password + Session Persistence)',
    'Native Google Sign-In with instant profile metadata auto-fill (0 browser redirects)',
    'Secure Gemini AI Architecture via Supabase Edge Function proxy with rate limiting (10 req/min/UID) & prompt caps',
    'Real Profile Personalization & 12 Verified Indian Government Schemes matching (PM-Kisan, Ayushman Bharat, PM-MY, etc.)',
    'Complete User Profile System with 100% completeness scoring & state dropdowns',
    'Spoken English & Communication Coach Pro with structured daily challenges',
    'SMS Financial Spending Tracker with local categorizer & offline diary backup',
  ],
};
