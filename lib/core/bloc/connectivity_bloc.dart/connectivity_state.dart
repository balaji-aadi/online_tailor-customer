part of 'connectivity_bloc.dart';

abstract class ConnectivityState {}

class ConnectivityInitial extends ConnectivityState {}

class ConnectivitySuccess extends ConnectivityState {}

class ConnectivityFailure extends ConnectivityState {}
