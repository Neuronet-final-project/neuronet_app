# NEURONET — Project Context

## Overview

NEURONET is a **Flutter monorepo** containing two Android mobile apps for an AI-driven adolescent mental health support platform. The project is a **final-year university project** targeting teens (13–17) and their parents/guardians.

| Package | Purpose |
|---------|---------|
| `apps/adolescent_app` | Teen-facing app: journaling, mood tracking, AI chat, personal dashboard, counselor communication, channel browsing |
| `apps/guardian_app` | Parent-facing app: adolescent registration, consent management, aggregated insights, alerts, counselor messaging |
| `packages/neuronet_core` | Shared core: data models (Freezed), API client (Dio), services, theme system, shared widgets, error handling (`Result<T>` / `Failure`) |

The two apps share **~70% of code** through `neuronet_core`.

## Architecture

- **Pattern:** MVVM with Riverpod (code generation-based, `@riverpod` / `AsyncNotifier`)
- **Models:** Freezed with JSON serialization
- **Routing:** GoRouter with auth guards and `StatefulShellRoute` for bottom navigation
- **Networking:** Dio with JWT Bearer auth interceptor + logging interceptor
- **State:** Riverpod + `riverpod_generator`
- **Theme:** Parameterized dual-brand system — green (adolescent) / pink (guardian)

### Auth Flow

1. Splash screen → `AuthController._checkInitialAuth()` checks for stored token (500ms min)
2. If token exists → calls `GET /auth/me` → authenticated with real user
3. If no token → redirects to login
4. Login → `POST /auth/login` → saves access token → fetches real user via `GET /auth/me`
5. Token expiry is handled by `AuthInterceptor` which fires `sessionExpiredNotifier` → auth provider sets unauthenticated → router redirects to login

## Key Commands

```bash
# Bootstrap workspace (install deps for all packages)
melos bootstrap

# Run code generation (Freezed, Riverpod, JSON serialization)
melos run build_runner

# Analyze all packages
melos run analyze

# Run all tests
melos run test

# Clean all packages
melos run clean

# Format all packages
melos run format
```

Or per-package:

```bash
# In any package directory:
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

## Environment Configuration

- `.env` file at project root (gitignored) with `BASE_URL` key
- `.env.example` template is committed
- Both `main.dart` files load `.env` via `flutter_dotenv` with web-safe fallback
- `ApiEndpoints.init(baseUrl: ...)` is called at startup
- On web, dotenv loading is skipped and the default Railway URL is used

## Testing

57 tests total across the workspace:

| Test File | Count | Coverage |
|-----------|-------|----------|
| `packages/neuronet_core/test/models_test.dart` | 37 | All Freezed models JSON parsing, `Result<T>`, enum serialization |
| `packages/neuronet_core/test/services_test.dart` | 14 | AuthService, AlertService, JournalService, ChannelService, EducationalService, MessagingService (mocktail) |
| `apps/adolescent_app/test/widget_test.dart` | 5 | Login screens (adolescent + guardian) — branding, validation, loading states |
| `apps/guardian_app/test/widget_test.dart` | 1 | Placeholder (tests consolidated in adolescent_app) |

## Known Gaps (from cross-reference analysis)

See `cross_reference_analysis.md` for the full report. Key items:

| Priority | Gap |
|---|---|
| 🔴 P0 | AI chat uses mock data — no backend integration |
| 🔴 P0 | Consent types mismatch (2 app types vs 5 PRD types) |
| 🔴 P0 | API paths missing `/api/v1` prefix — may 404 if backend enforces it |
| 🔴 P0 | FCM push notifications not wired up |
| 🟡 P1 | Adolescent consent status screen missing |
| 🟡 P1 | Counselor chat lacks consent gate |
| 🟡 P1 | Profile update not implemented |
| 🟡 P1 | Guardian followed-pages screen missing |

## Project Structure

```
neuronet_app/
├── apps/
│   ├── adolescent_app/         # Teen-facing Flutter app
│   │   ├── lib/
│   │   │   ├── main.dart
│   │   │   ├── config/
│   │   │   │   └── router/     # GoRouter config + AdolescentRoutes
│   │   │   └── features/       # feature-first: providers/, view/screens/, view/widgets/
│   │   │       ├── auth/
│   │   │       ├── dashboard/
│   │   │       ├── journal/
│   │   │       ├── mood/
│   │   │       ├── ai_chat/    # MOCK only — no backend integration
│   │   │       ├── channels/
│   │   │       ├── counselor_chat/
│   │   │       ├── alerts/
│   │   │       ├── educational/
│   │   │       └── profile/
│   │   └── test/
│   │
│   └── guardian_app/           # Parent-facing Flutter app
│       ├── lib/
│       │   ├── main.dart
│       │   ├── config/
│       │   │   └── router/     # GoRouter config + GuardianRoutes
│       │   └── features/
│       │       ├── auth/
│       │       ├── dashboard/
│       │       ├── registration/
│       │       ├── consent/
│       │       ├── alerts/
│       │       ├── counselor_msg/
│       │       ├── adolescents/
│       │       └── profile/
│       └── test/
│
├── packages/
│   └── neutron_core/           # Shared package
│       └── lib/
│           ├── neuronet_core.dart    # Barrel export
│           └── src/
│               ├── models/           # Freezed DTOs + enums
│               ├── network/          # ApiClient, ApiEndpoints, interceptors, session_expired
│               ├── services/         # AuthService, JournalService, ChannelService, etc.
│               ├── errors/           # Result<T>, Failure hierarchy
│               ├── theme/            # NeuroTheme (green/pink)
│               └── widgets/          # NeuroErrorWidget, NeuroCard, etc.
│
├── melos.yaml                  # Monorepo orchestrator
├── pubspec.yaml                # Workspace root (Dart 3.9.0)
├── analysis_options.yaml       # very_good_analysis (3 rules disabled)
├── .env                        # Local env (gitignored)
├── .env.example                # Env template
├── prd.md                      # Product Requirements Document
├── implementation_plan.md      # Architecture & setup plan
├── cross_reference_analysis.md # PRD vs implementation gap analysis
└── README.md                   # Project overview
```

## Development Conventions

- **Feature-first organization:** Each feature has `providers/`, `view/screens/`, `view/widgets/`
- **Riverpod code generation:** All providers use `@riverpod` annotations with `part '*.g.dart'`
- **Freezed models:** All data models use `@freezed` with immutable data classes
- **Linting:** Root uses `very_good_analysis`; apps use `flutter_lints`. Generated files (`.g.dart`, `.freezed.dart`) excluded from analysis
- **Error handling:** Services return `Result<T>` — providers handle via `.when()` / `.isSuccess` / `.isFailure`
- **API errors:** `failureFromException()` maps `DioException` → `Failure` subclasses (`ServerFailure`, `NetworkFailure`, `AuthFailure`, `UnknownFailure`)
- **Backend URL:** `https://final-year-project-backend-production-da67.up.railway.app` (configurable via `.env`)
- **Platform:** Android only (`.gitignore` excludes web/desktop platform directories)
- **Git:** `.agent/` directory is intentionally untracked
