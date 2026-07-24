---
name: flutter-frontend-design
description: Builds production-quality, visually stunning Flutter UIs using tailored typography, rich color palettes, smooth animations, and clean spatial layout. Use when implementing or styling Flutter components and screens.
---
# Flutter Frontend Design & Aesthetic Guidelines

## Architecture & Structure

```text
lib/
├── main.dart
├── app.dart                    # MaterialApp / CupertinoApp config
├── core/
│   ├── theme/
│   │   ├── app_theme.dart      # ThemeData definitions
│   │   ├── app_colors.dart     # Color constants & extensions
│   │   ├── app_typography.dart # TextStyle definitions
│   │   └── app_spacing.dart    # Spacing constants
│   ├── constants/
│   └── utils/
├── features/
│   └── feature_name/
│       ├── presentation/
│       │   ├── screens/
│       │   ├── widgets/
│       │   └── controllers/
│       ├── domain/
│       └── data/
└── shared/
    └── widgets/                # Reusable custom widgets
```

### State Management
- Use `StatefulWidget` for simple local state
- Recommend Riverpod or Provider/Bloc for complex state
- Always separate UI from business logic
- Use `ValueNotifier` / `ChangeNotifier` for lightweight reactive patterns

### Responsive Design
```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 1200) return _desktopLayout();
    if (constraints.maxWidth > 600) return _tabletLayout();
    return _mobileLayout();
  },
)
```

## Flutter Aesthetics Guidelines

### Typography
- **NEVER** use default Material font without customization
- Pair a bold display font with a refined body font
- Define ALL text styles in `AppTypography` / `AppTextStyles` class

### Color & Theme
- Define colors using `ColorScheme.fromSeed()` or custom `ColorScheme`
- Support BOTH light and dark themes from the start
- Dominant colors with sharp accents outperform timid, evenly-distributed palettes

```dart
class AppColors {
  static const primary = Color(0xFF1A1A2E);
  static const accent = Color(0xFFE94560);
  static const surface = Color(0xFF16213E);
  static const background = Color(0xFF0F3460);

  static const success = Color(0xFF00C897);
  static const warning = Color(0xFFFFB800);
  static const error = Color(0xFFFF4757);

  static const heroGradient = LinearGradient(
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
```

### Motion & Animation
- **Implicit animations**: `AnimatedContainer`, `AnimatedOpacity`, `AnimatedScale`, `AnimatedSlide`, `AnimatedSwitcher`
- **Hero animations**: For screen transitions with shared elements
- **Staggered animations**: Use `Interval` with `AnimationController` for orchestrated reveals
- **Micro-interactions**: `GestureDetector` + `AnimatedScale` for tap feedback

### Spatial Composition
- Use `SliverAppBar` with `FlexibleSpaceBar` for immersive scroll effects
- `CustomScrollView` with mixed `Sliver` widgets for complex layouts
- `Stack` + `Positioned` for overlapping elements
- `BackdropFilter` with `ImageFilter.blur` for glassmorphism

## What to NEVER Do

- **NEVER** use default Material theme without customization
- **NEVER** use only `Scaffold` + `ListView` + `Card` with zero styling
- **NEVER** rely solely on Material default colors
- **NEVER** hardcode sizes — use `MediaQuery`, `LayoutBuilder`, `Flexible`, `Expanded`
- **NEVER** ignore platform conventions

## Quality Checklist

Before delivering Flutter UI code, verify:
- [ ] Custom `ThemeData` with unique colors and typography
- [ ] Responsive layout (mobile + tablet minimum)
- [ ] At least 2-3 meaningful animations or transitions
- [ ] Proper widget extraction (no mega-build methods)
- [ ] Performance considerations (`const` constructors, `RepaintBoundary` where needed)
