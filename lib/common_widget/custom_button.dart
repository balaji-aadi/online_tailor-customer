import 'package:flutter/material.dart';
import 'package:khyate_tailor_app/constants/color_constant.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Future<void> Function()? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? loadingColor;
  final double? height;
  final double? width;
  final double? borderRadius;
  final bool enabled;
  final IconData? icon;
  final double? elevation;
  final String? semanticLabel;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.loadingColor,
    this.height,
    this.width,
    this.borderRadius,
    this.enabled = true,
    this.icon,
    this.elevation = 0,
    this.semanticLabel,
  });

  // Primary button style (default)
  const CustomButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.height,
    this.width,
    this.borderRadius,
    this.enabled = true,
    this.icon,
    this.semanticLabel,
  })  : backgroundColor = ColorConstants.accentTeal,
        textColor = Colors.white,
        loadingColor = Colors.white,
        elevation = 0;

  // Secondary button style
  const CustomButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.height,
    this.width,
    this.borderRadius,
    this.enabled = true,
    this.icon,
    this.semanticLabel,
  })  : backgroundColor = Colors.transparent,
        textColor = ColorConstants.primaryGold,
        loadingColor = ColorConstants.primaryGold,
        elevation = 0;

  // Outline button style
  const CustomButton.outline({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.height,
    this.width,
    this.borderRadius,
    this.enabled = true,
    this.icon,
    this.semanticLabel,
  })  : backgroundColor = Colors.white,
        textColor = ColorConstants.primaryGold,
        loadingColor = ColorConstants.primaryGold,
        elevation = 0;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: enabled ? (backgroundColor ?? ColorConstants.accentTeal) : Colors.grey[400],
      foregroundColor: enabled ? (textColor ?? Colors.white) : Colors.grey[600],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 14),
      ),
      elevation: elevation,
      shadowColor: Colors.transparent,
      minimumSize: Size(width ?? double.infinity, height ?? 52),
    );

    return Semantics(
      button: true,
      label: semanticLabel ?? text,
      enabled: enabled && !isLoading,
      child: SizedBox(
        width: width,
        height: height ?? 52,
        child: ElevatedButton(
          onPressed: (enabled && !isLoading) ? onPressed : null,
          style: buttonStyle,
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: loadingColor ?? Colors.white,
                  ),
                )
              : icon != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          text,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: enabled ? (textColor ?? Colors.white) : Colors.grey[600],
                          ),
                        ),
                      ],
                    )
                  : Text(
                      text,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: enabled ? (textColor ?? Colors.white) : Colors.grey[600],
                      ),
                    ),
        ),
      ),
    );
  }
}

// Custom Text Button variant
class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? textColor;
  final bool enabled;
  final IconData? icon;
  final String? semanticLabel;
  final double? fontSize;
  final FontWeight? fontWeight;

  const CustomTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.textColor,
    this.enabled = true,
    this.icon,
    this.semanticLabel,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel ?? text,
      enabled: enabled,
      child: TextButton(
        onPressed: enabled ? onPressed : null,
        style: TextButton.styleFrom(
          foregroundColor: enabled ? (textColor ?? ColorConstants.primaryGold) : Colors.grey[400],
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
        child: icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize ?? 15,
                      fontWeight: fontWeight ?? FontWeight.w700,
                      color: enabled ? (textColor ?? ColorConstants.primaryGold) : Colors.grey[400],
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: fontSize ?? 15,
                  fontWeight: fontWeight ?? FontWeight.w700,
                  color: enabled ? (textColor ?? ColorConstants.primaryGold) : Colors.grey[400],
                ),
              ),
      ),
    );
  }
}
