part of 'connectivity_bloc.dart';

abstract class ConnectivityEvent {}

class InitializeConnectivity extends ConnectivityEvent {}
class ConnectivityChanged extends ConnectivityEvent {
  final List <ConnectivityResult> result;
  ConnectivityChanged(this.result);
}
