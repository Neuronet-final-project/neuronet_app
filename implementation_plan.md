# Monorepo Architecture for NEURONET Mobile Apps

## Goal

Set up a Melos-based monorepo containing two Flutter apps (Adolescent & Guardian) that share a common core package. Use the `flutter_mvvm` Mason brick to scaffold each app, then extract shared code into a `neuronet_core` package.

## Why a Monorepo?

The two apps share **~70% of code**: data models, API client, auth flow, consent logic, notification service, theme tokens, and shared widgets. A monorepo with Melos avoids:
- Duplicated models and services across repos
- Version drift between shared dependencies
- Redundant CI/CD pipelines

---

## Proposed Structure

```
neuronet/
├── melos.yaml                        # Monorepo orchestrator
├── pubspec.yaml                      # Root (for Melos workspace)
├── analysis_options.yaml             # Shared lint rules
├── mason.yaml                        # Brick registry (dev tooling)
├── prd.md                            # Product Requirements
│
├── apps/
│   ├── adolescent_app/               # ← mason make flutter_mvvm
│   │   ├── lib/
│   │   │   ├── main.dart
│   │   │   ├── bootstrap.dart
│   │   │   ├── config/
│   │   │   │   ├── env/
│   │   │   │   ├── providers/
│   │   │   │   └── router/           # Adolescent-specific routes
│   │   │   ├── features/
│   │   │   │   ├── journal/          # Journal entry, history
│   │   │   │   ├── mood/             # Mood recording
│   │   │   │   ├── ai_chat/          # AI conversational chat
│   │   │   │   ├── dashboard/        # Personal emotional dashboard
│   │   │   │   ├── channels/         # Channel browsing & interaction
│   │   │   │   └── counselor_chat/   # Counselor messaging (consent-gated)
│   │   │   └── shared/              # App-specific shared widgets
│   │   ├── test/
│   │   ├── pubspec.yaml              # Depends on neuronet_core
│   │   └── README.md
│   │
│   └── guardian_app/                 # ← mason make flutter_mvvm
│       ├── lib/
│       │   ├── main.dart
│       │   ├── bootstrap.dart
│       │   ├── config/
│       │   │   ├── env/
│       │   │   ├── providers/
│       │   │   └── router/           # Guardian-specific routes
│       │   ├── features/
│       │   │   ├── registration/     # Adolescent registration
│       │   │   ├── consent/          # Consent management
│       │   │   ├── dashboard/        # Aggregated insights dashboard
│       │   │   ├── alerts/           # Alert history & notifications
│       │   │   └── counselor_msg/    # Guardian-counselor messaging
│       │   └── shared/
│       ├── test/
│       ├── pubspec.yaml              # Depends on neuronet_core
│       └── README.md
│
└── packages/
    └── neuronet_core/                # ← Shared package
        ├── lib/
        │   ├── neuronet_core.dart     # Barrel export
        │   ├── models/               # All Freezed DTOs
        │   │   ├── user.dart
        │   │   ├── journal_entry.dart
        │   │   ├── mood_record.dart
        │   │   ├── consent.dart
        │   │   ├── alert.dart
        │   │   ├── chat_message.dart
        │   │   ├── channel.dart
        │   │   ├── channel_post.dart
        │   │   ├── counselor_assignment.dart
        │   │   ├── ai_analysis.dart
        │   │   └── enums.dart         # MoodType, ConsentType, etc.
        │   ├── network/              # Shared Dio client + interceptors
        │   │   ├── api_client.dart
        │   │   ├── api_endpoints.dart
        │   │   └── interceptors/
        │   │       ├── auth_interceptor.dart
        │   │       └── logging_interceptor.dart
        │   ├── services/             # Shared repositories (abstract + impl)
        │   │   ├── auth/
        │   │   ├── consent/
        │   │   ├── profile/
        │   │   └── notification/
        │   ├── providers/            # Shared Riverpod providers
        │   ├── theme/                # Design tokens (colors, typography)
        │   │   ├── app_colors.dart    # Green (adolescent) + Pink (guardian)
        │   │   ├── app_typography.dart
        │   │   └── app_spacing.dart
        │   ├── widgets/              # Shared UI components
        │   │   ├── neuro_button.dart
        │   │   ├── neuro_text_field.dart
        │   │   ├── mood_selector.dart
        │   │   ├── consent_badge.dart
        │   │   └── alert_card.dart
        │   ├── errors/               # Failure model, Result type
        │   ├── constants/            # API URLs, limits, enums
        │   └── utils/               # Shared utilities
        ├── test/
        ├── pubspec.yaml
        └── README.md
```

---

## Brick Usage Plan

### Bricks to Use

| Brick | Where | Purpose |
|-------|-------|---------|
| `flutter_mvvm` | `apps/adolescent_app/`, `apps/guardian_app/` | Scaffold each app with MVVM architecture |
| `failure_model` | `packages/neuronet_core/` | Unified `Failure` hierarchy + `Result<T>` type |
| `session_management` | `packages/neuronet_core/` | JWT token pair management + auto-refresh |
| `notification_service` | `packages/neuronet_core/` | FCM + local notifications + deep link routing |
| `form_validators` | `packages/neuronet_core/` | Email, password, required-field validators |
| `ui_state` | `packages/neuronet_core/` | `UiState<T>` (Idle/Loading/Success/Error/Empty) |
| `theme_controller` | `packages/neuronet_core/` | Light/Dark/System theme with persistence |
| `cache_repository` | Both apps (per feature) | In-memory caching for API responses |
| `network_image_widget` | `packages/neuronet_core/` | Cached network images (avatars, channel media) |
| `pagination_utils` | `packages/neuronet_core/` | Journal history, mood history, alert list pagination |
| `localization_controller` | `packages/neuronet_core/` | English ARB translations with locale persistence |

### Bricks NOT needed (for MVP)

| Brick | Reason |
|-------|--------|
| `media_picker_service` | No image/file upload in MVP |
| `viewmodel_test` | Use later for test scaffolding |

---

## Implementation Steps

### Phase 1: Workspace Setup (Detailed Dependencies)

To ensure compatibility between `freezed`, `riverpod_generator`, and `flutter_test`, the following versions are used across all packages:

- `freezed: ^3.2.5`
- `freezed_annotation: ^3.0.0`
- `riverpod_generator: ^4.0.3`
- `build_runner: ^2.13.1`
- `json_serializable: ^6.13.1`
- `json_annotation: ^4.11.0`

1. **Initialize Melos monorepo:**
   - Create root `melos.yaml` with workspace config
   - Create root `pubspec.yaml` (workspace dependency)
   - Create root `analysis_options.yaml`

2. **Create `neuronet_core` package:**
   - `flutter create --template=package packages/neuronet_core`
   - Apply shared bricks: `failure_model`, `session_management`, `form_validators`, `ui_state`, `theme_controller`, `notification_service`, `network_image_widget`, `pagination_utils`, `localization_controller`
   - Define all Freezed data models from the PRD
   - Set up shared Dio API client and endpoints
   - Create shared auth service (login, activate, logout, token refresh)

3. **Scaffold Adolescent App:**
   - `mason make flutter_mvvm` → `apps/adolescent_app/`
   - Add `neuronet_core` as path dependency
   - Remove duplicated code generated by brick (use core instead)
   - Configure adolescent-specific routing, theme (green), features

4. **Scaffold Guardian App:**
   - `mason make flutter_mvvm` → `apps/guardian_app/`
   - Add `neuronet_core` as path dependency
   - Remove duplicated code generated by brick (use core instead)
   - Configure guardian-specific routing, theme (pink), features

### Phase 2: Shared Foundation (neuronet_core)

5. **Data Models** — All Freezed DTOs with JSON serialization
6. **API Client** — Dio + auth/logging interceptors + API endpoints
7. **Auth Service** — Login, activate, logout, token refresh
8. **Consent Service** — View/manage consent (shared logic)
9. **Shared Providers** — Riverpod providers for auth state, user profile, consent
10. **Theme** — Color system (parameterized for adolescent green / guardian pink)

### Phase 3: App-Specific Features

11. **Adolescent App features:** Journal, Mood, AI Chat, Dashboard, Channels, Counselor Chat
12. **Guardian App features:** Registration, Consent Management, Dashboard, Alerts, Counselor Messaging

---

## Key Configuration Files

### `melos.yaml`

```yaml
name: neuronet
packages:
  - apps/*
  - packages/*

scripts:
  analyze:
    exec: flutter analyze
  test:
    exec: flutter test
  build_runner:
    exec: dart run build_runner build --delete-conflicting-outputs
  clean:
    exec: flutter clean
  get:
    exec: flutter pub get
```

### App `pubspec.yaml` dependency (both apps)

```yaml
dependencies:
  neuronet_core:
    path: ../../packages/neuronet_core
```

---

## Verification Plan

### Automated Verification
1. **Melos bootstrap:** `melos bootstrap` succeeds with no errors
2. **Static analysis:** `melos run analyze` shows 0 errors
3. **Build runner:** `melos run build_runner` generates Freezed/Riverpod code with no errors
4. **Unit tests:** `melos run test` passes all existing tests
5. **Build check:** Both apps build for Android with `flutter build apk --debug`

### Manual Verification
1. Confirm `packages/neuronet_core/` exports compile and can be imported from both apps
2. Confirm each app launches on an Android emulator with the correct theme color
3. Confirm shared models serialize/deserialize correctly via unit tests

---

## User Review Required

> [!IMPORTANT]
> **Monorepo tool choice:** This plan uses **Melos** (industry-standard Flutter monorepo tool). An alternative is `dart pub workspace` (newer, Dart 3.6+). Melos is more mature and has better script orchestration. Are you okay with Melos?

> [!IMPORTANT]
> **Brick application strategy:** Mason bricks will scaffold the initial app structure, but shared code (models, API, auth, theme) will live in `neuronet_core` and be removed from individual apps to avoid duplication. This means some brick-generated files will be deleted or moved. Is this approach acceptable?

> [!IMPORTANT]
> **Scope:** This plan sets up the *architecture and shared foundation only* (Phases 1–2). Feature implementation (Phase 3) is a separate follow-up. Should I include Phase 3 feature scaffolding in this plan, or keep it as a separate pass?
