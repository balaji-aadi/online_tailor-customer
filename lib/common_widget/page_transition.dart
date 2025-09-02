import 'package:flutter/material.dart';

class PageTransition<T> extends PageRoute<T> {
  PageTransition({required this.child, required this.routeSettings})
      : super(settings: routeSettings);

  final Widget child;
  final RouteSettings routeSettings;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => child.runtimeType.toString();

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  bool get maintainState => true;

  @override
  bool get barrierDismissible => false;

  @override
  bool get fullscreenDialog => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);
}
