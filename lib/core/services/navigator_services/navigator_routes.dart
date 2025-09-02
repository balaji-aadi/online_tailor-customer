import 'dart:io';

import 'package:flutter/material.dart';
import 'package:khyate_tailor_app/common_widget/page_transition.dart';
import 'package:khyate_tailor_app/screens/auth/login_form.dart';

// Screen routes available in app.
enum Routes {
  splash,
  login,
  home,
 
  // location
}

// Route paths for navigator.
const Map<Routes, String> _routePaths = {
  Routes.splash: 'splash',
  Routes.login: '/login',
  Routes.home: '/home',
 
  // Routes.location: '/location',
};

// Extension method to return route path from enum
extension MapRoutePath on Routes {
  String get routePath => _routePaths[this]!;
}

// Generates routes for app
Route<dynamic> generateRoutes(RouteSettings settings) {
  Widget? page;

  if (settings.name == Routes.splash.routePath) {
    page =  LoginScreen(
     onLanguageChanged: (p0) => null,
    );
  } else if (settings.name == Routes.login.routePath) {
    page =  LoginScreen(
    onLanguageChanged: (p0) => null,
    );
  
;
  }

  // Return page transition.
  if (page != null) {
    if (Platform.isAndroid) {
      return PageTransition(child: page, routeSettings: settings);
    } else {
      return MaterialPageRoute(builder: (context) => page!, settings: settings);
    }
  }

  // Route not registered in app.
  throw UnimplementedError('Route not found');
}
