import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';

class BkuDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final T? initialValue;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final void Function(T?)? onSaved;
  final String? Function(T?)? validator;
  final bool enabled;
  final Widget? prefixIcon;
  final InputDecoration? decoration;
  final Widget? underline;
  final bool isExpanded;
  final TextStyle? style;
  final Widget? icon;
  final Color? dropdownColor;
  final Widget? disabledHint;

  const BkuDropdown({
    super.key,
    this.label,
    this.hint,
    required this.items,
    this.value,
    this.initialValue,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
    this.decoration,
    this.underline,
    this.isExpanded = true,
    this.style,
    this.icon,
    this.dropdownColor,
    this.disabledHint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    
    final resolvedLabel = label ?? decoration?.labelText;
    final resolvedHint = hint ?? decoration?.hintText;
    final resolvedPrefixIcon = prefixIcon ?? decoration?.prefixIcon;
    final resolvedValue = value ?? initialValue;
    final resolvedStyle = style ?? AppTextStyles.bodyLg.copyWith(color: AppColors.neutral900);

    final border = OutlineInputBorder(
      borderRadius: AppRadius.radiusMd,
      borderSide: const BorderSide(color: AppColors.neutral200),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: AppRadius.radiusMd,
      borderSide: BorderSide(color: theme.primary, width: 1.5),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: AppRadius.radiusMd,
      borderSide: BorderSide(color: theme.colorError, width: 1.5),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (resolvedLabel != null) ...[
          Text(
            resolvedLabel,
            style: AppTextStyles.labelMd.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        DropdownButtonFormField<T>(
          initialValue: resolvedValue,
          items: items,
          onChanged: enabled ? onChanged : null,
          onSaved: onSaved,
          validator: validator,
          icon: icon ?? const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.neutral500),
          isExpanded: isExpanded,
          style: resolvedStyle,
          dropdownColor: dropdownColor,
          disabledHint: disabledHint,
          decoration: decoration?.copyWith(
            hintText: resolvedHint,
            hintStyle: AppTextStyles.bodyLg.copyWith(color: AppColors.neutral400),
            filled: true,
            fillColor: !enabled ? AppColors.neutral100 : AppColors.neutral50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: resolvedPrefixIcon,
            border: border,
            enabledBorder: border,
            focusedBorder: focusedBorder,
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder.copyWith(
              borderSide: BorderSide(color: theme.colorError, width: 2),
            ),
          ) ?? InputDecoration(
            hintText: resolvedHint,
            hintStyle: AppTextStyles.bodyLg.copyWith(color: AppColors.neutral400),
            filled: true,
            fillColor: !enabled ? AppColors.neutral100 : AppColors.neutral50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: resolvedPrefixIcon,
            border: border,
            enabledBorder: border,
            focusedBorder: focusedBorder,
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder.copyWith(
              borderSide: BorderSide(color: theme.colorError, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
