# NEURONET – Product Requirements Document (PRD)

## Adolescent & Guardian Mobile Applications (Flutter)

**Project:** NEURONET – AI-Driven Early Detection and Support System for Adolescent Mental Health  
**Platform:** Android (Flutter)  
**Derived From:** SRS v1.0 (Dec 19, 2025) & SDD v1.0 (Dec 19, 2025)  
**Version:** 1.0  
**Date:** March 7, 2026

---

## 1. Product Overview

NEURONET is a **non-clinical, privacy-first** digital platform that helps adolescents aged 13–17 engage in emotional self-awareness through journaling, mood tracking, and consent-based support. The system uses AI-driven sentiment analysis to detect emotional trends and alert guardians/counselors when predefined thresholds are met — **without** providing diagnosis, therapy, or medical advice.

This PRD covers the **two Flutter mobile applications**:

| App | Primary User | Purpose |
|---|---|---|
| **Adolescent App** | Teens aged 13–17 | Journaling, mood tracking, AI chat, personal dashboard, counselor communication, channel browsing |
| **Guardian App** | Parents / Legal Caretakers | Adolescent registration, consent management, aggregated insights, alerts, counselor communication |

> [!IMPORTANT]
> NEURONET is explicitly **non-clinical**. The AI never provides diagnosis, therapy, advice, or treatment recommendations. All AI outputs are presented as "indicative trends," not conclusions.

---

## 2. User Personas

### 2.1 Adolescent User
- **Age:** 13–17 years
- **Digital literacy:** Basic to moderate
- **Key traits:** Highly sensitive to privacy, trust, and autonomy; may be hesitant to seek help traditionally
- **Needs:** A non-judgmental, emotionally safe interface; assurance that journals are private from guardians; clear AI limitations; ability to view personal emotional trends

### 2.2 Guardian User
- **Role:** Parent or legal caretaker
- **Digital literacy:** Varying levels
- **Key traits:** Strong concern for adolescent safety; prefers concise, clearly presented information
- **Needs:** Register adolescents; manage consent; receive summarized alerts (never raw journal data); communicate with counselors

---

## 3. System Architecture Context

The mobile apps sit within a layered architecture:

```
┌─────────────────────────────────────────────────┐
│         Presentation Layer (Flutter Apps)        │
├─────────────────────────────────────────────────┤
│    Application Layer (Django/FastAPI – REST)     │
├─────────────────────────────────────────────────┤
│        AI Processing Layer (NLP/Sentiment)       │
├─────────────────────────────────────────────────┤
│  Data Layer (PostgreSQL + MongoDB)               │
└─────────────────────────────────────────────────┘
```

- **API:** RESTful over HTTPS, JSON payloads, JWT (Bearer token) authentication
- **Push Notifications:** Firebase Cloud Messaging (FCM)
- **Backend:** Django / FastAPI (Python)
- **Databases:** PostgreSQL (structured) + MongoDB (journals, chat, AI results)

---

## 4. Adolescent App – Feature Requirements

### 4.1 Account Activation & Authentication

| Ref | Requirement | Priority |
|-----|-------------|----------|
| FR-03 | Activate account by setting a personal password using guardian-provided credentials (activation code) | P0 |
| FR-05 | Authenticate via email + password | P0 |
| FR-06 | Enforce role-based access (adolescent role) | P0 |
| FR-07 | Deny access on authentication failure | P0 |
| FR-08 | Secure logout | P0 |

**Screens:** Login Screen (email field, password field, login button, forgot password link, activation code entry for new users)

**Acceptance Criteria:**
- Adolescent cannot self-register; must use activation code from guardian
- Failed login shows clear, non-alarming error message
- Session token (JWT) stored securely; auto-expire on inactivity
- Password reset flow via email

---

### 4.2 Profile Management

| Ref | Requirement | Priority |
|-----|-------------|----------|
| FR-09 | View profile information | P1 |
| FR-10 | Update editable profile details (contact info, preferences) | P1 |
| FR-11 | Restrict modification of sensitive identity info (role, guardian link) | P0 |

**Acceptance Criteria:**
- Profile screen shows name, email, account status
- Users can update permitted fields only
- Role and guardian relationship are read-only

---

### 4.3 Journaling & Mood Reflection

| Ref | Requirement | Priority |
|-----|-------------|----------|
| FR-21 | Create personal journal entries | P0 |
| FR-22 | Record mood reflections at any time | P0 |
| FR-23 | View journal history and mood trends | P0 |
| FR-24 | Securely store journal/mood data | P0 |
| FR-25 | Prevent guardians and counselors from accessing raw journal content | P0 |

**Screens:**
- **Journal Entry Screen:** Date/time display, mood selector, text area with 5,000-character counter, privacy assurance notice, save button
- **Mood Recording Screen:** Emoji-based mood selection (Happy, Sad, Anxious, Calm, Stressed, Neutral, Excited, Tired, Angry, Hopeful), optional intensity (1–5), optional context notes, timestamp
- **Journal History:** Chronological list, read-only, filterable by date range

**Acceptance Criteria:**
- Journal entries are immutable after submission (cannot edit or delete)
- Mood entries use predefined enum values
- Minimum 10 characters for AI analysis eligibility
- Privacy notice clearly states: "Your journal entries are private and cannot be read by guardians or counselors"
- Data stored encrypted in MongoDB

---

### 4.4 AI Chat Interface

| Ref | Requirement | Priority |
|-----|-------------|----------|
| FR-26 | Provide AI chat interface | P0 |
| FR-27 | AI responds to system-related and informational queries | P0 |
| FR-28 | Emotionally neutral and supportive responses | P0 |
| FR-29 | AI shall NOT provide medical advice, therapy, diagnosis, or treatment | P0 |
| FR-30 | Redirect advice-seeking or clinical questions to human counselors | P0 |
| FR-31 | Recommend relevant counselor pages on medium-risk patterns | P1 |

**Screens:** AI Chat Interface — chat bubble UI with "NEURO Assistant" branding, informational disclaimer, suggestion chips for common topics, message input

**Acceptance Criteria:**
- Clear disclaimer visible: "I'm an informational assistant. I cannot provide medical advice or therapy."
- Clinical/emergency questions trigger redirection message: "For personal support, please reach out to your assigned counselor."
- Responses use non-judgmental, supportive language
- AI does not process emojis, images, audio, or video
- Input limited to English, max 5,000 characters per message

---

### 4.5 Personal Dashboard

| Ref | Requirement | Priority |
|-----|-------------|----------|
| FR-43 | Adolescent personal dashboard with emotional trends | P0 |
| FR-47 | Clear visual elements (charts, summaries) | P0 |
| FR-33 | Present non-diagnostic emotional indicators only | P0 |

**Screens:** Dashboard — personalized greeting, mood selector (quick log), recent journal entries summary, emotional trend charts (7/14/30 days)

**Acceptance Criteria:**
- Trends shown as aggregated visual summaries, never raw sentiment scores
- No alerts or counselor-specific information displayed
- Time-range filters: 7, 14, 30 days
- Confidence disclaimer on AI-generated insights
- Data is read-only

---

### 4.6 Counselor Communication

| Ref | Requirement | Priority |
|-----|-------------|----------|
| FR-34 | Communicate with counselor ONLY after guardian approval | P0 |
| FR-38 | Secure message storage | P0 |

**Screens:** Counselor Chat — message list, input field, approval status indicator

**Acceptance Criteria:**
- Chat is disabled until `ConsentStatus = Granted` for `CounselorCommunication` type
- Messages stored encrypted in MongoDB
- Asynchronous messaging (not real-time by default)
- Clear indicator showing consent status
- No audio/video communication

---

### 4.7 Consent Status Viewing

| Ref | Requirement | Priority |
|-----|-------------|----------|
| FR-19 | View current consent status | P1 |

**Acceptance Criteria:**
- Read-only view of all consent records granted by guardian
- Shows consent types: JournalAnalysis, CounselorCommunication, DataSharing, AlertNotification, ChannelParticipation
- Shows status: Granted / Revoked / Expired

---

### 4.8 Counselor Channels & Group Interaction

| Ref | Requirement | Priority |
|-----|-------------|----------|
| FR-40 | Join approved counselor channels | P1 |
| FR-41 | React to and comment on counselor posts | P1 |
| FR-42 | Restrict sensitive/personal disclosures in channels | P1 |
| FR-14 | Follow counselor educational pages | P1 |

**Screens:** Channel Browser — channel cards, follow buttons, content preview; Channel Detail — posts, reactions (predefined emoticons), comments

**Acceptance Criteria:**
- Joining channels does NOT require guardian consent
- Content filters automatically block personal/sensitive disclosures
- Interactions logged and moderated
- Channel interactions not included in guardian dashboards or alert systems

---

### 4.9 Alerts Viewing

| Ref | Requirement | Priority |
|-----|-------------|----------|
| FR-50 | View alert history (limited, self-facing) | P2 |

**Acceptance Criteria:**
- Adolescents can see non-diagnostic summaries of their own trend alerts
- Alerts never use language implying diagnosis or emergency

---

## 5. Guardian App – Feature Requirements

### 5.1 Authentication

| Ref | Requirement | Priority |
|-----|-------------|----------|
| FR-05 | Authenticate via email + password | P0 |
| FR-06 | Enforce role-based access (guardian role) | P0 |
| FR-07 | Deny access on authentication failure | P0 |
| FR-08 | Secure logout | P0 |

**Screens:** Login Screen (same flow as adolescent, role determined server-side)

---

### 5.2 Adolescent Registration

| Ref | Requirement | Priority |
|-----|-------------|----------|
| FR-01 | Guardian initiates and completes adolescent registration | P0 |
| FR-02 | Provide valid identification and contact information | P0 |

**Screens:** Registration Form — adolescent name, date of birth, email, relationship type (Parent/LegalGuardian/Other), initial consent configuration checkboxes, submit button

**Acceptance Criteria:**
- Generates an activation code for the adolescent
- Guardian is automatically linked as `is_primary = true`
- Validates: email format, required fields, no duplicate accounts (DR-01, DR-02, DR-07)
- Only primary guardians can manage consent (business rule)

---

### 5.3 Consent Management

| Ref | Requirement | Priority |
|-----|-------------|----------|
| FR-16 | Guardian consent required before data analysis or sharing | P0 |
| FR-17 | Grant or revoke consent for counselor access to summarized data | P0 |
| FR-18 | Enforce consent validation before any data access | P0 |
| FR-20 | Record consent history for auditing | P0 |

**Screens:** Consent Management — toggle switches per consent type, consent history log, save button

**Consent Types:**
- `JournalAnalysis` — Allow AI to analyze journal entries
- `CounselorCommunication` — Allow adolescent–counselor chat
- `DataSharing` — Share summarized trends with counselor
- `AlertNotification` — Send alerts to guardian
- `ChannelParticipation` — Allow channel participation

**Acceptance Criteria:**
- Toggle switches for each consent type
- Revocation takes effect immediately
- Consent history shows all past grant/revoke actions with timestamps
- Only primary guardian can manage consent (enforced server-side)

---

### 5.4 Aggregated Dashboard & Insights

| Ref | Requirement | Priority |
|-----|-------------|----------|
| FR-44 | Aggregated dashboard with alerts, subject to consent | P0 |
| FR-47 | Clear visual elements | P0 |

**Screens:** Guardian Dashboard — adolescent profile cards, alert summary, weekly mood trend chart, activity statistics, quick-access buttons

**Acceptance Criteria:**
- Shows aggregated emotional trends, NEVER raw journal entries or AI chat content
- Dashboard data visibility controlled by active consent settings
- Consent revocation immediately hides corresponding data
- Trends displayed over 7/14/30 day periods
- Non-diagnostic language throughout

---

### 5.5 Alert History

| Ref | Requirement | Priority |
|-----|-------------|----------|
| FR-49 | Receive notifications based on consent settings | P0 |
| FR-50 | View alert history | P0 |
| FR-51 | Alerts avoid diagnostic or emergency language | P0 |

**Screens:** Alert History — chronological alert list, severity filters, mark-as-read

**Acceptance Criteria:**
- Alerts include: timestamp, severity (Low/Medium/High), non-diagnostic description
- Alerts NEVER imply diagnosis, urgency, or required action
- Push notifications via FCM for new alerts
- Filter by severity and date range

---

### 5.6 Counselor Communication

| Ref | Requirement | Priority |
|-----|-------------|----------|
| FR-37 | Communicate with counselor without exposing private adolescent content | P1 |

**Screens:** Counselor Messages — message thread, compose button, attachments

**Acceptance Criteria:**
- Guardian can message the assigned counselor
- Messages never expose raw journal content or adolescent–counselor private chats
- Stored encrypted in MongoDB

---

### 5.7 Profile Management

| Ref | Requirement | Priority |
|-----|-------------|----------|
| FR-09 | View profile information | P1 |
| FR-10 | Update editable profile details | P1 |
| FR-15 | View which counselor pages adolescent is following | P1 |

**Acceptance Criteria:**
- Guardian can see list of counselor pages followed by each linked adolescent
- List shows page titles, counselor names, follow dates
- No access to page content or adolescent interactions within channels

---

## 6. Shared / Cross-Cutting Requirements

### 6.1 Security & Data Protection

| Ref | Requirement |
|-----|-------------|
| FR-56 | Role-based access control (RBAC) for all features |
| FR-57 | Sensitive data accessible only to authorized users |
| FR-58 | Log significant system actions for auditing |
| NFR-17 | Authentication required before any access |
| NFR-18 | Strict RBAC enforcement |
| NFR-19 | All sensitive data encrypted in storage and transmission |
| NFR-20 | Restrict access to private content (journals, chats) |
| NFR-22 | Passwords securely stored using bcrypt hashing |

**Implementation Notes:**
- JWT tokens in HTTP `Authorization: Bearer <token>` header
- HTTPS/TLS 1.3 for all API communication
- Encrypted storage in MongoDB for journals, chat messages
- PostgreSQL TDE for structured data
- Session auto-expire on inactivity

### 6.2 Performance

| Ref | Target |
|-----|--------|
| NFR-06 | API response < 2 seconds for 95% of interactive requests |
| NFR-07 | Support 100+ concurrent active users during pilot |
| NFR-08 | AI results available within 24 hours of submission |
| NFR-10 | Database operations < 500ms for 95% of transactions |

### 6.3 Usability

| Ref | Target |
|-----|--------|
| NFR-11 | Intuitive interface for adolescents |
| NFR-12 | Clear, simple, supportive language (no technical jargon) |
| NFR-13 | Consistent navigation and layout |
| NFR-14 | Minimize steps for common tasks |
| NFR-15 | Non-stigmatizing presentation of insights/alerts |

### 6.4 Push Notifications (FCM)

- New alerts (guardian, adolescent)
- New counselor messages
- Consent status changes
- Channel post notifications (based on preference: All / Important / None)

### 6.5 Offline Behavior
- System requires internet connectivity for all major features
- Graceful error messaging when offline
- No offline data caching or sync (MVP constraint)

---

## 7. API Endpoints (Key Mobile Endpoints)

| Feature | Method | Endpoint | Notes |
|---------|--------|----------|-------|
| Login | POST | `/api/v1/auth/login` | Returns JWT token + role |
| Account Activation | POST | `/api/v1/auth/activate` | Activation code + new password |
| Profile | GET/PUT | `/api/v1/users/me` | View/update profile |
| Journal - Create | POST | `/api/v1/journals` | Title, content, mood_id |
| Journal - List | GET | `/api/v1/journals` | Paginated, date-filtered |
| Mood - Record | POST | `/api/v1/moods` | mood_type, intensity, context_notes |
| Mood - History | GET | `/api/v1/moods` | Paginated |
| AI Chat | POST | `/api/v1/chat/ai` | Message content |
| Dashboard Trends | GET | `/api/v1/dashboard/trends` | Period: 7d/14d/30d |
| Consent - View | GET | `/api/v1/consents` | Adolescent views status |
| Consent - Manage | PUT | `/api/v1/consent/{id}` | Guardian grants/revokes |
| Register Adolescent | POST | `/api/v1/guardians/register-adolescent` | Guardian-only |
| Alerts | GET | `/api/v1/alerts` | Filterable by severity |
| Chat Request | POST | `/api/v1/chat/request` | Counselor chat initiation |
| Messages | GET/POST | `/api/v1/chat/messages` | Counselor/Guardian chat |
| Channels | GET | `/api/v1/channels` | Browse available channels |
| Channel Join | POST | `/api/v1/channels/{id}/join` | No guardian consent needed |
| Channel Interact | POST | `/api/v1/channels/{id}/posts/{pid}/interact` | React/Comment |
| Followed Pages | GET | `/api/v1/guardians/followed-pages` | Guardian views teen's follows |

**Error Handling:** All errors follow standardized JSON schema:
```json
{
  "status": 400,
  "error_code": "BAD_REQUEST",
  "message": "Human-readable message",
  "details": "Detailed explanation",
  "timestamp": "ISO-8601"
}
```

---

## 8. Data Models (Mobile-Relevant)

### Mood Types Enum
`Happy` | `Sad` | `Anxious` | `Calm` | `Stressed` | `Neutral` | `Excited` | `Tired` | `Angry` | `Hopeful`

### Consent Types Enum
`JournalAnalysis` | `CounselorCommunication` | `DataSharing` | `AlertNotification` | `ChannelParticipation`

### Consent Status Enum
`Granted` | `Revoked` | `Expired`

### Alert Severity Enum
`Low` | `Medium` | `High`

### Alert Types Enum
`EmotionalPattern` | `MoodDrop` | `JournalFrequency` | `ContentFlag`

### Message Types Enum
`AI_Chat` | `Counselor_Chat` | `Guardian_Chat`

---

## 9. UI/UX Design Guidelines

### Color Scheme
| Role | Primary Color | Usage |
|------|--------------|-------|
| Adolescent | **Green** | All adolescent-facing screens |
| Guardian | **Pink** | All guardian-facing screens |

### Navigation Pattern (Mobile)
- Bottom tab bar for primary navigation
- Back button for hierarchical navigation
- Pull-to-refresh for data updates
- Swipe gestures for quick actions

### Key Design Principles
1. **Emotional Safety** — Non-judgmental language, calming UI, no alarming colors for alerts
2. **Privacy Awareness** — Consent status prominently displayed, privacy notices on sensitive screens
3. **Simplicity** — Minimal interaction steps, clear visual hierarchy, age-appropriate complexity
4. **Supportive Communication** — Encouraging messages, constructive error messages
5. **Accessibility** — Readable fonts, appropriate contrast, touch-friendly elements

### Screen Inventory

#### Adolescent App Screens
1. Login / Account Activation
2. Dashboard (Home)
3. Journal Entry
4. Journal History
5. Mood Recording
6. AI Chat
7. Personal Emotional Trends Dashboard
8. Counselor Chat
9. Channel Browser
10. Channel Detail (posts, reactions, comments)
11. Profile
12. Consent Status (read-only)
13. Alert History

#### Guardian App Screens
1. Login
2. Dashboard (adolescent card overview)
3. Adolescent Registration
4. Consent Management
5. Aggregated Insights
6. Alert History
7. Counselor Messages
8. Profile
9. Followed Pages View

---

## 10. Business Rules Summary

| ID | Rule | Impact |
|----|------|--------|
| BR-01 | No medical diagnosis, therapy, or treatment | Ethical |
| BR-02 | Non-clinical awareness platform only | Scope |
| BR-03 | Users informed of purpose & limitations during onboarding | Usability |
| BR-04 | Adolescent journal content NOT accessible to guardians | Privacy |
| BR-05 | Adolescent accounts registered ONLY by guardians | Registration |
| BR-06 | Data shared with counselors/guardians ONLY after consent | Privacy |
| BR-07 | Adolescents can revoke consent at any time | Functional |
| BR-08 | Counselor–adolescent communication requires guardian approval | Access Control |
| BR-13 | AI analyzes content ONLY for sentiment and trend detection | Functional |
| BR-14 | AI provides informational responses about system usage and well-being only | Usability |
| BR-15 | AI refuses advice/therapy/diagnosis requests, redirects to counselors | Ethical |
| BR-16 | AI outputs presented as indicators/trends, NOT definitive conclusions | Functional |
| BR-18 | Counselor–guardian communication shall NOT expose private journal data | Privacy |

---

## 11. MVP Scope & Prioritization

### P0 — Must Have (MVP)
- Account activation & authentication (both apps)
- Journal entry creation (adolescent)
- Mood recording (adolescent)
- AI chat with safety guardrails (adolescent)
- Personal dashboard with trend visualization (adolescent)
- Adolescent registration (guardian)
- Consent management (guardian)
- Aggregated dashboard (guardian)
- Alert notifications via FCM (guardian)
- RBAC and JWT authentication
- Encrypted data transmission (HTTPS/TLS 1.3)

### P1 — Should Have
- Counselor chat (adolescent, with guardian consent)
- Profile management (both apps)
- Channel browsing and interaction (adolescent)
- Counselor messaging (guardian)
- Followed pages view (guardian)
- Consent status viewing (adolescent)

### P2 — Nice to Have
- Alert history viewing (adolescent)
- Advanced trend filtering
- Mood intensity tracking with context notes
- Channel notification preferences

---

## 12. Technical Constraints & Notes

| Constraint | Detail |
|-----------|--------|
| **Platform** | Android OS 8.0+ (primary target for MVP) |
| **Framework** | Flutter (Dart) |
| **Minimum Device** | Dual-core, 2GB RAM, 200MB free storage |
| **API** | RESTful, JSON, JWT auth |
| **AI Limitations** | English only; no emoji/image/audio/video processing; 75–85% accuracy for sentiment polarity; no sarcasm detection |
| **Journal Analysis** | Processed once on submission; batch trend analysis runs nightly (7/14/30 day windows) |
| **Availability Target** | 99.5% uptime during expected usage periods |
| **No Offline Mode** | All features require internet connectivity |
| **Non-Clinical** | No diagnosis, therapy, clinical advice, or emergency intervention |

---

## 13. Data Retention Policy

| Data Type | Retention Period |
|-----------|-----------------|
| User accounts | Active use + 1 year after deactivation |
| Journal entries & mood records | Anonymized after 2 years; deleted after 5 years |
| Chat messages | 3 years from last message |
| Consent records & audit logs | 7 years |
| Alert history | 2 years; aggregated thereafter |
| Backups | Encrypted; purged after 90 days |

---

## 14. Success Metrics

| Metric | Target |
|--------|--------|
| Adolescent weekly engagement (journal + mood entries) | ≥ 3 interactions/week per active user |
| Guardian consent completion rate | ≥ 90% of registered adolescents have active consent |
| API response time (p95) | < 2 seconds |
| Alert delivery latency | < 24 hours from trend detection |
| App crash rate | < 1% of sessions |
| User satisfaction (adolescent) | ≥ 4.0/5.0 in usability testing |
