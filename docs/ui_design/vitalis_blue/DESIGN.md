# Design System Strategy: Clinical Serenity

## 1. Overview & Creative North Star
**The Creative North Star: "The Clinical Sanctuary"**

This design system moves away from the cold, sterile, and grid-locked aesthetics of traditional medical software. Instead, it adopts a "Clinical Sanctuary" approach—an editorial-inspired digital environment that feels as authoritative as a prestigious medical journal but as calming as a high-end wellness retreat.

We break the "template" look by rejecting the rigid use of 1px borders and boxed-in grids. Instead, we use **Intentional Asymmetry** and **Tonal Layering**. By utilizing the high-contrast scale between `display-lg` (Manrope) and `body-md` (Inter), we create a clear information hierarchy that guides the eye through complex medical data with ease. This system isn't just a tool; it is a premium, trustworthy companion in a user’s healthcare journey.

---

## 2. Colors & Surface Philosophy
The palette is rooted in deep, authoritative blues and pristine, layered whites, accented by sophisticated medicinal tones.

### The "No-Line" Rule
To achieve a premium feel, **1px solid borders are strictly prohibited for sectioning.** Physical boundaries must be defined solely through background color shifts or subtle tonal transitions. For example, a `surface-container-low` card should sit on a `surface` background to create a "soft-edge" separation that feels integrated rather than walled off.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers—like stacked sheets of fine paper.
*   **Base Layer:** `surface` (#f8f9fa) or `surface-bright`.
*   **Secondary Content Area:** Use `surface-container-low` (#f3f4f5).
*   **Interactive Cards:** Use `surface-container-lowest` (#ffffff) to make them "pop" forward naturally.
*   **Floating Elements:** Use `surface-container-highest` (#e1e3e4) for high-priority utility bars.

### The "Glass & Gradient" Rule
To move beyond a "flat" app look, floating elements (like bottom navigation bars or sticky headers) must utilize **Glassmorphism**. Apply a semi-transparent version of `surface` with a 20px backdrop-blur. 

**Signature Texture:** Main CTAs or vaccine progress bars should utilize a subtle linear gradient from `primary` (#00478d) to `primary-container` (#005eb8). This adds "soul" and depth, signaling a higher level of professional polish.

---

## 3. Typography: The Editorial Voice
We use a dual-font strategy to balance character with clinical precision.

*   **Display & Headlines (Manrope):** Used for "Wayfinding" and high-level summaries. Manrope’s geometric yet friendly curves provide the "Modern & Professional" feel. 
    *   *Usage:* `display-md` for vaccine names; `headline-sm` for section headers.
*   **Body & Labels (Inter):** The workhorse for medical data. Inter is chosen for its exceptional legibility in small sizes (dates, dosages, batch numbers).
    *   *Usage:* `body-md` for patient instructions; `label-md` for metadata.

**Hierarchy Tip:** Always pair a large `headline-lg` with a significantly smaller `body-md` to create the "white space" luxury associated with high-end editorial design.

---

## 4. Elevation & Depth
In this design system, depth is a function of light and tone, not shadows and lines.

*   **The Layering Principle:** Place a `surface-container-lowest` card on a `surface-container-low` section. This creates a soft, natural lift without the "dirty" look of heavy shadows.
*   **Ambient Shadows:** If a floating effect is required (e.g., a modal), use an extra-diffused shadow: `box-shadow: 0 20px 40px rgba(25, 28, 29, 0.06)`. The shadow color must be a tinted version of `on-surface` rather than pure black.
*   **The "Ghost Border" Fallback:** If a border is required for accessibility, use the `outline-variant` token at **15% opacity**. Never use 100% opaque borders.
*   **Glassmorphism:** Use `surface-variant` at 70% opacity with a blur effect for elements that overlay medical records, ensuring the user never loses context of the "layer" beneath.

---

## 5. Components

### Cards & Progress Indicators
*   **Rule:** Forbid the use of divider lines. Use vertical spacing (Scale `6` or `8`) to separate content blocks. 
*   **Status Indicators:** Instead of a simple dot, use a subtle pill-shaped chip using `secondary-container` (#8cf3f3) for "Completed" and `tertiary-fixed` (#ffdea8) for "Upcoming."

### Buttons
*   **Primary:** Gradient fill (`primary` to `primary-container`), `xl` roundedness (1.5rem), and `title-sm` (Inter) for the label.
*   **Tertiary:** No background or border. Use `primary` color for text with a `surface-variant` hover state.

### Input Fields
*   **Visual Style:** Use a `surface-container-highest` fill instead of a border. 
*   **Focus State:** Transition the background to `surface-container-lowest` and add a 2px `primary` "Ghost Border" at 20% opacity.

### Additional Signature Components
*   **The "Dose Timeline":** A vertical line-less track using tonal shifts in `surface-container` tiers to show past and future vaccination events.
*   **The Medical "Quick-Action" Glass Bar:** A bottom-anchored floating bar with `backdrop-filter: blur(12px)` containing primary actions like "Book Next Dose."

---

## 6. Do’s and Don’ts

### Do:
*   **Do** use asymmetrical margins. For example, a wider left margin for headlines to create an editorial "ragged" feel.
*   **Do** use `secondary` (#006a6a) for "Success" states to maintain the trustworthy blue-green medical palette.
*   **Do** use the `xl` (1.5rem) roundedness for large containers to soften the "institutional" feel of medical data.

### Don't:
*   **Don't** use pure black (#000000) for text. Always use `on-surface` (#191c1d) to maintain a soft, high-end contrast.
*   **Don't** use 1px dividers to separate list items. Use a 4px gap and a subtle background shift to `surface-container-low`.
*   **Don't** use standard "Warning Red" for upcoming shots. Use the sophisticated `tertiary` (#5f4300) amber tones to encourage action without causing panic.