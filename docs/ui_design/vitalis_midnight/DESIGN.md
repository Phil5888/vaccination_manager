# Design System Specification: High-End Clinical Dark Mode

## 1. Overview & Creative North Star
### The Creative North Star: "The Luminescent Lab"
This design system moves away from the "flat dashboard" trope and toward a high-end, editorial medical experience. The goal is to convey clinical precision through **Tonal Depth** and **Atmospheric Clarity**. 

We break the "template" look by utilizing intentional asymmetry and "The No-Line Rule." Instead of boxes and borders, we use light as a structural element. The interface should feel like a sophisticated medical instrument: dark, focused, and illuminated only where data requires attention. We achieve this through:
*   **Layered Translucency:** Utilizing glassmorphism to suggest depth without weight.
*   **Asymmetric Breathing Room:** Breaking the rigid 12-column feel with generous, intentional whitespace (using our 16 and 24 spacing tokens).
*   **Chromatic Depth:** Using a navy-based neutral palette to ensure the dark mode feels "expensive" rather than just "black."

---

## 2. Colors & Surface Architecture

### The Palette
The core of the system is the interplay between the deep `surface` (`#060E20`) and the vibrant `primary` (`#85ADFF`).

*   **Primary/Action:** Use `primary` for high-intent actions. Use `primary_container` for secondary emphasis.
*   **The Neutrals:** Use `surface_container` tiers to define hierarchy.
*   **The Tertiary Glow:** `tertiary` (`#FBABFF`) is reserved for "System Insights" or "Human Touch" moments—use it sparingly to highlight breakthrough data or patient-centric highlights.

### The "No-Line" Rule
**Explicit Instruction:** Do not use 1px solid borders to section content. 
Boundaries must be defined solely through background color shifts. A `surface_container_low` section sitting on a `surface` background provides enough contrast for the eye to perceive a boundary without the "grid-trap" of traditional lines.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers. Use the following nesting logic:
1.  **Level 0 (Base):** `surface` (#060E20)
2.  **Level 1 (Sectioning):** `surface_container_low` (#091328)
3.  **Level 2 (Cards/Modules):** `surface_container` (#0F1930)
4.  **Level 3 (Popovers/Overlays):** `surface_bright` (#1F2B49)

### The "Glass & Gradient" Rule
To add visual "soul," use subtle linear gradients for Hero areas: 
`Linear-Gradient(135deg, primary 0%, primary_container 100%)`. 
For floating elements, apply `surface_bright` at 60% opacity with a `backdrop-filter: blur(12px)` to create a frosted-glass clinical feel.

---

## 3. Typography: The Manrope Scale
We use **Manrope** for its geometric yet approachable medical aesthetic.

*   **Display (lg/md/sm):** Used for "Hero Numbers" or headline stats. High-impact, low word count.
*   **Headline (lg/md):** Used for page titles. These should always sit on the `surface` base, never inside tight containers, to allow them to "breathe."
*   **Title (lg/md/sm):** Used for card headings. Use `title-md` for standard modules.
*   **Body (lg/md):** The workhorse. `body-md` is the default for medical records and descriptions. Use `on_surface_variant` (#A3AAC4) for secondary body text to reduce visual noise.
*   **Labels:** Use `label-md` in All-Caps with 0.05rem letter-spacing for category headers to provide an "authoritative" feel.

---

## 4. Elevation & Depth

### The Layering Principle
Depth is achieved by "stacking" surface tiers. To create a "lifted" card, place a `surface_container_high` card on top of a `surface_container_low` background.

### Ambient Shadows
Avoid black shadows. Use "Luminous Shadows":
*   **Shadow Color:** `on_surface` (#DEE5FF) at 4%–8% opacity.
*   **Blur:** Use large 32px–64px blur values for a soft, ambient glow that mimics a light source hitting a surface.

### The "Ghost Border" Fallback
If a border is required for accessibility (e.g., in high-density data tables), use a **Ghost Border**:
*   **Stroke:** `outline_variant` (#40485D) at 20% opacity. 
*   **Strict Proscription:** Never use 100% opaque outlines.

---

## 5. Components

### Buttons
*   **Primary:** `primary` background with `on_primary` text. `ROUND_EIGHT` (0.5rem) corners.
*   **Secondary:** `surface_variant` background with `primary` text. No border.
*   **Tertiary/Ghost:** No background. `primary` text. Use a subtle `surface_container_highest` background on `:hover`.

### Input Fields
*   **Background:** `surface_container_highest`.
*   **Indicator:** Instead of a full border, use a 2px bottom-stroke of `primary` when focused.
*   **Error State:** Use `error` (#FF716C) text and `error_container` as a subtle 10% opacity background wash.

### Cards & Lists
*   **Rule:** Forbid divider lines.
*   **Separation:** Use `spacing-6` (1.5rem) to separate list items. Use a `surface_container_low` background shift on hover to indicate interactivity.
*   **Medical Data Cards:** Use `surface_container` with `padding-5` (1.25rem). 

### Progress & Charts
*   Use `primary` for standard data.
*   Use `tertiary` (#FBABFF) for "Goal Reached" or "Healthy Range" to provide a soft, non-clinical contrast.

---

## 6. Do's and Don'ts

### Do:
*   **DO** use `surface_container` shifts to group related medical data.
*   **DO** use `display-lg` for critical vital signs to create an editorial "Data-First" hierarchy.
*   **DO** use `primary_fixed` for elements that must remain high-contrast regardless of the specific background tier.

### Don't:
*   **DON'T** use 1px solid dividers (the "No-Line" Rule).
*   **DON'T** use pure black (#000000) for backgrounds; it kills the "Clinical Navy" depth. Use `surface`.
*   **DON'T** use standard drop shadows. Always use the "Luminous Shadow" tinted with the surface color.
*   **DON'T** crowd the interface. If the data feels cramped, increase the container to the next `spacing` token. This system relies on "Luxurious Whitespace" to maintain a premium feel.