# 🥗 Foodiary

**Your meals, your target, your day — planned simply.**

Foodiary is a local-first iOS calorie tracker and daily meal planner. Set a personal calorie target, plan meals from breakfast to dinner, and track whether you're under, near, or over your estimated daily target. No accounts, no cloud, no complexity.

![Platform](https://img.shields.io/badge/platform-iOS%2018%2B-4BB8FA)
![Swift](https://img.shields.io/badge/swift-6.0-4BB8FA)
![License](https://img.shields.io/badge/license-MIT-black)

---

## ✨ Features

- **Personal calorie profile** — age, sex, height, weight, activity level, goal
- **Mifflin-St Jeor BMR calculation** with activity multipliers and goal adjustments
- **Daily meal planning** — 4 fixed slots: Breakfast, Lunch, Snack, Dinner
- **Food search** — query FatSecret and USDA databases for nutritional info
- **Manual food entry** — add name, calories, and optional notes
- **Live calorie tracking** — planned vs remaining with progress visualization
- **Macro tracking** — protein, carbs, fat breakdown
- **Weekly plan view** — browse past and future meal plans
- **Insights** — calorie trends and observations
- **Dark mode** — full dynamic theming with Light / Dark / System toggle
- **Bilingual** — Indonesian (default) and English with live language switching
- **Neutral language** — never shames. "120 kcal over your estimated target", not "you failed"
- **Local-first** — all data stored on device via SwiftData. No account, no internet required
- **Edit & recalculate** — full onboarding-style profile edit flow, target updates automatically

## 🎨 Design

Pulse v2 — modern, clean, planning cockpit aesthetic. Soft shadows, gradient hero cards, dynamic dark mode colors, and rounded surfaces.

## 🏗 Architecture

```
MVVM + Central AppState
├── Models/          SwiftData @Model classes
├── Services/        CalorieCalculator, MealPlanService, FoodDatabase/
├── ViewModels/      AppState + OnboardingViewModel
├── DesignSystem/    Colors, Typography, ButtonStyles, Modifiers, Components
├── Utilities/       L10n, LocaleManager, ThemeManager
└── Views/           SwiftUI, 4-tab navigation
```

- **Zero external dependencies** — Apple frameworks only
- **SwiftData persistence** — `@Model` classes, `PersistenceService` protocol
- **Stateless calculator** — fully testable pure functions
- **Tab-based navigation** — Today | Plan | Insights | Profile
- **Onboarding flow** — Welcome → Profile → Goal → Result
- **Full localization** — String Catalogs (`.xcstrings`), Indonesian + English

## 🚀 Quick Start

```bash
# Clone
git clone git@github.com:MainActorDev/Foodiary.git
cd Foodiary

# Generate Xcode project
xcodegen --spec project.yml --project .

# Build & run on simulator
xcodebuild -project Foodiary.xcodeproj -scheme Foodiary \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build

# Or open in Xcode
open Foodiary.xcodeproj
```

**Requirements:** Xcode 16+, iOS 18.0+, [XcodeGen](https://github.com/yonaskolb/XcodeGen)

## 📱 Screens

| Screen | Description |
|--------|-------------|
| Welcome | App intro + disclaimer |
| Profile Setup | Age, sex, height, weight (ruler-based input) |
| Goal Setup | Activity level + goal selection |
| Calorie Result | BMR, maintenance, target breakdown with energy balance bar |
| Today Dashboard | Hero card, macro grid, meal timeline, action strip |
| Plan | Weekly calendar with day detail cards |
| Insights | Calorie trends and observations |
| Meal Detail | Food items with add/search/delete |
| Profile | View details, edit profile (full flow), settings |
| Settings | Theme (Light/Dark/System) + language (ID/EN) switching |

## 📂 Project Structure

```
Foodiary/
├── FoodiaryApp.swift              App entry point + SwiftData container
├── ContentRootView.swift          Onboarding vs. main app routing
├── Models/                        SwiftData @Model classes
├── Services/                      Calculator, persistence, food database
├── ViewModels/                    AppState + OnboardingViewModel
├── DesignSystem/                  Pulse v2 tokens, styles, modifiers
├── Utilities/                     L10n, LocaleManager, ThemeManager
├── Views/
│   ├── Onboarding/                4 onboarding screens
│   ├── Today/                     Dashboard, hero, macros, timeline, action strip
│   ├── Plan/                      Weekly calendar
│   ├── Insights/                  Trends
│   ├── MealPlan/                  Meal detail + food search/add
│   ├── Profile/                   Profile + ProfileEditFlow
│   ├── Settings/                  Theme + language
│   └── MainTabView.swift          4-tab navigation
├── AGENTS.md                      AI agent guidelines
├── FEATURES.md                    Feature inventory
└── project.yml                    XcodeGen spec
```

## 📋 Feature Roadmap

See [`FEATURES.md`](FEATURES.md) for the full inventory.

## 🤖 For AI Agents

If you're an AI coding agent working on this project, start with [`AGENTS.md`](AGENTS.md). It covers architecture, design system rules, common pitfalls, build commands, and mandatory language/tone guidelines.

## 📄 License

MIT — free for personal use. This is a non-commercial app.
