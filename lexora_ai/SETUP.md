# Lexora AI — Setup Guide

## Prerequisites
- Flutter SDK 3.16+
- Dart SDK 3.0+
- Android Studio / Xcode
- Firebase project
- OpenAI API key

## Installation

### 1. Generate platform folders + install dependencies
The repo ships only `lib/` and `pubspec.yaml`. Generate the Android/iOS/Web
projects (MainActivity, Gradle, web/index.html, etc.) with `flutter create`,
then fetch packages:
```bash
cd lexora_ai
flutter create . --org com.lexora --platforms=android,ios,web
flutter pub get
flutter run                # runs on a connected device / Chrome
```
No code generation step is needed — the app uses hand-written providers.

> **AI key (optional):** the app runs out of the box in *demo mode*. To enable
> real GPT-4o answers, run with your key:
> ```bash
> flutter run --dart-define=OPENAI_API_KEY=sk-your-key
> ```
> or set it from the in-app **Settings → AI & API** screen.

### 2. OpenAI API (optional but recommended)
1. Get an API key from platform.openai.com
2. Provide it via `--dart-define=OPENAI_API_KEY=sk-...` or the in-app Settings screen.
3. Without a key the AI features run in **demo mode** (canned replies) so the
   whole UI is still usable.

### 3. Build for release
```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release

# Web
flutter build web --release
```

### Backend (Firebase / Supabase) — not yet wired
Authentication currently uses a local mock (`UserNotifier`) so the app runs with
zero backend setup. To connect a real backend, add `firebase_core`/`firebase_auth`
(or `supabase_flutter`) to `pubspec.yaml`, run `flutterfire configure`, and
replace the mock calls in `lib/presentation/providers/user_provider.dart`.

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
