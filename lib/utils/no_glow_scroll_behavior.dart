import 'package:flutter/material.dart';

/// A custom ScrollBehavior that removes:
/// - iOS overscroll bounce
/// - Android overscroll glow
class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    // Removes the glowing overscroll indicator (Android)
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // Uses ClampingScrollPhysics (no bounce on iOS)
    return const ClampingScrollPhysics();
  }
}
