# Foodiary UI/UX Revamp — Design Direction Proposal

## Current-state read

Foodiary is currently a local-first iOS calorie planner with four main top-level areas:

1. **Today** — calorie progress, planned/remaining summary, macros, meal cards.
2. **Plan** — weekly strip calendar, selected-day meal plan, read-only past days, editable future days.
3. **Insights** — calorie and macro summary.
4. **Profile** — user profile, estimated calorie target, BMR/maintenance info, disclaimer, reset/edit actions.

The current UI has already moved away from the original neubrutalist look into a more clinical “Calorie Ring” style: blue/green/amber palette, soft cards, thin borders, system typography, and a progress ring hero.

## Revamp goal

The revamp should make Foodiary feel **clean, modern, calm, and trustworthy** without becoming medical, judgmental, or overcomplicated.

The product should feel less like a spreadsheet and more like a daily planning companion:

- neutral language, no shame;
- clear calorie estimate context;
- fast meal entry;
- planning-first weekly flow;
- enough visual polish to feel premium, but not decorative clutter.

## Non-negotiable UX principles

1. **Planning, not judgment**  
   Foodiary should frame calories as an estimated planning target, not a pass/fail score.

2. **One hero metric per screen**  
   Today should focus on the user’s current estimated calorie position. Plan should focus on selected day readiness. Profile should focus on target context.

3. **Cards should reduce cognitive load**  
   Cards should group related information, not simply box every piece of content.

4. **No emoji as structural UI**  
   Use SF Symbols / vector icons for a professional iOS feel.

5. **Modern iOS-native feel**  
   Respect safe areas, Dynamic Type, 44pt touch targets, predictable navigation, and bottom tab conventions.

6. **Neutral over/under states**  
   Use soft wording such as “120 kcal above estimate” or “420 kcal remaining,” not success/failure framing.

## Three proposed design directions

### Direction A — Aura

**Vibe:** warm, friendly, soft-modern wellness.

Aura is the most approachable direction. It uses a warm off-white background, coral/sage accents, soft gradients, rounded cards, and a glowing progress ring. It keeps the calorie ring mental model from the current app but makes it warmer and more premium.

**Best if we want:**

- friendly consumer-app personality;
- visual warmth;
- continuity from the existing Today progress ring;
- a polished but still simple SwiftUI implementation.

**Tradeoff:** Slightly more visual styling than the most minimal option.

### Direction B — Pulse

**Vibe:** energetic, data-forward, modern fitness/wellness tool.

Pulse treats calories like a daily energy budget. It uses stronger violet/mint accents, segmented progress, denser stat tiles, and more visible week/day data. This is the most actionable and “power-user” direction.

**Best if we want:**

- more informative dashboard;
- stronger meal planning/productivity feel;
- clearer macro/data visibility;
- an app that feels active and dynamic.

**Tradeoff:** Higher information density; needs careful hierarchy so it does not feel busy.

### Direction C — Zenith

**Vibe:** premium, editorial, ultra-clean.

Zenith strips the UI down: large typography, no decorative borders, lots of whitespace, monochrome surfaces, and one emerald accent. It feels mature and calm. The user sees fewer competing elements and can focus on the plan.

**Best if we want:**

- premium minimalism;
- strong modern identity;
- maximum clarity;
- lowest visual clutter.

**Tradeoff:** Less playful and less “consumer-friendly”; requires excellent spacing and typography to avoid feeling plain.

## Recommendation

My recommendation is **Direction A — Aura** as the primary path, with one detail borrowed from Direction C: more whitespace and less boxed content.

Reasoning:

- It preserves Foodiary’s existing progress-ring strength, so the revamp is not a total UX reset.
- It is warmer than the current blue clinical look.
- It still supports the full app flow: Today, Plan, Insights, Profile, onboarding, add-food sheet.
- It can be implemented cleanly in SwiftUI with no external dependencies.
- It aligns with the app’s constraint: local-first, simple, and planning-oriented.

## Proposed implementation direction after approval

If you choose a direction, the next phase should be:

1. Define the new design tokens in `DesignSystem.swift`.
2. Replace card/button/input modifiers with the selected visual language.
3. Redesign `TodayDashboardView` around the chosen hero metric.
4. Redesign `PlanView` as a clearer week/day planning surface.
5. Redesign meal detail/add food forms with stronger input hierarchy.
6. Update onboarding and profile for consistency.
7. Build and run on simulator; compare against the web prototype.

No app code should change until the design direction is approved.
