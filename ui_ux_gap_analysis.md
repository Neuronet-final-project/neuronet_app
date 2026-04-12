# NEURONET — UI/UX Gap Analysis

> **Date:** April 8, 2026  
> **Scope:** `apps/adolescent_app` + `apps/guardian_app` + `packages/neuronet_core`  
> **Method:** Full screen-by-screen audit of layout, navigation, widgets, theme, states, forms, accessibility, animations, and domain-specific UX patterns.

---

## Table of Contents

- [Shared Issues (Both Apps)](#shared-issues-both-apps)
- [Adolescent App — Unique Gaps](#adolescent-app--unique-gaps)
- [Guardian App — Unique Gaps](#guardian-app--unique-gaps)
- [Adolescent App — Detailed Screen Analysis](#adolescent-app--detailed-screen-analysis)
- [Guardian App — Detailed Screen Analysis](#guardian-app--detailed-screen-analysis)
- [Navigation Flow Analysis](#navigation-flow-analysis)
- [Widget Patterns & Consistency](#widget-patterns--consistency)
- [Theme Usage](#theme-usage)
- [Empty / Loading / Error States Audit](#empty--loading--error-states-audit)
- [Form Inputs & Validation UX](#form-inputs--validation-ux)
- [Accessibility Audit](#accessibility-audit)
- [Animations & Transitions](#animations--transitions)
- [Missing Domain-Specific UX Patterns](#missing-domain-specific-ux-patterns)
- [Recommended Next Steps](#recommended-next-steps)

---

## Shared Issues (Both Apps)

| Priority | Issue | Impact |
|----------|-------|--------|
| 🔴 P0 | **No password visibility toggles** on any auth form | Frustrating login experience, especially for less tech-savvy users |
| 🔴 P0 | **No "Forgot Password" flow** | No recovery path for lost credentials |
| 🔴 P0 | **Inconsistent error states** — raw `Text()` instead of `NeuroErrorWidget` on many screens | Poor, inconsistent error UX |
| 🔴 P0 | **No pull-to-refresh** on most data screens | Users can't manually refresh stale data |
| 🔴 P0 | **No onboarding/tutorial flow** for first-time users | Users dropped into app with no guidance |
| 🟡 P1 | **Only 2 consent types** instead of PRD's 5 | Feature incomplete |
| 🟡 P1 | **Profile has no editing capability** | Incomplete feature |
| 🟡 P1 | **No confirmation dialogs** for destructive actions (logout, resolve alert, unlink) | Accidental data loss |
| 🟡 P1 | **No offline/connectivity indicator** | Users unaware when connection is lost |
| 🟢 P2 | **No Hero/shared element transitions** on list-to-detail navigation | Jarring transitions |
| 🟢 P2 | **No dark mode support** | Missing expected feature |
| 🟢 P2 | **Hardcoded colors bypassing theme** (`Colors.grey`, `Colors.blue`, etc.) | Brand inconsistency |
| 🟢 P2 | **No `Semantics` widgets** anywhere | Poor screen reader support |
| 🟢 P2 | **No skeleton loaders** — only bare spinners | Poor perceived performance |
| 🟢 P2 | **Debug `print()` statements** in router redirect | Production code quality |

---

## Adolescent App — Unique Gaps

| Priority | Issue | Impact |
|----------|-------|--------|
| 🔴 P0 | **Counselor Chat is a stub** (12 lines, placeholder text) | Core mental health feature missing |
| 🔴 P0 | **No crisis/safety resources** anywhere in the app | Safety risk for vulnerable teens |
| 🔴 P0 | **AI Chat uses mock data** — no backend integration | Prominent feature non-functional |
| 🔴 P0 | **2 routes crash on deep link** (`/alerts/:id`, `/learn/:slug` use `state.extra`) | Broken navigation |
| 🟡 P1 | **Journal has no auto-save** — data lost on crash/navigate | Data loss risk |
| 🟡 P1 | **Journal has no edit/delete** | Incomplete feature |
| 🟡 P1 | **4 screens silently swallow errors** (Dashboard alerts, Dashboard learning, Mood history) | Users unaware of failures |
| 🟡 P1 | **Bottom nav tab re-tap doesn't scroll to top** | Navigation frustration |
| 🟡 P1 | **Notification bell is a dead button** (`onPressed: () {}`) | Broken affordance |
| 🟡 P1 | **No mood trend visualization** — `NeuroTrendChart` exists but unused | Missing key insight feature |
| 🟢 P2 | **Inconsistent AppBar patterns** (6 different styles across screens) | Visual inconsistency |
| 🟢 P2 | **Border radius varies** (12/16/20/24px with no system) | Visual inconsistency |
| 🟢 P2 | **WCAG contrast failures** — placeholder text (~2.1:1), AI Chat empty state (~2.9:1) | Accessibility failure |
| 🟢 P2 | **No time-based greeting** on dashboard ("Good morning" etc.) | Missed engagement opportunity |
| 🟢 P2 | **No breathing/calming exercises** | Missing standard teen mental health app feature |

---

## Guardian App — Unique Gaps

| Priority | Issue | Impact |
|----------|-------|--------|
| 🔴 P0 | **Messages tab is broken** — `adolescentId: ''`, shows "no counselor" screen | Bottom nav tab non-functional |
| 🔴 P0 | **No conversation list** for guardian-counselor messages | Can't choose which adolescent's counselor to message |
| 🔴 P0 | **SignUp SnackBar styling inconsistent** — raw red full-width vs floating styled on other screens | Visual inconsistency |
| 🟡 P1 | **No "Followed Pages" view** (PRD FR-15) | Missing PRD requirement |
| 🟡 P1 | **No unread alert badge** on bottom nav tab | No visual indicator of new alerts |
| 🟡 P1 | **No consent history/audit log** (PRD FR-20) | Missing PRD requirement |
| 🟡 P1 | **No date range filter for alerts** (PRD FR-51) | Incomplete filtering |
| 🟡 P1 | **Adolescent detail screen shows no mood/alert summary** | Missing "aggregated insights" for specific child |
| 🟡 P1 | **Notification toggles are no-ops** (`onChanged: (val) {}`) | Fake settings |
| 🟡 P1 | **"Unlink Account" button is a TODO** | Incomplete feature |
| 🟢 P2 | **Doesn't use `NeuroAlertCard`** from shared package — reimplements inline | Duplicated, less polished code |
| 🟢 P2 | **`NeuroCard`/`NeuroDashboardCard` not used** — private widgets per screen | Underutilizing shared library |
| 🟢 P2 | **Dashboard greeting is static** ("Good Morning," never changes) | Missed personalization |
| 🟢 P2 | **"Risk Level: HIGH" language** may violate PRD's "avoid clinical language" requirement | Tone mismatch with PRD |
| 🟢 P2 | **No multi-adolescent consolidated view** | Parents with multiple teens can't see all status at once |

---

## Adolescent App — Detailed Screen Analysis

### Dashboard Screen
- **Strengths:** Pull-to-refresh, clear sectioning, FAB for AI Assistant.
- **Issues:**
  - Visual overload — 6+ sections in one scroll view (Material 3 recommends 3–4).
  - Inconsistent card patterns — 4 different card styles for similar content.
  - `_StatCard` uses hard-coded `Colors.blue/orange/green/red` — breaks brand.
  - `_buildRecentJournals` cards have empty `onTap: () {}` — broken interaction.
  - Hard-coded "Active Streak: 3" mock data.
  - Two notification icons in AppBar; second has empty `onPressed`.

### Login Screen
- **Strengths:** Clean layout, proper validation, loading state, floating SnackBar.
- **Issues:** No password visibility toggle, naive email validator, no "Forgot Password", no haptic feedback.

### Activation Screen
- **Strengths:** Privacy tip card, password match validation, success SnackBar.
- **Issues:** 4 fields without progressive disclosure, no password strength indicator, no show/hide toggle, hard-coded activation code hint.

### Journal History Screen
- **Strengths:** Proper empty state with action button, FAB, pull-to-refresh.
- **Issues:** Redundant AppBar refresh icon, plain `Text()` error state (no `NeuroErrorWidget`, no retry), no search/filter, no date grouping headers.

### Journal Detail Screen
- **Strengths:** Large emoji + mood header, "End-to-End Encrypted" badge, readable content.
- **Issues:** `firstWhere` throws raw exception on not found, raw `toString()` date format, no edit/delete, no scroll position preservation on back.

### New Journal Entry Screen
- **Strengths:** Bottom mood toolbar, character counter, privacy notice, `autofocus: true`.
- **Issues:** **No auto-save** (critical for journaling), title looks static, validation uses disruptive SnackBar instead of inline, no "skip" affordance for mood, no attachment support.

### Mood Screen
- **Strengths:** 3-column grid, intensity slider, notes field, success view.
- **Issues:** Success view has no clear "continue" action, reset button has no confirmation (dangerously wipes data), error in mood history silently swallowed, intensity slider lacks color gradient feedback.

### AI Chat Screen
- **Strengths:** Typing indicator, quick prompts, proper bubble alignment, auto-scroll.
- **Issues:** **ENTIRELY MOCK DATA**, info button is dead, no AI disclaimer, no crisis/safety escalation, error view hard-coded to network icon, hacky scroll approach, no message persistence.

### Channels Screen
- **Strengths:** Clean list, pull-to-refresh, follow toggle.
- **Issues:** Plain `Text()` error state (no retry), **no empty state**, small follow toggle (easy to mis-tap), no search/filter, "Counselor Channels" label unclear for teens.

### Channel Detail Screen
- **Strengths:** `SliverAppBar` with gradient, post cards with reactions, comments bottom sheet.
- **Issues:** Hard-coded channel fallback with `DateTime.now()`, hard-coded comment count, no loading skeleton in comments sheet, generic "Adolescent" label for all users, no post creation.

### Counselor Chat Screen
- **STUB.** 12 lines. `Center(child: Text('Chat with Counselor'))`. Critical gap.

### Profile Screen
- **Strengths:** Polished hero section, clean info card, consent status link.
- **Issues:** No profile editing, no settings section, hard-coded version string, no sign-out confirmation, hard-coded AppBar background, no dark mode toggle.

### Consent Status Screen
- **Strengths:** Teen-friendly explanation banner, clear status chips.
- **Issues:** Only 2 of 5 consent types shown, read-only (no "Request Change" action), no consent history.

### Alerts Screen
- **Strengths:** Non-clinical language, avoids red for high severity, proper empty state.
- **Issues:** Redundant refresh icon, hard-coded "A new pattern noticed" for all alerts, no dismiss/mark-as-read, no filter by type/severity.

### Alert Detail Screen
- **Strengths:** Non-clinical language, suggestion tiles, footer disclaimer.
- **Issues:** Both action tiles have `onTap: () {}` — dead buttons, locale-specific date format.

### Educational Library Screen
- **Strengths:** Friendly naming, proper states.
- **Issues:** No search, no category filtering/grouping, no reading progress tracking, empty state lacks action button.

### Educational Page Detail Screen
- **Strengths:** Markdown rendering, curved header, "I've read this!" button.
- **Issues:** "I've read this!" only does `Navigator.pop` — doesn't track, no related articles, no image support handling, no font size adjustment, no table of contents for long articles.

### Recommendations Screen
- **Strengths:** Playful badge, shows reason prominently.
- **Issues:** Empty state lacks action buttons, inconsistent padding (24px vs 16px elsewhere).

---

## Guardian App — Detailed Screen Analysis

### Splash Screen
- **Issues:** Static, no progress text, hardcodes `NeuroColors.guardianPrimary` instead of using theme.

### Login Screen
- **Strengths:** Clean layout, floating SnackBar styling.
- **Issues:** No password visibility toggle, primitive email validation, no "Forgot Password", inconsistent SnackBar styling across auth screens.

### SignUp Screen
- **Issues:** **SnackBar NOT styled** (full-width raw red, no floating), password requirements minimal with no strength indicator, uses `context.go` instead of `context.push` for login link.

### Activation Screen
- **Strengths:** Best-styled auth screen — privacy tip card, floating SnackBars.
- **Issues:** No back button to login, activation code has no auto-uppercase, confirm password skips empty check.

### Dashboard Screen
- **Strengths:** `SliverAppBar` for performant scrolling, uses `NeuroEmptyState` and `NeuroErrorWidget`.
- **Issues:** Static greeting (no time-of-day), adolescents list swallows errors silently, **no `RefreshIndicator`**, mood distribution is minimal (text rows only), quick action cards are hard-coded.

### Registration Screen
- **Strengths:** Success state with activation code display and clipboard copy.
- **Issues:** No form-level validation feedback until submit, DOB field not part of form validation system, only 2 consent types available, success view has no AppBar or back navigation.

### Consent Screen
- **Strengths:** Optimistic updates, grouped by adolescent, floating SnackBars.
- **Issues:** Empty state is plain `Text` (no `NeuroEmptyState`), error state is plain `Text` (no `NeuroErrorWidget`), section headers show email instead of name, only 2 consent types, no consent history/audit log, uses deprecated Switch properties.

### Alerts Screen
- **Issues:** **Doesn't use `NeuroAlertCard`** from shared package, doesn't show adolescent name or timestamp in list, no pull-to-refresh, plain `Text` error state (no retry), no date range filter.

### Alert Details Screen
- **Issues:** Client-side alert lookup (throws if list not loaded), raw `toString()` date, notes field lacks border styling, no confirmation on resolve, no redirect after resolution.

### Counselor Messaging Screen
- **Strengths:** Empty state, no-counselor state, auto-scroll, optimistic sending.
- **Issues:** **Broken default** in router (`adolescentId: ''`), no typing indicator/read receipts, no visual sender differentiation beyond alignment, inline error text (not dismissable), no retry for failed sends, no attachment support, no character limit.

### Profile Screen
- **Strengths:** Most polished screen visually — consistent card design, clear hierarchy.
- **Issues:** **Notification toggles are no-ops** (empty `onChanged`), no profile editing, no change/delete password, no sign-out confirmation, hard-coded version, no link to "Followed Pages".

### Adolescent Detail Screen
- **Issues:** **"Unlink Account" is a TODO**, plain `Text` error state (no `NeuroErrorWidget`), consent items are plain `Row` widgets (not cards), no mood/alert summary for specific adolescent, raw date formatting.

### Recommendations Screen
- **Strengths:** Uses `NeuroEmptyState` and `NeuroErrorWidget` correctly, `skipLoadingOnReload: true`.
- **Issues:** Tinted background may reduce readability, redundant "Tap to read full article" text.

### Educational Page Detail Screen
- **Strengths:** Well-styled markdown, custom blockquote styling.
- **Issues:** "I've read this!" does nothing (just pops), no share/save, no related recommendations.

---

## Navigation Flow Analysis

### Adolescent App — GoRouter

**Route Structure:**
```
/splash
/login
/activate
/                  -> StatefulShellRoute (5 tabs)
  Branch 0: /       → DashboardScreen
  Branch 1: /journal → JournalHistoryScreen
  Branch 2: /mood    → MoodScreen
  Branch 3: /channels → ChannelsScreen
  Branch 4: /profile → ProfileScreen
/ai-chat             → Full-screen push
/counselor-chat      → Full-screen push (STUB)
/journal/new         → Full-screen push
/journal/:id         → Full-screen push
/channels/:id        → Full-screen push
/alerts              → Full-screen push
/consent-status      → Full-screen push
/alerts/:id          → Full-screen push (uses state.extra)
/learn               → Full-screen push
/learn/:slug         → Full-screen push (uses state.extra)
/recommendations     → Full-screen push
```

**Issues:**
1. `/alerts/:id` and `/learn/:slug` pass objects via `state.extra` — crashes on deep link.
2. No route guard for counselor chat (any teen can navigate regardless of consent).
3. `navigationShell.goBranch` does NOT pass `initialLocation` — tapping same tab twice won't reset scroll.
4. No 404/unknown route handler.
5. Debug `print()` statements in production router.
6. No transition animations defined.

### Guardian App — GoRouter

**Route Structure:**
```
/splash
/login
/signup
/activate
/                  -> StatefulShellRoute (5 tabs)
  Branch 0: /       → DashboardScreen
  Branch 1: /consent → ConsentScreen
  Branch 2: /alerts  → AlertsScreen
  Branch 3: /messages → CounselorMsgScreen(adolescentId: '', adolescentName: 'General')  ← BROKEN
  Branch 4: /profile → ProfileScreen
/register-adolescent → Full-screen push
/alert-details/:alertId → Full-screen push
/adolescent/:id      → Full-screen push
/adolescent/:id/chat → Full-screen push
/adolescent/:id/recommendations → Full-screen push
/learn               → Full-screen push
/learn/:slug         → Full-screen push (uses state.extra)
```

**Issues:**
1. **Messages tab broken** — empty `adolescentId` + "General" name.
2. No conversation list screen to pick which adolescent's counselor to message.
3. No route guards for adolescent-specific routes.
4. No 404 route.
5. `GuardianRoutes` constants defined but hardcoded strings used in some navigations.
6. No transition animations.

---

## Widget Patterns & Consistency

### Shared Widgets from `neuronet_core` — Usage Gap

| Widget | Adolescent App | Guardian App |
|--------|---------------|--------------|
| `NeuroEmptyState` | ✅ Used (4 screens) | ✅ Used (3 screens) |
| `NeuroErrorWidget` | ⚠️ Used (5/10 screens) | ⚠️ Used (2/8 screens) |
| `NeuroCard` / `NeuroDashboardCard` | ✅ Used (Dashboard) | ❌ **NOT USED** |
| `NeuroAlertCard` | ❌ **NOT USED** | ❌ **NOT USED** (reimplemented inline) |
| `NeuroMoodIcon` | ✅ Used (Mood screen) | ❌ **NOT USED** |
| `NeuroSummaryCard` | ❌ **Dead code** | ❌ **NOT USED** |
| `NeuroTrendChart` | ❌ **Dead code** | ❌ **NOT USED** |
| `NeuroJournalCard` | ✅ Used (Journal history) | N/A |

**Key Finding:** Guardian app significantly underutilizes the shared widget library, leading to duplicated card UI patterns and inconsistent styling.

### Border Radius Inconsistency

| Component | Adolescent App | Guardian App |
|-----------|---------------|--------------|
| Theme default (card) | 16px | 16px |
| Theme default (input) | 12px | 12px |
| Stat cards | Hard-coded | N/A |
| Quick action cards | N/A | 16px |
| Setting sections | N/A | 24px |
| Recommendation cards | N/A | 24px |
| Empty state | 24px | 24px |
| Profile sign-out | N/A | 20px |

### SnackBar Pattern Inconsistency (Guardian App)

| Screen | Style |
|--------|-------|
| Login | ✅ Floating, 12px radius, custom margins |
| Activation | ✅ Floating, 12px radius, custom margins |
| SignUp | ❌ Full-width, no radius, no margins, raw error |
| Consent | ✅ Floating, success/error colors |
| Registration | ❌ Basic (non-floating, no styling) |
| Alert details | ❌ Basic (non-floating, no styling) |
| Counselor msg | ❌ Inline error text instead |

---

## Theme Usage

### Strengths (Both Apps)
- Dual-brand system applied correctly (`NeuroTheme.adolescentTheme()` / `NeuroTheme.guardianTheme()`)
- `NeuroColors` constants used for primary color references
- Input decoration theme provides consistent form field styling
- Alert severity colors (`NeuroColors.alertHigh/Medium/Low`) used

### Issues
1. **Hardcoded colors throughout:** `Colors.grey[600]`, `Colors.grey[400]`, `Colors.grey[100]`, `Colors.blue[50]`, `Colors.blue[800]`, `Colors.white`, `Colors.green` used instead of theme tokens.
2. **Dashboard `_StatCard` (adolescent):** Uses `Colors.blue`, `Colors.orange`, `Colors.green`, `Colors.red` — completely bypasses theme.
3. **Activation screen (adolescent):** Uses `Colors.blue` for privacy tip — unrelated accent color.
4. **Mixed access patterns:** Some screens use `theme.colorScheme.primary` (Material approach), others use `NeuroColors.guardianPrimary` (direct constant).
5. **Typography scale underutilized:** Manual `fontSize` + `fontWeight` overrides instead of semantic text styles.
6. **No custom component themes:** Missing `ChipTheme`, `FABTheme`, `SnackBarTheme`, `BottomSheetTheme`, `DialogTheme`, `ListTileTheme`.
7. **No dark theme support:** Only `ColorScheme.light` defined.

---

## Empty / Loading / Error States Audit

### Adolescent App

| Screen | Empty State | Loading State | Error State |
|--------|------------|---------------|-------------|
| Dashboard | ✅ `NeuroEmptyState` (mini) | ✅ Spinner | ✅ `NeuroErrorWidget` (retry) |
| Dashboard (alerts) | N/A | ✅ Spinner | ❌ `SizedBox.shrink()` — **SILENT** |
| Dashboard (learning) | N/A | ✅ Spinner | ❌ **SILENT** |
| Journal History | ✅ `NeuroEmptyState` + action | ✅ Spinner | ❌ Plain `Text` — no retry |
| Journal Detail | N/A | ✅ Spinner | ❌ Plain `Text` — no retry |
| Mood | N/A | ✅ Spinner | ❌ SnackBar |
| Mood History | N/A | ✅ Spinner | ❌ `SizedBox.shrink()` — **SILENT** |
| AI Chat | ✅ Custom empty view | ✅ Spinner | ❌ Custom view (no retry) |
| Channels | ❌ **NONE** | ✅ Spinner | ❌ Plain `Text` — no retry |
| Channel Detail | N/A | ✅ Spinner | ❌ Plain `Text` — no retry |
| Comments Sheet | N/A | ✅ Spinner | ❌ Plain `Text` — no retry |
| Profile | N/A | ✅ Spinner | ⚠️ Text + retry (no `NeuroErrorWidget`) |
| Consent | N/A | ✅ Spinner | ✅ `NeuroErrorWidget` (retry) |
| Alerts | ✅ `NeuroEmptyState` | ✅ Spinner | ✅ `NeuroErrorWidget` (retry) |
| Alert Detail | N/A | ✅ Spinner | ❌ Plain `Text` — no retry |
| Library | ✅ `NeuroEmptyState` | ✅ Spinner | ✅ `NeuroErrorWidget` (retry) |
| Recommendations | ✅ `NeuroEmptyState` | ✅ Spinner | ✅ `NeuroErrorWidget` (retry) |

### Guardian App

| Screen | Empty State | Loading State | Error State |
|--------|------------|---------------|-------------|
| Dashboard | ✅ `NeuroEmptyState` (mini) | ✅ Spinner | ✅ `NeuroErrorWidget` (retry) |
| Dashboard (adolescents) | ❌ `SizedBox.shrink()` — **HIDDEN** | ✅ Spinner | ❌ `SizedBox.shrink()` — **SILENT** |
| Dashboard (mood) | ✅ `NeuroEmptyState` (mini) | N/A | N/A |
| Consent | ❌ Plain `Text` | ✅ Spinner | ❌ Plain `Text` |
| Alerts | ✅ `NeuroEmptyState` | ✅ Spinner | ❌ Plain `Text` — no retry |
| Alert Details | N/A | ✅ Spinner | ❌ Plain `Text` — no retry |
| Counselor Msg | ✅ Custom empty/no-counselor | ✅ Spinner | ❌ Plain `Text` |
| Profile | N/A | ✅ Spinner | ⚠️ Text + retry |
| Adolescent Detail | ✅ `NeuroEmptyState` (mini, consents) | ✅ Spinner | ⚠️ Text + retry |
| Recommendations | ✅ `NeuroEmptyState` | ✅ Spinner | ✅ `NeuroErrorWidget` (retry) |

### Loading States — Both Apps
- **All screens** use bare `CircularProgressIndicator` centered.
- **No skeleton loaders, no shimmer effects, no progressive loading.**
- **No context messages** ("Loading dashboard data...", "Fetching consents...").

---

## Form Inputs & Validation UX

### Common Gaps Across All Forms

| Gap | Impact |
|-----|--------|
| No password visibility toggles | Frustrating for all users |
| No "Forgot Password" flow | No credential recovery |
| No input formatters (auto-lowercase email, auto-uppercase activation code) | Manual correction needed |
| No autofill hints (`AutofillHints.email`, `AutofillHints.password`) | No OS password manager integration |
| No text input actions (`TextInputAction.next` / `TextInputAction.done`) | Keyboard doesn't show "Next" / "Go" |
| No inline validation (only on submit) | Errors discovered too late |
| No real-time character counters (except journal content) | Users don't know limits |
| No focus management (`FocusScope`, `autofocus` on first field) | Extra taps to reach fields |
| No "submit on keyboard enter" | Relies on button tap only |
| Naive email validator (`value.contains('@')`) | Invalid emails like `test@` pass |

### Adolescent App — Specific
- **Journal:** Validation uses disruptive SnackBar instead of inline, no "skip" affordance for optional mood.
- **Mood:** No character limit on notes field.
- **Activation:** 4 fields without progressive disclosure, no password strength indicator.

### Guardian App — Specific
- **Registration:** DOB field uses `InkWell` + `showDatePicker` — not a form field, can't show inline validation error.
- **Registration:** Name, DOB, relationship have no validators on the widgets — validation only in provider on submit.
- **SignUp:** Confirm password validator skips empty check.

---

## Accessibility Audit

### WCAG Contrast Failures

| Element | Approximate Ratio | Verdict |
|---------|------------------|---------|
| Journal placeholder text (`onSurface` at 50%) | ~2.1:1 | ❌ **FAIL** (needs 4.5:1) |
| AI Chat empty state text (`Colors.grey[400]`) | ~2.9:1 | ❌ **FAIL** |
| `NeuroColors.onSurfaceVariant` (`0xFF757575`) on white | ~4.6:1 | ⚠️ Borderline |

### Semantic Labels

| Issue | Location |
|-------|----------|
| No `Semantics` widgets anywhere in either app | Global |
| AI Chat info button has no `tooltip` or `semanticsLabel` | Adolescent |
| Mood grid items have no `semanticsLabel` — screen readers won't announce mood type | Adolescent |
| Dashboard stat cards have no semantic grouping | Adolescent |
| ChannelCard follow button has no tooltip | Adolescent |
| Alert filter/refresh buttons have no tooltips | Guardian |
| Loading spinners not labeled or excluded from semantics | Both |

### Touch Targets
- Mood grid items in `NeuroMoodIcon` may be below 48dp for small emojis.
- Some trailing `Icons.arrow_forward_ios` at 16px may not meet minimum interactive dimension.

### Other Accessibility Gaps
1. **Zero `Semantics` widgets** for grouping related information (e.g., mood emoji + label should be one semantic unit).
2. **No `ExcludeSemantics`** for decorative elements (shadows, decorative icons).
3. **No `Hero` animations** for shared element transitions.
4. **No dynamic text scaling testing** — fixed font sizes in many places.
5. **No color-blind considerations** — alert severity in guardian app is color-coded (green/orange/red) with no text label in the list.
6. **Color-only information encoding** — mood types rely on emoji + color; if color is the only differentiator, color-blind users struggle.

---

## Animations & Transitions

### What Exists
| Feature | Location |
|---------|----------|
| Auto-scroll `animateTo()` (300ms easeOut) | AI Chat (adolescent), Counselor Msg (guardian) |
| Bottom sheet default animation | Comments sheet (adolescent) |
| GoRouter default page transitions | Both apps (platform default) |

### What Is Missing
1. **No custom page transition animations** — all navigation uses abrupt cuts or platform defaults.
2. **No shared element transitions (Hero)** — journal cards to detail, channel cards to detail, alert cards to detail, educational cards to detail all lack Hero animations.
3. **No staggered animations** on dashboard — all sections appear simultaneously.
4. **No loading skeleton animations** — content simply replaces the spinner.
5. **No micro-interactions** — button presses, card taps, mood selections lack haptic or visual feedback beyond default Material splash.
6. **No celebration animation** on mood saved — success view appears statically.
7. **No fade-in for list items** — journal entries, channel cards, alert cards appear instantly.
8. **No transition for bottom navigation tab changes** — `IndexedStack` simply switches visible children.
9. **No implicit animations** — `AnimatedContainer`, `AnimatedOpacity`, `AnimatedSwitcher` not used anywhere. State changes are instant.
10. **No haptic feedback** — no `HapticFeedback` calls on important actions (submit, resolve alert, send message).

---

## Missing Domain-Specific UX Patterns

### Adolescent App (Mental Health Support for Teens 13–17)

| Missing Pattern | Why It Matters |
|----------------|----------------|
| **Crisis/Safety Resources** — no emergency contact info, suicide hotline numbers, or text lines | A mental health app for teens MUST have a prominent "Get Help Now" entry point |
| **Onboarding/Tutorial Flow** — first-time users dropped directly into app with no guided tour | Teens need feature explanation, privacy reassurance |
| **Wellness Check Streaks/Gamification** — "Active Streak: 3" is hard-coded mock data | Gamification is important for teen engagement |
| **Mood Trend Visualization** — `NeuroTrendChart` exists but is unused; dashboard shows text list only | Teens need to see patterns over time |
| **Breathing/Calming Exercises** — no guided breathing, grounding techniques, or quick calming tools | Standard features in teen mental health apps (Calm, Headspace, Woebot) |
| **Customization/Personalization** — no preferred name, avatar, theme preferences, notification frequency | Personalization increases engagement |
| **Data Export/Privacy Dashboard** — no "My Data" section to view or export data | Transparency and control over personal data |
| **Content Warnings** — educational content may discuss sensitive topics (self-harm, anxiety) without warnings | Emotional safety |
| **Offline Support** — no indication of what works offline, no feedback when connectivity lost | Journal entries should be locally cached |
| **Time-based Contextual Greeting** — dashboard says "Hi [name]" not "Good morning/Good evening" | Time-aware greetings increase engagement |
| **Notification System UI** — in-app notification center for counselor messages, channel updates | AppBar notification bell has empty `onPressed` |
| **Mood Correlation Insights** — no correlations shown ("You tend to feel anxious on Sundays") | Actionable insights from collected data |
| **Goal Setting** — no ability to set emotional wellness goals | Motivational feature |
| **Parent-Teen Communication Bridge** — no UI for teens to see messages from parents | PRD mentions bidirectional communication |
| **Progress Over Time Screen** — no "My Journey" screen showing emotional growth and milestones | Long-term engagement and reflection |

### Guardian App (Parent/Guardian Monitoring)

| Missing Pattern | PRD Reference | Why It Matters |
|----------------|---------------|----------------|
| **Followed Pages View** | FR-15 (P1) | Guardian cannot see which counselor pages their adolescent follows |
| **Profile Edit** | FR-10 (P1) | Guardian cannot update their own profile details |
| **Adolescent Profile Edit** | FR-10 (P1) | No way to edit adolescent info after registration |
| **Password Reset** | Acceptance criteria | No "forgot password" flow in any auth screen |
| **Conversation List for Messages** | FR-37 | Messages tab is broken — no list of conversations per adolescent |
| **Unread Alert Badge on Tab** | UX best practice | No visual indicator of new alerts on bottom nav |
| **Consent History/Audit Log** | FR-20 (P0) | No historical record of consent changes with timestamps |
| **Date Range Filter for Alerts** | FR-51 | Only severity filter exists |
| **Adolescent Mood/Risk Trend Visualization** | FR-44 | Dashboard shows raw counts, not trends over time |
| **Non-Diagnostic Language Guardrails** | BR-01, BR-16 | "Risk Level: HIGH" is clinical-adjacent; PRD says "avoid diagnostic language" |
| **Privacy Assurance Notices** | BR-04 | Registration screen has no explicit statement that raw journal content is never visible to guardians |
| **Confirmation Dialogs for Destructive Actions** | UX best practice | Logout, resolve alert, and unlink have no confirmation |
| **Notification Preferences Backend** | PRD 6.4 | Settings toggles are non-functional no-ops |
| **Offline/Connectivity Indicator** | NFR-15 | No "you are offline" messaging anywhere |
| **Onboarding/Tutorial Flow** | NFR-11, NFR-12 | First-time guardian users get no guidance on what each tab does |
| **Multi-Adolescent Consolidated View** | Domain best practice | No grid showing all adolescents' status at a glance |
| **"Last Checked" / "Last Activity" Timestamps** | Domain best practice | First thing a concerned parent wants to know |
| **Action Guidance for Alerts** | BR-01 | Alert resolution provides no guidance on what guardian should do |

---

## Recommended Next Steps

### Quick Wins (High Impact, Low Effort)

1. **Add password visibility toggles** to all auth forms (both apps)
2. **Replace plain error states with `NeuroErrorWidget`** across both apps (~10 screens)
3. **Fix the Messages tab** in guardian app — add conversation list or remove from bottom nav
4. **Add pull-to-refresh** to key data screens (alerts, consent, profile, channels)
5. **Style SignUp SnackBar consistently** in guardian app
6. **Remove dead buttons** (`onPressed: () {}`) or implement their actions

### Medium Effort

7. **Implement journal auto-save** (adolescent app)
8. **Add unread alert badge** to guardian bottom nav tab
9. **Add confirmation dialogs** for destructive actions (logout, resolve, unlink)
10. **Wire up notification toggles** in guardian profile
11. **Add 5 consent types** (currently only 2, both apps)
12. **Fix deep link crashes** — use path params + API fetch instead of `state.extra`
13. **Guard `print()` statements** with `kDebugMode`

### Higher Effort

14. **Crisis resources screen** (adolescent — critical for safety evaluation)
15. **Onboarding/tutorial flow** (both apps)
16. **Counselor chat backend integration** (adolescent)
17. **AI chat backend integration** (adolescent)
18. **Mood trend visualization** with `NeuroTrendChart`
19. **Dark mode support** (both apps)
20. **Hero transitions** for all list-to-detail navigation
21. **Skeleton loaders** for all loading states
22. **Accessibility audit fix** — semantic labels, contrast ratios, color-blind support

---

## Appendix: Files Reviewed

### Adolescent App (`apps/adolescent_app/lib/`)
```
main.dart
config/router/app_router.dart
features/auth/providers/auth_provider.dart
features/auth/view/screens/login_screen.dart
features/auth/view/screens/activation_screen.dart
features/dashboard/providers/dashboard_provider.dart
features/dashboard/view/screens/dashboard_screen.dart
features/journal/providers/journal_provider.dart
features/journal/view/screens/journal_history_screen.dart
features/journal/view/screens/journal_detail_screen.dart
features/journal/view/screens/new_journal_entry_screen.dart
features/mood/providers/mood_provider.dart
features/mood/view/screens/mood_screen.dart
features/ai_chat/providers/ai_chat_provider.dart
features/ai_chat/view/screens/ai_chat_screen.dart
features/channels/providers/channel_provider.dart
features/channels/view/screens/channels_screen.dart
features/channels/view/screens/channel_detail_screen.dart
features/counselor_chat/view/screens/counselor_chat_screen.dart
features/profile/providers/profile_provider.dart
features/profile/view/screens/profile_screen.dart
features/profile/view/screens/consent_status_screen.dart
features/alerts/providers/alert_provider.dart
features/alerts/view/screens/alerts_screen.dart
features/alerts/view/screens/alert_detail_screen.dart
features/educational/providers/educational_provider.dart
features/educational/view/screens/educational_library_screen.dart
features/educational/view/screens/educational_page_detail_screen.dart
features/educational/view/screens/recommendations_screen.dart
```

### Guardian App (`apps/guardian_app/lib/`)
```
main.dart
config/router/app_router.dart
features/auth/providers/auth_provider.dart
features/auth/view/screens/login_screen.dart
features/auth/view/screens/sign_up_screen.dart
features/auth/view/screens/activation_screen.dart
features/dashboard/providers/dashboard_provider.dart
features/dashboard/view/screens/dashboard_screen.dart
features/registration/providers/registration_provider.dart
features/registration/view/screens/registration_screen.dart
features/consent/providers/consent_provider.dart
features/consent/view/screens/consent_screen.dart
features/alerts/providers/alert_provider.dart
features/alerts/view/screens/alerts_screen.dart
features/alerts/view/screens/alert_details_screen.dart
features/counselor_msg/providers/counselor_msg_provider.dart
features/counselor_msg/view/screens/counselor_msg_screen.dart
features/profile/providers/profile_provider.dart
features/profile/view/screens/profile_screen.dart
features/adolescents/providers/adolescent_provider.dart
features/adolescents/view/screens/adolescent_detail_screen.dart
features/educational/providers/educational_provider.dart
features/educational/view/screens/recommendations_screen.dart
features/educational/view/screens/educational_page_detail_screen.dart
```

### Shared Core (`packages/neuronet_core/lib/`)
```
src/theme/neuro_theme.dart
src/theme/neuro_colors.dart
src/widgets/neuro_empty_state.dart
src/widgets/neuro_error_widget.dart
src/widgets/neuro_card.dart
src/widgets/neuro_mood_icon.dart
src/widgets/neuro_dashboard_card.dart
src/widgets/neuro_alert_card.dart
src/widgets/neuro_summary_card.dart
src/widgets/neuro_trend_chart.dart
src/widgets/neuro_journal_card.dart
```
