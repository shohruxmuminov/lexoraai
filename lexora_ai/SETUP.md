# Lexora AI — Setup Guide

## Prerequisites
- Flutter SDK 3.16+
- Dart SDK 3.0+
- Android Studio / Xcode
- Firebase project
- OpenAI API key

## Installation

### 1. Install Flutter dependencies
```bash
cd lexora_ai
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Firebase Setup
1. Create a Firebase project at console.firebase.google.com
2. Add Android app with package: `com.lexora.lexora_ai`
3. Add iOS app with bundle ID: `com.lexora.lexoraAi`
4. Download `google-services.json` → place in `android/app/`
5. Download `GoogleService-Info.plist` → place in `ios/Runner/`
6. Enable: Authentication, Firestore, Storage, Analytics, Messaging

### 3. Supabase Setup
1. Create project at app.supabase.com
2. Copy your Project URL and anon key
3. Add to `lib/core/constants/app_constants.dart`

### 4. OpenAI API
1. Get API key from platform.openai.com
2. Add in Settings screen or environment variable
3. Or hardcode in `AiService.initialize()` during development

### 5. Run
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome

# Release APK
flutter build apk --release

# Release AAB (Play Store)
flutter build appbundle --release
```

## Architecture

```
lib/
├── core/
│   ├── constants/     # App-wide constants
│   ├── theme/         # Colors, typography, themes
│   ├── router/        # GoRouter navigation
│   └── utils/         # SRS, gamification helpers
├── data/
│   ├── models/        # JSON-serializable data classes
│   ├── repositories/  # Data access layer
│   └── datasources/   # Remote (API) + Local (Hive/SQLite)
├── domain/
│   ├── entities/      # Pure business objects
│   ├── repositories/  # Repository interfaces
│   └── usecases/      # Business logic
├── presentation/
│   ├── screens/       # All screens
│   ├── widgets/       # Reusable components
│   ├── providers/     # Riverpod state
│   └── shell/         # Navigation shell
└── services/          # TTS, Speech, AI, Dictionary
```

## Key Features Implemented

| Feature | Status |
|---------|--------|
| Splash Screen | ✅ |
| Onboarding | ✅ |
| Auth (Email + Google) | ✅ |
| Home Dashboard | ✅ |
| Word Search | ✅ |
| Word Detail (5 tabs) | ✅ |
| AI Chat (GPT-4o stream) | ✅ |
| Flashcards + SRS | ✅ |
| Quiz Generator | ✅ |
| Speaking Practice | ✅ |
| IELTS Hub | ✅ |
| Reading Assistant | ✅ |
| Camera Scanner | ✅ |
| Vocabulary Bank | ✅ |
| Progress Dashboard | ✅ |
| Profile | ✅ |
| Settings | ✅ |
| Gamification (XP, Streaks, Levels) | ✅ |
| Dark / Light Mode | ✅ |

## API Keys Required

- `OPENAI_API_KEY` — for AI chat, quiz generation, writing evaluation
- Firebase credentials — for auth, database, storage
- Supabase credentials — for scalable data storage

## Supported Languages (Translation)

- English ↔ Uzbek (uz)
- English ↔ Russian (ru)
- English ↔ Turkish (tr)
- English ↔ Arabic (ar)

## Wisdom App Analysis

Based on Play Store research, Wisdom Dictionary:
- **Strengths**: Large offline database, multiple language support, clean UI
- **Gaps vs Lexora AI**:
  - No AI chat or explanations
  - No speaking/pronunciation scoring
  - No SRS flashcard system
  - No IELTS-specific content
  - No gamification system
  - No reading assistant
  - No camera OCR
  - No personalized study plans

Lexora AI addresses ALL these gaps while maintaining an offline-capable dictionary.
