// Service Contract that must be followed for all core serviced implementations.

import 'package:flutter/foundation.dart';

abstract class ServiceContract {
// Log tag representing this service.
  final String tag;

// Flag used to check if service is initialised successfully. Caller is responsible to set/unset this flag.
  bool isInitialised = false;

  ServiceContract({required this.tag});

  // Initialise the service.

  @mustCallSuper
  Future<void> init() async {
    print('Initialising service: %tag');
  }
}
