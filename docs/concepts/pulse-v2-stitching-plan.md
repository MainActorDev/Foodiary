# Foodiary Pulse v2 — Full-App Stitching Plan

## Status

This is a preparation document, not SwiftUI implementation.

The current preferred direction is **Pulse v2**: a clean, modern, data-forward food planning cockpit with a violet/mint/off-white visual language, bold daily metrics, weekly readiness, search-first food entry, neutral insights, and clear estimate context.

The goal is to apply the same direction to **every screen**, not only Today.

## What we confirmed from the repo

The current Foodiary screen inventory under `Foodiary/Views` is:

1. `MainTabView.swift`
2. `Today/TodayDashboardView.swift`
3. `Plan/PlanView.swift`
4. `MealPlan/MealDetailView.swift`
5. `MealPlan/AddFoodItemView.swift`
6. `Profile/ProfileView.swift`
7. `Onboarding/WelcomeView.swift`
8. `Onboarding/ProfileSetupView.swift`
9. `Onboarding/GoalSetupView.swift`
10. `Onboarding/CalorieResultView.swift`
11. `Onboarding/IntStepperField.swift`

So the stitching work must cover:

- onboarding;
- main app shell;
- Today;
- weekly Plan;
- meal detail;
- add food/search/manual entry;
- profile/settings/estimate context;
- shared form controls.

## The core stitching idea

Pulse v2 should not be applied as “make every screen purple.”

It should be applied as a shared product system:

> Every screen should answer one clear planning question, use the same visual grammar, and lead to one obvious next action.

| Screen area | User question |
|---|---|
| Welcome | “What is Foodiary for?” |
| Profile setup | “What information is needed to estimate my target?” |
| Goal setup | “What planning preference should this estimate use?” |
| Calorie result | “What estimate did the app calculate, and what does it mean?” |
| Main tabs | “Where am I in the app?” |
| Today | “Where am I right now, and what should I adjust next?” |
| Plan | “Is my week prepared?” |
| Meal detail | “What belongs in this meal slot?” |
| Add food | “How quickly can I find/add the right food?” |
| Profile | “What estimate is this based on?” |

## What we should prepare before implementation

### 1. Pulse design tokens

We need one token source before touching screens.

Recommended token groups:

#### Color

| Token | Purpose |
|---|---|
| `pulseBackground` | cool off-white / light lavender app background |
| `pulseSurface` | primary white card surface |
| `pulseSurfaceSoft` | tinted lavender/blue secondary surface |
| `pulsePrimary` | electric violet for main actions and active states |
| `pulsePrimaryDark` | deep violet/navy for dark hero surfaces |
| `pulseMint` | positive/available/under-estimate state |
| `pulseCyan` | data highlight and gradient support |
| `pulseAmber` | attention/empty/planning reminder state |
| `pulseInk` | primary text |
| `pulseMuted` | secondary text |
| `pulseBorder` | hairline divider/border |

Important: the design-system search suggested a green health palette, but for this chosen direction we should keep the Pulse violet/mint identity. We can borrow its structural advice — mobile-first, high contrast, whitespace, single primary CTA — without changing the agreed brand palette.

#### Typography

Use iOS-native fonts, but mimic the prototype hierarchy:

| Role | Direction |
|---|---|
| Display metric | very bold rounded/system display, tabular digits |
| Screen title | bold, compact, modern |
| Section label | uppercase or small-caps, high weight, letter spacing |
| Body | readable system body |
| Caption/helper | muted, clear, not too tiny |

Key requirement: calorie numbers must use **tabular digits** so values do not visually jump.

#### Spacing

Use a consistent 4/8pt rhythm:

- screen horizontal padding: 20pt;
- card padding: 16–20pt;
- section gap: 20–24pt;
- compact item gap: 8–12pt;
- bottom content inset must account for the tab bar/safe area.

#### Radius

| Token | Suggested use |
|---|---|
| small radius | chips, badges, compact fields |
| medium radius | buttons, search fields, meal icons |
| large radius | cards and panels |
| extra-large radius | hero cards and sheets |

#### Elevation

Pulse should use **soft, subtle elevation**, not the old neubrutalist hard offset shadows.

Suggested scale:

- `none`: flat rows/dividers;
- `card`: subtle card lift;
- `hero`: slightly stronger hero card lift;
- `sheet`: modal/sheet lift with scrim.

#### Motion

Keep motion modern but quiet:

- tap scale: subtle `0.97–0.99`, not bouncy/childish;
- screen transitions: default iOS navigation where possible;
- list/card entrance: optional and restrained;
- reduced motion must be respected.

### 2. Shared component kit

Before applying Pulse to every screen, define the reusable building blocks.

#### App shell components

| Component | Used by | Purpose |
|---|---|---|
| Pulse screen background | every screen | unify backdrop color |
| Pulse top bar | Today, Plan, Profile, Meal Detail, Add Food | consistent title/action layout |
| Pulse bottom tab bar | MainTabView | active state and app identity |
| Pulse sheet style | Add Food, Profile edit | consistent modal treatment |
| Pulse scroll container | most screens | safe area + bottom inset discipline |

#### Data components

| Component | Used by | Purpose |
|---|---|---|
| Daily budget hero | Today, Calorie Result | show estimate/remaining clearly |
| Segmented budget bar | Today, Plan, Meal Detail | show meal distribution |
| Metric tile | Today, Insights, Profile | compact stats |
| Macro chip/row | Today, Meal Detail, Add Food | protein/carbs/fat display |
| Insight card | Insights/Profile future | neutral observation |

#### Meal/planning components

| Component | Used by | Purpose |
|---|---|---|
| Meal card | Today, Plan | breakfast/lunch/snack/dinner rows |
| Emoji meal marker | meal cards | friendly category marker only |
| Week strip | Plan | planned/empty/today/future states |
| Day readiness badge | Plan | day state at a glance |
| Meal slot detail card | Meal Detail | food list inside one meal |
| Empty meal state | Meal Detail | clear add-food prompt |

Emoji decision:

- Use emoji for **meal category markers** only: `🍳`, `🍱`, `🍌`, `🍽️`.
- Do **not** use emoji for structural navigation/system controls.
- If we later want a more premium finish, we can convert these into custom vector icons inspired by the emoji, but the current experiment is acceptable for direction review.

#### Food entry components

| Component | Used by | Purpose |
|---|---|---|
| Search field | Add Food | primary add-food entry path |
| Provider/source badge | Add Food | FatSecret/custom/local source trust |
| Food result card | Add Food | searchable result item |
| Recent/favorite section | Add Food | fast repeat entry |
| Serving picker | Add Food | portion adjustment before add |
| Manual fallback form | Add Food | secondary path when search fails |

#### Form components

| Component | Used by | Purpose |
|---|---|---|
| Pulse text field | onboarding, profile edit, manual food | consistent input style |
| Pulse stepper field | onboarding `IntStepperField` | cleaner number input |
| Pulse segment control | goal/activity/sex selections | selected state consistency |
| Primary button | all flows | one main CTA per screen |
| Secondary button | back/edit/cancel | subordinate action |
| Inline helper/error text | forms/search | clear recovery path |

### 3. State matrix

Every repeated component should have defined states before implementation.

#### Calorie/budget states

| State | Meaning | Visual direction |
|---|---|---|
| empty | no plan yet | soft empty card + primary CTA |
| under estimate | planned below estimate | mint/cyan accent, neutral copy |
| near estimate | close to estimate | violet/blue normal state |
| above estimate | over estimated target | amber attention, not red/shame |
| unavailable | missing profile/target | explain what setup is needed |

Copy rule: say “above your estimated target,” not “bad,” “failed,” or “cheat.”

#### Plan/day states

| State | Meaning | Visual direction |
|---|---|---|
| today | currently selected date | deep ink/violet selected pill |
| planned | has meals/items | mint/cyan readiness marker |
| empty | no meal items yet | amber soft marker + action |
| future | editable future date | soft neutral marker |
| past/read-only | historical date | muted state with clear indication |

#### Search/add-food states

| State | Meaning | Visual direction |
|---|---|---|
| idle | no query yet | recent/favorites visible |
| searching | query in progress | skeleton/loader in result area |
| results | matches found | source badges + kcal summaries |
| no results | no search match | manual fallback promoted |
| provider error | API issue | recoverable message + retry/manual |
| selected | result selected | serving picker card appears |
| adding | save in progress | button loading/disabled |
| added | item saved | success feedback and return path |

#### Form states

- default;
- focused;
- valid;
- invalid with inline message;
- disabled;
- read-only;
- loading/saving.

### 4. Screen-by-screen application plan

## Onboarding

### WelcomeView

Purpose: introduce Foodiary as a planning tool.

Apply Pulse by:

- replacing old welcome styling with a clean hero card;
- using one clear headline and short explanation;
- showing a subtle mini budget/meal preview instead of decorative art;
- one primary CTA.

Key copy direction:

> Plan meals around a daily calorie estimate. Simple, local-first, and made for everyday planning.

### ProfileSetupView

Purpose: collect estimate inputs without feeling clinical.

Apply Pulse by:

- grouping fields into clean cards;
- using Pulse stepper/text-field styles;
- showing helper text that explains why each field is needed;
- keeping the form calm and not judgmental.

### IntStepperField

Purpose: reusable numeric input.

Apply Pulse by:

- making controls 44pt+ tap targets;
- matching radius/elevation/tint tokens;
- adding clear selected/focused state;
- supporting Dynamic Type.

### GoalSetupView

Purpose: choose planning preference.

Apply Pulse by:

- using segmented option cards instead of isolated controls;
- copy should frame goals as preferences, not health instructions;
- show maintain/lose/gain as planning multipliers with neutral labels.

### CalorieResultView

Purpose: explain calculated estimate and enter the app.

Apply Pulse by:

- using a Daily Budget Hero similar to Today;
- showing target, BMR, activity multiplier, preference adjustment;
- including the disclaimer near the result;
- one primary CTA to start planning.

## Main app shell

### MainTabView

Purpose: persistent top-level navigation.

Apply Pulse by:

- keeping bottom tabs to max 5 items;
- active tab uses deep ink/violet pill or tint;
- icons must be vector/system icons, not emoji;
- labels always visible;
- content must reserve bottom safe-area inset.

Potential tab model:

1. Today
2. Plan
3. Add
4. Insights — if implemented as real destination
5. Profile

If Insights is not yet a real Swift screen, we either:

- keep 3 tabs for now: Today / Plan / Profile;
- or add Insights only when there is a real screen and data.

Do not add a fake tab just because the prototype has one.

## TodayDashboardView

Purpose: daily command center.

Apply Pulse by:

- top section becomes Daily Budget Hero;
- show remaining/used estimate prominently;
- segmented bar maps to meals;
- next best action card tells user what to adjust next;
- meal timeline uses emoji category markers;
- macro/status cards are compact and secondary.

Must support:

- no profile/target yet;
- no meal plan yet;
- empty day;
- partially planned day;
- above estimate;
- all meal slots complete.

## PlanView

Purpose: weekly readiness.

Apply Pulse by:

- week strip at top with clear day states;
- selected day summary card;
- meal slots underneath;
- read-only past days visually distinct;
- empty days get helpful CTA, not blank content;
- segmented budget bar reused from Today.

Must support:

- today selected;
- future selected;
- past/read-only selected;
- day with no plan;
- day with plan but no items;
- day above estimate.

## MealDetailView

Purpose: edit one meal slot.

Apply Pulse by:

- top card shows meal name, emoji marker, current kcal, and estimated share;
- food list uses clean result/item rows;
- empty state uses one strong “Add food” action;
- delete/edit affordances are clear but not dominant;
- if meal is read-only, actions are disabled and explained.

Must support:

- empty meal;
- meal with items;
- delete item;
- read-only meal;
- navigation back to selected plan date.

## AddFoodItemView

Purpose: search-first food entry.

Apply Pulse by:

- search field is the hero;
- recent/favorites shown before typing;
- source badges distinguish FatSecret/custom/manual;
- selected food opens serving picker before save;
- manual entry is a fallback section, not the main visual focus;
- loading/error/no-results states are designed.

Must support:

- search idle;
- search loading;
- results;
- no results;
- provider error;
- manual fallback;
- selected serving;
- save success/failure.

## ProfileView

Purpose: estimate context and settings.

Apply Pulse by:

- top card shows estimated daily target;
- BMR/maintenance/preference details are grouped as context;
- disclaimer visible and calm;
- edit profile opens a Pulse-styled sheet;
- settings rows use consistent row/card patterns.

Must support:

- profile exists;
- profile missing;
- target missing;
- edit profile flow;
- localized strings.

## Insights screen decision

The prototype includes Insights because Pulse v2 needs a pattern-review destination.

Before implementation, decide one of two paths:

### Option A — Implement Insights now

Add a real Insights screen/tab with:

- planned days count;
- weekly calorie range;
- average planned kcal;
- neutral observation cards;
- no medical/nutrition claims.

### Option B — Keep Insights as future direction

Do not add the tab yet. Instead:

- fold one or two insight cards into Today/Profile;
- keep app nav simple: Today / Plan / Profile;
- document Insights as Phase 2.

Recommendation: **Option B first**, unless we want to expand scope. The current app can still feel complete without a new Insights destination if Today, Plan, and Profile are fully stitched.

### 5. Content and localization preparation

Because Foodiary uses `Localizable.xcstrings`, prepare new/updated string keys before implementation.

String groups likely needed:

- `pulse.today.*`
- `pulse.plan.*`
- `pulse.meal.*`
- `pulse.add_food.*`
- `pulse.profile.*`
- `pulse.state.empty.*`
- `pulse.state.error.*`
- `pulse.disclaimer.*`

Copy rules:

- neutral and planning-oriented;
- no shame framing;
- no medical claims;
- estimated target always described as an estimate;
- goals described as planning preferences.

### 6. Asset/icon preparation

Prepare two icon layers:

1. **System/navigation icons**
   - Use SF Symbols or a consistent vector style.
   - No emoji for nav/settings/system actions.

2. **Meal category markers**
   - Current direction uses emoji markers:
     - Breakfast `🍳`
     - Lunch `🍱`
     - Snack `🍌`
     - Dinner `🍽️`
   - These should be treated as category markers, not structural icons.
   - If final polish requires consistency beyond native emoji rendering, create custom vector meal icons inspired by these emoji.

### 7. Implementation order later

When we are ready to code, do it in phases so the app does not become half-Pulse/half-old-style.

#### Phase 0 — Lock design spec

- Confirm final Pulse tokens.
- Confirm tab model: 3 tabs vs 5 tabs with Insights.
- Confirm emoji markers vs custom icons.
- Confirm screen coverage checklist.

#### Phase 1 — Shared design system only

- Add Pulse color/type/spacing/radius/elevation tokens.
- Add reusable Pulse card/button/chip/field/progress components.
- Do not redesign individual screens yet.

#### Phase 2 — App shell + navigation

- Update MainTabView styling.
- Establish screen background and top/bottom safe-area behavior.
- Ensure old and new components do not clash.

#### Phase 3 — Today + Plan foundation

- Today becomes command center.
- Plan becomes week readiness.
- Meal cards and segmented budget bar become shared components.

#### Phase 4 — Meal Detail + Add Food

- Apply shared meal components.
- Redesign add-food as search-first.
- Add loading/error/no-results/serving-picker states.

#### Phase 5 — Onboarding + Profile

- Apply Pulse form system.
- Redesign calorie result hero.
- Add estimate context and disclaimer treatment.

#### Phase 6 — QA + polish

- iPhone 16 Pro simulator visual QA.
- Dynamic Type check.
- Indonesian localization check.
- Empty/error/read-only state check.
- Build/test.

### 8. Acceptance checklist

Before calling the revamp complete:

#### Coverage

- [ ] Welcome uses Pulse direction.
- [ ] Profile setup uses Pulse form controls.
- [ ] Goal setup uses Pulse preference cards.
- [ ] Calorie result uses Pulse estimate hero + disclaimer.
- [ ] MainTabView uses Pulse navigation styling.
- [ ] Today uses command-center structure.
- [ ] Plan uses week-readiness structure.
- [ ] Meal Detail uses meal-slot structure.
- [ ] Add Food uses search-first structure.
- [ ] Profile uses estimate-context structure.
- [ ] Shared IntStepperField matches Pulse controls.

#### Visual consistency

- [ ] No old neubrutalist hard shadows remain in redesigned screens.
- [ ] No random per-screen colors outside tokens.
- [ ] Cards, buttons, chips, fields use shared styling.
- [ ] Screen padding and section spacing are consistent.
- [ ] Tab bar and fixed elements do not cover scroll content.

#### UX consistency

- [ ] Every screen has one clear primary action.
- [ ] Empty states explain what to do next.
- [ ] Error states include a recovery action.
- [ ] Loading states are visible.
- [ ] Read-only states are explained.
- [ ] Above-estimate states use neutral language.

#### Accessibility

- [ ] Touch targets are at least 44pt.
- [ ] Color is not the only state indicator.
- [ ] Text contrast is acceptable.
- [ ] Dynamic Type does not break layout.
- [ ] VoiceOver labels are meaningful for icon-only buttons.
- [ ] Reduced motion is respected.

#### Localization and tone

- [ ] No hardcoded user-facing strings in Swift views.
- [ ] English and Indonesian entries are added/updated.
- [ ] Disclaimer is present near calorie estimates.
- [ ] No shame-based or medical language.

## Recommended next step

The missing design artifacts are now prepared:

- Canonical prototype: `design-prototype/pulse-v2-proposal.html`
- Pulse-aligned screen spec board: `design-prototype/pulse-v2-screen-spec-board.html`
- Implementation audit and phased plan: `docs/concepts/pulse-v2-implementation-audit.md`
- Hermes execution handoff: `.hermes/plans/2026-06-22_231716-pulse-v2-ui-revamp-implementation.md`

The recommended next coding gate is **Phase 1 — Pulse foundation/components only**. Do not start with direct one-off rewrites of every screen. Phase 1 should add the shared Pulse tokens/components while preserving existing `Ring*`/`NB*` compatibility so the app keeps building during migration.

The app-shell decision is now locked: implement **four normal tabs plus a centered Add Food action/router**. This preserves the Pulse v2 primary Add Food affordance while respecting the current app architecture where `AddFoodItemView` needs a target date and meal.
