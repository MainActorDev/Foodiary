# AGENTS.md — Foodiary

Guidelines for AI coding agents working on this project.
Last updated: 2026-06-20

## Project Overview

Foodiary is a simple, local-first iOS calorie tracker and daily meal planner.
Built with SwiftUI, targeting iOS 18+. No external dependencies, no backend,
no cloud sync. The app helps users create a personalized estimated daily
calorie target and plan meals from breakfast to dinner.

## Architecture

```
MVVM with a central AppState ObservableObject
├── Models/          — Codable structs (UserProfile, CalorieTarget, MealPlan, Meal, FoodItem)
├── Services/        — Stateless pure functions (CalorieCalculator) + persistence (StorageService)
├── ViewModels/      — AppState.swift (single source of truth)
├── Utilities/       — L10n.swift (localization), LocaleManager.swift (language preference)
└── Views/           — SwiftUI views organized by feature
    ├── Onboarding/  — Welcome → ProfileSetup → GoalSetup → CalorieResult
    ├── Today/       — TodayDashboardView
    ├── MealPlan/    — MealPlanView, MealDetailView, AddFoodItemView
    ├── Profile/     — ProfileView (+ ProfileEditView inline)
    └── MainTabView  — TabView with Today / Meal Plan / Profile
```

### Key Principles

- **Stateless services.** `CalorieCalculator` is an enum with static methods — no side effects, fully testable. `StorageService` is also an enum with static methods operating on JSON files in the app's Documents directory.
- **Single AppState.** `@MainActor class AppState: ObservableObject` owns all data. Views observe it via `@ObservedObject`. No scattered `@State` for shared data.
- **No external dependencies.** The `project.yml` declares zero package dependencies. Everything is built with Apple frameworks only.
- **Local-first.** Data persists as JSON files (`profile.json`, `target.json`, `mealplan_YYYY-MM-DD.json`) in `FileManager.default.documentDirectory`.

### Localization

- **String Catalogs (`.xcstrings`).** All user-facing strings live in `Foodiary/Localizable.xcstrings`
  — Apple's modern format (Xcode 15+/iOS 17+). Single file contains English source + Indonesian translations.
- **Type-safe access** via `L10n["key"]` and `L10n["key", args...]`. Never hardcode user-facing strings.
- **Model display names** use `localizedDisplayName` computed properties (`UserProfile.Sex`,
  `ActivityLevel`, `Goal`, `Meal.MealType`). The older `displayName` delegates to it for backward compat.
- **Default language: Indonesian.** `CFBundleDevelopmentRegion = id` in Info.plist.
  `LocaleManager` (in `Utilities/`) sets `AppleLanguages` to `["id"]` on first launch.
- **Keys follow a dot-notation convention:** `category.subcategory.element` (e.g. `onboarding.welcome.tagline`,
  `label.age`, `action.continue`, `model.meal.breakfast`, `status.over_target`).
- **Plurals** use `.xcstrings` plural variations (see `food.item_count`).

## Design System

The app uses a **neubrutalist** design language — bold, playful, Gen-Z aesthetic.

### Colors
| Token | Hex | Usage |
|-------|-----|-------|
| `coral` | `#FF6B4A` | Primary buttons, target numbers, CTAs |
| `mint` | `#2DD4BF` | Under-target states, progress bar |
| `yellow` | `#FFD60A` | Attention states |
| `background` | `#FAFAF5` | Warm cream screen background |
| `black` | `#1A1A1A` | All borders, primary text, shadows |

### Signature Elements
- **3px hard black borders** on every card, button, field, badge
- **Hard offset shadows** — NOT SwiftUI `.shadow(radius:)`. Use ZStack with offset black shape behind (see `DesignSystem.swift` for `nbCard()`, `NBButtonStyle`, etc.)
- **ALL CAPS labels** via `.sectionLabel()` with `FoodiaryTypography.label` (SF Rounded Bold, 11pt)
- **SF Rounded Bold** for display/metrics/titles; system font for body
- **Push-in animation** on button press — shadow shrinks from (4,4) to (2,2)
- **Full-width cards** always need `.frame(maxWidth: .infinity, alignment: .leading)` before `.nbCard()` — otherwise cards shrink to content width

### Design Tokens
- `FoodiaryDesign` — colors, constants
- `FoodiaryTypography` — font definitions
- View modifiers: `.nbCard()`, `.nbCardCompact()`, `.nbCardColored(bg:)`, `.nbBadge(bg:)`, `.nbField()`, `.nbSegment(isActive:)`, `.sectionLabel()`
- Button styles: `NBButtonStyle`, `NBSecondaryButtonStyle`, `NBStepperButtonStyle`, `NBIconButtonStyle`
- Progress bar: `NBProgressBar(progress:isOver:)`

### Reference
- Full design spec: `DESIGN.md`
- Interactive HTML prototype: `design-prototype/index.html`
- Compare SwiftUI output against the HTML prototype for visual parity

## Calorie Calculation

Uses **Mifflin-St Jeor** equation. All logic in `CalorieCalculator`:

```
Male:   BMR = 10 × weightKg + 6.25 × heightCm - 5 × age + 5
Female: BMR = 10 × weightKg + 6.25 × heightCm - 5 × age - 161
```

Activity multipliers: Sedentary 1.2, Lightly Active 1.375, Moderately Active 1.55, Very Active 1.725

Goal adjustments: Maintain 1.0, Lose 0.90, Gain 1.10

Final target rounded to nearest 10 kcal.

## Data Flow

1. **Onboarding**: User fills profile → `CalorieCalculator.calculate(for:)` → result shown
2. **Save**: `AppState.saveProfile()` + `calculateAndSaveTarget()` → `StorageService` writes JSON
3. **Meal Plan**: `AppState.createTodayMealPlan()` creates 4 default meal slots (breakfast, lunch, snack, dinner)
4. **Food Items**: `addFoodItem(_:toMealAt:)` / `deleteFoodItem(mealIndex:itemIndex:)` → meal totals recalculate automatically via computed properties
5. **Today Dashboard**: `plannedCalories`, `remainingCalories`, `calorieProgress`, `statusMessage` are all computed properties on `AppState`

## Navigation Structure

- **Onboarding**: `NavigationStack` with `NavigationPath` — pushes Welcome → ProfileSetup → GoalSetup → CalorieResult
- **Main App**: `TabView` with 3 tabs (Today, Meal Plan, Profile), each wrapped in its own `NavigationStack`
- **Meal Detail**: `NavigationLink` or `navigationDestination(isPresented:)` from Today/MealPlan to MealDetail
- **Add Food**: `.sheet()` from MealDetail
- **Profile Edit**: `.sheet()` from Profile

## Project Configuration

- **XcodeGen**: `project.yml` → generates `Foodiary.xcodeproj`
- **Deployment target**: iOS 18.0
- **Swift version**: 6.0
- **Development team**: `296RF6QMS7`
- **Bundle ID**: `com.foodiary.app`
- **Regenerate project after adding files**: `/opt/homebrew/bin/xcodegen --spec project.yml --project .`

## Build Commands

```bash
# Regenerate project after adding/removing files
xcodegen --spec project.yml --project .

# Build for simulator
xcodebuild -project Foodiary.xcodeproj -scheme Foodiary \
  -destination 'platform=iOS Simulator,id=<DEVICE_ID>' build

# Run tests (when added)
xcodebuild test -project Foodiary.xcodeproj -scheme Foodiary \
  -destination 'platform=iOS Simulator,id=<DEVICE_ID>' \
  -only-testing:FoodiaryTests
```

Preferred simulator: iPhone 16 Pro, iOS 18.6, UDID `C33FC73C-AA6B-44BB-8359-EF4057D04515`

## Language & Tone Rules

**Mandatory — never violate:**
- ❌ Never use shame-based or judgmental language ("you failed", "cheat day", "bad food")
- ❌ Never make medical or nutrition claims
- ✅ Use neutral language: "You are 120 kcal over your estimated target" NOT "You failed your goal"
- ✅ Always include disclaimer near calorie results: "This is an estimate for planning purposes only..."
- ✅ Present goals as planning preferences, not health instructions
- ✅ Use "Weight" / "Height" — avoid "Body problem", "Ideal body", "Fat level"

## Common Pitfalls

1. **Hard shadows clip** — SwiftUI `.background()` clips to bounds. The `nbCard()` modifiers use a padding trick (add positive padding before background, negative padding after) to make room for the offset shadow. Do NOT remove these or shadows will disappear.

2. **Cards not full-width** — VStacks with `.nbCard()` need `.frame(maxWidth: .infinity, alignment: .leading)` before the modifier. Otherwise the card background sizes to the content, not the screen.

3. **Old DesignSystem constants removed** — `FoodiaryDesign.radiusMd`, `FoodiaryDesign.borderColor`, `FoodiaryDesign.borderWidth` no longer exist. Use hardcoded values or the modifier functions.

4. **UIFont doesn't take `design:`** — Use `UIFont.systemFont(ofSize:weight:)` in UIKit appearance proxies, not `design: .rounded`.

5. **`try?` in StorageService** — errors are silently swallowed. For production, replace with `do/catch` and surface errors to the user.

6. **AppIcon** — currently a solid coral square. Replace with a proper app icon before shipping.
