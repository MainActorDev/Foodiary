# Foodiary Pulse v2 — Focused Design Direction

## Why Pulse v1 felt incomplete

The first Pulse direction had the right energy — modern, data-forward, and more active than Aura — but it was still mostly a visual treatment. It showed calories, macros, and meal cards, but it did not yet define the full product experience.

What was missing:

1. **A stronger product identity**  
   Pulse should not be “a dashboard with purple.” It should feel like a daily planning command center for food decisions.

2. **A clearer daily decision loop**  
   The user needs to know: What is my estimate? What have I planned? What can I do next? What changed after I add food?

3. **A better add-food experience**  
   Search is the heart of the app now that Foodiary has FatSecret + custom food sources. The UI should make search, recent foods, favorites, serving selection, and manual fallback feel first-class.

4. **A stronger weekly planning model**  
   The current Plan screen has the foundation, but the redesign should make week readiness visible at a glance: which days are planned, empty, above estimate, or read-only.

5. **Useful insights, not decorative charts**  
   Insights should explain planning patterns in neutral language: logged days, common meal distribution, calorie range, macro totals. No medical claims and no judgment.

6. **Trust and context**  
   Profile should explain where the estimate comes from and keep the planning disclaimer visible without making the app feel clinical.

## Pulse v2 concept

**Pulse v2 turns Foodiary into a food planning cockpit.**

The app still stays simple and local-first, but every screen has a sharper job:

- **Today** answers: “Where am I right now, and what should I adjust next?”
- **Plan** answers: “Is my week prepared?”
- **Add Food** answers: “What did I plan or eat, and how fast can I add it?”
- **Insights** answers: “What pattern is forming from my plans?”
- **Profile** answers: “What estimate is this based on?”

## Implementation references

Use these artifacts as the locked handoff package before SwiftUI work starts:

| Artifact | Purpose |
|---|---|
| `design-prototype/pulse-v2-proposal.html` | Canonical visual source of truth |
| `design-prototype/pulse-v2-screen-spec-board.html` | Screen-by-screen Pulse mapping for the current app |
| `docs/concepts/pulse-v2-stitching-plan.md` | Shared components, states, and copy rules |
| `docs/concepts/pulse-v2-implementation-audit.md` | Repo audit and phased SwiftUI implementation plan |
| `.hermes/plans/2026-06-22_231716-pulse-v2-ui-revamp-implementation.md` | Task-by-task Hermes execution handoff |

Implementation should begin with the shared Pulse foundation/components, not direct one-off screen rewrites.

## Visual language

Pulse v2 should feel:

- clean;
- modern;
- energetic;
- precise;
- mobile-native;
- not clinical;
- not gamified in a childish way.

### Suggested tokens

| Role | Direction |
|---|---|
| Background | very light cool lavender / blue-gray |
| Primary | electric violet |
| Secondary | mint / teal |
| Warning | amber |
| Text | deep navy / ink |
| Cards | white with subtle border and soft shadow |
| Data surfaces | tinted panels, segmented bars, compact metric tiles |
| Typography | Inter / SF Pro style, bold metrics, compact labels |

## Screen model

### Today — Command Center

Hero:

- remaining calorie estimate;
- used percentage;
- segmented budget bar;
- next best action.

Below hero:

- macro chips;
- meal timeline with friendly emoji category markers (`🍳` breakfast, `🍱` lunch, `🍌` snack, `🍽️` dinner);
- quick add CTA.

### Plan — Week Readiness

Hero:

- weekly strip with readiness markers;
- selected day total vs estimate;
- planning status.

Below hero:

- meal slots;
- read-only state for past days;
- future days open directly into meal detail/add food.

### Add Food — Search First

Hero:

- search input;
- provider/source badge;
- recent/favorite foods;
- serving picker preview.

Fallback:

- manual entry is secondary, not the main path.

### Insights — Pattern Review

Hero:

- days planned/logged;
- calorie range;
- macro distribution.

Tone:

- neutral observations only;
- no shame language;
- no health claims.

### Profile — Estimate Context

Hero:

- estimated daily target;
- BMR and maintenance;
- profile settings;
- disclaimer.

## Recommendation

Move forward with **Pulse v2** instead of the earlier generic Pulse.

It gives Foodiary a stronger design spine while staying aligned with the actual product: meal planning, food search, weekly planning, local-first context, and neutral calorie estimates.
