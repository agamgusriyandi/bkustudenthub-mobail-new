import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';

class BkuBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool useRootNavigator = true,
    EdgeInsets padding = const EdgeInsets.all(AppSpacing.lg),
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      useRootNavigator: useRootNavigator,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = context.watch<ThemeProvider>();
        final mediaQuery = MediaQuery.of(context);

        return Padding(
          padding: EdgeInsets.only(
            bottom: mediaQuery.viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: mediaQuery.size.height * 0.90,
            ),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A0F172A),
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: BkuTheme.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (title != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: BkuTheme.textSectionTitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: BkuTheme.borderSubtle),
                  ],
                  Flexible(
                    child: Padding(padding: padding, child: child),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
