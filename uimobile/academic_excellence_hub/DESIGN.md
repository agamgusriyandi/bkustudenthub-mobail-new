---
name: Academic Excellence Hub
colors:
  surface: '#fbf9f8'
  surface-dim: '#dbdad9'
  surface-bright: '#fbf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f3f3'
  surface-container: '#efeded'
  surface-container-high: '#e9e8e7'
  surface-container-highest: '#e4e2e2'
  on-surface: '#1b1c1c'
  on-surface-variant: '#444653'
  inverse-surface: '#303031'
  inverse-on-surface: '#f2f0f0'
  outline: '#747684'
  outline-variant: '#c4c5d5'
  surface-tint: '#3557bc'
  primary: '#002068'
  on-primary: '#ffffff'
  primary-container: '#003399'
  on-primary-container: '#8aa4ff'
  inverse-primary: '#b5c4ff'
  secondary: '#745b00'
  on-secondary: '#ffffff'
  secondary-container: '#fdd355'
  on-secondary-container: '#735a00'
  tertiary: '#002e14'
  on-tertiary: '#ffffff'
  tertiary-container: '#004721'
  on-tertiary-container: '#3dbe6e'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dce1ff'
  primary-fixed-dim: '#b5c4ff'
  on-primary-fixed: '#00164e'
  on-primary-fixed-variant: '#153ea3'
  secondary-fixed: '#ffe08b'
  secondary-fixed-dim: '#ebc246'
  on-secondary-fixed: '#241a00'
  on-secondary-fixed-variant: '#584400'
  tertiary-fixed: '#7efba4'
  tertiary-fixed-dim: '#61de8a'
  on-tertiary-fixed: '#00210c'
  on-tertiary-fixed-variant: '#005228'
  background: '#fbf9f8'
  on-background: '#1b1c1c'
  surface-variant: '#e4e2e2'
typography:
  display:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  title-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 10px
    fontWeight: '600'
    lineHeight: 14px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  margin-page: 16px
  gutter: 12px
  card-padding: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 24px
---

## Brand & Style

This design system is built on a **Corporate / Modern** aesthetic tailored specifically for an academic environment. The brand personality is authoritative yet supportive, functioning as a reliable digital companion for students. The goal is to evoke a sense of order and prestige while maintaining the approachability required for a mobile application.

The visual direction prioritizes clarity and efficiency. It avoids unnecessary decorative elements in favor of high-quality typography and a structured information hierarchy. The interface feels institutional and trustworthy, reflecting the values of a higher education establishment while utilizing modern UI patterns to ensure the student experience is fluid and intuitive.

## Colors

The color palette is anchored by a deep navy blue, representing stability and academic rigor. This primary color is used for top-level navigation, primary buttons, and significant brand moments. A gold-yellow accent is extracted from the BKU identity to serve as a high-visibility highlighter for status indicators, achievements, and call-to-action details.

To maintain a clean aesthetic, the background utilizes a very light gray, which provides a subtle contrast against white card surfaces. Success states and health indicators use a professional emerald green, while semantic reds are reserved strictly for critical alerts or logout actions. All colors are calibrated to meet WCAG AA contrast standards for maximum accessibility.

## Typography

This design system utilizes **Inter** for its exceptional legibility on mobile screens and its neutral, professional character. The typographic scale is highly structured to manage the information-dense nature of academic data.

Headlines use semi-bold weights to establish clear section breaks. Body text is set at a comfortable size for long-form reading of scholarship details or campus announcements. Labels and captions use tighter line heights and slightly increased tracking for better readability in dense lists and status badges.

## Layout & Spacing

The design system employs a **Fluid Grid** model optimized for the mobile viewport. It utilizes a 4px baseline grid to ensure vertical rhythm and consistent alignment across all components. 

The primary layout container has a 16px margin on both sides. Content within cards follows a consistent 16px internal padding. Vertical spacing between different modules or "widgets" is set to 24px to provide clear visual separation, while related items within a module use 8px or 12px gaps. This tiered approach to spacing helps the user distinguish between distinct functional areas of the app.

## Elevation & Depth

Visual hierarchy is managed through **Tonal Layers** combined with **Ambient Shadows**. The interface uses depth to signify interactivity and priority:

1.  **Level 0 (Base):** The app background (#F8F9FA) sits at the lowest level.
2.  **Level 1 (Cards):** Main content containers are pure white with a subtle, highly diffused shadow (0px 4px 12px, 5% opacity).
3.  **Level 2 (Interactive):** Elements like "Floating Action Buttons" or active selection cards use a slightly more pronounced shadow (0px 8px 24px, 10% opacity) to suggest they are "above" the content.

Outlines are used sparingly, primarily for input fields or secondary buttons, maintaining a soft, clean look that avoids visual clutter.

## Shapes

The shape language is **Rounded**, using a systematic approach to corner radii that softens the professional aesthetic without feeling overly casual. 

Main container cards and primary buttons utilize a 0.5rem (8px) radius. Larger interactive modules or banners can scale up to 1rem (16px) for a more modern, friendly feel. Smaller elements, like status chips or checkboxes, use the 0.25rem (4px) scale to maintain precision. This consistency in rounding helps unify the various features of the app, from the dashboard to the user profile.

## Components

### Buttons
- **Primary:** Solid Navy Blue (#003399) with white text. Rounded corners (8px). High-contrast and easily identifiable.
- **Secondary:** White background with a Navy Blue border and Navy Blue text. Used for less critical actions like "View History."
- **Ghost:** No background or border, used for navigation within headers or tertiary actions.

### Cards & Containers
Cards are the primary organizational unit. They must have white backgrounds and soft shadows. Headers within cards should use the primary navy color for titles.

### Input Fields
Inputs should have a light gray border (#E0E0E0) that transitions to the primary navy blue when focused. Placeholder text should be neutral and clear.

### Chips & Badges
Used for status indicators (e.g., "Verified," "Pending"). They should use soft, low-saturation backgrounds of the status color (e.g., light green for success) with higher-contrast text.

### Navigation
A bottom navigation bar provides quick access to the Dashboard, Achievement, Scholarship, and Profile. Icons should be line-style with a 2px stroke weight for clarity on retina displays.

### List Items
Interactive lists (like Achievement History) should include a chevron-right icon to indicate the item is tappable, with ample vertical padding (min 12px) to ensure a generous touch target.