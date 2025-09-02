import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;

  ConnectivityBloc() : super(ConnectivityInitial()) {
    on<InitializeConnectivity>(_onInitializeConnectivity);
    on<ConnectivityChanged>(_onConnectivityChanged);
  }

  Future<void> _onInitializeConnectivity(
      InitializeConnectivity event, Emitter<ConnectivityState> emit) async {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      add(ConnectivityChanged(result));
    });
    final result = await _connectivity.checkConnectivity();
    add(ConnectivityChanged(result));
  }

 void _onConnectivityChanged(ConnectivityChanged event, Emitter<ConnectivityState> emit) {
  print('Connectivity changed: ${event.result}');
  if (event.result.contains(ConnectivityResult.none) && event.result.length == 1) {
    print('Emitting ConnectivityFailure');
    emit(ConnectivityFailure());
  } else {
    print('Emitting ConnectivitySuccess');
    emit(ConnectivitySuccess());
  }
}

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
