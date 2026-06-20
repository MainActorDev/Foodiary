---
version: alpha
name: Foodiary (Neubrutalist)
description: A bold, playful calorie tracker with personality. Neubrutalist foundation — hard black borders, thick offset shadows, vibrant flat colors. Gen-Z energy meets food warmth. No gradients, no blur, just confidence.

colors:
  primary: "#FF6B4A"
  secondary: "#2DD4BF"
  accent: "#FFD60A"
  background: "#FAFAF5"
  foreground: "#1A1A1A"
  card: "#FFFFFF"
  cardForeground: "#1A1A1A"
  muted: "#F5F2ED"
  mutedForeground: "#6B6560"
  border: "#1A1A1A"
  destructive: "#1A1A1A"
  positive: "#2DD4BF"
  warning: "#FFD60A"
  ring: "#FF6B4A"

typography:
  display:
    fontFamily: Space Grotesk
    fontSize: 2.5rem
    fontWeight: 700
    lineHeight: 1.1
    letterSpacing: "-0.03em"
  title:
    fontFamily: Space Grotesk
    fontSize: 1.375rem
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: "-0.01em"
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 1.0625rem
    fontWeight: 500
    lineHeight: 1.5
  body:
    fontFamily: Plus Jakarta Sans
    fontSize: 0.9375rem
    fontWeight: 400
    lineHeight: 1.5
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 0.8125rem
    fontWeight: 400
    lineHeight: 1.5
  caption:
    fontFamily: Plus Jakarta Sans
    fontSize: 0.75rem
    fontWeight: 600
    lineHeight: 1.4
    letterSpacing: "0.03em"
  label:
    fontFamily: Space Grotesk
    fontSize: 0.75rem
    fontWeight: 700
    lineHeight: 1.4
    letterSpacing: "0.05em"

rounded:
  sm: 8px
  md: 12px
  lg: 16px
  xl: 20px
  full: 9999px

spacing:
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 24px
  2xl: 32px
  3xl: 48px

elevation:
  card:
    shadowColor: "#1A1A1A"
    shadowOffset: "4px 4px 0"
    shadowRadius: 0px
  floating:
    shadowColor: "#1A1A1A"
    shadowOffset: "6px 6px 0"
    shadowRadius: 0px

components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "#FFFFFF"
    borderColor: "{colors.foreground}"
    borderWidth: 3px
    rounded: "{rounded.md}"
    padding: 14px
    typography: "{typography.body-lg}"
    shadowColor: "{colors.foreground}"
    shadowOffset: "4px 4px 0"

  button-primary-hover:
    backgroundColor: "#E55A3A"
    shadowOffset: "2px 2px 0"

  button-secondary:
    backgroundColor: "{colors.card}"
    textColor: "{colors.foreground}"
    borderColor: "{colors.foreground}"
    borderWidth: 3px
    rounded: "{rounded.md}"
    padding: 14px
    shadowColor: "{colors.foreground}"
    shadowOffset: "4px 4px 0"

  button-destructive:
    backgroundColor: "{colors.foreground}"
    textColor: "#FFFFFF"
    rounded: "{rounded.md}"
    padding: 14px
    shadowColor: "{colors.foreground}"
    shadowOffset: "4px 4px 0"

  card-summary:
    backgroundColor: "{colors.card}"
    borderColor: "{colors.foreground}"
    borderWidth: 3px
    rounded: "{rounded.xl}"
    padding: 20px
    shadowColor: "{colors.foreground}"
    shadowOffset: "4px 4px 0"

  card-meal:
    backgroundColor: "{colors.card}"
    borderColor: "{colors.foreground}"
    borderWidth: 3px
    rounded: "{rounded.lg}"
    padding: 16px
    shadowColor: "{colors.foreground}"
    shadowOffset: "3px 3px 0"

  input-field:
    backgroundColor: "{colors.card}"
    textColor: "{colors.foreground}"
    borderColor: "{colors.foreground}"
    borderWidth: 3px
    rounded: "{rounded.md}"
    padding: 12px
    typography: "{typography.body}"

  tab-bar:
    backgroundColor: "{colors.card}"
    borderTopColor: "{colors.foreground}"
    borderTopWidth: 3px

  tag-calorie:
    backgroundColor: "{colors.muted}"
    textColor: "{colors.foreground}"
    borderColor: "{colors.foreground}"
    borderWidth: 2px
    rounded: "{rounded.full}"
    padding: 6px

  status-under:
    backgroundColor: "#D1FAE5"
    textColor: "#065F46"
    borderColor: "{colors.foreground}"
    borderWidth: 2px
    rounded: "{rounded.full}"
    padding: 6px

  status-over:
    backgroundColor: "#FEE2E2"
    textColor: "#991B1B"
    borderColor: "{colors.foreground}"
    borderWidth: 2px
    rounded: "{rounded.full}"
    padding: 6px

  segmented-control:
    backgroundColor: "{colors.muted}"
    borderColor: "{colors.foreground}"
    borderWidth: 3px
    rounded: "{rounded.md}"
---

## Overview

Foodiary v2 embraces **neubrutalism** — the design language of Gen-Z.
Bold, confident, and playful. Every element has a hard black border and
a thick offset shadow. Colors are vibrant and flat — no gradients, no
blur, no half-measures. The personality is warm and food-friendly
(coral primary, mint secondary, sunny yellow accents) while the
structure is unapologetically bold.

This is NOT your mom's calorie tracker.

## Colors

- **Primary (#FF6B4A):** Bold coral — energetic, warm, food-associated. Primary buttons, selected states, key metrics.
- **Secondary (#2DD4BF):** Fresh mint — healthy, crisp, under-target indicator. Calorie progress bars.
- **Accent (#FFD60A):** Sunny yellow — happy, breakfast energy. Attention states, highlights.
- **Background (#FAFAF5):** Warm off-white — soft backdrop that lets cards pop.
- **Foreground (#1A1A1A):** Hard black — borders, text, shadows. Maximum contrast, zero apology.
- **Card (#FFFFFF):** Pure white — content surface with black border and shadow.
- **Muted (#F5F2ED):** Warm gray — secondary backgrounds, tags, disabled states.
- **Muted Foreground (#6B6560):** Warm gray text — secondary information.
- **Border (#1A1A1A):** Hard black — every element has a 2-3px solid border. Non-negotiable.
- **Destructive (#1A1A1A):** Black — delete actions. Bold, not red-alarm scary.
- **Positive (#2DD4BF):** Mint — under target, good states.
- **Warning (#FFD60A):** Yellow — near target, attention.

## Typography

**Space Grotesk** for everything bold — headings, labels, metrics, buttons.
**Plus Jakarta Sans** for body text — readable at small sizes.

- Display: Space Grotesk Bold, 40px, tight leading. Hero numbers.
- Title: Space Grotesk Bold, 22px. Screen titles, card headers.
- Labels: Space Grotesk Bold, 12px, ALL CAPS, letter-spacing 0.05em. Section headers, badges.
- Body: Plus Jakarta Sans, 15px. All paragraphs and descriptions.
- Caption: Plus Jakarta Sans SemiBold, 12px. Metadata, timestamps.

**Rule:** Space Grotesk is never used below 700 weight. No light, no regular.
Bold or nothing. On iOS, SF Pro Rounded Bold is the system fallback.

## Shapes

- Cards: 16-20px radius with 3px black border + 4px 4px 0 black shadow
- Buttons: 12px radius with 3px black border + 4px 4px 0 black shadow
- Input fields: 12px radius with 3px black border
- Tags/badges: Fully rounded pills with 2px border
- **No border-radius 0** — we're neubrutalist, not brutalist. Soft edges keep it friendly.

## Components

### button-primary
Coral background, white bold text, 3px black border, 4px offset shadow.
On press: shadow shrinks to 2px (feels like it's being pushed).

### button-secondary
White background, black bold text, 3px black border, 4px offset shadow.
For cancel, back, secondary actions.

### card
White background, 3px black border, 4px offset shadow. Every card.
Cards are the core container — not subtle, not blending in.

### input-field
White background, 3px black border. Label above in Space Grotesk Bold ALL CAPS.
Focus: border turns coral (keeps 3px width).

### status-badge
Pill shape with 2px black border. Green bg for under, red-tinted for over.
Always includes the black border — neubrutalist rules apply everywhere.

### tab-bar
White background, 3px black top border. Active tab: coral text + black underline.
Inactive: muted gray. Space Grotesk Bold labels (10px).

## Layout

Single column, 16px horizontal padding. Generous vertical spacing (24-32px between sections).
Cards stack with clear separation — each one is a distinct "block" thanks to shadows.

## Do's and Don'ts

### Do
- ✅ Hard black borders on every interactive element — no exceptions
- ✅ Offset shadows (4px 4px 0) on cards and buttons
- ✅ Space Grotesk Bold for ALL headings, labels, metrics
- ✅ Flat vibrant colors — coral, mint, yellow, white, black
- ✅ Neutral, non-judgmental language
- ✅ Push-in animation on button press (shadow shrinks)
- ✅ ALL CAPS labels with letter-spacing

### Don't
- ❌ No gradients — ever
- ❌ No blur effects — we're not glassmorphism
- ❌ No light shadows — go hard or go home
- ❌ No thin borders — 2px minimum, 3px standard
- ❌ No muted, safe color palette
- ❌ Never shame the user
- ❌ No emojis as structural icons (use bold SVG/SF Symbols)
