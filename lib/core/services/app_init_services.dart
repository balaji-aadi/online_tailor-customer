// Main service responsible for initialising entire app dependencies.
// Make sure not to initialise everytime in the preInit method as it gets called at the very beginning to prevent
// slowdown of boot time.


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khyate_tailor_app/core/bloc/bloc_observer.dart';
import 'package:khyate_tailor_app/core/services/contract/service_contract.dart';
import 'package:khyate_tailor_app/core/services/navigator_services/navigator_service.dart';
import 'package:khyate_tailor_app/utils/get_it.dart';

class AppInitServices {
  AppInitServices._privateConstructor();
  static final AppInitServices instance = AppInitServices._privateConstructor();

  bool isPreServiceInitialised = false;

  // Initial critical services that are needed before app run.
  Future<void> preInit() async {
    try {
      if (isPreServiceInitialised) return;

// Attach bloc observer
      Bloc.observer = BlocEventObserver();

// Register services and providers. Services instance won't be created until they are called.
      registerServicesWithGetIt();

// Initialise app core services only.
      final serviceContracts = <ServiceContract>[
        locator<NavigatorService>(),
        // locator<MapService>(),
        // locator<StorageService>(),
      ];

      for (var service in serviceContracts) {
        await service.init();
      }

      isPreServiceInitialised = true;
    } catch (error, stackTrace) {
      print(error);
      print(stackTrace);
      rethrow;
    }
  }
}
