# BKU Student Hub: Design System Contract

This document acts as the **permanent governing contract** for all User Interface development inside the BKU Student Hub mobile application. 

By contributing to this repository, you agree to adhere strictly to the `BkuDesign` constraints below. The core objective is **ONE SOURCE OF TRUTH**, **ONE DESIGN LANGUAGE**, and **NO UNNECESSARY DUPLICATION**.

---

### Rule 1: Use `BkuButton`, not raw Flutter buttons.
Never use `ElevatedButton`, `FilledButton`, `OutlinedButton`, or `TextButton` for standard application flow (Submits, Cancels, Navigations). Always use `BkuButton` (e.g., `BkuButton.primary()`, `BkuButton.outline()`, `BkuButton.text()`).

### Rule 2: Use `BkuTextField` / `BkuDropdown` for standard forms.
Do not use `TextField` or `TextFormField` directly for data entry forms. Use `BkuTextField` and `BkuDropdown` to ensure consistent error states, borders, typography, and spacing.

### Rule 3: Use `BkuCard` for generic content cards.
Avoid instantiating raw `Card` or custom `Container` with box shadows for generic content grouping. Use `BkuCard` to maintain uniform elevation and radius.

### Rule 4: Use `BkuDialog` for standard dialogs.
Do not use `AlertDialog` or `showDialog` for simple confirmations, alerts, or success/error messages. Use `BkuDialog.show()` and `BkuLoadingDialog.show()`. 

### Rule 5: Use `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadius`, `AppShadows`.
Hardcoded design tokens (`Color(0xFF...)`, `16.0`, `FontWeight.w600`) are strictly forbidden for semantic components. Always rely on the global constants inside `lib/core/theme/`.
*For colors, use `context.appColors.primary` (theme-aware) or `AppColors.neutral500` (static).*

### Rule 6: Raw Flutter primitives require a documented technical justification.
If you must use a raw primitive (e.g. `Colors.black`, `showDialog`), it must be justified by:
1. **Rendering Constraint:** e.g., `Colors.transparent` for hitbox mapping.
2. **Extreme Customization:** e.g., A complex multi-step form inside a dialog where `BkuDialog` constraints fail.

### Rule 7: Feature-specific UI remains allowed.
Gamification (Quizzes, Leaderboards), specific tracking visualizations (Stages), and bespoke brand elements are permitted to use localized raw colors/layouts **only** if they intentionally bypass the semantic design system. Do not map a gamification "gold" tier to a semantic `AppColors.warning`.

### Rule 8: Do not create duplicate design tokens inside features.
Do not define local `Color` constants, local `TextStyle` variables, or local `Constants` files inside feature directories (e.g., `lib/features/auth/auth_colors.dart` is strictly forbidden). 

### Rule 9: Core components must stay semantic and reusable.
Widgets in `lib/core/widgets/bku_design/` must never import from `lib/features/`. They must remain completely agnostic, state-independent, and purely presentational.

### Rule 10: Before adding a new UI component, search Core first.
Before building a custom badge, empty state, loader, or button, verify if it already exists in `lib/core/widgets/bku_design/`. If a modification is needed, update the Core component instead of building a localized duplicate.
