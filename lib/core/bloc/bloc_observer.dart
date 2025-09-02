import 'package:flutter_bloc/flutter_bloc.dart';

class BlocEventObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('[BLOC_EVENT]: ${bloc.runtimeType}: ${event.runtimeType}');
  }

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    print('[BLOC_CREATE]: ${bloc.runtimeType}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('[BLOC_ERROR]: ${bloc.runtimeType}, $error');
    super.onError(bloc, error, stackTrace);
  }
}
