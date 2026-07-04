# AGENTS.md — Foodiary

Guidelines for AI coding agents working on this project.
Last updated: 2026-07-04

## Project Overview

Foodiary is a local-first iOS calorie tracker and daily meal planner.
Built with SwiftUI, targeting iOS 18+. No external dependencies, no backend,
no cloud sync. The app helps users create a personalized estimated daily
calorie target and plan meals from breakfast to dinner.

## Architecture

```
MVVM with a central AppState ObservableObject
├── Models/          — SwiftData @Model classes (UserProfile, CalorieTarget, MealPlan, Meal, FoodItem)
├── Services/        — CalorieCalculator (pure), MealPlanService, ProfileService, MigrationService, FoodDatabase/
├── ViewModels/      — AppState.swift (single source of truth), OnboardingViewModel.swift
├── Utilities/       — L10n.swift (localization), LocaleManager.swift, ThemeManager.swift, DateFormatter+Static.swift
└── Views/           — SwiftUI views organized by feature
    ├── Onboarding/  — Welcome → ProfileSetup → GoalSetup → CalorieResult
    ├── Today/       — TodayDashboardView, HeroSection, MacroGrid, MealTimeline, ActionStrip
    ├── Plan/        — PlanView, WeekCard, DayDetailCard, WeekSummary
    ├── Insights/    — InsightsView
    ├── MealPlan/    — MealDetailView, AddFoodItemView, SearchFoodView, AddFoodRouteView
    ├── Profile/     — ProfileView + ProfileEditFlow (reuses onboarding views)
    ├── Settings/    — SettingsView (theme + language switching)
    └── MainTabView  — TabView with Today / Plan / Insights / Profile
```

### Key Principles

- **SwiftData persistence.** All models use `@Model`. `PersistenceService` protocol abstracts the `ModelContext`. Data persists in the app's SwiftData store (not JSON files — the old StorageService has been replaced and migrated by `MigrationService`).
- **Single AppState.** `@MainActor class AppState: ObservableObject` owns all data. Views observe it via `@ObservedObject`. No scattered `@State` for shared data.
- **No external dependencies.** The `project.yml` declares zero package dependencies. Everything is built with Apple frameworks only.
- **Local-first.** Data persists via SwiftData. No network required for core functionality.

### Localization

- **String Catalogs (`.xcstrings`).** All user-facing strings live in `Foodiary/Localizable.xcstrings`
  — Apple's modern format (Xcode 15+/iOS 17+). Single file contains English source + Indonesian translations.
- **Type-safe access** via `L10n["key"]` and `L10n["key", args...]`. Never hardcode user-facing strings.
- **Model display names** use `localizedDisplayName` computed properties (`UserProfile.Sex`,
  `ActivityLevel`, `Goal`, `Meal.MealType`). The older `displayName` delegates to it for backward compat.
- **Default language: Indonesian.** `CFBundleDevelopmentRegion = id` in Info.plist.
  `LocaleManager` (in `Utilities/`) sets `AppleLanguages` to `["id"]` on first launch.
- **Runtime language switching** via Settings → Language picker. `LocaleManager.switchTo(_:)`
  updates `UserDefaults`, invalidates the `L10n` bundle cache, and triggers SwiftUI re-render.
- **Keys follow a dot-notation convention:** `category.subcategory.element` (e.g. `onboarding.welcome.tagline`,
  `label.age`, `action.continue`, `model.meal.breakfast`, `status.over_target`).
- **Plurals** use `.xcstrings` plural variations (see `food.item_count`).
- **Dates** use `DateFormatter.localizedFullDate` with locale set dynamically from `localeManager.selectedLanguage`.

### Theming

- **Dark mode** is fully supported via dynamic `UIColor { tc in ... }` color tokens in `Colors.swift`.
  All `pulse*` tokens automatically resolve light/dark variants.
- **Theme switching** via Settings → Theme picker (Light / Dark / System). `ThemeManager.shared`
  is an `ObservableObject` injected into the environment. `.preferredColorScheme()` applies the selection.
- **`pulseInkFixed`** — always-dark color for inverted surfaces (action strip). Use instead of `pulseInk`
  when a surface must stay dark in both modes.
- **iOS 26 Liquid Glass** — the nav bar uses `configureWithOpaqueBackground()` to prevent iOS 26
  from wrapping toolbar buttons in Liquid Glass circles. Do not change to transparent.

## Design System

The app uses the **Pulse v2** design language — modern, clean, planning cockpit aesthetic.

### Colors (Pulse v2)
| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `pulsePrimary` | `#4BB8FA` | `#4BB8FA` | Primary accent, buttons, targets |
| `pulseBackground` | `#F6F7FF` | `#0C0C14` | Screen background |
| `pulseSurface` | `#FFFFFF` | `#1A1A2E` | Cards, sheets |
| `pulseSurfaceSoft` | `#EEF0FF` | `#222238` | Inactive states, subtle fills |
| `pulseInk` | `#15142A` | `#F4F4F8` | Primary text (dynamic) |
| `pulseInkFixed` | `#15142A` | `#15142A` | Inverted surfaces (always dark) |
| `pulseMuted` | `#6B6880` | `#8E8EA0` | Secondary text |
| `pulseBorder` | `#C8C6D0` | `#2A2A40` | Strokes, dividers |

### Design Tokens
- `FoodiaryDesign` — all colors (dynamic for dark mode), meal tint helpers
- `FoodiaryTypography` — font definitions (pulse* variants)
- View modifiers: `.pulseCard()`, `.pulseBadge()`, `.pulseSectionLabel()`, `.pulseBackButton()`
- Button styles: `PulsePrimaryButtonStyle`, `PulseSecondaryButtonStyle`, `PulseIconButtonStyle`, `PulseStepperButtonStyle`
- Tab bar: `RingTabBarModifier` (opaque background)
- Nav bar: `RingNavBarModifier` (opaque background, iOS 26 Liquid Glass safe)

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
2. **Save**: `AppState.saveProfile()` + `calculateAndSaveTarget()` → SwiftData persist
3. **Meal Plan**: `AppState.createTodayMealPlan()` creates 4 default meal slots (breakfast, lunch, snack, dinner)
4. **Food Items**: `addFoodItem(_:toMealAt:)` / `deleteFoodItem(mealIndex:itemIndex:)` → meal totals recalculate automatically via computed properties
5. **Today Dashboard**: `plannedCalories`, `remainingCalories`, `calorieProgress`, `statusMessage` are all computed properties on `AppState`
6. **Profile Edit**: `ProfileEditFlow` reuses onboarding views (ProfileSetup → GoalSetup → CalorieResult) pre-filled with current profile

## Navigation Structure

- **Onboarding**: `NavigationStack` with `NavigationPath` — pushes Welcome → ProfileSetup → GoalSetup → CalorieResult
- **Main App**: `TabView` with 4 tabs (Today, Plan, Insights, Profile), each wrapped in its own `NavigationStack`
- **Meal Detail**: `navigationDestination(isPresented:)` from Today/Plan to MealDetail
- **Add Food**: `.sheet()` from MealDetail
- **Profile Edit**: `.sheet()` presenting `ProfileEditFlow` (full onboarding-style flow)
- **Settings**: `navigationDestination(isPresented:)` from Profile
- **Tab bar visibility**: Driven by root views via `.toolbar(showX ? .hidden : .visible, for: .tabBar)` + `.animation()` for smooth transitions

## SwiftData Relationship Ordering

SwiftData `@Relationship` arrays have **no guaranteed order** after fetch. `MealPlan.sortedMeals`
sorts by canonical `MealType.allCases` order (breakfast → lunch → snack → dinner).
**Always use `plan.sortedMeals`** — never `plan.meals` directly in UI or index-based service calls.

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

1. **`plan.meals` ordering** — SwiftData relationships are unordered. Always use `plan.sortedMeals` for display and index-based access. Never use `plan.meals` directly in UI.

2. **`pulseInk` is dynamic** — it flips to near-white in dark mode. For inverted surfaces that must stay dark (action strip, etc.), use `pulseInkFixed`.

3. **iOS 26 Liquid Glass** — nav bar must use `configureWithOpaqueBackground()`. Transparent causes iOS 26 to wrap toolbar buttons in Liquid Glass circles, conflicting with custom button styles.

4. **Tab bar animation** — drive `.toolbar(.hidden/.visible, for: .tabBar)` from the **root** view of each tab (not the pushed view) with `.animation()` for smooth transitions.

5. **Hardcoded `Color.white.opacity(0.6)`** — invisible in dark mode. Use `FoodiaryDesign.pulseSurface` for card backgrounds that must adapt.

6. **`DateFormatter.indonesianDate` removed** — use `DateFormatter.localizedFullDate` with `.locale = Locale(identifier: localeManager.selectedLanguage)` for dates that follow the app language.

7. **`try?` in services** — errors are silently swallowed in `MealPlanService`. For production, replace with `do/catch` and surface errors to the user.

8. **AppIcon** — currently a solid coral square. Replace with a proper app icon before shipping.
