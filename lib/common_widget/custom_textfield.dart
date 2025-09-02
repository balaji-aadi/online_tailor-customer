import 'package:flutter/material.dart';
import 'package:khyate_tailor_app/constants/color_constant.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool autocorrect;
  final bool enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final GestureTapCallback? onTap;
  final String? semanticLabel;
  final bool isRTL;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final Color? fillColor;
  final bool filled;

  const CustomTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.semanticLabel,
    this.isRTL = false,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.contentPadding,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.fillColor,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Semantics(
      textField: true,
      label: semanticLabel ?? labelText,
      readOnly: readOnly,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        validator: validator,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        autocorrect: autocorrect,
        enableSuggestions: enableSuggestions,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        enabled: enabled,
        readOnly: readOnly,
        onTap: onTap,
        textCapitalization: textCapitalization,
        autofillHints: autofillHints,
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: enabled ? Colors.black87 : Colors.grey[600],
        ),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: enabled
                      ? ColorConstants.primaryGold
                      : Colors.grey[400],
                )
              : null,
          suffixIcon: suffixIcon,
          contentPadding: contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: border ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
          enabledBorder: enabledBorder ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
          focusedBorder: focusedBorder ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: ColorConstants.primaryGold,
                  width: 1.5,
                ),
              ),
          errorBorder: errorBorder ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
          focusedErrorBorder: focusedErrorBorder ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
          filled: filled,
          fillColor: fillColor ?? Colors.grey.shade50,
          alignLabelWithHint: true,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: enabled ? Colors.black54 : Colors.grey[400],
          ),
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[500],
          ),
          errorStyle: theme.textTheme.bodySmall?.copyWith(
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}