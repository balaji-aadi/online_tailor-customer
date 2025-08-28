import 'package:flutter/material.dart';

class ColorConstants {
  // Basic Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;

  // UAE Cultural Color Palette (main one)

  /// Primary Gold (#C5A572): Inspired by traditional UAE gold jewelry and desert sands
  static const Color primaryGold = Color(0xFFC5A572);

  /// Deep Navy (#1A2332): Reflecting the depth of Arabian nights and premium luxury
  static const Color deepNavy = Color(0xFF1A2332);

  /// Warm Ivory (#FEFCF8): Clean, sophisticated alternative to harsh whites
  static const Color warmIvory = Color(0xFFFEFCF8);

  /// Accent Teal (#2D7D7A): Subtle nod to Arabian Gulf waters
  static const Color accentTeal = Color(0xFF2D7D7A);

  // Gradient Colors for UI Enhancement

  /// Light Gold for gradients and backgrounds
  static const Color lightGold = Color(0xFFE8D5B7);

  /// Dark Navy for text and emphasis
  static const Color darkNavy = Color(0xFF0F1419);

  /// Light Teal for accents and highlights
  static const Color lightTeal = Color(0xFF4A9B98);

  /// Soft Ivory for cards and surfaces
  static const Color softIvory = Color(0xFFFCFAF6);

  // Semantic Colors

  /// Success color using teal tone
  static const Color success = Color(0xFF2D7D7A);

  /// Warning color using gold tone
  static const Color warning = Color(0xFFC5A572);

  /// Error color
  static const Color error = Color(0xFFD32F2F);

  /// Info color using navy tone
  static const Color info = Color(0xFF1A2332);

  // Gradient Definitions

  /// Primary gradient from gold to light gold
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGold, lightGold],
    begin: Alignment.topLeft, 
    end: Alignment.bottomRight,
  );

  /// Secondary gradient from navy to dark navy
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [deepNavy, darkNavy],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Accent gradient from teal to light teal
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentTeal, lightTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Background gradient for subtle depth
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [warmIvory, softIvory],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
