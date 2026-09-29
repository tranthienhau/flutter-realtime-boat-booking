# Boatingo Design System

Bright, premium marine charter app. Graphite + brass, like polished yacht hardware on a warm off-white deck. Light theme only.

## Color (use ONLY these colors; no default violet/indigo, no flat neutral grey)
- Background: #F9F8F7 (warm tinted near-white)
- Surface / cards / sheets: #FFFFFF
- Surface alt (grouped rows, chips): #F1EEEA
- Accent (primary actions, active states, key numerals): graphite #2B2A28
- Accent pressed: #1C1B1A
- Accent tint: #EAE9E8
- Support (highlights, seats-left chips, focal accents, countdowns, charts): brass #D4B06A
- Support tint: #F7EFDD
- Text primary #181614, secondary #5E5952, tertiary #8A8580
- Border / hairline: #E7E3DD
- Success #16A34A (live dot, available), Warning #D97706 (limited, weather), Danger #DC2626 (cancel, full)
- White labels only on graphite. Brass carries graphite text, never white.

## Typography
- UI + body: Montserrat. Display / hero titles: Playfair Display (serif, elegant).
- Numerals (prices, seats, countdown, booking IDs): Montserrat tabular.
- Display 32/700/-0.02em, Title 20/600, Body 16/400, Label 14/500, Caption 13/500.

## Frame
- 393x852 mobile (iPhone 16/17). Keep top ~59px and bottom ~34px safe areas clear.
- Edge padding 20px, 8pt spacing scale (4, 8, 12, 16, 24, 32).

## Shape + elevation
- Radius: card 20, control 14, input 12, pill 999.
- Soft shadow only: 0 1px 2px rgba(24,22,20,.04) + 0 8px 24px rgba(24,22,20,.06).

## Icons
- One set: rounded outline (Lucide style), 24px, 1.75 stroke. Never mix filled + outline.

## Controls (one spec each, reused everywhere)
- Primary button: pill, graphite #2B2A28 fill, white Montserrat 600 label. Pressed #1C1B1A. Disabled #D9D5CF with #8A8580 label.
- Secondary button: pill, 1.5px graphite outline, graphite label.
- Text input: 12px radius, white, 1px #E7E3DD border; focus = 2px brass ring; error = danger ring + caption.
- Card: 20px radius, white, soft shadow.
- Chip: pill; selected = graphite fill, white text; unselected = #F1EEEA fill, graphite text.
- Live pill (reused on every listing/detail): small white pill, pulsing green #16A34A dot, 'Live' label + 'synced 12s ago' caption.
- Seats-left chip: brass tint #F7EFDD fill, graphite text, e.g. '3 seats left'. 'Last seat' uses solid brass fill. 'Sold out' uses #F1EEEA with tertiary text.

## Shared components
- Bottom tab bar: exactly 4 tabs in this order - Explore (compass icon), Search (calendar-search icon), Bookings (ticket icon), Profile (user icon). Active tab: graphite #2B2A28 icon + label with a small brass dot beneath. Inactive: #8A8580. Flat white bar, hairline top border #E7E3DD, no gradient. Never rename, reorder, add, or remove tabs.
- Modal / full-screen / checkout / onboarding screens show NO tab bar.

## Gradient + focal rules
- Soft brass #D4B06A -> graphite #2B2A28 gradient (or graphite-to-transparent over photos) only on hero photo overlays, onboarding, confirmation header and featured cards. Tab bar stays flat. Max two gradient moments per screen.
- Every screen has ONE bold focal element (hero boat photo card, countdown ring, booking ID, capacity bar). Everything else stays quiet.

## Imagery
- Real photography wherever there is a visual slot: yachts, catamarans, phinisi boats, fast boats, turquoise lagoons, marinas, skipper portraits. Natural light, premium travel editorial look. Prefer photos over icon placeholders.
