# FEATURES.md — Foodiary

Feature inventory: implemented, planned, and explicitly out of scope.
Last updated: 2026-06-20

## Implemented (MVP)

### Profile & Calorie Calculation
- [x] Collect age, biological sex, height, weight, activity level, goal
- [x] Mifflin-St Jeor BMR calculation
- [x] Activity level multipliers (sedentary 1.2 → very active 1.725)
- [x] Goal adjustments (maintain 1.0, lose 0.90, gain 1.10)
- [x] Round final target to nearest 10 kcal
- [x] Profile editing with recalculation
- [x] Calorie disclaimer on result screen and profile
- [x] Profile data persisted locally as JSON

### Meal Planning
- [x] Create daily meal plan with 4 default slots: Breakfast, Lunch, Snack, Dinner
- [x] Add food items manually (name, calories, optional note)
- [x] Edit food items (via delete + re-add pattern)
- [x] Delete food items with confirmation
- [x] Meal total calories computed automatically
- [x] Daily total calories computed automatically
- [x] Validation: food name required, calories must be whole number ≥ 0
- [x] Meal plans persisted locally as JSON

### Today Dashboard
- [x] Daily target display (large coral number)
- [x] Planned calories vs remaining calories summary cards
- [x] Calorie progress bar (mint under target, coral over target)
- [x] Status badge: under target / at target / over target
- [x] Meal-by-meal summary cards with calorie totals
- [x] Empty state: "No meal plan for today — Create one"
- [x] Neutral language for over-target: "X kcal over your estimated target"

### Navigation
- [x] 3-tab bottom bar: Today / Meal Plan / Profile
- [x] Onboarding flow: Welcome → Profile Setup → Goal Setup → Calorie Result
- [x] Meal Detail screen with food item list
- [x] Add Food Item sheet
- [x] Profile Edit sheet

### Design System
- [x] Neubrutalist visual language — 3px black borders, hard offset shadows
- [x] Coral `#FF6B4A` primary, Mint `#2DD4BF` secondary, Yellow `#FFD60A` accent
- [x] Cream `#FAFAF5` background
- [x] ALL CAPS labels with letter-spacing
- [x] SF Rounded Bold for display/metrics
- [x] Push-in button animation on press
- [x] Tab bar with black top border + coral active state
- [x] Custom navigation bar styling
- [x] Colored meal icon containers (orange, teal, pink, indigo)
- [x] Pill-shaped status badges with black borders

### Data Persistence
- [x] User profile → `profile.json`
- [x] Calorie target → `target.json`
- [x] Daily meal plans → `mealplan_YYYY-MM-DD.json`
- [x] Reset all data action
- [x] Data survives app restarts

### States Covered
- [x] First launch (no profile) → onboarding
- [x] Returning user (profile exists) → Today dashboard
- [x] No meal plan today → empty state with CTA
- [x] Meal plan exists, no food items → meal cards show "0 items, 0 kcal"
- [x] Meal plan with food → calorie totals display
- [x] Under target → green badge
- [x] At target → yellow badge
- [x] Over target → red-tinted badge with neutral language
- [x] Empty meal → "No food added yet"

---

## Planned (Post-MVP)

### High Priority
- [ ] **Unit tests** — CalorieCalculator, StorageService, AppState
- [ ] **Food item editing** — currently delete + re-add; add inline edit
- [ ] **Proper error handling** — replace `try?` with `do/catch` + user-visible errors
- [ ] **Accessibility** — VoiceOver labels, dynamic type support, reduced motion
- [ ] **App icon** — replace solid coral placeholder with proper icon
- [ ] **Empty state for Dinner** — currently cut off on smaller screens; fix scroll
- [ ] **Meal Plan for past/future dates** — currently only today

### Medium Priority
- [ ] Copy yesterday's meal plan
- [ ] Favorite food items (quick-add from history)
- [ ] Weekly meal planning
- [ ] Meal templates (predefined meal structures)
- [ ] Swipe-to-delete on meal cards and food items
- [ ] Haptic feedback on button presses and deletions
- [ ] Dark mode support
- [ ] iPad layout (max content width 680px)
- [ ] Undo delete (toast: "Item removed. Undo?")

### Low Priority
- [ ] Macro tracking (protein, carbs, fat)
- [ ] Weight tracking over time
- [ ] Progress charts
- [ ] Export meal plan (PDF, text)
- [ ] Reminder notifications
- [ ] Multiple profiles
- [ ] Food database (offline)
- [ ] Barcode scanner
- [ ] AI meal suggestions

---

## Explicitly Out of Scope (v1)

These are intentionally excluded from the MVP per the PRD:

- ❌ Login / account system
- ❌ Cloud sync / backend
- ❌ Public food database
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
- ❌ Macro tracking
- ❌ Weight progress charts

---

## Feature Status Summary

| Category | Implemented | Planned | Out of Scope |
|----------|:-----------:|:-------:|:------------:|
| Profile & Onboarding | 8 | 0 | 0 |
| Calorie Calculation | 5 | 0 | 0 |
| Meal Planning | 9 | 3 | 0 |
| Today Dashboard | 7 | 0 | 0 |
| Navigation | 5 | 0 | 0 |
| Design System | 12 | 1 | 0 |
| Data Persistence | 5 | 0 | 0 |
| Testing | 0 | 1 | 0 |
| Accessibility | 0 | 1 | 0 |
| Advanced Features | 0 | 10 | 12 |
| **Total** | **51** | **16** | **12** |
