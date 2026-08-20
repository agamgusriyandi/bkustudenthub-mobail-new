import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';

class OrmawaTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final Color? prefixIconColor;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;

  const OrmawaTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.prefixIcon,
    this.prefixIconColor,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.onChanged,
    this.inputFormatters,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return BkuTextField(
      label: label,
      hint: hintText,
      controller: controller,
      prefixIcon: prefixIcon != null
          ? Icon(
              prefixIcon,
              color: prefixIconColor ?? const Color(0xFF64748B),
              size: 20,
            )
          : null,
      prefixIconColor: prefixIconColor,
      suffixIcon: suffixIcon,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      prefixText: prefixText,
    );
  }
}
