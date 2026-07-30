# 🌟 Lifemate — Your Intelligent AI Life Companion

[![Flutter](https://img.shields.io/badge/Built%20with-Flutter%203.29-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Language-Dart%203.7-0175C2?logo=dart)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20(API%2024%2B)-3DDC84?logo=android)](https://developer.android.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Repo](https://img.shields.io/badge/GitHub-Lifemate--app-181717?logo=github)](https://github.com/Hemashreebm/Lifemate-app)

**Lifemate** is a feature-rich, all-in-one personal lifestyle and productivity application built with Flutter. Designed to assist users in their daily routines, Lifemate brings together smart task management, true native clock alarms, AI-powered communication coaching, location awareness, personal diary logging, real-time speech/text translation, and expense tracking into a cohesive, beautifully styled mobile interface.

---

## 📱 Features

### ⏰ True Native Android Clock Alarm
- **Continuous 30-Second Ringing**: Plays on native system `USAGE_ALARM` audio stream.
- **Lock Screen Full-Screen UI**: Wakes phone screen and displays interactive alarm UI (`⏹️ STOP` & `⏰ SNOOZE 10 MIN`) directly over the Android lock screen.
- **Background & Closed App Wakeup**: Uses `AlarmManager.setAlarmClock()` and a native Kotlin `ForegroundService` to wake up device CPU even when the app is completely closed.

### 🗣️ Communication Coach
- AI-assisted speaking and tone analysis to help practice social interactions, interview responses, and professional speech.

### 📋 Smart Tasks & Reminders
- Priority-coded task creation (Low, Medium, High).
- Choice between **⏰ Ringing Alarm** (30s full-screen clock alarm) and **🔔 Normal Chime**.
- Repeat patterns (Daily, Weekly, Monthly) and smart time offsets.

### 📖 Friendly Diary
- Private daily mood & journal logger to record thoughts, reflections, and personal highlights.

### 🌐 Real-Time Translation
- On-device speech and text translation supporting multiple global languages.

### 📍 Smart Location
- Real-time location tracking, address lookup, and quick navigation shortcuts.

### 💰 Expense Tracker
- Personal finance ledger to track daily expenses, income, and category breakdowns.

---

## 📥 Download APK

Get the latest pre-compiled Android APK directly to test Lifemate on your physical device:

👉 **[Download Lifemate Android APK from GitHub Releases](https://github.com/Hemashreebm/Lifemate-app/releases)**

> You can download the pre-built `app-debug.apk` or `app-release.apk` directly from the Releases page and install it on any Android device running Android 7.0 (API 24) or higher.

---

## 🖼️ Screenshots

| Home & Features | Smart Tasks & Reminders | Full-Screen Clock Alarm |
| :---: | :---: | :---: |
| *(Add your screenshot here)* | *(Add your screenshot here)* | *(Add your screenshot here)* |

| Communication Coach | Friendly Diary | Real-Time Translation |
| :---: | :---: | :---: |
| *(Add your screenshot here)* | *(Add your screenshot here)* | *(Add your screenshot here)* |

---

## 🛠️ Flutter & Environment Requirements

- **Flutter SDK**: `^3.29.0` (Dart `^3.7.0`)
- **Android SDK Target**: API Level 34 (Android 14)
- **Minimum Android Version**: API Level 24 (Android 7.0)
- **JDK**: Java 17 / OpenJDK 17

---

## 🚀 How to Build & Run Locally

### 1. Clone the Repository
```bash
git clone https://github.com/Hemashreebm/Lifemate-app.git
cd Lifemate-app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run on Connected Device / Emulator
```bash
flutter run
```

### 4. Build Debug / Release APK
```bash
# Debug APK
flutter build apk --debug

# Release APK (requires keystore configuration)
flutter build apk --release
```

---

## 📁 Project Structure

```
Lifemate/
├── android/                   # Native Android codebase (Kotlin, Manifest, Gradle)
│   └── app/src/main/kotlin/com/example/lifemate/
│       ├── MainActivity.kt    # MethodChannels & AlarmManager setup
│       ├── AlarmReceiver.kt   # Native BroadcastReceiver for alarms
│       ├── AlarmService.kt    # Native Foreground Service for 30s looping audio/vibrate
│       └── AlarmActivity.kt   # Full-screen lock screen alarm UI
├── apk/                       # Pre-compiled ready-to-test APK binary
│   └── lifemate-debug.apk
├── assets/                    # App icons, audio resources, and assets
│   └── sounds/
│       └── reminder_ring.wav
├── lib/                       # Flutter Dart source code
│   ├── main.dart              # Application entry point
│   ├── models/                # Data models (TaskItem, DiaryEntry, etc.)
│   ├── screens/               # UI screens (Home, Tasks, Profile, Diary, etc.)
│   └── services/              # Business logic (NotificationService, NativeAlarmService, TaskService)
├── pubspec.yaml               # Project dependencies and asset definitions
└── README.md                  # Project documentation
```

---

## 🧰 Technologies Used

- **Framework**: [Flutter](https://flutter.dev) (Dart)
- **Native Android**: Kotlin (`AlarmManager`, `ForegroundService`, `BroadcastReceiver`, `Full-Screen Intent`)
- **Notifications & Audio**: `flutter_local_notifications`, `audioplayers`, `timezone`
- **Speech & Translation**: `speech_to_text`, `flutter_tts`, `google_mlkit_translation`
- **Location**: `geolocator`, `geocoding`
- **Storage**: `shared_preferences`

---

## 🔐 Android Permissions Required

- `RECEIVE_BOOT_COMPLETED`: Reschedule alarms after device reboot.
- `SCHEDULE_EXACT_ALARM` & `USE_EXACT_ALARM`: Trigger clock alarms at exact scheduled millisecond.
- `USE_FULL_SCREEN_INTENT`: Display alarm interface over the lock screen.
- `WAKE_LOCK`: Keep CPU awake during alarm ringing.
- `FOREGROUND_SERVICE_MEDIA_PLAYBACK`: Run continuous audio playback service in background.
- `RECORD_AUDIO`: Voice input for Communication Coach and Real-Time Translation.
- `ACCESS_FINE_LOCATION`: Location services for Smart Location feature.

---

## 🗺️ Future Roadmap

- [ ] Dark Mode / Custom Theme Switcher
- [ ] Cloud Synchronization & Multi-Device Backup
- [ ] Expanded AI Voice Dialogs in Communication Coach
- [ ] iOS Full-Screen Alarm Equivalent Integration

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more details.

---

## 👤 Author & Contact

- **Author**: Hemashree B M ([@Hemashreebm](https://github.com/Hemashreebm))
- **GitHub Repository**: [https://github.com/Hemashreebm/Lifemate-app](https://github.com/Hemashreebm/Lifemate-app)

---

*Made with ❤️ for smart, intuitive daily life management.*
