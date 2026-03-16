# Red Taxi Design Language & Visual Identity

All UI development must conform to these tokens. This ensures visual consistency across the dispatch console, driver app, customer portal, and tenant admin screens.

**Design reference:** CoinTax by Phenomenon Studio (Dribbble). Adapted for a dispatch-operator context with higher-contrast status states and 8-12 hour shift ergonomics.

---

## Design Philosophy

**Dark-first.** Dispatch operators work extended shifts in low-light control rooms. Dark backgrounds reduce eye strain and make coloured status indicators more distinguishable. Light mode is supported as a toggle but dark is the shipped default.

**Card-based layout.** Every data grouping (booking, driver, vehicle, KPI) lives in its own card. Cards use subtle 0.5px borders, never box-shadows. This keeps the interface clean at high information density.

**Status-colour-driven.** Vehicle and booking states are communicated through colour alone at first glance, with text labels as secondary reinforcement. Every status colour is tested for WCAG AA contrast against the dark card background.

**Minimal chrome.** No decorative gradients, rounded-everything, or animations-for-the-sake-of-it. Motion is used only for state transitions (e.g. a booking card sliding from Unassigned to Dispatched).

---

## Colour Palette

### Background Scale (Dark Mode)

Five shades from deepest to lightest, used for layering surfaces:

| Token | Hex | Usage |
|-------|-----|-------|
| `bg-base` | `#0B0D11` | Main content area background |
| `bg-surface` | `#12151B` | Sidebar, secondary panels |
| `bg-card` | `#1A1E27` | Cards, modals, popovers |
| `bg-elevated` | `#242934` | Hover states on cards, nested elements |
| `bg-hover` | `#2E3440` | Interactive element hover |

### Background Scale (Light Mode)

| Token | Hex |
|-------|-----|
| `bg-base` | `#FFFFFF` |
| `bg-surface` | `#F8F9FA` |
| `bg-card` | `#F1F3F5` |
| `bg-elevated` | `#E9ECEF` |
| `bg-hover` | `#DEE2E6` |

### Brand Red Ramp

Primary action colour. Used for dispatch buttons, active states, brand marks, and urgent indicators.

| Token | Hex | Usage |
|-------|-----|-------|
| `brand-300` | `#FF6B6B` | Hover/light variant |
| `brand-500` | `#FF2D2D` | Primary brand, buttons, active states |
| `brand-600` | `#E62626` | Pressed/dark variant |
| `brand-900` | `#331010` | Tinted backgrounds for brand elements |

### Vehicle Status Colours

These five colours are the most critical in the entire system. Operators must distinguish 40+ map pins at a glance. Each hue is maximally separated and tested for deuteranopia/protanopia distinguishability.

| Status | Foreground | Background (10% tint) |
|--------|-----------|----------------------|
| Available | `#34D399` | `#0D2E1A` |
| On Job | `#FBBF24` | `#2D2206` |
| Dispatched | `#A78BFA` | `#1A1333` |
| Offline | `#FF6B6B` | `#331010` |
| On Break | `#38BDF8` | `#0C2333` |

### Booking Status Colours

| Status | Foreground | Background (10% tint) |
|--------|-----------|----------------------|
| Unallocated | `#FBBF24` | `#2D2206` |
| Allocated | `#A78BFA` | `#1A1333` |
| Accepted | `#34D399` | `#0D2E1A` |
| Completed | `#38BDF8` | `#0C2333` |
| Cancelled | `#FF6B6B` | `#331010` |
| COA | `#FF6B6B` | `#331010` |

### Semantic Colours

| Token | Hex | Usage |
|-------|-----|-------|
| `success` | `#34D399` | Confirmations, positive actions |
| `warning` | `#FBBF24` | Warnings, attention needed |
| `danger` | `#FF6B6B` | Errors, destructive actions, cancellations |
| `info` | `#38BDF8` | Informational messages |

### Text Colours

| Token | Dark | Light |
|-------|------|-------|
| `text-primary` | `#F9FAFB` | `#111827` |
| `text-secondary` | `#9CA3AF` | `#6B7280` |
| `text-tertiary` | `#6B7280` | `#9CA3AF` |

### Border Colours

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
| `xs` | 12px | Captions, timestamps, tertiary labels |
| `sm` | 13px | Status pills, table cells, secondary text |
| `base` | 14px | Body text, form inputs, primary table content |
| `lg` | 18px | Card titles, section headings |
| `xl` | 24px | Page titles |
| `2xl` | 28px | KPI numbers |
| `3xl` | 32px | Hero numbers (dashboard totals) |

**All number displays** (fares, distances, counts) must use `font-variant-numeric: tabular-nums`.

---

## Spacing & Layout

All spacing uses a **4px base grid**: 4, 8, 12, 16, 24, 32, 48, 64px.

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4px | Tight inline spacing |
| `sm` | 8px | Between related elements |
| `md` | 12px | Card internal padding (compact) |
| `base` | 16px | Default padding, gaps |
| `lg` | 24px | Section spacing |
| `xl` | 32px | Major section breaks |
| `2xl` | 48px | Page-level spacing |

---

## Component Tokens

### Cards

- Background: `bg-card` (`#1A1E27` dark / `#F1F3F5` light)
- Border: `0.5px solid border-subtle`
- Border radius: `radius-lg` (12px)
- Padding: `base` (16px)
- **Never use box-shadows.** Cards are distinguished by background colour layering only.

### Buttons

- Height: 36px (compact) or 44px (standard)
- Border radius: `radius-md` (8px)
- Font weight: 500
- Primary: `brand-500` background, white text
- Secondary: `bg-elevated` background, `text-primary`
- Danger: `danger` background, white text
- Ghost: transparent, `text-secondary`, hover `bg-hover`

### Status Pills

Used in tables, cards, and map tooltips to show vehicle/booking status.

- Structure: coloured dot (8px) + label text on a tinted background
- Background: status colour at ~10% opacity
- Border radius: `radius-pill` (20px)
- Padding: 6px 14px
- Font size: 13px, weight 500

### Form Inputs

- Height: 44px
- Background: `bg-elevated` (`#242934` dark)
- Border: `1px solid border-default`, on focus `border-focus` (`#FF2D2D`)
- Border radius: `radius-md` (8px)
- Text: `text-primary`
- Placeholder: `text-tertiary`

---

## Iconography

**Icon library:** Lucide Icons (open-source, consistent 24px grid, 1.5px stroke weight). Matches the thin-line aesthetic.

| Size | Usage |
|------|-------|
| 16px | Inline with text |
| 20px | Buttons and nav items |
| 24px | Card headers and empty states |

Icon colour inherits text colour by default. Status icons use the corresponding status colour.

---

## Map Styling

- Google Maps with custom dark style (Aubergine or Silver Dark preset, override water/road/poi colours to match background scale)
- Map pins use the five vehicle status colours with a white border for legibility
- Selected vehicle pin: scale 1.3x with a pulsing ring animation in brand red
- Route overlay: 3px solid line in `brand-500` (`#FF2D2D`) with 40% opacity fill

---

## Logo & Brand Mark

- **Logo:** Text-based wordmark. "red" in lowercase Inter 700 (bold) in `#FF2D2D`, followed by "taxi" in lowercase Inter 400 (regular) in `#F9FAFB` (dark) / `#111827` (light)
- **No icon mark for v1.** The wordmark sits in the top-left of the sidebar at 20px size
- **Favicon:** Red square (rounded 4px) with a white "R" in Inter 700. Reads clearly at 16x16

---

## Dark/Light Mode Strategy

- Dark is the default and the design target
- Light mode inverts the background scale and swaps text colours
- Status colours, brand red, and semantic colours remain unchanged between modes
- Implementation: CSS custom properties at `:root` level, toggled via a `data-theme` attribute on `<html>`
- No separate stylesheet
- Syncfusion theme: Material Dark as base, override primary/accent with brand red tokens. Light mode: Material Light with same overrides

---

## Implementation Rules for Claude Code

1. Import `design-tokens.json` and generate CSS custom properties at build time
2. Use Syncfusion Material Dark theme as base, override `--color-sf-primary` with `#FF2D2D`
3. **Never use hardcoded hex values in component code.** Always reference CSS variables (e.g. `var(--color-brand-500)`)
4. Status pills must always use the foreground/background pairs from the status table. Never use status colours for non-status purposes
5. All number displays (fares, distances, counts) must use `font-variant-numeric: tabular-nums`
6. Dispatch console layout: sidebar is `bg-surface` (`#12151B`), main content area is `bg-base` (`#0B0D11`), cards float on `bg-card` (`#1A1E27`)

---

## Dispatch Console Layout

**See `docs/design/dispatch-layout.md` for the full layout specification.**

Summary: Map-centric with floating panels. The map fills the entire content area as the base layer. All other UI (booking form, detail panels, timeline) floats on top or docks to edges.

### Key Surfaces

| Surface | Background | Position |
|---------|-----------|----------|
| Map (base layer) | Google Maps dark style | Full content area |
| Sidebar | `bg-surface` (`#12151B`) | Left, 64px (expands to 240px on hover) |
| Top bar | `bg-surface` (`#12151B`) | Top, 48px |
| Booking form panel | `bg-card` (`#1A1E27`) | Floating left, 480px, slides in on demand |
| Context panel | `bg-card` (`#1A1E27`) | Floating right, 400px, slides in on click |
| Timeline dock | `bg-card` (`#1A1E27`) | Bottom dock, ~200px, expandable to full diary |
| Command palette | `bg-card` (`#1A1E27`) | Centre modal overlay |
| Toast notifications | `bg-elevated` (`#242934`) | Bottom right stack |

### Panel Animations (the ONLY animations in the app)
- Booking form: slide in from left, 200ms ease-out
- Context panel: slide in from right, 200ms ease-out
- Timeline expand: slide up from bottom, 200ms ease-out
- Command palette: fade in + scale from 95%, 150ms ease-out
- Toast: slide in from right, 200ms ease-out, auto-dismiss after 5s

---

## Scheduler / Diary Colours

### Driver Colour (Allocated Bookings)
Each driver has an operator-assigned colour stored on their profile. When a booking is allocated to a driver, the booking block on the scheduler uses that driver's colour as the background.

### Operator-Configurable Unallocated Colour
The colour for **unallocated bookings** on the scheduler is configurable per tenant in Company Settings. Default: `#D97706` (amber/orange — visible against both dark and light backgrounds). This allows each operator to pick the unallocated colour that works best for their workflow.

### COA (Cancel on Arrival) Visual Treatment
COA bookings need to be immediately distinguishable from normal bookings on the scheduler and in lists:

| Element | Treatment |
|---------|-----------|
| Scheduler block | Strikethrough pattern overlay (diagonal lines at 45°) + `danger` border (`#FF6B6B`) |
| Scheduler text | Prefixed with `[COA]` |
| Status pill | `danger` colours (`#FF6B6B` fg / `#331010` bg) with text "COA" |
| Booking list row | Left border 3px `danger` + muted text (`text-tertiary`) |
| COA Entries tab | Dedicated tab on right panel showing all COA records |

### Full Scheduler Colour Key

| State | Colour Source | Example |
|-------|--------------|---------|
| Unallocated | Tenant config (default `#D97706`) | Amber/orange block |
| Allocated | Driver's profile colour | Driver-specific colour |
| Accepted | Driver's colour + crosshatch overlay | Driver colour with pattern |
| Rejected | Driver's colour + `[R]` prefix | Greyed with prefix |
| Timeout | Driver's colour + `[RT]` prefix | Greyed with prefix |
| COA | Strikethrough + `#FF6B6B` border | Red-bordered with diagonal lines |
| ASAP | Booking colour + pulsing `brand-500` border | Urgent animation |
| Soft Allocated | Driver's colour at 50% opacity | Faded version of driver colour |
| Completed | `#38BDF8` (info) at 30% opacity | Faded blue |

---

## Driver App Design Direction

The driver app follows the same design language but adapted for mobile, outdoor use:

- **Dark-first** (same as dispatch console) — matches brand, works well in-vehicle at night
- **Light mode toggle available** — for outdoor daytime use
- Same brand red, same status colours, same Inter typeface
- **Large touch targets:** minimum 48px tap targets for all interactive elements (Accept/Reject buttons: 56px height, full width)
- **High contrast mode:** status colours are already WCAG AA — maintain this on mobile
- **Simplified layout:** single-column, card-based, no multi-panel splits
- **Key screen priorities:** job offer (accept/reject must be reachable with one thumb), active job (navigation + status updates), earnings summary
