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
  versionCode: 14,
  releaseDate: 'August 9, 2026',
  apkUrl: 'https://github.com/Hemashreebm/Lifemate-app/releases/download/v2.0.1-release/app-release.apk',
  apkSize: '257 MB',
  minAndroid: 'Android 7.0 (API level 24)',
  targetAndroid: 'Android 14 / 15 (API level 36)',
  sha256Checksum: '3a9a10858efcb8eb38eacd5194bf045534eb74eacda31132d72a56089e53eeca',
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
