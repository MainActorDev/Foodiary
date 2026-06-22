# Foodiary Pulse v2 — Implementation Audit & Phase Plan

## Status

Prepared on 2026-06-22 after the Pulse v2 prototype/spec-board alignment pass.

This is an implementation planning document. It does **not** approve blind SwiftUI changes by itself. The next coding phase should start only after this audit is accepted.

## Source of truth

| Artifact | Role |
|---|---|
| `design-prototype/pulse-v2-proposal.html` | Canonical visual direction for Pulse v2 |
| `design-prototype/pulse-v2-screen-spec-board.html` | Screen-by-screen Pulse v2 mapping for current app surfaces |
| `docs/concepts/pulse-v2-design-direction.md` | Product/design rationale |
| `docs/concepts/pulse-v2-stitching-plan.md` | Component/state/copy stitching plan |
| `docs/concepts/pulse-v2-implementation-audit.md` | This implementation audit and phase plan |

## Current repo state observed

The working tree already contains unrelated or pre-existing changes, including:

- modified `Foodiary.xcodeproj/project.pbxproj`;
- modified `Foodiary/Info.plist`;
- modified `Foodiary/Localizable.xcstrings`;
- modified `Foodiary/Views/MealPlan/AddFoodItemView.swift`;
- modified `project.yml`;
- untracked `Configuration/`;
- untracked `Foodiary/Services/FoodDatabase/`;
- untracked design prototypes and concept docs.

Implementation must avoid overwriting these changes. Before coding, re-run:

```bash
git status --short
```

If the Food Database/API changes are still uncommitted, treat them as in-progress user work and preserve them.

## Screen/code inventory audited

| Area | Current file | Current state | Pulse v2 implementation implication |
|---|---|---|---|
| App root/onboarding router | `Foodiary/ContentRootView.swift` | SwiftData-backed root chooses onboarding vs main app | Keep navigation structure; update tint/background/nav styling only |
| App shell | `Foodiary/Views/MainTabView.swift` | 4 tabs: Today, Plan, Insights, Profile. Insights is inline in same file | Needs Pulse shell decision: 4-tab app + center quick-add action vs true 5-destination tab shell |
| Today | `Foodiary/Views/Today/TodayDashboardView.swift` | Calorie Ring layout with circular progress, summary tiles, macro bars, SF Symbols meal icons | Replace ring mental model with Pulse budget hero, segmented bar, macro chips, emoji meal tiles |
| Plan | `Foodiary/Views/Plan/PlanView.swift` | Week strip and day detail already exist; uses ring cards/progress bar/SF Symbols | Good functional base; restyle to week readiness cockpit and emoji meal slots |
| Meal detail | `Foodiary/Views/MealPlan/MealDetailView.swift` | Simple food list plus Add Food sheet; read-only past-day state | Needs meal-header hero, segmented/macro context, empty state, item rows, read-only treatment |
| Add food | `Foodiary/Views/MealPlan/AddFoodItemView.swift` | Already search-first, async provider search, manual fallback, provider badges | Preserve functionality; restyle as Pulse search command center. Do not regress API provider state handling |
| Profile | `Foodiary/Views/Profile/ProfileView.swift` | Details card, target card, disclaimer, edit/reset actions | Convert to estimate context surface with target hero and trust/disclaimer card |
| Profile edit | `Foodiary/Views/Profile/ProfileView.swift` | Inline `ProfileEditView` with existing form controls | Restyle form controls; keep state/save behavior |
| Welcome | `Foodiary/Views/Onboarding/WelcomeView.swift` | Very simple emoji/text/CTA | Needs Pulse intro hero and planning-focused copy treatment |
| Profile setup | `Foodiary/Views/Onboarding/ProfileSetupView.swift` | Mixed old neubrutalist borders/hard strokes; hardcoded nav title | Needs Pulse cards/steppers, localized nav title, progress treatment |
| Goal setup | `Foodiary/Views/Onboarding/GoalSetupView.swift` | Mixed old borders; hardcoded nav title | Needs Pulse segment cards and “planning preference” framing |
| Calorie result | `Foodiary/Views/Onboarding/CalorieResultView.swift` | Large target number and stat cards, old neubrutalist stat styling; hardcoded nav title | Needs Pulse estimate hero, source-of-estimate metrics, disclaimer nearby |
| Integer stepper | `Foodiary/Views/Onboarding/IntStepperField.swift` | Old thick black border style | Replace with shared Pulse stepper field |
| Design system | `Foodiary/DesignSystem.swift` | “Calorie Ring” system: blue/green/amber, ring cards, progress ring/bar, legacy NB aliases | Create Pulse tokens/components; keep aliases during migration to avoid breaking all screens at once |
| Meal model icons | `Foodiary/Models/Meal.swift` | `MealType.icon` returns SF Symbols | Add Pulse emoji/tint helpers or map emoji in UI components without changing persistence |
| App state | `Foodiary/ViewModels/AppState.swift` | SwiftData, cached profile/today plan, computed calorie/macro/plan state | Enough data exists for Today/Plan/Profile; Add Food central action needs routing decision |
| Localization | `Foodiary/Localizable.xcstrings` | Has disclaimer, Insights tab/nav, estimated-target copy; some hardcoded strings remain in Swift files | Add missing Pulse copy keys before replacing hardcoded UI text |

## Main implementation decisions before coding

### 1. App shell / Add Food placement

The canonical Pulse v2 prototype shows five destinations:

- Today;
- Plan;
- Add Food;
- Insights;
- Profile.

The current Swift app has four tabs:

- Today;
- Plan;
- Insights;
- Profile.

`AddFoodItemView` currently requires a target meal/date through `onSave`, so it is not truly standalone.

**Approved implementation:** use a Pulse bottom shell with four normal tabs plus a centered “Add Food” action. The center action should open a quick-add router sheet that asks where to add the food:

1. Today or selected Plan date;
2. Breakfast / Lunch / Snack / Dinner;
3. Then reuse `AddFoodItemView`.

This preserves the approved Pulse v2 visual hierarchy without pretending Add Food is a stateless tab.

### 2. Design system migration strategy

Do not rewrite every screen in one pass. First add Pulse tokens/components while preserving existing `Ring*`/`NB*` aliases, then migrate screen-by-screen.

Recommended approach:

- Add Pulse tokens to `FoodiaryDesign` rather than deleting existing names immediately.
- Add Pulse-specific components/modifiers to `Foodiary/DesignSystem.swift` or a new file under `Foodiary/Views/Components/`.
- Keep legacy aliases until all screens compile.
- Remove or deprecate Calorie Ring components only after the visual migration is complete.

### 3. Insights scope

`InsightsView` exists inline in `MainTabView.swift`. It is functional but minimal.

Recommended approach:

- Phase 1 can keep the inline view but restyle it enough to match Pulse.
- Later, extract it to `Foodiary/Views/Insights/InsightsView.swift` if the file grows.

### 4. Localized copy first, especially hardcoded strings

Hardcoded strings currently include examples like:

- `About You`;
- `Your Goal`;
- `Your Target`;
- `Protein`, `Carbs`, `Fat` in several places;
- `Optional — enter grams for each macronutrient.`;
- `No food logged yet` in Insights;
- status pills like `TODAY`, `PLANNING`, `VIEW ONLY`.

Before UI polish, add/verify localization keys and Indonesian translations. Keep copy neutral:

- use “estimated target”;
- use “above estimate” / “above your estimated target”;
- use “planning preference”;
- do not use shame language or medical/nutrition claims.

## Phase plan

### Phase 0 — Lock scope and branch hygiene

**Goal:** prevent overwriting existing work and confirm the implementation target.

**Files touched:** none unless creating a branch.

**Steps:**

1. Re-run `git status --short`.
2. Confirm whether existing Food Database/API changes are intentionally part of the current working branch.
3. Confirm the app-shell decision: four tabs + centered Add Food action, or true five-tab shell.
4. Confirm no SwiftUI implementation begins until Phase 1 is approved.

**Verification:** no files changed.

### Phase 1 — Pulse foundation/components

**Goal:** create the shared visual system needed by all screens.

**Likely files:**

- Modify: `Foodiary/DesignSystem.swift`
- Optional create: `Foodiary/Views/Components/PulseComponents.swift`
- Modify: `Foodiary/Localizable.xcstrings`

**Work:**

1. Add Pulse color tokens:
   - background/off-white lavender;
   - surface;
   - surface soft;
   - primary violet;
   - primary dark/ink;
   - mint;
   - cyan;
   - amber;
   - border;
   - muted text.
2. Add Pulse typography helpers with tabular metric digits.
3. Add Pulse card modifiers:
   - standard card;
   - compact card;
   - hero card;
   - dark action strip.
4. Add Pulse buttons:
   - primary violet;
   - secondary surface;
   - icon/stepper.
5. Add data components:
   - `PulseBudgetHero`;
   - `PulseSegmentedBudgetBar`;
   - `PulseMetricTile`;
   - `PulseMacroChip` or `PulseMacroRow`.
6. Add meal components:
   - `PulseMealIconTile` using 🍳/🍱/🍌/🍽️;
   - `PulseMealCard` for Today/Plan.
7. Keep existing `Ring*` and `NB*` APIs available until later phases compile.

**Verification:**

```bash
xcodegen --spec project.yml --project .
xcodebuild -project Foodiary.xcodeproj -scheme Foodiary -destination 'platform=iOS Simulator,id=C33FC73C-AA6B-44BB-8359-EF4057D04515' build
```

### Phase 2 — App shell and navigation

**Goal:** make the main shell match Pulse v2 without breaking data flow.

**Likely files:**

- Modify: `Foodiary/Views/MainTabView.swift`
- Optional create: `Foodiary/Views/Components/PulseTabBar.swift`
- Optional create: `Foodiary/Views/MealPlan/QuickAddRouterView.swift`
- Modify: `Foodiary/Localizable.xcstrings`

**Work:**

1. Restyle navigation/tint/tab bar around Pulse tokens.
2. If approved, implement centered Add Food action as a sheet/router rather than a normal tab.
3. Keep existing Today → Meal Detail navigation working.
4. Keep Plan → Meal Detail navigation working.
5. Keep Profile sheet behavior working.
6. Make Insights route visually consistent.

**Verification:**

- Build succeeds.
- Launch in simulator.
- Tap all tabs/actions.
- Add Food route reaches a valid meal/date target before saving.

### Phase 3 — Today command center

**Goal:** replace circular Calorie Ring dashboard with Pulse v2 daily planning cockpit.

**Likely files:**

- Modify: `Foodiary/Views/Today/TodayDashboardView.swift`
- Reuse: `Foodiary/DesignSystem.swift` / Pulse components
- Modify: `Foodiary/Localizable.xcstrings`

**Work:**

1. Replace `ringSection` with `PulseBudgetHero`.
2. Replace separate summary tiles/status badge with hero-integrated metrics and next action.
3. Replace ring progress with segmented budget bar.
4. Convert macro section to Pulse chips/rows.
5. Replace SF Symbol meal icons with emoji meal tiles.
6. Preserve empty state CTA.
7. Keep `onTapMeal` and `onCreateMealPlan` behavior unchanged.

**Verification:**

- Today renders with and without a meal plan.
- Tapping a meal opens `MealDetailView`.
- Creating a meal plan still works.
- Over/under/empty estimate copy remains neutral.

### Phase 4 — Plan week readiness

**Goal:** make weekly planning read as readiness, not just a date picker.

**Likely files:**

- Modify: `Foodiary/Views/Plan/PlanView.swift`
- Reuse: shared Pulse week strip/meal cards
- Modify: `Foodiary/Localizable.xcstrings`

**Work:**

1. Restyle week strip to match spec-board readiness markers.
2. Replace day header/status/progress with Pulse day readiness hero.
3. Reuse Pulse segmented budget bar.
4. Replace `PlanMealCardView` with shared Pulse meal card.
5. Preserve read-only state for past days.
6. Preserve `createPlanAndAddFood(type:)` behavior.

**Verification:**

- Switch weeks.
- Tap future/today date.
- Tap meal slot and return.
- Past date remains read-only.

### Phase 5 — Meal detail + Add Food

**Goal:** make the meal-level flow feel like part of the same Pulse cockpit.

**Likely files:**

- Modify: `Foodiary/Views/MealPlan/MealDetailView.swift`
- Modify: `Foodiary/Views/MealPlan/AddFoodItemView.swift`
- Modify: `Foodiary/Localizable.xcstrings`

**Work:**

1. Add meal hero header using emoji tile, meal name, item count, calories.
2. Restyle item list rows/cards.
3. Improve empty state with one clear Add Food CTA.
4. Preserve read-only delete restrictions.
5. Restyle Add Food search field/results/manual fallback with Pulse surfaces.
6. Preserve async search debounce, cancellation, provider badges, and manual validation.
7. Avoid changing food-provider behavior during UI work.

**Verification:**

- Search path works.
- No-results manual fallback works.
- Manual save validates name/calories.
- Add result saves to the correct meal/date.
- Delete remains unavailable in read-only mode.

### Phase 6 — Onboarding and estimate context

**Goal:** align first-run setup with Pulse v2 and clarify the estimate calmly.

**Likely files:**

- Modify: `Foodiary/ContentRootView.swift`
- Modify: `Foodiary/Views/Onboarding/WelcomeView.swift`
- Modify: `Foodiary/Views/Onboarding/ProfileSetupView.swift`
- Modify: `Foodiary/Views/Onboarding/GoalSetupView.swift`
- Modify: `Foodiary/Views/Onboarding/CalorieResultView.swift`
- Modify: `Foodiary/Views/Onboarding/IntStepperField.swift`
- Modify: `Foodiary/Localizable.xcstrings`

**Work:**

1. Replace old hard-bordered steppers/segments with Pulse controls.
2. Localize hardcoded navigation titles.
3. Reframe goal selection as planning preference.
4. Make `CalorieResultView` use Pulse estimate hero and disclaimer placement.
5. Preserve onboarding route order and save behavior.

**Verification:**

- Fresh install/onboarding path works from Welcome → Profile → Goal → Result.
- Create Meal Plan transitions to main app.
- Edit profile route goes back correctly.
- Indonesian and English copy render.

### Phase 7 — Profile and Insights polish

**Goal:** complete the full-app system and remove the remaining clinical/ring styling.

**Likely files:**

- Modify: `Foodiary/Views/Profile/ProfileView.swift`
- Modify: `Foodiary/Views/MainTabView.swift` or extract `Foodiary/Views/Insights/InsightsView.swift`
- Modify: `Foodiary/Localizable.xcstrings`

**Work:**

1. Convert Profile target area into Pulse estimate context card.
2. Keep disclaimer visible but not alarmist.
3. Restyle profile details and edit form controls.
4. Restyle Insights cards with neutral observation language.
5. Consider extracting `InsightsView` out of `MainTabView.swift` if it grows.

**Verification:**

- Profile edit/save still recalculates target.
- Reset alert still works.
- Insights displays empty/no-food state without judgmental copy.

### Phase 8 — Cleanup and visual QA

**Goal:** remove migration leftovers and verify the app against the prototype/spec board.

**Likely files:**

- `Foodiary/DesignSystem.swift`
- Any migrated view files
- `Foodiary/Localizable.xcstrings`

**Work:**

1. Search for remaining `ringCard`, `Ring*`, `NB*`, old hard black 3px borders, and SF Symbol meal icons.
2. Decide whether to keep compatibility aliases or mark them deprecated for one more cycle.
3. Compare simulator screenshots against:
   - `design-prototype/pulse-v2-proposal.html`;
   - `design-prototype/pulse-v2-screen-spec-board.html`.
4. Check Dynamic Type enough to catch clipping.
5. Check Indonesian text expansion.
6. Ensure no shame/medical claims slipped in.

**Verification:**

```bash
xcodegen --spec project.yml --project .
xcodebuild -project Foodiary.xcodeproj -scheme Foodiary -destination 'platform=iOS Simulator,id=C33FC73C-AA6B-44BB-8359-EF4057D04515' build
```

Then run simulator visual QA for the core routes:

1. onboarding;
2. Today empty;
3. Today populated;
4. Plan current week;
5. Meal detail empty/populated;
6. Add Food search/manual;
7. Insights;
8. Profile.

## Recommended first coding slice

Start with **Phase 1 only**.

Why:

- It creates the design vocabulary once.
- It minimizes conflict with active feature/API changes.
- It gives later screen work reusable components.
- It reduces the chance of Pulse drifting again while implementation proceeds.

Do **not** start by redesigning every screen directly. That will duplicate styles and make later corrections expensive.

## Acceptance criteria before Phase 1 is considered complete

- `Foodiary/DesignSystem.swift` or shared component files expose Pulse tokens/components.
- Existing app still builds.
- No current functionality is removed.
- Existing `Ring*`/`NB*` usage still compiles.
- Meal emoji helpers exist or are implemented in the shared meal tile component.
- New localized strings introduced by Phase 1 are present in both English and Indonesian.

## Decisions locked for implementation

1. The Pulse shell will use **four normal tabs plus a centered Add Food action/router**.

## Remaining implementation choices

1. Should later phases extract shared components into `Foodiary/Views/Components/`, or keep all shared design primitives inside `Foodiary/DesignSystem.swift` for now?
2. Should Insights remain in `MainTabView.swift` for this revamp, or be extracted into `Views/Insights/InsightsView.swift` during Phase 7?
