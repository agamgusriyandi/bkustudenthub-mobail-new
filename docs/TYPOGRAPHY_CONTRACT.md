# TYPOGRAPHY SYSTEM CONTRACT — BKU STUDENT HUB

## 1. Font Family
The BKU Student Hub mobile application strictly uses **Google Fonts: Plus Jakarta Sans** as its sole typography font family.

- **Primary Font Family:** `Plus Jakarta Sans`
- **Fallback Font:** System default sans-serif

---

## 2. Display Scale (Hero & Branding)
Used for splash branding, hero numbers, and major splash screen headers.

| Token Name | Size | Font Weight | Line Height Formula | Line Height (px) | Usage |
|---|---:|---:|---|---:|---|
| `displayLarge` | `40px` | `700` (Bold) | `48 / 40` | `48px` | App branding, splash screen hero title |
| `displayMedium` | `32px` | `700` (Bold) | `40 / 32` | `40px` | Hero section main banner text |
| `displaySmall` | `28px` | `700` (Bold) | `36 / 28` | `36px` | Section hero banners |

---

## 3. Headline Scale (Pages & Major Sections)
Used for page titles, major screen headers, and prominent section titles.

| Token Name | Size | Font Weight | Line Height Formula | Line Height (px) | Usage |
|---|---:|---:|---|---:|---|
| `headlineLarge` | `24px` | `700` (Bold) | `32 / 24` | `32px` | Page primary titles |
| `headlineMedium` | `22px` | `600` (SemiBold) | `28 / 22` | `28px` | Major section headers |
| `headlineSmall` | `20px` | `600` (SemiBold) | `28 / 20` | `28px` | Sub-section headers |

---

## 4. Title Scale (Cards, Items & Dialogs)
Used for card titles, dialog titles, list item headers, and interactive component titles.

| Token Name | Size | Font Weight | Line Height Formula | Line Height (px) | Usage |
|---|---:|---:|---|---:|---|
| `titleLarge` | `18px` | `600` (SemiBold) | `24 / 18` | `24px` | Dialog titles, prominent card headers |
| `titleMedium` | `16px` | `600` (SemiBold) | `24 / 16` | `24px` | List item titles, card titles |
| `titleSmall` | `14px` | `600` (SemiBold) | `20 / 14` | `20px` | Small card titles, chip labels |

---

## 5. Body Scale (Paragraphs & Content Text)
Used for descriptions, body text, secondary explanations, and list subtitles.

| Token Name | Size | Font Weight | Line Height Formula | Line Height (px) | Usage |
|---|---:|---:|---|---:|---|
| `bodyLarge` | `16px` | `400` (Regular) | `24 / 16` | `24px` | Primary body text, main descriptions |
| `bodyMedium` | `14px` | `400` (Regular) | `20 / 14` | `20px` | Standard body paragraphs, content notes |
| `bodySmall` | `12px` | `400` (Regular) | `16 / 12` | `16px` | Secondary text, tertiary descriptions |

---

## 6. Label Scale (Buttons, Form Inputs & Tabs)
Used for button text, form field labels, tab item titles, and badges.

| Token Name | Size | Font Weight | Line Height Formula | Line Height (px) | Usage |
|---|---:|---:|---|---:|---|
| `labelLarge` | `14px` | `500` (Medium) | `20 / 14` | `20px` | Primary button text, main tab labels |
| `labelMedium` | `12px` | `500` (Medium) | `16 / 12` | `16px` | Form field labels, secondary tab labels |
| `labelSmall` | `11px` | `600` (SemiBold) | `14 / 11` | `14px` | Badges, timestamps, small action pills |

---

## 7. Special Scales (Caption & Overline)
Used for fine print, footnotes, and decorative uppercase labels.

| Token Name | Size | Font Weight | Letter Spacing | Line Height Formula | Line Height (px) | Usage |
|---|---:|---:|---:|---|---:|---|
| `caption` | `10px` | `400` (Regular) | `0` | `14 / 10` | `14px` | Micro copy, footnotes, legal disclaimers |
| `overline` | `10px` | `700` (Bold) | `0.5` | `16 / 10` | `16px` | Decorative uppercase section category tags |

---

## 8. Line-Height Calculation Rules
Line height in Flutter `TextStyle` MUST always be calculated as:

$$\text{height} = \frac{\text{lineHeightInPixels}}{\text{fontSizeInPixels}}$$

- **Rule 1:** `height` is a multiplier relative to the exact `fontSize`.
- **Rule 2:** The divisor in `height: lineHeight / fontSize` MUST match the `fontSize` property. Never use mismatched hardcoded denominators.

---

## 9. Naming Convention
1. **Canonical Names:** Use camelCase matching Material Design 3 scale conventions (`displayLarge`, `headlineMedium`, `titleMedium`, `bodySmall`, `labelLarge`).
2. **Semantic Clarity:** Always select typography styles based on their **semantic role** in the UI hierarchy, not just visual font size.

---

## 10. Legacy Aliases & Deprecation Strategy
To maintain 100% backward compatibility with existing feature screens without breaking existing UI code:

| Legacy Token | Canonical Equivalent | Deprecation Status |
|---|---|---|
| `AppTextStyles.display` | `AppTextStyles.displaySmall` | `@Deprecated('Use displaySmall instead.')` |
| `AppTextStyles.headlineMd` | `AppTextStyles.headlineSmall` | `@Deprecated('Use headlineSmall instead.')` |
| `AppTextStyles.titleLg` | `AppTextStyles.titleLarge` | `@Deprecated('Use titleLarge instead.')` |
| `AppTextStyles.titleMd` | `AppTextStyles.titleMedium` | `@Deprecated('Use titleMedium instead.')` |
| `AppTextStyles.titleSm` | `AppTextStyles.titleSmall` | `@Deprecated('Use titleSmall instead.')` |
| `AppTextStyles.bodyLg` | `AppTextStyles.bodyLarge` | `@Deprecated('Use bodyLarge instead.')` |
| `AppTextStyles.bodyMd` | `AppTextStyles.bodyMedium` | `@Deprecated('Use bodyMedium instead.')` |
| `AppTextStyles.bodySm` | `AppTextStyles.bodySmall` | `@Deprecated('Use bodySmall instead.')` |
| `AppTextStyles.labelLg` | `AppTextStyles.labelLarge` | `@Deprecated('Use labelLarge instead.')` |
| `AppTextStyles.labelMd` | `AppTextStyles.labelMedium` | `@Deprecated('Use labelMedium instead.')` |
| `AppTextStyles.labelSm` | `AppTextStyles.labelSmall` | `@Deprecated('Use labelSmall instead.')` |

---

## 11. Usage Examples

```dart
// 1. Screen Title
Text(
  'Katalog Beasiswa',
  style: AppTextStyles.headlineLarge.copyWith(
    color: AppColors.neutral900,
  ),
);

// 2. Card Header
Text(
  'BKU Berdampak Ganjil 2026-2027',
  style: AppTextStyles.titleMedium.copyWith(
    color: AppColors.neutral900,
  ),
);

// 3. Body Description
Text(
  'Program bantuan biaya pendidikan mahasiswa.',
  style: AppTextStyles.bodyMedium.copyWith(
    color: AppColors.neutral700,
  ),
);

// 4. Action Button Label
Text(
  'Lihat Detail Program',
  style: AppTextStyles.labelLarge.copyWith(
    color: Colors.white,
  ),
);
```

---

## 12. Rules for Developers & AI Assistants
1. **Never Hardcode TextStyle:** Do not write inline `TextStyle(fontSize: 14, fontWeight: FontWeight.bold)` for standard app typography. Always consume `AppTextStyles.*`.
2. **Never Hardcode Colors in AppTextStyles:** Keep default colors linked to `AppColors.onSurface`, `AppColors.onSurfaceVariant`, or `AppColors.neutral500`. Override colors at consumer level using `.copyWith(color: ...)`.
3. **Preserve Semantic Scale:** Do not use `headlineLarge` for body text or `caption` for card titles.
