
import 'package:khyate_tailor_app/core/services/contract/service_contract.dart';
import 'package:khyate_tailor_app/core/services/navigator_services/navigator_routes.dart';

import 'package:flutter/material.dart';

class AppService extends ServiceContract {
  String? _currentPage;
  String get currentPage => _currentPage ?? Routes.login.name;

  String? _lastPage;
  String get lastPage => _lastPage ?? Routes.login.name;

  AppService({required super.tag});

  @override
  Future<void> init() async {
    super.init();
    try {
      isInitialised = true;
    } on Exception catch (e) {
      debugPrint(e.toString());
      isInitialised = false;
    }
  }

  void updatePage(String page) {
    _currentPage = page;
  }

  void updateLastPage(String page) {
    _lastPage = _currentPage;
  }
}
