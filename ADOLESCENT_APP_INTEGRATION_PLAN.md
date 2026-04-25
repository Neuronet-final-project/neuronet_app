# Adolescent App Integration Plan

## ✅ Completed

### 1. Core Package Updates
- ✅ Created new models:
  - `educational_follow.dart` - Educational page following models
  - `ai_recommendation.dart` - AI recommendation models  
  - `guardian_approval.dart` - Guardian approval models
- ✅ Updated `models.dart` to export new models
- ✅ Updated `api_endpoints.dart` with new endpoints
- ✅ Created new services:
  - `educational_follow_service.dart` - Educational page following API
  - `ai_recommendation_service.dart` - AI recommendations API
  - `guardian_approval_service.dart` - Guardian approval API

### 2. New API Endpoints Added
**Educational Page Following (FR-14 & FR-15):**
- POST `/educational-follows/follow/{slug}`
- DELETE `/educational-follows/unfollow/{slug}`
- GET `/educational-follows/my-followed-pages`
- GET `/educational-follows/discover`
- GET `/educational-follows/page/{slug}/is-followed`
- GET `/educational-follows/page/{slug}/follow-count`

**AI Recommendations (FR-31):**
- POST `/ai-recommendations/analyze-and-recommend`
- GET `/ai-recommendations/my-recommendations`
- POST `/ai-recommendations/mark-viewed/{id}`

**Guardian Approvals (FR-34):**
- POST `/guardian-approvals/request-communication`
- GET `/guardian-approvals/pending`
- GET `/guardian-approvals/history`
- POST `/guardian-approvals/respond/{id}`
- GET `/guardian-approvals/check-approval/{adolescent_id}/{counselor_email}`

## 🔄 In Progress

### 3. Code Generation
- ⏳ Need to run `dart run build_runner build` to generate:
  - Freezed models (`.freezed.dart` files)
  - Riverpod providers (`.g.dart` files)

### 4. Adolescent App Features to Implement

#### A. Educational Page Following UI
**Files to Create/Update:**
- `lib/features/educational/providers/educational_follow_provider.dart` - State management
- `lib/features/educational/view/screens/discover_pages_screen.dart` - Page discovery
- `lib/features/educational/view/screens/followed_pages_screen.dart` - My followed pages
- `lib/features/educational/view/widgets/page_follow_button.dart` - Follow/unfollow button
- Update `educational_library_screen.dart` - Add follow buttons
- Update `educational_page_detail_screen.dart` - Add follow button

**UI Features:**
- Follow/unfollow button on each educational page
- "Followed Pages" section in library
- Page discovery with filters (category, search)
- Follow count and popularity indicators
- Visual indication of followed status

#### B. AI Recommendations UI
**Files to Create/Update:**
- `lib/features/educational/providers/ai_recommendation_provider.dart` - State management
- Update `recommendations_screen.dart` - Show AI-generated recommendations
- `lib/features/educational/view/widgets/ai_recommendation_card.dart` - Recommendation card
- `lib/features/dashboard/view/screens/dashboard_screen.dart` - Add recommendations widget

**UI Features:**
- Smart recommendation cards with trigger reasons
- "Why this recommendation?" explanations
- Mark as viewed functionality
- Proactive notification for new recommendations
- Integration with dashboard

#### C. Guardian Approval Request UI
**Files to Create/Update:**
- `lib/features/counselor_chat/providers/approval_provider.dart` - State management
- `lib/features/counselor_chat/view/screens/request_approval_screen.dart` - Request form
- `lib/features/counselor_chat/view/widgets/approval_status_widget.dart` - Status indicator
- Update `counselor_chat` screens - Add approval check

**UI Features:**
- Request approval form (reason input)
- Approval status indicator
- Pending/approved/denied states
- Counselor communication gating based on approval

## 📋 Next Steps

### Phase 1: Code Generation & Testing
1. Run build_runner to generate code
2. Fix any compilation errors
3. Test new services with mock data

### Phase 2: Educational Following Implementation
1. Create educational follow provider
2. Update educational library screen with follow buttons
3. Create discover pages screen
4. Create followed pages screen
5. Add follow status indicators

### Phase 3: AI Recommendations Implementation
1. Create AI recommendation provider
2. Update recommendations screen
3. Create recommendation cards
4. Add dashboard widget
5. Implement mark as viewed

### Phase 4: Guardian Approval Implementation
1. Create approval provider
2. Create request approval screen
3. Add approval status checks
4. Update counselor chat flow
5. Add approval notifications

### Phase 5: UI Polish & Testing
1. Add loading states
2. Add error handling
3. Add empty states
4. Test all flows
5. Add animations and transitions

## 🎨 UI Design Guidelines

### Color Scheme
- Primary: Use existing theme primary color
- Follow button: Primary color when not followed, outlined when followed
- Recommendations: Highlight with primary container color
- Approval status: Green (approved), Yellow (pending), Red (denied)

### Components to Reuse
- `NeuroCard` - For cards
- `NeuroButton` - For buttons
- `NeuroEmptyState` - For empty states
- `NeuroErrorWidget` - For errors
- `NeuroShimmer` - For loading states

### Animations
- Follow button: Scale animation on tap
- Recommendation cards: Slide in from bottom
- Approval status: Fade in/out transitions

## 🔧 Technical Notes

### State Management
- Use Riverpod for all state management
- Use `AsyncValue` for async operations
- Implement proper error handling
- Add refresh functionality

### API Integration
- All services already created in core package
- Use `Result` type for error handling
- Implement retry logic for failed requests
- Add proper loading states

### Navigation
- Use GoRouter for navigation
- Add new routes for new screens
- Implement deep linking where needed

## 📱 Testing Checklist

### Educational Following
- [ ] Can follow a page
- [ ] Can unfollow a page
- [ ] Follow status persists
- [ ] Followed pages list updates
- [ ] Discovery filters work
- [ ] Search functionality works

### AI Recommendations
- [ ] Recommendations load correctly
- [ ] Can mark as viewed
- [ ] Trigger analysis works
- [ ] Recommendations update after new journals
- [ ] Dashboard widget shows recommendations

### Guardian Approval
- [ ] Can request approval
- [ ] Approval status displays correctly
- [ ] Cannot message counselor without approval
- [ ] Approval notifications work
- [ ] Status updates in real-time

## 🚀 Deployment Notes

### Before Deployment
1. Run all tests
2. Test on both iOS and Android
3. Verify API endpoints are correct
4. Test with real backend
5. Check performance

### After Deployment
1. Monitor crash reports
2. Gather user feedback
3. Track feature usage
4. Optimize based on metrics