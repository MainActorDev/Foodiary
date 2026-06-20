# 🥗 Foodiary

**Your meals, your target, your day — planned simply.**

Foodiary is a local-first iOS calorie tracker and daily meal planner. Set a personal calorie target, plan meals from breakfast to dinner, and track whether you're under, near, or over your estimated daily target. No accounts, no cloud, no complexity.

![Platform](https://img.shields.io/badge/platform-iOS%2018%2B-coral)
![Swift](https://img.shields.io/badge/swift-6.0-coral)
![License](https://img.shields.io/badge/license-MIT-black)
[![Design](https://img.shields.io/badge/design-neubrutalist-FF6B4A)](DESIGN.md)

---

## ✨ Features

- **Personal calorie profile** — age, sex, height, weight, activity level, goal
- **Mifflin-St Jeor BMR calculation** with activity multipliers and goal adjustments
- **Daily meal planning** — 4 fixed slots: Breakfast, Lunch, Snack, Dinner
- **Manual food entry** — add name, calories, and optional notes
- **Live calorie tracking** — planned vs remaining with progress bar
- **Neutral language** — never shames. "120 kcal over your estimated target", not "you failed"
- **Local-first** — all data stored as JSON on device. No account, no internet required
- **Edit & recalculate** — change your profile anytime, target updates automatically

## 🎨 Design

Neubrutalist — bold, playful, Gen-Z aesthetic. Think hard black borders, chunky offset shadows, vibrant flat colors. No gradients, no blur, just confidence.

| Color | Hex | Role |
|-------|-----|------|
| Coral | `#FF6B4A` | Primary buttons, targets, CTAs |
| Mint | `#2DD4BF` | Under target, progress |
| Yellow | `#FFD60A` | Attention states |
| Cream | `#FAFAF5` | Background |

Full design spec: [`DESIGN.md`](DESIGN.md)  
Interactive prototype: [`design-prototype/index.html`](design-prototype/index.html)

## 🏗 Architecture

```
MVVM + Central AppState
├── Models/          Codable structs
├── Services/        CalorieCalculator (pure) + StorageService (JSON)
├── ViewModels/      AppState (single source of truth)
└── Views/           SwiftUI, 3-tab navigation
```

- **Zero external dependencies** — Apple frameworks only
- **Stateless calculator** — fully testable pure functions
- **Tab-based navigation** — Today | Meal Plan | Profile
- **Onboarding flow** — Welcome → Profile → Goal → Result

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

**Requirements:** Xcode 26+, iOS 18.0+, [XcodeGen](https://github.com/yonaskolb/XcodeGen)

## 📱 Screens

| Screen | Description |
|--------|-------------|
| Welcome | App intro + disclaimer |
| Profile Setup | Age, sex, height, weight |
| Goal Setup | Activity level + goal selection |
| Calorie Result | BMR, maintenance, target breakdown |
| Today Dashboard | Target, planned/remaining, meal summaries |
| Meal Plan | 4 meal slots with calorie totals |
| Meal Detail | Food items with add/edit/delete |
| Profile | View/edit details, recalculate, reset |

## 📂 Project Structure

```
Foodiary/
├── FoodiaryApp.swift              App entry point
├── DesignSystem.swift             Neubrutalist tokens + modifiers
├── Models/                        5 data models
├── Services/                      Calculator + persistence
├── ViewModels/                    AppState
├── Views/
│   ├── Onboarding/                4 onboarding screens
│   ├── Today/                     Dashboard
│   ├── MealPlan/                  Meal management + add food
│   ├── Profile/                   Profile + edit
│   └── MainTabView.swift          3-tab navigation
├── DESIGN.md                      Design token spec
├── AGENTS.md                      AI agent guidelines
├── FEATURES.md                    Feature inventory
└── project.yml                    XcodeGen spec
```

## 📋 Feature Roadmap

See [`FEATURES.md`](FEATURES.md) for the full inventory.

**MVP (shipped):** 51 features — profile, calorie calculation, meal planning, dashboard, design system, persistence.

**Coming next:**
- Unit tests
- Inline food item editing
- Proper error handling
- Accessibility (VoiceOver, Dynamic Type)
- Dark mode

## 🤖 For AI Agents

If you're an AI coding agent working on this project, start with [`AGENTS.md`](AGENTS.md). It covers architecture, design system rules, common pitfalls, build commands, and mandatory language/tone guidelines.

## 📄 License

MIT — free for personal use. This is a non-commercial app.

---

Built with ❤️ and hard black borders.
