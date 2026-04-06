# NEURONET — Final Cross-Reference Analysis

**Date:** April 6, 2026  
**Scope:** PRD requirements vs. frontend implementation vs. backend API endpoints

---

## Executive Summary

The app implements **~70% of PRD requirements**. Core features (auth, journals, mood, dashboard, consent management, channels, alerts, counselor messaging) are structurally in place. The biggest gaps are:

- **AI chat is mock-only** — no backend integration
- **Consent types are fundamentally wrong** — 2 implemented vs 5 required
- **FCM/push notifications not wired up** — dependency present, zero code
- **All API paths lack the `/api/v1` prefix** the PRD specifies

---

## A. PRD Feature Coverage

### ✅ Fully Implemented

| PRD Ref | Feature | Implementation |
|---------|---------|---------------|
| FR-03, FR-05, FR-06, FR-07, FR-08 | Auth (login, activation, RBAC, logout) | Both apps: login/activation screens, `AuthController`, `AuthService`, token storage |
| FR-01, FR-02 | Adolescent Registration | Guardian: `RegistrationScreen` → `POST /auth/guardian/create-adolescent` |
| FR-16, FR-17 | Consent Management (grant/revoke) | Guardian: `ConsentScreen` with toggle switches |
| FR-21, FR-22 | Journal creation + mood recording | `NewJournalEntryScreen`, `MoodScreen` |
| FR-23 | Journal history + mood trends | `JournalHistoryScreen`, dashboard mood distribution |
| FR-43, FR-47 | Dashboards (both apps) | Both dashboards with mood trends, recent journals, alert summaries |
| FR-40, FR-41 | Channel browsing + interaction | `ChannelsScreen`, `ChannelDetailScreen`, reactions + comments |
| FR-34, FR-38 | Counselor chat (adolescent) | `CounselorChatScreen` + messaging provider |
| FR-37 | Counselor messages (guardian) | `CounselorMsgScreen` |
| FR-49, FR-50 | Guardian alerts | `AlertsScreen` with mark-viewed + resolve |
| FR-50 | Adolescent alerts | `AlertsScreen` with `getAdolescentAlerts()` |

### ❌ Not Implemented

| PRD Ref | Feature | Gap |
|---------|---------|-----|
| **FR-26 – FR-31** | **AI Chat** | **Fully mocked.** `MockDataService` for messages + responses. Backend endpoints (`/ai-chat/sessions`, `/ai-chat/sessions/{id}/messages`) exist but never called |
| **FR-49** | **Push Notifications (FCM)** | `firebase_messaging` is a dependency but **zero setup code** — no token registration, no handlers, no notification display |
| **FR-19** | **Adolescent Consent Status View** | **Zero consent code in adolescent app.** No screen, no provider, no route |
| **FR-15** | **Guardian Followed Pages View** | `GET /guardians/followed-pages` endpoint not implemented. No screen |
| **FR-10** | **Profile Update** | Both profile screens are read-only. No PUT call |
| FR-31 | AI redirect clinical questions | No detection logic for clinical/emergency queries |
| FR-42 | Channel content filtering | No auto-block for sensitive disclosures |
| FR-20 | Consent history audit log | Screen shows current toggles only, no historical log |
| Password reset | PRD acceptance criteria | No forgot/reset password flow |

### ⚠️ Partially Implemented

| PRD Ref | Feature | What's Done | What's Missing |
|---------|---------|-------------|----------------|
| FR-16, FR-17 | **Consent Types** | 2 types implemented (`shareAiSummaries`, `shareAlerts`) | PRD requires **5 types**: `JournalAnalysis`, `CounselorCommunication`, `DataSharing`, `AlertNotification`, `ChannelParticipation`. **3 types completely missing** |
| FR-34 | Counselor chat consent gate | Chat works | **No consent check before enabling chat.** PRD requires `ConsentStatus = Granted` for `CounselorCommunication` before chat is accessible |
| NFR-22 | Offline behavior | `NetworkFailure` exists, services return `Result.failure` | No explicit connectivity check, no "you are offline" UI messaging |

---

## B. Frontend Endpoints vs Backend API

### Critical Path Mismatch

**All frontend endpoints are missing the `/api/v1` prefix** defined in the PRD:

| PRD Endpoint | Frontend Endpoint | Status |
|---|---|---|
| `POST /api/v1/auth/login` | `POST /auth/login` | ❌ Missing prefix |
| `POST /api/v1/auth/activate` | `POST /auth/activate-account` | ❌ Missing prefix + path differs |
| `GET/PUT /api/v1/users/me` | `GET /auth/me` | ❌ Missing prefix + path completely different |
| `POST /api/v1/journals` | `POST /journals/` | ❌ Missing prefix |
| `POST /api/v1/chat/ai` | `POST /ai-chat/sessions/{id}/messages` | ❌ Completely different structure |
| `POST /api/v1/channels/{id}/join` | `POST /channels/{id}/subscribe` | ❌ `/join` vs `/subscribe` |
| `GET /api/v1/consents` | `GET /consents/{email}` | ❌ Different structure |
| `PUT /api/v1/consent/{id}` | `POST /consents/{email}` | ❌ Method differs (PUT vs POST) |

> **⚠️ If the backend deploys with the `/api/v1` prefix, every API call will 404.** This needs verification against the actual deployed backend.

### Extra Frontend Endpoints (not in PRD)

| Endpoint | Purpose |
|---|---|
| `POST /auth/register` | Guardian self-registration (signup) — PRD only mentions activation |
| `GET /auth/guardian/pending-adolescents` | List pending adolescents |
| `GET /ai-chat/sessions` | Defined but never called |
| `GET /consents/me` | Defined but never called |
| `GET /alerts/counselor/me` | Defined but never called |
| `GET /journals/adolescent/{id}` | Defined but never called |
| `GET /educational-pages/` | Educational library browsing (goes beyond PRD) |
| `GET /educational/recommendations/adolescent/{id}` | AI recommendations |

---

## C. Data Model Compliance

### ✅ Matches

| Model | PRD Values | App Values | Status |
|---|---|---|---|
| **Mood Types** | Happy, Sad, Anxious, Calm, Stressed, Neutral, Excited, Tired, Angry, Hopeful | All 10 present | ✅ |
| **Consent Status** | Granted, Revoked, Expired | All 3 present | ✅ |
| **Alert Severity** | Low, Medium, High | All 3 present | ✅ |
| **Alert Types** | EmotionalPattern, MoodDrop, JournalFrequency, ContentFlag | All 4 present | ✅ |
| **Message Types** | AI_Chat, Counselor_Chat, Guardian_Chat | All 3 present (snake_case) | ✅ |

### ❌ Mismatches

| Model | PRD Values | App Values | Status |
|---|---|---|---|
| **Consent Types** | `JournalAnalysis`, `CounselorCommunication`, `DataSharing`, `AlertNotification`, `ChannelParticipation` | `shareAiSummaries`, `shareAlerts` | ❌ **COMPLETE MISMATCH** |

The app's 2 consent types don't match any of the PRD's 5. `shareAiSummaries` loosely maps to `JournalAnalysis` and `shareAlerts` to `AlertNotification`, but `CounselorCommunication`, `DataSharing`, and `ChannelParticipation` are **entirely absent**.

---

## D. Screen Inventory

### Adolescent App — 12 of 13 Screens

| # | PRD Screen | Status |
|---|---|---|
| 1 | Login / Account Activation | ✅ |
| 2 | Dashboard (Home) | ✅ |
| 3 | Journal Entry | ✅ |
| 4 | Journal History | ✅ |
| 5 | Mood Recording | ✅ |
| 6 | AI Chat | ✅ (screen exists, mock data) |
| 7 | Emotional Trends Dashboard | ✅ (merged with #2) |
| 8 | Counselor Chat | ✅ |
| 9 | Channel Browser | ✅ |
| 10 | Channel Detail | ✅ |
| 11 | Profile | ✅ |
| **12** | **Consent Status (read-only)** | **❌ MISSING** |
| 13 | Alert History | ✅ |

### Guardian App — 8 of 9 Screens

| # | PRD Screen | Status |
|---|---|---|
| 1 | Login | ✅ |
| 2 | Dashboard | ✅ |
| 3 | Adolescent Registration | ✅ |
| 4 | Consent Management | ✅ |
| 5 | Aggregated Insights | ✅ (merged with #2) |
| 6 | Alert History | ✅ |
| 7 | Counselor Messages | ✅ |
| 8 | Profile | ✅ |
| **9** | **Followed Pages View** | **❌ MISSING** |

### Extra Screens (bonus, not required)

- Educational library, page detail, recommendations screens
- Guardian sign-up screen
- Adolescent detail screen (guardian)
- Journal detail screen

---

## E. Priority Action Items

| Priority | Issue | Impact |
|---|---|---|
| 🔴 **P0** | AI chat uses mock data — no backend integration | Core P0 MVP feature non-functional |
| 🔴 **P0** | Consent types mismatch (2 vs 5) | Guardian can't manage counselor communication, data sharing, or channel participation consent |
| 🔴 **P0** | All API paths missing `/api/v1` prefix | Will 404 if backend enforces prefix |
| 🔴 **P0** | FCM not wired up | No alert notifications, no push messages |
| 🟡 **P1** | Adolescent consent status screen missing | Teens can't see what guardian has approved |
| 🟡 **P1** | Counselor chat has no consent gate | Chat accessible without `CounselorCommunication` consent |
| 🟡 **P1** | Profile update not implemented | FR-10 requirement gap |
| 🟡 **P1** | Guardian followed-pages screen missing | FR-15 requirement gap |
| 🟢 **P2** | Password reset flow absent | PRD acceptance criteria gap |
| 🟢 **P2** | Channel content filtering absent | FR-42 gap |
| 🟢 **P2** | Consent history audit log absent | FR-20 gap |
| 🟢 **P2** | Dead endpoints (`/consents/me`, `/alerts/counselor/me`, `/ai-chat/sessions`) | Cleanup needed |
