import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';

class BkuTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? prefixIcon;
  final Color? prefixIconColor;
  final String? prefixText;
  final TextStyle? prefixStyle;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function(String)? onFieldSubmitted;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final bool readOnly;
  final VoidCallback? onTap;
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
  final bool expands;
  final EdgeInsets scrollPadding;
  final Color? cursorColor;
  final Widget? Function(BuildContext, {required int currentLength, required bool isFocused, required int? maxLength})? buildCounter;

  const BkuTextField({
    super.key,
    this.label,
    this.hint,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.prefixIconColor,
    this.prefixText,
    this.prefixStyle,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.maxLengthEnforcement,
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
    this.expands = false,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.cursorColor,
    this.buildCounter,
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
  void didUpdateWidget(covariant BkuTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _obscureText = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    final border = OutlineInputBorder(
      borderRadius: BkuTheme.r16,
      borderSide: const BorderSide(color: BkuTheme.border, width: 1.0),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BkuTheme.r16,
      borderSide: BorderSide(color: theme.primary, width: 1.5),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BkuTheme.r16,
      borderSide: BorderSide(color: theme.colorError, width: 1.5),
    );

    final resolvedLabel = widget.label ?? widget.decoration?.labelText;
    final resolvedHint = widget.hint ?? widget.hintText ?? widget.decoration?.hintText;
    final resolvedPrefixIcon = widget.prefixIcon ?? widget.decoration?.prefixIcon;
    final resolvedSubmitted = widget.onFieldSubmitted ?? widget.onSubmitted;

    Widget? suffixIcon = widget.suffixIcon ?? widget.decoration?.suffixIcon;
    if (widget.obscureText) {
      suffixIcon = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: BkuTheme.textPlaceholder,
          size: 20,
        ),
        tooltip: _obscureText ? 'Tampilkan password' : 'Sembunyikan password',
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (resolvedLabel != null) ...[
          Text(
            resolvedLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: BkuTheme.textHeading,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 6),
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
          onFieldSubmitted: resolvedSubmitted,
          onSaved: widget.onSaved,
          inputFormatters: widget.inputFormatters,
          autovalidateMode: widget.autovalidateMode,
          enabled: widget.enabled,
          textAlign: widget.textAlign,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          maxLengthEnforcement: widget.maxLengthEnforcement,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          expands: widget.expands,
          scrollPadding: widget.scrollPadding,
          cursorColor: widget.cursorColor ?? theme.primary,
          buildCounter: widget.buildCounter,
          style: widget.style ??
              const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: BkuTheme.textHeading,
              ),
          decoration: widget.decoration?.copyWith(
                hintText: resolvedHint,
                hintStyle: const TextStyle(
                  fontSize: 12.5,
                  color: BkuTheme.textPlaceholder,
                ),
                filled: true,
                fillColor: widget.readOnly ? BkuTheme.borderSubtle : BkuTheme.cardSurface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                prefixText: widget.prefixText,
                prefixStyle: widget.prefixStyle ??
                    const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: BkuTheme.textHeading,
                    ),
                prefixIcon: resolvedPrefixIcon,
                prefixIconColor: widget.prefixIconColor,
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
                hintStyle: const TextStyle(
                  fontSize: 12.5,
                  color: BkuTheme.textPlaceholder,
                ),
                filled: true,
                fillColor: widget.readOnly ? BkuTheme.borderSubtle : BkuTheme.cardSurface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                prefixText: widget.prefixText,
                prefixStyle: widget.prefixStyle ??
                    const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: BkuTheme.textHeading,
                    ),
                prefixIcon: resolvedPrefixIcon,
                prefixIconColor: widget.prefixIconColor,
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
