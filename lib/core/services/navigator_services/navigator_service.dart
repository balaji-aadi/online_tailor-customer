
import 'package:khyate_tailor_app/core/services/contract/service_contract.dart';
import 'package:flutter/material.dart';
import 'package:khyate_tailor_app/core/services/navigator_services/navigator_routes.dart';

// Application's Navigator Service.

class NavigatorService extends ServiceContract {
  NavigatorService() : super(tag: 'NavigatorService');

  late final GlobalKey<NavigatorState> rootNavigatorKey;
  late final String initialRoute;

  @override
  Future<void> init() async {
    super.init();

    if (isInitialised) return;

    rootNavigatorKey = GlobalKey<NavigatorState>();
    initialRoute = Routes.splash.routePath;

    isInitialised = true;
    print('Initialised: $tag');
  }

  BuildContext? get currentContext => rootNavigatorKey.currentContext;

  // Perform push operation.
  Future<T?>? push<T extends Object?>(Routes route, {Object? arguments}) {
    return rootNavigatorKey.currentState
        ?.pushNamed<T>(route.routePath, arguments: arguments);
  }

  // Perform pop operation.
  void pop<T extends Object?>([T? result]) {
    rootNavigatorKey.currentState?.pop(result);
  }

  // Perform push replacement operation.
  void pushReplacement(Routes route, {Object? arguments}) {
    rootNavigatorKey.currentState
        ?.pushReplacementNamed(route.routePath, arguments: arguments);
  }

  // Pop until given route or first if not route is given.
  void popUntil(Routes? route) {
    rootNavigatorKey.currentState?.popUntil((r) {
      if (route != null) {
        return r.settings.name == route.routePath;
      }

      // Pop to home page
      return r.isFirst;
    });
  }

  // Remove all pages below and push this route.
  Future<T?>? pushAndRemoveUntil<T extends Object?>(Routes route,
      {Object? arguments}) {
    return rootNavigatorKey.currentState?.pushNamedAndRemoveUntil<T>(
        route.routePath, (route) => false,
        arguments: arguments);
  }
}
