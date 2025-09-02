import 'package:flutter/material.dart';
import 'package:khyate_tailor_app/constants/color_constant.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String labelText;
  final IconData prefixIcon;
  final String? Function(T?)? validator;
  final bool isRTL;
  final String? semanticLabel;
  final bool enabled;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.labelText,
    required this.prefixIcon,
    this.validator,
    this.isRTL = false,
    this.semanticLabel,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      textField: true,
      label: semanticLabel ?? labelText,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: enabled ? ColorConstants.primaryGold : Colors.grey[600],
          ),
          decoration: InputDecoration(
            labelText: labelText,
            prefixIcon: Icon(prefixIcon, color: ColorConstants.primaryGold),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            labelStyle: WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
              if (states.contains(WidgetState.focused)) {
                return TextStyle(color: ColorConstants.primaryGold);
              }
              return TextStyle(color: Colors.grey[600]);
            }),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: ColorConstants.primaryGold, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          validator: validator,
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: enabled ? ColorConstants.primaryGold : Colors.grey[400],
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
