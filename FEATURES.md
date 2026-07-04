# FEATURES.md — Foodiary

Feature inventory: implemented, planned, and explicitly out of scope.
Last updated: 2026-07-04

## Implemented

### Profile & Calorie Calculation
- [x] Collect age, biological sex, height, weight, activity level, goal
- [x] Mifflin-St Jeor BMR calculation
- [x] Activity level multipliers (sedentary 1.2 → very active 1.725)
- [x] Goal adjustments (maintain 1.0, lose 0.90, gain 1.10)
- [x] Round final target to nearest 10 kcal
- [x] Full onboarding-style profile edit flow (reuses ProfileSetup → GoalSetup → CalorieResult)
- [x] Calorie disclaimer on result screen and profile
- [x] Profile data persisted via SwiftData

### Meal Planning
- [x] Create daily meal plan with 4 default slots: Breakfast, Lunch, Snack, Dinner
- [x] Add food items manually (name, calories, optional note)
- [x] Food search via FatSecret + USDA + Custom API providers
- [x] Delete food items
- [x] Meal total calories computed automatically
- [x] Daily total calories computed automatically
- [x] Validation: food name required, calories must be whole number ≥ 0
- [x] Meal plans persisted via SwiftData
- [x] Meal slots sorted chronologically (sortedMeals — SwiftData relationship ordering fix)

### Today Dashboard
- [x] Hero card with remaining estimate, progress %, aurora gradient background
- [x] Planned calories vs remaining calories summary
- [x] Calorie progress visualization
- [x] Status message with neutral language
- [x] Meal timeline with emoji tiles and calorie totals
- [x] Next best action strip with meal type picker
- [x] Empty state: "No meal plan for today — Create one"

### Weekly Plan
- [x] Week navigation with date range label
- [x] Day cards with meal slot summary and calorie totals
- [x] Past/future date support (read-only for past dates)
- [x] Plan and add food for any date

### Insights
- [x] Calorie trend visualization
- [x] Observations summary

### Macro Tracking
- [x] Protein, carbs, fat breakdown on Today dashboard

### Navigation
- [x] 4-tab bottom bar: Today / Plan / Insights / Profile
- [x] Onboarding flow: Welcome → Profile Setup → Goal Setup → Calorie Result
- [x] Meal Detail screen with food item list
- [x] Add Food Item sheet (manual entry + search)
- [x] Profile Edit flow (full onboarding-style, pre-filled)
- [x] Settings screen (theme + language)
- [x] Meal type picker sheet from action strip

### Design System (Pulse v2)
- [x] Modern planning cockpit aesthetic — soft shadows, rounded surfaces
- [x] Dynamic accent color `#4BB8FA`
- [x] Full dark mode support via `UIColor { tc in ... }` dynamic tokens
- [x] Gradient hero card with animated aurora blobs
- [x] Ruler-based input for onboarding (age, height, weight)
- [x] Energy balance bar on calorie result
- [x] Colored meal icon tiles with type-specific tints
- [x] Pulse button styles (primary, secondary, icon, stepper)
- [x] PulseTopbar component
- [x] Opaque nav bar (iOS 26 Liquid Glass safe)

### Theming
- [x] Light / Dark / System theme toggle in Settings
- [x] ThemeManager ObservableObject
- [x] Live theme switching (no restart)
- [x] `.preferredColorScheme()` applied at root

### Localization
- [x] String Catalogs (`.xcstrings`) — Indonesian + English
- [x] Runtime language switching via Settings
- [x] L10n type-safe lookup with bundle caching
- [x] LocaleManager ObservableObject
- [x] Localized dates (DateFormatter follows selected language)
- [x] Localized model display names (activity, goal, meal types)

### Data Persistence
- [x] SwiftData `@Model` classes for all data
- [x] PersistenceService protocol abstraction
- [x] MigrationService (legacy JSON → SwiftData migration)
- [x] Reset all data action
- [x] Data survives app restarts

### States Covered
- [x] First launch (no profile) → onboarding
- [x] Returning user (profile exists) → Today dashboard
- [x] No meal plan today → empty state with CTA
- [x] Meal plan exists, no food items → meal cards show "0 items, 0 kcal"
- [x] Meal plan with food → calorie totals display
- [x] Under target → neutral status message
- [x] At target → neutral status message
- [x] Over target → neutral language ("X kcal over your estimated target")
- [x] Empty meal → "No food added yet"
- [x] Past dates → read-only meal plans
- [x] Dark mode → all screens adapt

---

## Planned (Post-MVP)

### High Priority
- [ ] **Unit tests** — CalorieCalculator, MealPlanService, AppState
- [ ] **Food item editing** — currently delete + re-add; add inline edit
- [ ] **Proper error handling** — replace `try?` with `do/catch` + user-visible errors
- [ ] **Accessibility** — VoiceOver labels, dynamic type support, reduced motion
- [ ] **App icon** — replace solid coral placeholder with proper icon

### Medium Priority
- [ ] Copy yesterday's meal plan
- [ ] Favorite food items (quick-add from history)
- [ ] Swipe-to-delete on meal cards and food items
- [ ] Haptic feedback on button presses and deletions
- [ ] iPad layout (max content width 680px)
- [ ] Undo delete (toast: "Item removed. Undo?")

### Low Priority
- [ ] Weight tracking over time
- [ ] Export meal plan (PDF, text)
- [ ] Reminder notifications
- [ ] Multiple profiles

---

## Explicitly Out of Scope (v1)

These are intentionally excluded from the MVP per the PRD:

- ❌ Login / account system
- ❌ Cloud sync / backend
- ❌ Barcode scanning
- ❌ Food image recognition
- ❌ AI meal generation
- ❌ Social features / sharing
- ❌ Subscription / payments
- ❌ Exercise tracking
- ❌ Water tracking
- ❌ Recipe builder
- ❌ Shopping list
- ❌ Medical / nutrition diagnosis

---

## Feature Status Summary

| Category | Implemented | Planned | Out of Scope |
|----------|:-----------:|:-------:|:------------:|
| Profile & Onboarding | 8 | 0 | 0 |
| Calorie Calculation | 5 | 0 | 0 |
| Meal Planning | 9 | 2 | 0 |
| Today Dashboard | 7 | 0 | 0 |
| Weekly Plan | 4 | 0 | 0 |
| Insights | 2 | 0 | 0 |
| Macro Tracking | 1 | 0 | 0 |
| Navigation | 7 | 0 | 0 |
| Design System | 11 | 0 | 0 |
| Theming | 4 | 0 | 0 |
| Localization | 6 | 0 | 0 |
| Data Persistence | 5 | 0 | 0 |
| Testing | 0 | 1 | 0 |
| Accessibility | 0 | 1 | 0 |
| Advanced Features | 0 | 6 | 12 |
| **Total** | **69** | **10** | **12** |
