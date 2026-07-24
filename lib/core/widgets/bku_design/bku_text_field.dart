import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';

class BkuTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final int maxLines;
  final int? minLines;
  final bool readOnly;
  final VoidCallback? onTap;

  // Legacy TextFormField parameters for drop-in replacement
  final InputDecoration? decoration;
  final TextStyle? style;
  final String? initialValue;
  final FocusNode? focusNode;
  final bool autofocus;
  final void Function(String?)? onSaved;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;
  final bool? enabled;
  final TextAlign textAlign;

  const BkuTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.onTap,
    this.decoration,
    this.style,
    this.initialValue,
    this.focusNode,
    this.autofocus = false,
    this.onSaved,
    this.inputFormatters,
    this.autovalidateMode,
    this.enabled,
    this.textAlign = TextAlign.start,
  });

  @override
  State<BkuTextField> createState() => _BkuTextFieldState();
}

class _BkuTextFieldState extends State<BkuTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    final border = OutlineInputBorder(
      borderRadius: AppRadius.radiusMd, // 12px radius
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

    final resolvedLabel = widget.label ?? widget.decoration?.labelText;
    final resolvedHint = widget.hint ?? widget.decoration?.hintText;
    final resolvedPrefixIcon =
        widget.prefixIcon ?? widget.decoration?.prefixIcon;
    Widget? suffixIcon = widget.suffixIcon ?? widget.decoration?.suffixIcon;
    if (widget.obscureText) {
      suffixIcon = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.neutral500,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (resolvedLabel != null) ...[
          Text(
            resolvedLabel,
            style: AppTextStyles.labelMd.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.neutral700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          obscureText: _obscureText,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onSaved: widget.onSaved,
          inputFormatters: widget.inputFormatters,
          autovalidateMode: widget.autovalidateMode,
          enabled: widget.enabled,
          textAlign: widget.textAlign,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          style:
              widget.style ??
              AppTextStyles.bodyLg.copyWith(color: AppColors.neutral900),
          decoration:
              widget.decoration?.copyWith(
                hintText: resolvedHint,
                hintStyle: AppTextStyles.bodyLg.copyWith(
                  color: AppColors.neutral400,
                ),
                filled: true,
                fillColor:
                    widget.readOnly
                        ? AppColors.neutral100
                        : AppColors.neutral50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                prefixIcon: resolvedPrefixIcon,
                suffixIcon: suffixIcon,
                border: border,
                enabledBorder: border,
                focusedBorder: focusedBorder,
                errorBorder: errorBorder,
                focusedErrorBorder: errorBorder.copyWith(
                  borderSide: BorderSide(color: theme.colorError, width: 2),
                ),
              ) ??
              InputDecoration(
                hintText: resolvedHint,
                hintStyle: AppTextStyles.bodyLg.copyWith(
                  color: AppColors.neutral400,
                ),
                filled: true,
                fillColor:
                    widget.readOnly
                        ? AppColors.neutral100
                        : AppColors.neutral50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                prefixIcon: resolvedPrefixIcon,
                suffixIcon: suffixIcon,
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
