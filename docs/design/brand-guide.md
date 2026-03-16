# Red Taxi — Design Language & Visual Identity

All UI development must conform to these tokens. Visual consistency across the dispatch console, driver app, customer portal, and tenant admin screens.

**Design reference:** CoinTax by Phenomenon Studio (Dribbble). Adapted for dispatch-operator context with higher-contrast status states and 8-12 hour shift ergonomics.

---

## Design Philosophy

1. **Dark-first.** Dispatch operators work extended shifts in low-light control rooms. Dark backgrounds reduce eye strain and make coloured status indicators more distinguishable. Light mode supported as toggle but dark is the shipped default.

2. **Card-based layout.** Every data grouping (booking, driver, vehicle, KPI) lives in its own card. Cards use subtle 0.5px borders, never box-shadows. Keeps the interface clean at high information density.

3. **Status-colour-driven.** Vehicle and booking states communicated through colour alone at first glance, with text labels as secondary reinforcement. Every status colour tested for WCAG AA contrast against dark card background.

4. **Minimal chrome.** No decorative gradients, rounded-everything, or animations-for-the-sake-of-it. Motion used only for state transitions (e.g. booking card sliding from Unassigned to Dispatched).

---

## Colour Palette

### Background Scale

| Token | Dark | Light | Usage |
|-------|------|-------|-------|
| `bg-base` | `#0B0D11` | `#FFFFFF` | Page/app background |
| `bg-surface` | `#12151B` | `#F8F9FA` | Sidebar, nav panels |
| `bg-card` | `#1A1E27` | `#F1F3F5` | Cards, modals, dropdowns |
| `bg-elevated` | `#242934` | `#E9ECEF` | Nested cards, hover states |
| `bg-hover` | `#2E3440` | `#DEE2E6` | Row/item hover |

### Brand Red

| Token | Hex | Usage |
|-------|-----|-------|
| `brand-300` | `#FF6B6B` | Hover, lighter accents |
| `brand-500` | `#FF2D2D` | Primary action: dispatch buttons, active states, brand marks, urgent indicators |
| `brand-600` | `#E62626` | Pressed/active state |
| `brand-900` | `#331010` | Brand tint backgrounds |

### Vehicle Status Colours

These are the most critical colours in the system. Operators must distinguish 40+ map pins at a glance. Each hue is maximally separated and tested for deuteranopia/protanopia.

| Status | Foreground | Background | Usage |
|--------|-----------|------------|-------|
| Available | `#34D399` | `#0D2E1A` | Driver free and accepting jobs |
| On Job | `#FBBF24` | `#2D2206` | Driver currently on a booking |
| Dispatched | `#A78BFA` | `#1A1333` | Job sent to driver, awaiting acceptance |
| Offline | `#FF6B6B` | `#331010` | Driver not on shift |
| On Break | `#38BDF8` | `#0C2333` | Driver on break |

### Semantic Colours

| Token | Hex | Usage |
|-------|-----|-------|
| `success` | `#34D399` | Confirmations, completed states |
| `warning` | `#FBBF24` | Alerts, attention needed |
| `danger` | `#FF6B6B` | Errors, destructive actions, cancellations |
| `info` | `#38BDF8` | Informational messages |

### Text Colours

| Token | Dark | Light |
|-------|------|-------|
| `text-primary` | `#F9FAFB` | `#111827` |
| `text-secondary` | `#9CA3AF` | `#6B7280` |
| `text-tertiary` | `#6B7280` | `#9CA3AF` |

### Borders

| Token | Dark | Light |
|-------|------|-------|
| `border-subtle` | `#ffffff0f` | `#00000010` |
| `border-default` | `#2E3440` | `#DEE2E6` |
| `border-focus` | `#FF2D2D` | `#FF2D2D` |

---

## Typography

**Primary typeface:** Inter. Free, variable-weight, excellent legibility at small sizes, ships with tabular numerals (critical for fare displays and KPI dashboards).

**Fallback stack:** `Inter, system-ui, -apple-system, sans-serif`

**Monospace (code, IDs):** `JetBrains Mono, Consolas, monospace`

| Token | Size | Usage |
|-------|------|-------|
| `xs` | 12px | Labels, metadata, timestamps |
| `sm` | 13px | Table cells, status pills, secondary text |
| `base` | 14px | Body text, form inputs, nav items |
| `lg` | 18px | Card headers, section titles |
| `xl` | 24px | Page titles |
| `2xl` | 28px | KPI numbers, dashboard hero stats |
| `3xl` | 32px | Landing/marketing headers only |

**Critical rule:** All number displays (fares, distances, counts) must use `font-variant-numeric: tabular-nums` so columns align.

---

## Spacing & Layout

4px base grid: `4, 8, 12, 16, 24, 32, 48, 64px`

| Token | Value |
|-------|-------|
| `xs` | 4px |
| `sm` | 8px |
| `md` | 12px |
| `base` | 16px |
| `lg` | 24px |
| `xl` | 32px |
| `2xl` | 48px |

---

## Component Tokens

### Cards
- Background: `bg-card`
- Border: 0.5px `border-subtle`
- Border radius: `radius-lg` (12px)
- Padding: `base` (16px)
- No box-shadows. Ever.

### Buttons
- Height: 36px (compact) or 44px (standard)
- Border radius: `radius-md` (8px)
- Font weight: 500
- Primary: `brand-500` background, white text
- Secondary: `bg-elevated` background, `text-primary`
- Danger: `danger` background, white text

### Status Pills
Used in tables, cards, and map tooltips to show vehicle/booking status.
- Structure: coloured dot (8px) + label text on tinted background (status colour at ~10% opacity)
- Border radius: `radius-pill` (20px)
- Padding: 6px 14px
- Font size: 13px, weight 500

### Form Inputs
- Background: `bg-elevated`
- Border: 1px `border-default`
- Border radius: `radius-md` (8px)
- Focus: border changes to `border-focus` (`#FF2D2D`)
- Height: 36px (compact) or 44px (standard)
- Font size: `base` (14px)

---

## Iconography

**Icon library:** Lucide Icons (open-source, consistent 24px grid, 1.5px stroke weight). Matches thin-line aesthetic.

| Size | Usage |
|------|-------|
| 16px | Inline with text |
| 20px | Buttons and nav |
| 24px | Card headers and empty states |

Icon colour: inherits text colour by default. Status icons use corresponding status colour.

---

## Map Styling

- Google Maps with custom dark style (Aubergine or Silver Dark preset)
- Override water/road/poi colours to match background scale
- Map pins: five vehicle status colours with white border for legibility
- Selected vehicle pin: scale 1.3x with pulsing ring animation in brand red
- Route overlay: 3px solid line in `brand-500` (`#FF2D2D`) with 40% opacity fill

---

## Logo & Brand Mark

**Wordmark:** `red` in lowercase Inter 700 (bold) `#FF2D2D` + `taxi` in lowercase Inter 400 (regular) `#F9FAFB` (dark) / `#111827` (light)

**Size:** 20px in sidebar top-left

**Favicon:** Red square (rounded 4px) with white 'R' in Inter 700. Reads clearly at 16x16.

No icon mark for v1. Text wordmark only.

---

## Dark/Light Mode Strategy

- Dark is default and design target
- Light mode inverts background scale, swaps text colours
- Status colours, brand red, and semantic colours remain UNCHANGED between modes
- Implementation: CSS custom properties at `:root`, toggled via `data-theme` attribute on `<html>`
- No separate stylesheet
- Syncfusion: Material Dark base, override primary/accent with brand red tokens. Light mode: Material Light with same overrides.

---

## Layout Structure (Dispatch Console)

```
┌─────────────────────────────────────────────────────────────┐
│  Sidebar (bg-surface #12151B)  │  Main Content (bg-base #0B0D11)    │
│  - Logo (top-left)             │  ┌─────────────────────────────────┐│
│  - Nav items                   │  │  Cards (bg-card #1A1E27)        ││
│  - Collapsible sections        │  │  - Booking form                 ││
│                                │  │  - Diary/Scheduler              ││
│                                │  │  - Map panel                    ││
│                                │  │  - KPI cards                    ││
│                                │  └─────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

---

## Implementation Rules for Claude Code

1. Import `design-tokens.json` and generate CSS custom properties at build time
2. Use Syncfusion Material Dark theme as base, override `--color-sf-primary` with `#FF2D2D`
3. **Never use hardcoded hex values in component code.** Always reference CSS variables (e.g. `var(--color-brand-500)`)
4. Status pills must always use foreground/background pairs from the status table. Never use status colours for non-status purposes
5. All number displays (fares, distances, counts) must use `font-variant-numeric: tabular-nums`
6. Sidebar: `bg-surface` (`#12151B`). Main content area: `bg-base` (`#0B0D11`). Cards: `bg-card` (`#1A1E27`)
7. No box-shadows on cards. Use 0.5px `border-subtle` only
8. Motion only for state transitions. No decorative animations
9. Lucide Icons only. No mixing icon libraries
10. Inter font must be loaded (Google Fonts or self-hosted). No falling back to system fonts without Inter available
