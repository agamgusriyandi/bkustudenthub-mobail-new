import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';

class TkBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const TkBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<TkBottomNavBar> createState() => _TkBottomNavBarState();
}

class _TkBottomNavBarState extends State<TkBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.2,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void didUpdateWidget(TkBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      height: 85,
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Background Bar
          Container(
            height: 65,
            decoration: BoxDecoration(
              color: context.appColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
          ),
          // Nav Items
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildNavItem(
                    0,
                    Icons.dashboard_rounded,
                    'Home',
                    themeProvider,
                  ),
                  _buildNavItem(
                    1,
                    Icons.schedule_rounded,
                    'Jadwal',
                    themeProvider,
                  ),
                  _buildNavItem(
                    2,
                    Icons.event_note_rounded,
                    'Booking',
                    themeProvider,
                  ),
                  _buildNavItem(
                    3,
                    Icons.people_alt_rounded,
                    'Pasien',
                    themeProvider,
                  ),
                  _buildNavItem(
                    4,
                    Icons.settings_rounded,
                    'Setelan',
                    themeProvider,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    ThemeProvider themeProvider,
  ) {
    final isSelected = widget.currentIndex == index;

    return GestureDetector(
      onTap: () => widget.onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              transform: Matrix4.translationValues(0, isSelected ? -15 : 0, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected)
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildIconBox(icon, isSelected, themeProvider),
                    )
                  else
                    _buildIconBox(icon, isSelected, themeProvider),
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            if (!isSelected) const SizedBox(height: AppSpacing.s14),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBox(
    IconData icon,
    bool isSelected,
    ThemeProvider themeProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isSelected ? themeProvider.primary : Colors.transparent,
        shape: BoxShape.circle,
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: themeProvider.primary.withAlpha(60),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
                : [],
      ),
      child: Icon(
        icon,
        color: isSelected ? context.appColors.onPrimary : themeProvider.outline.withAlpha(150),
        size: 24,
      ),
    );
  }
}
